import 'package:equatable/equatable.dart';

class UserStats extends Equatable {
  final double overallAccuracy;
  final int quizzesCompleted;
  final int questionsAnswered;
  final List<DailyAccuracy> performanceTrend;
  final Map<String, double> specialtyAccuracy;
  final int studyStreak;

  const UserStats({
    required this.overallAccuracy,
    required this.quizzesCompleted,
    required this.questionsAnswered,
    required this.performanceTrend,
    required this.specialtyAccuracy,
    required this.studyStreak,
  });

  factory UserStats.empty() {
    return const UserStats(
      overallAccuracy: 0.0,
      quizzesCompleted: 0,
      questionsAnswered: 0,
      performanceTrend: [],
      specialtyAccuracy: {},
      studyStreak: 0,
    );
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      overallAccuracy: (json['overall_accuracy'] ?? 0.0).toDouble(),
      quizzesCompleted: json['quizzes_completed'] ?? 0,
      questionsAnswered: json['questions_answered'] ?? 0,
      performanceTrend: [],
      specialtyAccuracy: {},
      studyStreak: json['study_streak'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    overallAccuracy,
    quizzesCompleted,
    questionsAnswered,
    performanceTrend,
    specialtyAccuracy,
    studyStreak,
  ];
}

class DailyAccuracy extends Equatable {
  final DateTime date;
  final double accuracy;

  const DailyAccuracy(this.date, this.accuracy);

  @override
  List<Object?> get props => [date, accuracy];
}
