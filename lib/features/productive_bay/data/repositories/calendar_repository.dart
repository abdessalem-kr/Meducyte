import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/core/database/app_database.dart';
import 'package:meducyte_app/shared/providers/database_provider.dart';
import 'package:meducyte_app/core/network/dio_client.dart';
import 'package:meducyte_app/shared/providers/network_provider.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/calendar_models.dart';
import 'package:drift/drift.dart';

class CalendarRepository {
  final AppDatabase _db;
  final DioClient? _client;

  CalendarRepository(this._db, [this._client]);

  //GraphQL Operations
  static const String _getEventsQuery = r'''
query GetMyCalendarEvents{
  myCalendarEvents{
    id
    title
    startTime
    endTime
    color
    type
    isAIPlaced
    relatedId
   }
 }
''';

  static const String _syncEventMutation = r'''
mutation SyncCalendarEvent($input:CalendarEventInput!) {
  syncCalendarEvent(input: $input) {
    id
    remoteId
   }
 }
''';

  static const String _deleteEventMutation = r'''
mutation DeleteCalendarEvent($id:ID!) {
  deleteCalendarEvent(id: $id)
 }
''';

  Future<List<StudyEvent>> getLocalEvents() async {
    final dbEvents = await _db.getAllStudyEvents();
    return dbEvents.map((db) => _mapToDomain(db)).toList();
  }

  Future<void> syncFromRemote() async {
    if (_client == null) return;

    try {
      final response = await _client.post(
        '/graphql',
        data: {'query': _getEventsQuery},
      );

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null || responseData['errors'] != null) return;

      final remoteData = responseData['data']?['myCalendarEvents'] as List?;
      if (remoteData == null) return;

      //Sync logic can be added here if needed to iterate remoteData
    } catch (e) {
      debugPrint('DEBUG:syncFromRemote error: $e');
    }
  }

  StudyEvent _mapToDomain(DbStudyEvent db) {
    return StudyEvent(
      id: db.id.toString(),
      title: db.title,
      startTime: db.startTime.toLocal(),
      endTime: db.endTime.toLocal(),
      color: Color(int.parse(db.color, radix: 16)),
      type: StudyEventType.values.firstWhere(
        (e) => e.name == db.type,
        orElse: () => StudyEventType.manual,
      ),
      isAIPlaced: db.isAIPlaced,
      relatedId: db.relatedId,
    );
  }

  Future<void> syncEvent(StudyEvent event) async {
    //1.Update/Insert Local
    try {
      final companion = StudyEventsCompanion(
        title: Value(event.title),
        startTime: Value(event.startTime),
        endTime: Value(event.endTime),
        color: Value(event.color.value.toRadixString(16)),
        type: Value(event.type.name),
        isAIPlaced: Value(event.isAIPlaced),
        relatedId: Value(event.relatedId),
      );

      //Simple upsert logic:if id is numeric,try update,else insert
      final id = int.tryParse(event.id);
      if (id != null) {
        await _db.updateStudyEvent(id, companion);
      } else {
        await _db.insertStudyEvent(companion);
      }
    } catch (e) {
      debugPrint('DEBUG:CalendarRepository local sync error: $e');
    }

    //2.Update Remote
    if (_client != null) {
      try {
        await _client.post(
          '/graphql',
          data: {
            'query': _syncEventMutation,
            'variables': {
              'input': {
                'title': event.title,
                'startTime': event.startTime.toIso8601String(),
                'endTime': event.endTime.toIso8601String(),
                'color': event.color.value.toRadixString(16),
                'type': event.type.name,
                'isAIPlaced': event.isAIPlaced,
                'relatedId': event.relatedId,
              },
            },
          },
        );
      } catch (e) {
        debugPrint('DEBUG:CalendarRepository remote sync error: $e');
      }
    }
  }

  Future<void> deleteEvent(String id) async {
    final numericId = int.tryParse(id);
    if (numericId != null) {
      await _db.deleteStudyEvent(numericId);
    }

    if (_client != null) {
      try {
        await _client.post(
          '/graphql',
          data: {
            'query': _deleteEventMutation,
            'variables': {'id': id},
          },
        );
      } catch (e) {
        debugPrint('DEBUG:CalendarRepository remote delete error: $e');
      }
    }
  }
}

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final client = ref.watch(dioClientProvider);
  return CalendarRepository(db, client);
});
