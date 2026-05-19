import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/calendar_models.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/productive_bay_provider.dart';
import 'package:meducyte_app/features/productive_bay/data/repositories/calendar_repository.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/todo_item.dart';
import 'package:meducyte_app/features/notifications/application/services/notification_service.dart';
import 'package:meducyte_app/features/productive_bay/application/services/widget_service.dart';

class CalendarNotifier extends StateNotifier<CalendarState> {
  CalendarNotifier(this.ref) : super(_initialState) {
    _loadFromSource();
  }

  void _syncToWidget() {
    final now = DateTime.now();
    final nextEvent =
        state.events.where((e) => e.startTime.isAfter(now)).toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final tasks = ref.read(productiveBayProvider).asData?.value ?? [];
    final pending = tasks.where((t) => !t.isCompleted).toList();
    final urgent = pending
        .where((t) => t.priority == TodoPriority.urgent)
        .toList();

    WidgetService.updateWidget(
      nextEvent: nextEvent.isNotEmpty ? nextEvent.first : null,
      pendingTasks: pending.length,
      urgentTask: urgent.isNotEmpty
          ? urgent.first
          : (pending.isNotEmpty ? pending.first : null),
    );
  }

  final Ref ref;

  static final _initialState = CalendarState(
    selectedDate: DateTime.now(),
    events: [],
    weeklyObjectives: [], //Will be populated in UI if empty or via sync
  );

  Future<void> _loadFromSource() async {
    try {
      final events = await ref
          .read(calendarRepositoryProvider)
          .getLocalEvents();
      state = state.copyWith(events: events);
      _syncToWidget();
    } catch (e) {
      debugPrint('DEBUG:Error loading calendar events: $e');
    }
  }

  void nextWeek() {
    state = state.copyWith(
      selectedDate: state.selectedDate.add(const Duration(days: 7)),
    );
  }

  void previousWeek() {
    state = state.copyWith(
      selectedDate: state.selectedDate.subtract(const Duration(days: 7)),
    );
  }

  void setViewMode(CalendarViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void addEvent(StudyEvent event) {
    state = state.copyWith(events: [...state.events, event]);
    _syncToWidget();

    //Sync to backend
    ref.read(calendarRepositoryProvider).syncEvent(event);

    //Schedule notification
    ref
        .read(notificationServiceProvider)
        .scheduleStudyReminder(
          id: event.id,
          title: event.title,
          scheduledDate: event.startTime,
        );
  }

  void updateEvent(StudyEvent event) {
    state = state.copyWith(
      events: state.events.map((e) => e.id == event.id ? event : e).toList(),
    );
    _syncToWidget();

    //Sync to backend
    ref.read(calendarRepositoryProvider).syncEvent(event);

    //Re-schedule notification
    ref
        .read(notificationServiceProvider)
        .scheduleStudyReminder(
          id: event.id,
          title: event.title,
          scheduledDate: event.startTime,
        );
  }

  void removeEvent(String id) {
    state = state.copyWith(
      events: state.events.where((e) => e.id != id).toList(),
    );
    _syncToWidget();

    //Cancel notification
    ref.read(notificationServiceProvider).cancelStudyReminder(id);
  }

  void aiScheduleDay(String Function(String) titleFormatter) {
    final tasks = ref.read(productiveBayProvider).asData?.value ?? [];
    final pendingTasks = tasks.where((t) => !t.isCompleted).toList();

    final List<StudyEvent> newEvents = List.from(state.events);

    DateTime pointer = state.selectedDate.copyWith(hour: 9, minute: 0);
    int addedCount = 0;

    for (int i = 0; i < pendingTasks.length && addedCount < 2; i++) {
      final task = pendingTasks[i];
      final eventId = 'ai_${task.id}';

      //Prevent duplicates
      if (newEvents.any((e) => e.id == eventId)) continue;

      final event = StudyEvent(
        id: eventId,
        title: titleFormatter(task.title),
        startTime: pointer,
        endTime: pointer.add(const Duration(hours: 1)),
        color: Colors.orange,
        type: StudyEventType.practice,
        isAIPlaced: true,
      );
      newEvents.add(event);

      //Sync AI event
      ref.read(calendarRepositoryProvider).syncEvent(event);

      //Schedule notification
      ref
          .read(notificationServiceProvider)
          .scheduleStudyReminder(
            id: event.id,
            title: event.title,
            scheduledDate: event.startTime,
          );

      pointer = pointer.add(const Duration(hours: 2));
      addedCount++;
    }

    state = state.copyWith(events: newEvents);
    _syncToWidget();
  }
}

final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>(
  (ref) {
    return CalendarNotifier(ref);
  },
);
