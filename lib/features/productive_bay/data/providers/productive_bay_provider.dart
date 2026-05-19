import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/localization/app_localizations_provider.dart';
import 'package:meducyte_app/features/notifications/application/services/notification_service.dart';
import 'package:meducyte_app/features/productive_bay/application/services/widget_service.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/calendar_provider.dart';
import 'package:meducyte_app/features/productive_bay/data/repositories/api_productivity_repository.dart';

// ---To-Do List Provider---
class ProductiveBayNotifier extends AsyncNotifier<List<TodoItem>> {
  @override
  Future<List<TodoItem>> build() async {
    final repo = ref.read(productivityRepositoryProvider);
    final tasks = await repo.getTodoItems();
    _syncToWidget(tasks: tasks);
    return tasks;
  }

  void _syncToWidget({List<TodoItem>? tasks}) {
    final list = tasks ?? state.value ?? [];
    final pending = list.where((t) => !t.isCompleted).toList();
    final urgent = pending
        .where((t) => t.priority == TodoPriority.urgent)
        .toList();

    //Get Next Event from Calendar
    final events = ref.read(calendarProvider).events;
    final now = DateTime.now();
    final nextEvent = events.where((e) => e.startTime.isAfter(now)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    //Get Exams
    final exams = ref.read(examEventsProvider);
    final today = DateTime(now.year, now.month, now.day);

    final futureExams = exams.where((e) => !e.date.isBefore(today)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final pastExams = exams.where((e) => e.date.isBefore(today)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final nextExam = futureExams.isNotEmpty
        ? futureExams.first
        : (pastExams.isNotEmpty ? pastExams.first : null);

    int? daysRemaining;
    if (nextExam != null) {
      final examDay = DateTime(
        nextExam.date.year,
        nextExam.date.month,
        nextExam.date.day,
      );
      daysRemaining = examDay.difference(today).inDays;
    }

    //Get Stats
    final stats = ref.read(studyStatsProvider).value;

    WidgetService.updateWidget(
      nextEvent: nextEvent.isNotEmpty ? nextEvent.first : null,
      pendingTasks: pending.length,
      urgentTask: urgent.isNotEmpty
          ? urgent.first
          : (pending.isNotEmpty ? pending.first : null),
      nextExam: nextExam?.title,
      daysToExam: daysRemaining,
      pomodoroDone: stats?.completedPomodorosToday ?? 0,
      pomodoroGoal: stats?.totalPomodorosGoal ?? 8,
      focusScore: "${stats?.totalHours ?? 0}h",
    );
  }

  Future<void> toggleTask(String taskId) async {
    final tasks = state.value ?? [];
    final task = tasks.firstWhere((t) => t.id == taskId);

    final repo = ref.read(productivityRepositoryProvider);
    final updatedTask = await repo.updateTodo(
      id: taskId,
      isCompleted: !task.isCompleted,
    );

    state = AsyncValue.data(
      tasks.map((t) => t.id == taskId ? updatedTask : t).toList(),
    );
    _syncToWidget();

    //Cancel notification if completed,schedule if reopened
    final notificationService = ref.read(notificationServiceProvider);
    if (updatedTask.isCompleted) {
      notificationService.cancelNotification(taskId);
    } else if (updatedTask.deadline != null) {
      notificationService.scheduleTaskReminder(
        id: taskId,
        title: updatedTask.title,
        deadline: updatedTask.deadline!,
      );
    }
  }

  Future<void> toggleSubTask(String taskId, String subTaskId) async {
    final tasks = state.value ?? [];
    final task = tasks.firstWhere((t) => t.id == taskId);

    final newSubtasks = task.subtasks.map((s) {
      return s.id == subTaskId ? s.copyWith(isCompleted: !s.isCompleted) : s;
    }).toList();

    await updateTask(taskId: taskId, subtasks: newSubtasks);
  }

  Future<void> addTask(
    String moduleId,
    String title, {
    TodoPriority priority = TodoPriority.optional,
    DateTime? deadline,
    int estimatedPomodoros = 1,
    List<SubTask> subtasks = const [],
  }) async {
    final repo = ref.read(productivityRepositoryProvider);
    final newTask = await repo.createTodo(
      title: title,
      priority: priority,
      deadline: deadline,
      moduleId: moduleId,
      estimatedPomodoros: estimatedPomodoros,
      subtasks: subtasks,
    );

    state = AsyncValue.data([...(state.value ?? []), newTask]);
    _syncToWidget();

    if (deadline != null) {
      ref
          .read(notificationServiceProvider)
          .scheduleTaskReminder(
            id: newTask.id,
            title: newTask.title,
            deadline: deadline,
          );
    }
  }

  Future<void> updateTask({
    required String taskId,
    String? title,
    TodoPriority? priority,
    DateTime? deadline,
    int? estimatedPomodoros,
    List<SubTask>? subtasks,
    bool? isCompleted,
  }) async {
    final tasks = state.value ?? [];
    final repo = ref.read(productivityRepositoryProvider);

    final updatedTask = await repo.updateTodo(
      id: taskId,
      title: title,
      priority: priority,
      deadline: deadline,
      estimatedPomodoros: estimatedPomodoros,
      subtasks: subtasks,
      isCompleted: isCompleted,
    );

    state = AsyncValue.data(
      tasks.map((t) => t.id == taskId ? updatedTask : t).toList(),
    );
    _syncToWidget();

    //Re-schedule/Cancel based on update
    final notificationService = ref.read(notificationServiceProvider);
    if (updatedTask.isCompleted) {
      notificationService.cancelNotification(taskId);
    } else if (updatedTask.deadline != null) {
      notificationService.scheduleTaskReminder(
        id: taskId,
        title: updatedTask.title,
        deadline: updatedTask.deadline!,
      );
    } else {
      notificationService.cancelNotification(taskId);
    }
  }

  Future<void> addSubTask(String taskId, String subTaskTitle) async {
    final tasks = state.value ?? [];
    final task = tasks.firstWhere((t) => t.id == taskId);

    final newSubTask = SubTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: subTaskTitle,
    );

    await updateTask(taskId: taskId, subtasks: [...task.subtasks, newSubTask]);
  }

  Future<void> removeSubTask(String taskId, String subTaskId) async {
    final tasks = state.value ?? [];
    final task = tasks.firstWhere((t) => t.id == taskId);

    await updateTask(
      taskId: taskId,
      subtasks: task.subtasks.where((s) => s.id != subTaskId).toList(),
    );
  }

  Future<void> updateSubTask(
    String taskId,
    String subTaskId,
    String newTitle,
  ) async {
    final tasks = state.value ?? [];
    final task = tasks.firstWhere((t) => t.id == taskId);

    final newSubtasks = task.subtasks.map((s) {
      return s.id == subTaskId ? s.copyWith(title: newTitle) : s;
    }).toList();

    await updateTask(taskId: taskId, subtasks: newSubtasks);
  }

  Future<void> removeTask(String taskId) async {
    final repo = ref.read(productivityRepositoryProvider);
    await repo.deleteTodo(taskId);

    state = AsyncValue.data(
      (state.value ?? []).where((t) => t.id != taskId).toList(),
    );
    _syncToWidget();

    //Cancel notification
    ref.read(notificationServiceProvider).cancelNotification(taskId);
  }

  Future<void> incrementTaskPomodoro(String taskId) async {
    final tasks = state.value ?? [];
    final task = tasks.firstWhere((t) => t.id == taskId);

    final repo = ref.read(productivityRepositoryProvider);
    final updatedTask = await repo.updateTodo(
      id: taskId,
      completedPomodoros: task.completedPomodoros + 1,
    );

    state = AsyncValue.data(
      tasks.map((t) => t.id == taskId ? updatedTask : t).toList(),
    );
    _syncToWidget();
    ref.invalidate(studyStatsProvider);
  }
}

final productiveBayProvider =
    AsyncNotifierProvider<ProductiveBayNotifier, List<TodoItem>>(
      () => ProductiveBayNotifier(),
    );

//Provider to get progress for a specific module
final moduleProgressProvider = Provider.family<double, String>((ref, moduleId) {
  final modulesAsync = ref.watch(learnModulesProvider);

  return modulesAsync.maybeWhen(
    data: (modules) {
      //Helper function to find a module and its total/studied lessons
      (int, int)? getStats(LearnModule m) {
        if (m.id == moduleId) {
          final lessons = m.lessons ?? [];
          final children = m.children ?? [];

          if (children.isNotEmpty) {
            int total = 0;
            int studied = 0;
            for (final child in children) {
              final childLessons = child.lessons ?? [];
              total += childLessons.length;
              studied += childLessons.where((l) => l.isStudied).length;
            }
            return (total, studied);
          }

          if (lessons.isEmpty) return null;
          return (lessons.length, lessons.where((l) => l.isStudied).length);
        }

        if (m.children != null) {
          for (final child in m.children!) {
            final stats = getStats(child);
            if (stats != null) return stats;
          }
        }
        return null;
      }

      for (final m in modules) {
        final stats = getStats(m);
        if (stats != null) {
          final (total, studied) = stats;
          if (total == 0) return 0.0;
          return studied / total;
        }
      }

      return 0.0;
    },
    orElse: () => 0.0,
  );
});

// ---Advanced Study Intelligence Providers---

//Study Pulse(SRS Data)
final studyPulseProvider = Provider<StudyPulse>((ref) {
  return const StudyPulse(
    cardsDueToday: 124,
    currentReviewStreak: 15,
    masteryLevel: 0.72,
  );
});

//AI Study Scheduler
final aiSchedulerProvider = Provider<List<ScheduledBlock>>((ref) {
  final tasksAsync = ref.watch(productiveBayProvider);
  final l10nAsync = ref.watch(appLocalizationsProvider);

  final l10n = l10nAsync.asData?.value;
  if (l10n == null) return [];

  return tasksAsync.maybeWhen(
    data: (tasks) {
      final pending = tasks.where((t) => !t.isCompleted).toList();
      if (pending.isEmpty) {
        return [
          ScheduledBlock(
            id: 'suggest_1',
            title: l10n.exploreModulesTitle,
            duration: const Duration(minutes: 45),
            reason: l10n.noTasksReason,
            color: Colors.blue,
          ),
        ];
      }

      return pending.take(3).map((task) {
        final isUrgent = task.priority == TodoPriority.urgent;
        return ScheduledBlock(
          id: 'ai_suggest_${task.id}',
          title: task.title,
          duration: Duration(minutes: task.estimatedPomodoros * 25),
          reason: isUrgent
              ? l10n.highPriorityTaskReason
              : l10n.optimalTimeReason,
          color: isUrgent ? Colors.orange : Colors.green,
        );
      }).toList();
    },
    orElse: () => [],
  );
});

// ---Other Basic Providers---

final studyStatsProvider = FutureProvider<StudyStats>((ref) {
  return ref.watch(productivityRepositoryProvider).getStats();
});

final dailyGoalsProvider = Provider<List<DailyGoal>>((ref) {
  return const [];
});
