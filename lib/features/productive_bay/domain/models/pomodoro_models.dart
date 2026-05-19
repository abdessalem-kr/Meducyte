import 'package:equatable/equatable.dart';

enum PomodoroSessionType { work, shortBreak, longBreak }

enum PomodoroState { initial, running, paused, completed }

class FocusSession extends Equatable {
  final String? taskId;
  final PomodoroSessionType type;
  final PomodoroState state;
  final int durationSeconds;
  final int remainingSeconds;
  final DateTime? startTime;

  const FocusSession({
    this.taskId,
    this.type = PomodoroSessionType.work,
    this.state = PomodoroState.initial,
    required this.durationSeconds,
    required this.remainingSeconds,
    this.startTime,
  });

  FocusSession copyWith({
    String? taskId,
    PomodoroSessionType? type,
    PomodoroState? state,
    int? durationSeconds,
    int? remainingSeconds,
    DateTime? startTime,
  }) {
    return FocusSession(
      taskId: taskId ?? this.taskId,
      type: type ?? this.type,
      state: state ?? this.state,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      startTime: startTime ?? this.startTime,
    );
  }

  @override
  List<Object?> get props => [
    taskId,
    type,
    state,
    durationSeconds,
    remainingSeconds,
    startTime,
  ];

  double get progress => 1 - (remainingSeconds / durationSeconds);
}
