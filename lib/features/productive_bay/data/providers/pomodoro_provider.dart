import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/features/notifications/application/services/notification_service.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/pomodoro_models.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/productive_bay_provider.dart';
import 'package:meducyte_app/features/productive_bay/data/repositories/api_productivity_repository.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/pomodoro_settings_provider.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/pomodoro_settings.dart';

class PomodoroNotifier extends StateNotifier<FocusSession> {
  PomodoroNotifier(this.ref)
    : super(
        const FocusSession(durationSeconds: 25 * 60, remainingSeconds: 25 * 60),
      ) {
    _init();
  }

  final Ref ref;
  Timer? _timer;
  int _completedSessionsInCycle = 0;

  void _init() {
    //Listen to settings changes and update current duration if not running
    ref.listen(pomodoroSettingsProvider, (previous, next) {
      if (state.state == PomodoroState.initial) {
        next.whenData((settings) {
          final newDuration = _getDurationForType(state.type, settings);
          state = state.copyWith(
            durationSeconds: newDuration,
            remainingSeconds: newDuration,
          );
        });
      }
    });
  }

  int _getDurationForType(PomodoroSessionType type, PomodoroSettings settings) {
    switch (type) {
      case PomodoroSessionType.work:
        return settings.workDuration * 60;
      case PomodoroSessionType.shortBreak:
        return settings.shortBreakDuration * 60;
      case PomodoroSessionType.longBreak:
        return settings.longBreakDuration * 60;
    }
  }

  void selectTask(String? taskId) {
    state = state.copyWith(taskId: taskId);
  }

  void startSession() {
    if (state.state == PomodoroState.running) return;

    state = state.copyWith(
      state: PomodoroState.running,
      startTime: DateTime.now(),
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });
    _updateNotification();
  }

  void _tick() {
    if (state.remainingSeconds > 0) {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    } else {
      _completeSession();
    }
  }

  void _updateNotification() {
    String title;
    switch (state.type) {
      case PomodoroSessionType.work:
        title = "Concentration...";
        break;
      case PomodoroSessionType.shortBreak:
        title = "Courte pause...";
        break;
      case PomodoroSessionType.longBreak:
        title = "Longue pause...";
        break;
    }

    ref
        .read(notificationServiceProvider)
        .showPomodoroNotification(
          title: title,
          remainingDuration: Duration(seconds: state.remainingSeconds),
          isWork: state.type == PomodoroSessionType.work,
        );
  }

  void pauseSession() {
    _timer?.cancel();
    state = state.copyWith(state: PomodoroState.paused);
    ref.read(notificationServiceProvider).dismissPomodoroNotification();
  }

  void resumeSession() {
    startSession();
  }

  void stopSession() {
    _timer?.cancel();
    ref.read(notificationServiceProvider).dismissPomodoroNotification();
    final settings =
        ref.read(pomodoroSettingsProvider).value ??
        PomodoroSettings.defaultSettings();
    final duration = _getDurationForType(state.type, settings);

    state = state.copyWith(
      state: PomodoroState.initial,
      durationSeconds: duration,
      remainingSeconds: duration,
    );
  }

  void _completeSession() {
    _timer?.cancel();
    ref.read(notificationServiceProvider).dismissPomodoroNotification();
    final completedType = state.type;
    final settings =
        ref.read(pomodoroSettingsProvider).value ??
        PomodoroSettings.defaultSettings();

    // Log to backend
    final repo = ref.read(productivityRepositoryProvider);
    repo.logPomodoro(
      type: completedType.name,
      durationMinutes: (state.durationSeconds / 60).round(),
      startedAt: state.startTime ?? DateTime.now(),
      todoItemId: completedType == PomodoroSessionType.work ? state.taskId : null,
    );

    //If it was a work session,increment task pomodoro if selected
    if (completedType == PomodoroSessionType.work) {
      _completedSessionsInCycle++;

      if (state.taskId != null) {
        ref
            .read(productiveBayProvider.notifier)
            .incrementTaskPomodoro(state.taskId!);
      } else {
        ref.invalidate(studyStatsProvider);
      }
    } else {
      ref.invalidate(studyStatsProvider);
    }

    //Determine next session type
    PomodoroSessionType nextType;
    int nextDuration;

    if (completedType == PomodoroSessionType.work) {
      if (_completedSessionsInCycle >= settings.sessionsUntilLongBreak) {
        nextType = PomodoroSessionType.longBreak;
        nextDuration = settings.longBreakDuration * 60;
        _completedSessionsInCycle = 0; //Reset cycle
      } else {
        nextType = PomodoroSessionType.shortBreak;
        nextDuration = settings.shortBreakDuration * 60;
      }
    } else {
      nextType = PomodoroSessionType.work;
      nextDuration = settings.workDuration * 60;
    }

    state = state.copyWith(
      state: PomodoroState.completed,
      type: nextType,
      durationSeconds: nextDuration,
      remainingSeconds: nextDuration,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final pomodoroProvider = StateNotifierProvider<PomodoroNotifier, FocusSession>((
  ref,
) {
  return PomodoroNotifier(ref);
});
