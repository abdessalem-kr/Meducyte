import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meducyte_app/core/network/dio_client.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/fatigue_provider.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/analytics_models.dart'
    hide FocusSession;
import 'package:meducyte_app/features/productive_bay/domain/models/pomodoro_models.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/pomodoro_provider.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/productive_bay_provider.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/productive_bay_models.dart';
import 'package:meducyte_app/features/statistics/data/providers/stats_provider.dart';
import 'package:meducyte_app/features/statistics/domain/models/stats_models.dart';
import 'package:meducyte_app/features/quiz/presentation/providers/quiz_session_provider.dart';
import 'package:meducyte_app/features/quiz/domain/models/quiz_models.dart';
import 'package:meducyte_app/features/quiz/data/providers/srs_provider.dart';
import 'package:meducyte_app/features/quiz/data/providers/quiz_provider.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/mastery_provider.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/pomodoro_settings_provider.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/pomodoro_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meducyte_app/features/settings/providers/settings_provider.dart';

class FakePomodoroSettingsNotifier extends PomodoroSettingsNotifier {
  FakePomodoroSettingsNotifier(
    super.ref,
    AsyncValue<PomodoroSettings> initialState,
  ) {
    state = initialState;
  }

  @override
  Future<void> loadSettings() async {
    // Avoid network call in tests
  }
}

class FakePomodoroNotifier extends PomodoroNotifier {
  FakePomodoroNotifier(super.ref, FocusSession initialState) {
    state = initialState;
  }
}

class FakeQuizSessionNotifier extends QuizSessionNotifier {
  FakeQuizSessionNotifier(Ref ref, QuizSessionState initialState)
    : super(
        QuizRepository(
          DioClient(
            baseUrl: 'http://localhost',
            secureStorage: FlutterSecureStorage(),
          ),
        ),
        ref,
      ) {
    state = initialState;
  }
}

