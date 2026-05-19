import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/learn/presentation/screens/course_reader_screen.dart';
import 'package:meducyte_app/features/learn/presentation/screens/module_lessons_screen.dart';
import 'package:meducyte_app/features/learn/presentation/screens/specialty_courses_screen.dart';
import 'package:meducyte_app/features/quiz/presentation/screens/quiz_session_screen.dart';
import 'package:meducyte_app/features/quiz/presentation/screens/quiz_training_screen.dart';
import 'package:meducyte_app/features/chatbot/presentation/screens/chat_chatbot_screen.dart';
import 'package:meducyte_app/features/quiz/presentation/screens/spaced_repetition_screen.dart';
import 'package:meducyte_app/features/quiz/presentation/screens/saved_quizzes_screen.dart';
import 'package:meducyte_app/features/quiz/presentation/screens/flashcards_screen.dart';
import 'package:meducyte_app/features/quiz/presentation/screens/notes_screen.dart';
import 'package:meducyte_app/features/simulation/presentation/pages/simulation_page.dart';
import 'package:meducyte_app/features/simulation/presentation/screens/ai_patient_sim_screen.dart';
import 'package:meducyte_app/features/simulation/presentation/screens/ai_patient_setup_screen.dart';
import 'package:meducyte_app/features/explore/presentation/pages/explore_page.dart';
import 'package:meducyte_app/features/explore/presentation/screens/ecg_helper_screen.dart';
import 'package:meducyte_app/features/explore/presentation/screens/radiology_helper_screen.dart';
import 'package:meducyte_app/features/explore/presentation/screens/lab_helper_screen.dart';
import 'package:meducyte_app/features/explore/presentation/screens/lab_encyclopedia_screen.dart';
import 'package:meducyte_app/features/explore/presentation/screens/lab_entry_detail_screen.dart';
import 'package:meducyte_app/features/explore/domain/models/lab_encyclopedia_models.dart';
import 'package:meducyte_app/features/explore/presentation/screens/lab_normal_values_screen.dart';
import 'package:meducyte_app/features/explore/presentation/screens/first_aid_helper_screen.dart';
import 'package:meducyte_app/features/explore/presentation/screens/books_screen.dart';
import 'package:meducyte_app/features/explore/presentation/pages/medical_games_page.dart';
import 'package:meducyte_app/features/explore/presentation/screens/anatomy_game_screen.dart';
import 'package:meducyte_app/features/explore/presentation/screens/word_association_screen.dart';
import 'package:meducyte_app/features/explore/presentation/screens/diagnosis_mystery_screen.dart';
import 'package:meducyte_app/features/explore/presentation/screens/ecg_hero_screen.dart';
import 'package:meducyte_app/features/explore/presentation/screens/pharma_match_screen.dart';
import 'package:meducyte_app/features/explore/presentation/screens/lab_master_screen.dart';
import 'package:meducyte_app/features/explore/presentation/screens/medical_crossword_screen.dart';
import 'package:meducyte_app/features/explore/presentation/screens/surgical_sim_screen.dart';
import 'package:meducyte_app/features/quiz/presentation/screens/srs_session_screen.dart';
import 'package:meducyte_app/features/quiz/presentation/screens/flashcard_study_screen.dart';
import 'package:meducyte_app/features/calculator/presentation/screens/medical_calculator_screen.dart';
import 'package:meducyte_app/features/calculator/presentation/calculators/bmi_calculator_screen.dart';
import 'package:meducyte_app/features/calculator/presentation/calculators/glasgow_calculator_screen.dart';
import 'package:meducyte_app/features/calculator/presentation/calculators/apgar_calculator_screen.dart';
import 'package:meducyte_app/features/calculator/presentation/calculators/wells_pe_calculator_screen.dart';
import 'package:meducyte_app/features/calculator/presentation/calculators/cha2ds2vasc_calculator_screen.dart';
import 'package:meducyte_app/features/calculator/presentation/screens/generic_calculator_screen.dart';
import 'package:meducyte_app/features/calculator/domain/models/calculator_models.dart';
import 'package:meducyte_app/features/productive_bay/presentation/pages/productive_bay_page.dart';
import 'package:meducyte_app/features/productive_bay/presentation/pages/study_groups_page.dart';
import 'package:meducyte_app/features/productive_bay/presentation/pages/study_group_details_page.dart';
import 'package:meducyte_app/features/productive_bay/presentation/pages/quiz_group_study_page.dart';
import 'package:meducyte_app/features/productive_bay/presentation/pages/planner_page.dart';
import 'package:meducyte_app/features/productive_bay/presentation/pages/tasks_page.dart';
import 'package:meducyte_app/features/productive_bay/presentation/pages/analytics_page.dart';
import 'package:meducyte_app/features/productive_bay/presentation/pages/customize_bay_page.dart';
import 'package:meducyte_app/features/productive_bay/presentation/pages/deep_work_page.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/study_group_provider.dart';
import 'package:meducyte_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:meducyte_app/features/auth/presentation/screens/legal/privacy_policy_screen.dart';
import 'package:meducyte_app/features/auth/presentation/screens/legal/terms_of_use_screen.dart';
import 'package:meducyte_app/features/settings/font_settings_screen.dart';
import 'package:meducyte_app/features/settings/notification_settings_screen.dart';
import 'package:meducyte_app/features/settings/presentation/screens/faq_screen.dart';
import 'package:meducyte_app/features/settings/presentation/screens/srs_settings_screen.dart';

