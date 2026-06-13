import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/analytics_models.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/pomodoro_models.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/productive_bay_provider.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/pomodoro_provider.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/mastery_provider.dart';
import 'package:meducyte_app/features/statistics/data/providers/stats_provider.dart';
import 'package:meducyte_app/features/quiz/data/providers/srs_provider.dart';
import 'package:meducyte_app/features/quiz/presentation/providers/quiz_session_provider.dart';
import 'package:meducyte_app/features/settings/providers/settings_provider.dart';

final fatigueStatusProvider = Provider.autoDispose<FatigueStatus>((ref) {
  final settings = ref.watch(appSettingsProvider);
  if (!settings.fatigueAnalysisEnabled) {
    return FatigueStatus(
      level: FatigueLevel.peak,
      recommendation: "Concentration optimale. Prêt à aborder des sujets complexes !",
      recommendationKey: "peakFocusMsg",
      cognitiveLoad: 0.10,
      capacity: 0.90,
      breakDue: const Duration(minutes: 60),
    );
  }

  double sensitivityScale = 1.0;
  if (settings.fatigueSensitivity == 'Low') {
    sensitivityScale = 0.5;
  } else if (settings.fatigueSensitivity == 'High') {
    sensitivityScale = 1.5;
  }

  final statsAsync = ref.watch(studyStatsProvider);
  final pomodoroSession = ref.watch(pomodoroProvider);
  final masteryMap = ref.watch(masteryProvider);
  final srsStatsAsync = ref.watch(srsStatsProvider);
  final userStatsAsync = ref.watch(userStatsProvider);
  final quizState = ref.watch(quizSessionProvider);

  final completedPomodorosToday = statsAsync.valueOrNull?.completedPomodorosToday ?? 0;
  final completedShortBreaksToday = statsAsync.valueOrNull?.completedShortBreaksToday ?? 0;
  final completedLongBreaksToday = statsAsync.valueOrNull?.completedLongBreaksToday ?? 0;
  final srsStats = srsStatsAsync.valueOrNull;
  final userStats = userStatsAsync.valueOrNull;

  // 1. Calculate cognitive load
  // Base baseline load starts at a rested 0.10
  double load = 0.10;

  // A. Pomodoro workload: Each completed Pomodoro increases base fatigue by 0.10.
  // This is permanently offset by completed breaks today (short break = 0.10, long break = 0.30).
  final pomodoroWorkload = completedPomodorosToday * 0.10 * sensitivityScale;
  final completedBreaksRecovery = ((completedShortBreaksToday * 0.10) + (completedLongBreaksToday * 0.30)) * sensitivityScale;
  final pomodoroNetLoad = (pomodoroWorkload - completedBreaksRecovery).clamp(0.0, 0.60);
  load += pomodoroNetLoad;

  // B. Quiz workload: Each question answered today increases load by 0.005 (max 0.25)
  final questionsAnsweredToday = userStats?.questionsAnsweredToday ?? 0;
  load += (questionsAnsweredToday * 0.005 * sensitivityScale).clamp(0.0, 0.25);

  // C. Spaced Repetition (SRS) workload: Active cards in learning box 1-2 increase load by 0.015 (max 0.20)
  final srsLearning = srsStats?['learning'] ?? 0;
  load += (srsLearning * 0.015 * sensitivityScale).clamp(0.0, 0.20);

  // D. Active focus session strain:
  // If currently working on a Pomodoro focus work session, add load based on elapsed progress (up to 0.18)
  if (pomodoroSession.type == PomodoroSessionType.work &&
      pomodoroSession.state == PomodoroState.running) {
    final elapsed = pomodoroSession.durationSeconds - pomodoroSession.remainingSeconds;
    final ratio = pomodoroSession.durationSeconds > 0 ? (elapsed / pomodoroSession.durationSeconds) : 0.0;
    load += ratio * 0.18 * sensitivityScale;
  }

  // E. Frustration / Performance strain:
  // Low accuracy in quizzes (e.g. below 70%) increases stress and fatigue
  final overallAccuracy = userStats?.overallAccuracy ?? 0.80;
  if (overallAccuracy < 0.70) {
    load += (0.70 - overallAccuracy) * 0.25 * sensitivityScale;
  }

  // F. Low Mastery / Confidence strain:
  // If average mastery score is low (< 0.6), add stress modifier based on friction
  double avgMastery = 1.0;
  if (masteryMap.isNotEmpty) {
    final totalScores = masteryMap.values.map((m) => m.masteryScore).toList();
    if (totalScores.isNotEmpty) {
      avgMastery = totalScores.reduce((a, b) => a + b) / totalScores.length;
      if (avgMastery < 0.6) {
        load += (1.0 - avgMastery) * 0.15 * sensitivityScale;
      }
    }
  }

  // G. Active Quiz session time and incorrect answers (concentration tracking):
  // If a quiz session is active, track its duration and incorrect answers.
  if (quizState.isInitialized && !quizState.isFinished) {
    // 1. Time-on-task: mental load increases by 0.02 per minute spent in active quiz (max 0.20)
    final quizMinutes = quizState.timeSeconds / 60.0;
    load += (quizMinutes * 0.02 * sensitivityScale).clamp(0.0, 0.20);

    // 2. Performance stress: wrong answers in current session increase load/frustration by 0.05 each (max 0.25)
    final wrongAnswers = quizState.results.values.where((r) => !r.isCorrect).length;
    load += (wrongAnswers * 0.05 * sensitivityScale).clamp(0.0, 0.25);
  }

  // H. Recovery (Active Break sessions):
  // If in a break session, reduce cognitive load based on progress (up to 0.10 for short break, 0.30 for long break)
  if (pomodoroSession.state == PomodoroState.running) {
    if (pomodoroSession.type == PomodoroSessionType.shortBreak) {
      final elapsed = pomodoroSession.durationSeconds - pomodoroSession.remainingSeconds;
      final ratio = pomodoroSession.durationSeconds > 0 ? (elapsed / pomodoroSession.durationSeconds) : 0.0;
      load -= ratio * 0.10 * sensitivityScale;
    } else if (pomodoroSession.type == PomodoroSessionType.longBreak) {
      final elapsed = pomodoroSession.durationSeconds - pomodoroSession.remainingSeconds;
      final ratio = pomodoroSession.durationSeconds > 0 ? (elapsed / pomodoroSession.durationSeconds) : 0.0;
      load -= ratio * 0.30 * sensitivityScale;
    }
  }

  // Clamp load between 0.05 and 1.00
  load = load.clamp(0.05, 1.00);

  // 2. Determine Fatigue Level
  FatigueLevel level;
  String recommendation;
  String recommendationKey;

  if (load < 0.35) {
    level = FatigueLevel.peak;
    recommendation = "Concentration optimale. Prêt à aborder des sujets complexes !";
    recommendationKey = "peakFocusMsg";
  } else if (load < 0.65) {
    level = FatigueLevel.optimal;
    recommendation = "Concentration stable. Gardez ce rythme.";
    recommendationKey = "optimalConcentrationMsg";
  } else if (load < 0.85) {
    level = FatigueLevel.tired;
    recommendation = "Fatigue légère détectée. Envisagez de changer de sujet ou de faire une courte pause.";
    recommendationKey = "lightFatigueMsg";
  } else {
    level = FatigueLevel.exhausted;
    recommendation = "Fatigue élevée. Prenez une vraie pause pour recharger vos batteries.";
    recommendationKey = "burnoutRiskMsg";
  }

  // 3. Capacity calculation (inverse of load)
  final capacity = (1.0 - load).clamp(0.0, 1.0);

  // 4. Break due calculation
  // Let's estimate remaining duration before break is due.
  Duration breakDue;
  if (level == FatigueLevel.exhausted) {
    breakDue = Duration.zero;
  } else if (level == FatigueLevel.tired) {
    breakDue = const Duration(minutes: 15);
  } else {
    // If running, break due is remaining work seconds
    if (pomodoroSession.type == PomodoroSessionType.work &&
        pomodoroSession.state == PomodoroState.running) {
      breakDue = Duration(seconds: pomodoroSession.remainingSeconds);
    } else {
      // Otherwise estimate based on load
      final minsRemaining = ((1.0 - load) * 60).toInt().clamp(5, 90);
      breakDue = Duration(minutes: minsRemaining);
    }
  }

  return FatigueStatus(
    level: level,
    recommendation: recommendation,
    recommendationKey: recommendationKey,
    cognitiveLoad: load,
    capacity: capacity,
    breakDue: breakDue,
  );
});
