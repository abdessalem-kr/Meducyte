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
    final stats = ref.read(studyStatsProvider).valueOrNull;

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

  Future<void> _reloadTasks() async {
    final repo = ref.read(productivityRepositoryProvider);
    final tasks = await repo.getTodoItems();
    state = AsyncValue.data(tasks);
    _syncToWidget(tasks: tasks);
  }

  Future<void> toggleTask(String taskId) async {
    final tasks = state.value ?? [];
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final task = tasks[index];
    final updatedList = List<TodoItem>.from(tasks);
    updatedList[index] = task.copyWith(isCompleted: !task.isCompleted);
    state = AsyncValue.data(updatedList); // Optimistic Update

    final repo = ref.read(productivityRepositoryProvider);
    final updatedTask = await repo.updateTodo(
      id: taskId,
      isCompleted: !task.isCompleted,
    );

    _reloadTasks();

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
    String? moduleId,
    String title, {
    TodoPriority priority = TodoPriority.optional,
    DateTime? deadline,
    int estimatedPomodoros = 1,
    List<SubTask> subtasks = const [],
  }) async {
    debugPrint("DEBUG: Notifier addTask started for title: $title");
    final repo = ref.read(productivityRepositoryProvider);
    final newTask = await repo.createTodo(
      title: title,
      priority: priority,
      deadline: deadline,
      moduleId: moduleId,
      estimatedPomodoros: estimatedPomodoros,
      subtasks: subtasks,
    );
    debugPrint("DEBUG: Notifier addTask repository returned task: ${newTask.id}");

    _reloadTasks();

    if (deadline != null) {
      debugPrint("DEBUG: Notifier addTask scheduling notification reminder");
      ref
          .read(notificationServiceProvider)
          .scheduleTaskReminder(
            id: newTask.id,
            title: newTask.title,
            deadline: deadline,
          );
    }
    debugPrint("DEBUG: Notifier addTask completed successfully");
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
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = tasks[index];
      final updatedList = List<TodoItem>.from(tasks);
      updatedList[index] = task.copyWith(
        title: title ?? task.title,
        priority: priority ?? task.priority,
        deadline: deadline ?? task.deadline,
        estimatedPomodoros: estimatedPomodoros ?? task.estimatedPomodoros,
        subtasks: subtasks ?? task.subtasks,
        isCompleted: isCompleted ?? task.isCompleted,
      );
      state = AsyncValue.data(updatedList); // Optimistic Update
    }

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

    _reloadTasks();

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

    await _reloadTasks();

    //Cancel notification
    ref.read(notificationServiceProvider).cancelNotification(taskId);
  }

  Future<void> incrementTaskPomodoro(String taskId) async {
    final tasks = state.value ?? [];
    final task = tasks.firstWhere((t) => t.id == taskId);

    final repo = ref.read(productivityRepositoryProvider);
    await repo.updateTodo(
      id: taskId,
      completedPomodoros: task.completedPomodoros + 1,
    );

    await _reloadTasks();
    ref.invalidate(studyStatsProvider);
  }
}

final productiveBayProvider =
    AsyncNotifierProvider<ProductiveBayNotifier, List<TodoItem>>(
      () => ProductiveBayNotifier(),
    );

//Provider to get progress for a specific module
final moduleProgressProvider = FutureProvider.family<double, String>((
  ref,
  moduleId,
) async {
  try {
    final lessons = await ref.watch(moduleLessonsProvider(moduleId).future);
    if (lessons.isEmpty) return 0.0;
    final studiedCount = lessons.where((l) => l.isStudied).length;
    return studiedCount / lessons.length;
  } catch (_) {
    return 0.0;
  }
});

// ---Advanced Study Intelligence Providers---

//Study Pulse(SRS Data)
final studyPulseProvider = Provider<StudyPulse>((ref) {
  final dueCountAsync = ref.watch(dueQuestionsCountProvider);
  final statsAsync = ref.watch(studyStatsProvider);
  final srsStatsAsync = ref.watch(srsStatsProvider);

  final dueCount = dueCountAsync.valueOrNull ?? 0;
  final streak = statsAsync.valueOrNull?.currentStreak ?? 0;

  final srsStats = srsStatsAsync.valueOrNull;
  final total = srsStats?['total'] ?? 0;
  final mastered = srsStats?['mastered'] ?? 0;
  final double mastery = total > 0 ? (mastered / total) : 0.72;

  return StudyPulse(
    cardsDueToday: dueCount,
    currentReviewStreak: streak,
    masteryLevel: mastery,
  );
});

// ---AI Study Scheduler---
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

final studyStatsProvider = FutureProvider<StudyStats>((ref) async {
  final stats = await ref.watch(productivityRepositoryProvider).getStats();
  try {
    final modules = await ref.watch(learnModulesProvider.future);
    final Map<String, double> realScores = {};

    // Fetch all lessons lists in parallel using ref.read to prevent creating 80+ observers
    final lessonsLists = await Future.wait(
      modules.map((m) => ref.read(moduleLessonsProvider(m.id).future)),
    );

    for (int i = 0; i < modules.length; i++) {
      final module = modules[i];
      final lessons = lessonsLists[i];
      if (lessons.isNotEmpty) {
        final studiedCount = lessons.where((l) => l.isStudied).length;
        realScores[module.name] = studiedCount / lessons.length;
      } else {
        realScores[module.name] = 0.0;
      }
    }
    return StudyStats(
      currentStreak: stats.currentStreak,
      totalHours: stats.totalHours,
      completedPomodorosToday: stats.completedPomodorosToday,
      completedShortBreaksToday: stats.completedShortBreaksToday,
      completedLongBreaksToday: stats.completedLongBreaksToday,
      totalPomodorosGoal: stats.totalPomodorosGoal,
      moduleScores: realScores,
    );
  } catch (e) {
    debugPrint("DEBUG: Error calculating real module stats: $e");
    return stats;
  }
});

final dailyGoalsProvider = Provider<List<DailyGoal>>((ref) {
  final statsAsync = ref.watch(studyStatsProvider);
  final todoListAsync = ref.watch(productiveBayProvider);

  final stats = statsAsync.valueOrNull;
  final tasks = todoListAsync.valueOrNull ?? [];

  final hoursCompleted = stats?.totalHours ?? 0;
  final pomodorosCompleted = stats?.completedPomodorosToday ?? 0;
  final pomodorosGoal = stats?.totalPomodorosGoal ?? 8;

  final tasksCompleted = tasks.where((t) => t.isCompleted).length;
  final totalTasksCount = tasks.length;
  final targetTasksGoal = totalTasksCount > 0 ? totalTasksCount : 3;

  return [
    DailyGoal(
      id: 'focus_hours',
      title: "Heures de concentration",
      targetValue: 8,
      currentValue: hoursCompleted,
      icon: Iconsax.clock,
    ),
    DailyGoal(
      id: 'pomodoro_sessions',
      title: "Séances Pomodoro",
      targetValue: pomodorosGoal,
      currentValue: pomodorosCompleted,
      icon: Iconsax.timer_1,
    ),
    DailyGoal(
      id: 'tasks_completed',
      title: "Tâches accomplies",
      targetValue: targetTasksGoal,
      currentValue: tasksCompleted,
      icon: Iconsax.task,
    ),
  ];
});