//In app_routes.dart
final List<AppRoute> appRoutes = [
  AppRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
  AppRoute(
    path: AppRoutes.notificationSettings,
    builder: (_, __) => const NotificationSettingsScreen(),
  ),
  AppRoute(
    path: AppRoutes.fontSettings,
    builder: (_, __) => const FontSettingsScreen(),
  ),
  AppRoute(
    path: AppRoutes.srsSettings,
    builder: (_, __) => const SrsSettingsScreen(),
  ),
  AppRoute(
    path: AppRoutes.onboarding,
    builder: (_, __) => const OnboardingScreen(),
  ),
  AppRoute(path: AppRoutes.signup, builder: (_, __) => const SignUpScreen()),
  AppRoute(path: AppRoutes.welcome, builder: (_, __) => const WelcomeScreen()),
  AppRoute(
    path: AppRoutes.forgotPassword,
    builder: (_, __) => const ForgotPasswordScreen(),
  ),

  //OTP Verification with data extraction
  AppRoute(
    path: AppRoutes.otpVerification,
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>? ?? {};
      return OtpVerificationScreen(
        email: extra['email'] ?? '',
        type: extra['type'] ?? 'email_verification',
        isFromSignup: extra['isFromSignup'] ?? true,
      );
    },
  ),

  //Reset Password with data extraction
  AppRoute(
    path: AppRoutes.resetPassword,
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>? ?? {};
      return ResetPasswordScreen(
        email: extra['email'] ?? '',
        otp: extra['otp'] ?? '',
      );
    },
  ),
  AppRoute(
    path: AppRoutes.home,
    builder: (_, __) => const ResponsiveNavigationScreen(),
  ),
  AppRoute(path: AppRoutes.chatbot, builder: (_, __) => const ChatBotScreen()),

  //Learn routes
  AppRoute(
    path: AppRoutes.moduleLessons,
    builder: (context, state) {
      final id = state.pathParameters['id'] ?? '';
      return ModuleLessonsScreen(moduleId: id);
    },
  ),
  AppRoute(
    path: AppRoutes.specialtyCourses,
    builder: (context, state) {
      final specialtyName = state.pathParameters['specialtyName'] ?? '';
      return SpecialtyCoursesScreen(specialtyName: specialtyName);
    },
  ),
  AppRoute(
    path: AppRoutes.courseReader,
    builder: (context, state) {
      final courseId = state.pathParameters['id'] ?? 'default';
      final commentId = state.uri.queryParameters['commentId'];
      return CourseReaderScreen(
        courseId: courseId,
        initialCommentId: commentId,
      );
    },
  ),

  //Quiz Routes
  AppRoute(
    path: AppRoutes.quizTraining,
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>? ?? {};
      final isPractice = extra['isPractice'] as bool? ?? true;
      final isExplore = extra['isExplore'] as bool? ?? false;
      final initialYear = extra['initialYear'] as int?;
      return QuizTrainingScreen(
        isPractice: isPractice,
        isExplore: isExplore,
        initialYear: initialYear,
      );
    },
  ),
  AppRoute(
    path: AppRoutes.quizSession,
    builder: (context, state) {
      final filters =
          state.extra as QuizFilters? ?? QuizFilters(isPractice: true);
      final questionId = state.uri.queryParameters['questionId'];
      final commentId = state.uri.queryParameters['commentId'];
      return QuizSessionScreen(
        filters: filters,
        initialQuestionId: questionId,
        initialCommentId: commentId,
      );
    },
  ),
  AppRoute(
    path: AppRoutes.spacedRepetition,
    builder: (_, __) => const SpacedRepetitionScreen(),
  ),
  AppRoute(
    path: AppRoutes.srsSession,
    name: AppRoutes.srsSession,
    builder: (context, state) => const SrsSessionScreen(),
  ),
  AppRoute(
    path: AppRoutes.savedQuizzes,
    builder: (_, __) => const SavedQuizzesScreen(),
  ),
  AppRoute(
    path: AppRoutes.flashcards,
    builder: (_, __) => const FlashcardsScreen(),
  ),
  AppRoute(
    path: AppRoutes.flashcardStudy,
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>;
      return FlashcardStudyScreen(
        initialQuestions: extra['questions'] as List<Question>,
        title: extra['title'] as String,
      );
    },
  ),
  AppRoute(path: AppRoutes.quizNotes, builder: (_, __) => const NotesScreen()),
  AppRoute(
    path: AppRoutes.simulation,
    builder: (_, __) => const SimulationPage(),
  ),
  AppRoute(
    path: AppRoutes.aiPatientSim,
    builder: (context, state) => const AiPatientSetupScreen(),
  ),
  AppRoute(
    path: AppRoutes.aiPatientChat,
    builder: (context, state) => const AiPatientSimScreen(),
  ),
  AppRoute(path: AppRoutes.explore, builder: (_, __) => const ExplorePage()),
  AppRoute(
    path: AppRoutes.ecgHelper,
    builder: (_, __) => const EcgHelperScreen(),
  ),
  AppRoute(
    path: AppRoutes.radiologyHelper,
    builder: (_, __) => const RadiologyHelperScreen(),
  ),
  AppRoute(
    path: AppRoutes.labHelper,
    builder: (_, __) => const LabHelperScreen(),
  ),
  AppRoute(
    path: AppRoutes.labEncyclopedia,
    builder: (_, __) => const LabEncyclopediaScreen(),
  ),
  AppRoute(
    path: AppRoutes.labNormalValues,
    builder: (_, __) => const LabNormalValuesScreen(),
  ),
  AppRoute(
    path: AppRoutes.firstAid,
    builder: (_, __) => const FirstAidHelperScreen(),
  ),
  AppRoute(
    path: AppRoutes.booksLibrary,
    builder: (_, __) => const BooksLibraryScreen(),
  ),
  AppRoute(
    path: AppRoutes.medicalGames,
    builder: (_, __) => const MedicalGamesPage(),
  ),
  AppRoute(
    path: AppRoutes.anatomyQuiz,
    builder: (_, __) => const AnatomyGameScreen(),
  ),
  AppRoute(
    path: AppRoutes.wordAssociation,
    builder: (_, __) => const WordAssociationScreen(),
  ),
  AppRoute(
    path: AppRoutes.diagnosisMystery,
    builder: (_, __) => const DiagnosisMysteryScreen(),
  ),
  AppRoute(path: AppRoutes.ecgHero, builder: (_, __) => const EcgHeroScreen()),
  AppRoute(
    path: AppRoutes.pharmaMatch,
    builder: (_, __) => const PharmaMatchScreen(),
  ),
  AppRoute(
    path: AppRoutes.labMaster,
    builder: (_, __) => const LabMasterScreen(),
  ),
  AppRoute(
    path: AppRoutes.medicalCrossword,
    builder: (_, __) => const MedicalCrosswordScreen(),
  ),
  AppRoute(
    path: AppRoutes.surgicalSim,
    builder: (_, __) => const SurgicalSimScreen(),
  ),
  AppRoute(
    path: '${AppRoutes.labEncyclopedia}/:id',
    builder: (context, state) {
      final entry = state.extra as LabEntry;
      return LabEntryDetailScreen(entry: entry);
    },
  ),

  //Profile Route
  AppRoute(path: AppRoutes.profile, builder: (_, __) => const ProfileScreen()),

  //Settings Route
  AppRoute(path: AppRoutes.settings, builder: (_, __) => const SettingsPage()),
  //Statistics Route
  AppRoute(
    path: AppRoutes.statistics,
    builder: (_, __) => const StatisticsScreen(),
  ),
  //Medical Calculator Route
  AppRoute(
    path: AppRoutes.medicalCalculator,
    builder: (_, __) => const MedicalCalculatorScreen(),
    children: [
      AppRoute(path: 'bmi', builder: (_, __) => const BmiCalculatorScreen()),
      AppRoute(
        path: 'glasgow',
        builder: (_, __) => const GlasgowCalculatorScreen(),
      ),
      AppRoute(
        path: 'apgar',
        builder: (_, __) => const ApgarCalculatorScreen(),
      ),
      AppRoute(
        path: 'wells-pe',
        builder: (_, __) => const WellsPeCalculatorScreen(),
      ),
      AppRoute(
        path: 'cha2ds2vasc',
        builder: (_, __) => const Cha2ds2vascCalculatorScreen(),
      ),
      AppRoute(
        path: 'generic/:id',
        builder: (context, state) {
          final extra = state.extra as MedicalCalculatorMetadata?;
          if (extra != null) {
            return GenericCalculatorScreen(calculator: extra);
          }
          return const Scaffold(body: Center(child: Text('Error:No data')));
        },
      ),
    ],
  ),
  AppRoute(
    path: AppRoutes.productiveBay,
    name: AppRoutes.productiveBay,
    builder: (_, __) => const ProductiveBayPage(),
  ),
  AppRoute(
    path: AppRoutes.studyGroups,
    name: AppRoutes.studyGroups,
    builder: (_, __) => const StudyGroupsPage(),
  ),
  AppRoute(
    path: AppRoutes.quizGroupStudy,
    name: AppRoutes.quizGroupStudy,
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      final extra = state.extra as Map<String, dynamic>?;
      final session = extra?['session'] as StudyGroupQuizSession?;
      return QuizGroupStudyPage(groupId: id, initialSession: session);
    },
  ),
  AppRoute(
    path: AppRoutes.studyGroupDetails,
    name: AppRoutes.studyGroupDetails,
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      final extra = state.extra as Map<String, dynamic>?;
      final group = extra?['group'] as StudyGroup?;

      if (group != null) {
        return StudyGroupDetailsPage(group: group);
      }

      //Robust fallback if extra is dropped(e.g.process death/restoration)
      return Consumer(
        builder: (context, ref, child) {
          final groupAsync = ref.watch(studyGroupProvider(id));
          return groupAsync.when(
            data: (group) {
              if (group != null) return StudyGroupDetailsPage(group: group);
              //Show snackbar and go back—never leave user on a dead-end.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Groupe non trouvé',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                  Navigator.of(context).maybePop();
                }
              });
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
          );
        },
      );
    },
  ),
  AppRoute(
    path: AppRoutes.planner,
    name: AppRoutes.planner,
    builder: (_, __) => const PlannerPage(),
  ),
  AppRoute(
    path: AppRoutes.tasks,
    name: AppRoutes.tasks,
    builder: (_, __) => const TasksPage(),
  ),
  AppRoute(
    path: AppRoutes.analytics,
    name: AppRoutes.analytics,
    builder: (_, __) => const AnalyticsPage(),
  ),
  AppRoute(
    path: AppRoutes.customizeBay,
    name: AppRoutes.customizeBay,
    builder: (_, __) => const CustomizeBayPage(),
  ),
  AppRoute(
    path: AppRoutes.notifications,
    name: AppRoutes.notifications,
    builder: (_, __) => const NotificationsScreen(),
  ),
  AppRoute(
    path: AppRoutes.deepWork,
    name: AppRoutes.deepWork,
    builder: (_, __) => const DeepWorkPage(),
  ),

  //Legal routes
  AppRoute(
    path: AppRoutes.privacyPolicy,
    builder: (_, __) => const PrivacyPolicyScreen(),
  ),
  AppRoute(
    path: AppRoutes.termsOfUse,
    builder: (_, __) => const TermsOfUseScreen(),
  ),
  AppRoute(path: AppRoutes.faq, builder: (_, __) => const FaqScreen()),
];