class FakeMasteryNotifier extends MasteryNotifier {
  FakeMasteryNotifier(Map<String, MasteryData> initialState) : super() {
    state = initialState;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  const defaultUserStats = UserStats(
    overallAccuracy: 0.80,
    quizzesCompleted: 0,
    questionsAnswered: 0,
    questionsAnsweredToday: 0,
    performanceTrend: [],
    specialtyAccuracy: {},
    studyStreak: 0,
  );

  group('FatigueStatusProvider Tests', () {
    test('Should calculate base load when rested and no quiz active', () async {
      final container = ProviderContainer(
        overrides: [
          pomodoroSettingsProvider.overrideWith(
            (ref) => FakePomodoroSettingsNotifier(
              ref,
              AsyncValue.data(PomodoroSettings.defaultSettings()),
            ),
          ),
          studyStatsProvider.overrideWith(
            (ref) => const StudyStats(
              currentStreak: 5,
              totalHours: 10,
              completedPomodorosToday: 0,
              completedShortBreaksToday: 0,
              completedLongBreaksToday: 0,
              totalPomodorosGoal: 4,
              moduleScores: {},
            ),
          ),
          pomodoroProvider.overrideWith(
            (ref) => FakePomodoroNotifier(
              ref,
              const FocusSession(
                durationSeconds: 25 * 60,
                remainingSeconds: 25 * 60,
                state: PomodoroState.initial,
                type: PomodoroSessionType.work,
              ),
            ),
          ),
          masteryProvider.overrideWith((ref) => FakeMasteryNotifier(const {})),
          srsStatsProvider.overrideWith((ref) => Stream.value(<String, int>{})),
          userStatsProvider.overrideWith((ref) => defaultUserStats),
          quizSessionProvider.overrideWith(
            (ref) => FakeQuizSessionNotifier(ref, QuizSessionState()),
          ),
        ],
      );

      addTearDown(container.dispose);

      // Await resolution of the future/stream providers to populate state
      await container.read(studyStatsProvider.future);
      await container.read(userStatsProvider.future);
      await container.read(srsStatsProvider.future);

      final status = container.read(fatigueStatusProvider);

      // Base load should be 0.10
      expect(status.cognitiveLoad, equals(0.10));
      expect(status.level, equals(FatigueLevel.peak));
    });

    test(
      'Should increase load when quiz session is active with wrong answers and duration',
      () async {
        final container = ProviderContainer(
          overrides: [
            pomodoroSettingsProvider.overrideWith(
              (ref) => FakePomodoroSettingsNotifier(
                ref,
                AsyncValue.data(PomodoroSettings.defaultSettings()),
              ),
            ),
            studyStatsProvider.overrideWith(
              (ref) => const StudyStats(
                currentStreak: 5,
                totalHours: 10,
                completedPomodorosToday: 0,
                completedShortBreaksToday: 0,
                completedLongBreaksToday: 0,
                totalPomodorosGoal: 4,
                moduleScores: {},
              ),
            ),
            pomodoroProvider.overrideWith(
              (ref) => FakePomodoroNotifier(
                ref,
                const FocusSession(
                  durationSeconds: 25 * 60,
                  remainingSeconds: 25 * 60,
                  state: PomodoroState.initial,
                  type: PomodoroSessionType.work,
                ),
              ),
            ),
            masteryProvider.overrideWith(
              (ref) => FakeMasteryNotifier(const {}),
            ),
            srsStatsProvider.overrideWith(
              (ref) => Stream.value(<String, int>{}),
            ),
            userStatsProvider.overrideWith((ref) => defaultUserStats),
            quizSessionProvider.overrideWith(
              (ref) => FakeQuizSessionNotifier(
                ref,
                QuizSessionState(
                  isInitialized: true,
                  isFinished: false,
                  timeSeconds: 300, // 5 minutes -> +0.10 load
                  results: {
                    1: AnswerResult(isCorrect: false, score: 0.0),
                    2: AnswerResult(
                      isCorrect: false,
                      score: 0.0,
                    ), // 2 wrong answers -> +0.10 load
                  },
                ),
              ),
            ),
          ],
        );

        addTearDown(container.dispose);

        // Await resolution of the future/stream providers to populate state
        await container.read(studyStatsProvider.future);
        await container.read(userStatsProvider.future);
        await container.read(srsStatsProvider.future);

        final status = container.read(fatigueStatusProvider);

        // Base: 0.10
        // Active Quiz: 5 mins * 0.02 = +0.10
        // Active Quiz wrong answers: 2 * 0.05 = +0.10
        // Total load should be ~0.30
        expect(status.cognitiveLoad, closeTo(0.30, 0.01));
        expect(status.level, equals(FatigueLevel.peak));
      },
    );

    test(
      'Should trigger tired/exhausted status when quiz load is extremely high',
      () async {
        final container = ProviderContainer(
          overrides: [
            pomodoroSettingsProvider.overrideWith(
              (ref) => FakePomodoroSettingsNotifier(
                ref,
                AsyncValue.data(PomodoroSettings.defaultSettings()),
              ),
            ),
            studyStatsProvider.overrideWith(
              (ref) => const StudyStats(
                currentStreak: 5,
                totalHours: 10,
                completedPomodorosToday: 3, // +0.30 load
                completedShortBreaksToday: 0,
                completedLongBreaksToday: 0,
                totalPomodorosGoal: 4,
                moduleScores: {},
              ),
            ),
            pomodoroProvider.overrideWith(
              (ref) => FakePomodoroNotifier(
                ref,
                const FocusSession(
                  durationSeconds: 25 * 60,
                  remainingSeconds: 25 * 60,
                  state: PomodoroState.initial,
                  type: PomodoroSessionType.work,
                ),
              ),
            ),
            masteryProvider.overrideWith(
              (ref) => FakeMasteryNotifier(const {}),
            ),
            srsStatsProvider.overrideWith(
              (ref) => Stream.value(<String, int>{}),
            ),
            userStatsProvider.overrideWith((ref) => defaultUserStats),
            quizSessionProvider.overrideWith(
              (ref) => FakeQuizSessionNotifier(
                ref,
                QuizSessionState(
                  isInitialized: true,
                  isFinished: false,
                  timeSeconds: 600, // 10 minutes -> +0.20 load
                  results: {
                    1: AnswerResult(isCorrect: false, score: 0.0),
                    2: AnswerResult(isCorrect: false, score: 0.0),
                    3: AnswerResult(isCorrect: false, score: 0.0),
                    4: AnswerResult(isCorrect: false, score: 0.0),
                    5: AnswerResult(
                      isCorrect: false,
                      score: 0.0,
                    ), // 5 wrong answers -> +0.25 load
                  },
                ),
              ),
            ),
          ],
        );

        addTearDown(container.dispose);

        // Await resolution of the future/stream providers to populate state
        await container.read(studyStatsProvider.future);
        await container.read(userStatsProvider.future);
        await container.read(srsStatsProvider.future);

        final status = container.read(fatigueStatusProvider);

        // Base: 0.10
        // Completed Pomodoros today: 3 * 0.10 = +0.30
        // Active Quiz: 10 mins * 0.02 = +0.20
        // Active Quiz wrong answers: 5 * 0.05 = +0.25
        // Total load: 0.10 + 0.30 + 0.20 + 0.25 = 0.85
        expect(status.cognitiveLoad, closeTo(0.85, 0.01));
        expect(status.level, equals(FatigueLevel.exhausted));
      },
    );

    test('Should offset fatigue load using completed short and long breaks today', () async {
      final container = ProviderContainer(
        overrides: [
          pomodoroSettingsProvider.overrideWith(
            (ref) => FakePomodoroSettingsNotifier(
              ref,
              AsyncValue.data(PomodoroSettings.defaultSettings()),
            ),
          ),
          studyStatsProvider.overrideWith(
            (ref) => const StudyStats(
              currentStreak: 5,
              totalHours: 10,
              completedPomodorosToday: 4, // +0.40 workload
              completedShortBreaksToday: 1, // -0.10 recovery
              completedLongBreaksToday: 1, // -0.30 recovery
              totalPomodorosGoal: 4,
              moduleScores: {},
            ),
          ),
          pomodoroProvider.overrideWith(
            (ref) => FakePomodoroNotifier(
              ref,
              const FocusSession(
                durationSeconds: 25 * 60,
                remainingSeconds: 25 * 60,
                state: PomodoroState.initial,
                type: PomodoroSessionType.work,
              ),
            ),
          ),
          masteryProvider.overrideWith((ref) => FakeMasteryNotifier(const {})),
          srsStatsProvider.overrideWith((ref) => Stream.value(<String, int>{})),
          userStatsProvider.overrideWith((ref) => defaultUserStats),
          quizSessionProvider.overrideWith(
            (ref) => FakeQuizSessionNotifier(ref, QuizSessionState()),
          ),
        ],
      );

      addTearDown(container.dispose);

      await container.read(studyStatsProvider.future);
      await container.read(userStatsProvider.future);
      await container.read(srsStatsProvider.future);

      final status = container.read(fatigueStatusProvider);

      // Base: 0.10
      // Pomodoros (4 * 0.10) = +0.40
      // Breaks (1 * 0.10 + 1 * 0.30) = -0.40
      // Net Pomodoro load = 0.00
      // Total load should be 0.10 (base only)
      expect(status.cognitiveLoad, equals(0.10));
      expect(status.level, equals(FatigueLevel.peak));
    });

    test('Should return baseline status when fatigue analysis is disabled', () async {
      final container = ProviderContainer(
        overrides: [
          appSettingsProvider.overrideWith(
            (ref) => AppSettingsNotifier()
              ..state = const AppSettings(
                notificationsEnabled: true,
                highContrastEnabled: false,
                syncSettingsEnabled: true,
                fontSize: 'Medium',
                downloadMode: 'Wi-Fi only',
                fatigueAnalysisEnabled: false,
              ),
          ),
          pomodoroSettingsProvider.overrideWith(
            (ref) => FakePomodoroSettingsNotifier(
              ref,
              AsyncValue.data(PomodoroSettings.defaultSettings()),
            ),
          ),
          studyStatsProvider.overrideWith(
            (ref) => const StudyStats(
              currentStreak: 5,
              totalHours: 10,
              completedPomodorosToday: 4, // normally +0.40 load
              completedShortBreaksToday: 0,
              completedLongBreaksToday: 0,
              totalPomodorosGoal: 4,
              moduleScores: {},
            ),
          ),
          pomodoroProvider.overrideWith(
            (ref) => FakePomodoroNotifier(
              ref,
              const FocusSession(
                durationSeconds: 25 * 60,
                remainingSeconds: 25 * 60,
                state: PomodoroState.initial,
                type: PomodoroSessionType.work,
              ),
            ),
          ),
          masteryProvider.overrideWith((ref) => FakeMasteryNotifier(const {})),
          srsStatsProvider.overrideWith((ref) => Stream.value(<String, int>{})),
          userStatsProvider.overrideWith((ref) => defaultUserStats),
          quizSessionProvider.overrideWith(
            (ref) => FakeQuizSessionNotifier(ref, QuizSessionState()),
          ),
        ],
      );

      addTearDown(container.dispose);

      await container.read(studyStatsProvider.future);
      await container.read(userStatsProvider.future);
      await container.read(srsStatsProvider.future);

      final status = container.read(fatigueStatusProvider);

      // Should return baseline peak focus settings since analysis is disabled
      expect(status.cognitiveLoad, equals(0.10));
      expect(status.level, equals(FatigueLevel.peak));
    });

    test('Should scale fatigue build-up when sensitivity is Low', () async {
      final container = ProviderContainer(
        overrides: [
          appSettingsProvider.overrideWith(
            (ref) => AppSettingsNotifier()
              ..state = const AppSettings(
                notificationsEnabled: true,
                highContrastEnabled: false,
                syncSettingsEnabled: true,
                fontSize: 'Medium',
                downloadMode: 'Wi-Fi only',
                fatigueAnalysisEnabled: true,
                fatigueSensitivity: 'Low', // 0.5 sensitivity
              ),
          ),
          pomodoroSettingsProvider.overrideWith(
            (ref) => FakePomodoroSettingsNotifier(
              ref,
              AsyncValue.data(PomodoroSettings.defaultSettings()),
            ),
          ),
          studyStatsProvider.overrideWith(
            (ref) => const StudyStats(
              currentStreak: 5,
              totalHours: 10,
              completedPomodorosToday: 4, // base load = +0.40. scaled * 0.5 = +0.20
              completedShortBreaksToday: 0,
              completedLongBreaksToday: 0,
              totalPomodorosGoal: 4,
              moduleScores: {},
            ),
          ),
          pomodoroProvider.overrideWith(
            (ref) => FakePomodoroNotifier(
              ref,
              const FocusSession(
                durationSeconds: 25 * 60,
                remainingSeconds: 25 * 60,
                state: PomodoroState.initial,
                type: PomodoroSessionType.work,
              ),
            ),
          ),
          masteryProvider.overrideWith((ref) => FakeMasteryNotifier(const {})),
          srsStatsProvider.overrideWith((ref) => Stream.value(<String, int>{})),
          userStatsProvider.overrideWith((ref) => defaultUserStats),
          quizSessionProvider.overrideWith(
            (ref) => FakeQuizSessionNotifier(ref, QuizSessionState()),
          ),
        ],
      );

      addTearDown(container.dispose);

      await container.read(studyStatsProvider.future);
      await container.read(userStatsProvider.future);
      await container.read(srsStatsProvider.future);

      final status = container.read(fatigueStatusProvider);

      // Base: 0.10
      // Pomodoros: 4 * 0.10 * 0.5 = +0.20
      // Net load = 0.30
      expect(status.cognitiveLoad, closeTo(0.30, 0.001));
    });

    test('Should scale fatigue build-up when sensitivity is High', () async {
      final container = ProviderContainer(
        overrides: [
          appSettingsProvider.overrideWith(
            (ref) => AppSettingsNotifier()
              ..state = const AppSettings(
                notificationsEnabled: true,
                highContrastEnabled: false,
                syncSettingsEnabled: true,
                fontSize: 'Medium',
                downloadMode: 'Wi-Fi only',
                fatigueAnalysisEnabled: true,
                fatigueSensitivity: 'High', // 1.5 sensitivity
              ),
          ),
          pomodoroSettingsProvider.overrideWith(
            (ref) => FakePomodoroSettingsNotifier(
              ref,
              AsyncValue.data(PomodoroSettings.defaultSettings()),
            ),
          ),
          studyStatsProvider.overrideWith(
            (ref) => const StudyStats(
              currentStreak: 5,
              totalHours: 10,
              completedPomodorosToday: 2, // base load = +0.20. scaled * 1.5 = +0.30
              completedShortBreaksToday: 0,
              completedLongBreaksToday: 0,
              totalPomodorosGoal: 4,
              moduleScores: {},
            ),
          ),
          pomodoroProvider.overrideWith(
            (ref) => FakePomodoroNotifier(
              ref,
              const FocusSession(
                durationSeconds: 25 * 60,
                remainingSeconds: 25 * 60,
                state: PomodoroState.initial,
                type: PomodoroSessionType.work,
              ),
            ),
          ),
          masteryProvider.overrideWith((ref) => FakeMasteryNotifier(const {})),
          srsStatsProvider.overrideWith((ref) => Stream.value(<String, int>{})),
          userStatsProvider.overrideWith((ref) => defaultUserStats),
          quizSessionProvider.overrideWith(
            (ref) => FakeQuizSessionNotifier(ref, QuizSessionState()),
          ),
        ],
      );

      addTearDown(container.dispose);

      await container.read(studyStatsProvider.future);
      await container.read(userStatsProvider.future);
      await container.read(srsStatsProvider.future);

      final status = container.read(fatigueStatusProvider);

      // Base: 0.10
      // Pomodoros: 2 * 0.10 * 1.5 = +0.30
      // Net load = 0.40
      expect(status.cognitiveLoad, closeTo(0.40, 0.001));
    });
  });
}
