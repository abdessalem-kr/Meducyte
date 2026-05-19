import 'package:equatable/equatable.dart';

class PomodoroSettings extends Equatable {
  const PomodoroSettings({
    required this.workDuration,
    required this.shortBreakDuration,
    required this.longBreakDuration,
    required this.sessionsUntilLongBreak,
  });

  final int workDuration; //in minutes
  final int shortBreakDuration; //in minutes
  final int longBreakDuration; //in minutes
  final int sessionsUntilLongBreak;

  factory PomodoroSettings.defaultSettings() {
    return const PomodoroSettings(
      workDuration: 25,
      shortBreakDuration: 5,
      longBreakDuration: 15,
      sessionsUntilLongBreak: 4,
    );
  }

  PomodoroSettings copyWith({
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? sessionsUntilLongBreak,
  }) {
    return PomodoroSettings(
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      sessionsUntilLongBreak:
          sessionsUntilLongBreak ?? this.sessionsUntilLongBreak,
    );
  }

  @override
  List<Object?> get props => [
    workDuration,
    shortBreakDuration,
    longBreakDuration,
    sessionsUntilLongBreak,
  ];
}
