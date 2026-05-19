import 'package:meducyte_app/core/database/app_database.dart';
import 'package:meducyte_app/shared/providers/database_provider.dart';
import 'package:meducyte_app/features/notifications/domain/models/notification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/core/network/dio_client.dart';
import 'package:meducyte_app/shared/providers/network_provider.dart';
import 'package:drift/drift.dart';

class NotificationRepository {
  final AppDatabase _db;
  final DioClient? _client;

  NotificationRepository(this._db, [this._client]);

  // GraphQL Operations
  static const String _getNotificationsQuery = r'''
    query GetMyNotifications {
      myNotifications {
        id
        title
        body
        type
        data
        isRead
        createdAt
      }
    }
  ''';

  static const String _markAsReadMutation = r'''
    mutation MarkNotificationAsRead($id: ID!) {
      markNotificationAsRead(id: $id) {
        id
        isRead
      }
    }
  ''';

  static const String _deleteNotificationMutation = r'''
    mutation DeleteNotification($id: ID!) {
      deleteNotification(id: $id)
    }
  ''';

  Stream<List<AppNotification>> watchNotifications(String? userId) {
    return _db
        .watchNotifications(userId)
        .map((list) => list.map((db) => AppNotification.fromDb(db)).toList());
  }

  Future<List<AppNotification>> getAllNotifications(String? userId) async {
    final list = await _db.getAllNotifications(userId);
    return list.map((db) => AppNotification.fromDb(db)).toList();
  }

  Future<int> insertNotification(AppNotification notification, String? userId) {
    var companion = notification.toCompanion();
    if (userId != null) {
      companion = companion.copyWith(userId: Value(userId));
    }
    return _db.insertNotification(companion);
  }

  Future<void> markAsRead(int id, String? userId, {bool isRead = true}) async {
    // 1. Update local
    await _db.updateNotificationReadStatus(id, isRead);

    // 2. Update remote if possible
    if (_client != null) {
      final notification = await _db.getNotificationById(id);
      if (notification?.remoteId != null) {
        try {
          // If the backend doesn't support unread, we only call this when isRead is true
          if (isRead) {
            await _client.post(
              '/graphql',
              data: {
                'query': _markAsReadMutation,
                'variables': {'id': notification!.remoteId},
              },
            );
          }
        } catch (e) {
          // print('DEBUG: NotificationRepository markAsRead remote error: $e');
        }
      }
    }
  }

  Future<void> markAllAsRead(String? userId) async {
    await _db.markAllNotificationsAsRead(userId);
    // In a real app, you might want a bulk mutation here too
  }

  Future<void> deleteNotification(int id) async {
    if (_client != null) {
      final notification = await _db.getNotificationById(id);
      if (notification?.remoteId != null) {
        try {
          await _client.post(
            '/graphql',
            data: {
              'query': _deleteNotificationMutation,
              'variables': {'id': notification!.remoteId},
            },
          );
        } catch (e) {
          // print('DEBUG: NotificationRepository delete remote error: $e');
        }
      }
    }
    await _db.deleteNotification(id);
  }

  Future<void> clearAll(String? userId) {
    return _db.clearAllNotifications(userId);
  }

  /// Fetches notifications from backend and merges with local DB
  Future<void> syncNotificationsWithBackend(String? userId) async {
    if (_client == null || userId == null) return;

    try {
      final response = await _client.post(
        '/graphql',
        data: {'query': _getNotificationsQuery},
      );

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null || responseData['errors'] != null) {
        throw Exception(
          responseData?['errors']?[0]?['message'] ?? 'Fetch error',
        );
      }

      final remoteData = responseData['data']?['myNotifications'] as List?;
      if (remoteData == null) return;

      final localNotifications = await getAllNotifications(userId);
      final localRemoteIds = localNotifications
          .where((n) => n.remoteId != null)
          .map((n) => n.remoteId!)
          .toSet();

      for (final json in remoteData) {
        final remote = AppNotification.fromJson(json as Map<String, dynamic>);
        if (!localRemoteIds.contains(remote.remoteId)) {
          await insertNotification(remote, userId);
        } else {
          // Update local status if remote is read and local is not
          final local = localNotifications.firstWhere(
            (n) => n.remoteId == remote.remoteId,
          );
          if (remote.isRead && !local.isRead) {
            await _db.updateNotificationReadStatus(int.parse(local.id), true);
          }
        }
      }
    } catch (e) {
      // print('DEBUG: syncNotificationsWithBackend error: $e');
    }
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final client = ref.watch(dioClientProvider);
  return NotificationRepository(db, client);
});
