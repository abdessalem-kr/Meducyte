import 'package:equatable/equatable.dart';

class UserStats extends Equatable {
  final double overallAccuracy;
  final int quizzesCompleted;
  final int questionsAnswered;
  final int questionsAnsweredToday;
  final List<DailyAccuracy> performanceTrend;
  final Map<String, double> specialtyAccuracy;
  final int studyStreak;

  const UserStats({
    required this.overallAccuracy,
    required this.quizzesCompleted,
    required this.questionsAnswered,
    required this.questionsAnsweredToday,
    required this.performanceTrend,
    required this.specialtyAccuracy,
    required this.studyStreak,
  });

  factory UserStats.empty() {
    return const UserStats(
      overallAccuracy: 0.0,
      quizzesCompleted: 0,
      questionsAnswered: 0,
      questionsAnsweredToday: 0,
      performanceTrend: [],
      specialtyAccuracy: {},
      studyStreak: 0,
    );
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    final overallAccuracy = (json['overallAccuracy'] ?? json['overall_accuracy'] ?? 0.0).toDouble();
    final quizzesCompleted = json['quizzesCompleted'] ?? json['quizzes_completed'] ?? 0;
    final questionsAnswered = json['questionsAnswered'] ?? json['questions_answered'] ?? 0;
    final questionsAnsweredToday = json['questionsAnsweredToday'] ?? json['questions_answered_today'] ?? 0;
    final studyStreak = json['studyStreak'] ?? json['study_streak'] ?? 0;
    
    final specialtyData = json['specialtyAccuracy'] ?? json['specialty_accuracy'];
    final specialtyAccuracy = (specialtyData is Map)
        ? Map<String, double>.from(
            specialtyData.map(
              (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
            ),
          )
        : <String, double>{};
        
    final trendData = json['performanceTrend'] ?? json['performance_trend'];
    final List<DailyAccuracy> performanceTrend = [];
    if (trendData is List) {
      for (int i = 0; i < trendData.length; i++) {
        final val = trendData[i];
        final daysAgo = (trendData.length - 1) - i;
        final date = DateTime.now().subtract(Duration(days: daysAgo));
        performanceTrend.add(DailyAccuracy(date, (val as num).toDouble()));
      }
    }

    return UserStats(
      overallAccuracy: overallAccuracy,
      quizzesCompleted: quizzesCompleted,
      questionsAnswered: questionsAnswered,
      questionsAnsweredToday: questionsAnsweredToday,
      performanceTrend: performanceTrend,
      specialtyAccuracy: specialtyAccuracy,
      studyStreak: studyStreak,
    );
  }

  @override
  List<Object?> get props => [
    overallAccuracy,
    quizzesCompleted,
    questionsAnswered,
    questionsAnsweredToday,
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
