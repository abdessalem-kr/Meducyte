// individual routes
class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String otpVerification = '/otp-verification';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String chatbot = '/chatbot';
  // Quiz routes
  static const String quizTraining = '/quiz/training';
  static const String quiz = '/quiz';
  static const String quizList = '/quiz/list';
  static const String quizSession = '/quiz/session/:id';
  static const String quizResult = '/quiz/result/:id';
  static const String quizNotes = '/quiz/notes';
  static const String quizAttempts = '/quiz/attempts';
  static const String spacedRepetition = '/quiz/spaced-repetition';
  static const String srsSession = '/srs-session';
  static const String savedQuizzes = '/saved-quizzes';
  static const String flashcards = '/quiz/flashcards';
  static const String flashcardStudy = '/quiz/flashcards/study';
  static const String simulation = '/simulation';
  static const String aiPatientSim = '/simulation/ai-patient';
  static const String aiPatientChat = '/simulation/ai-patient/chat';
  static const String explore = '/explore';
  static const String ecgHelper = '/explore/ecg-helper';
  static const String radiologyHelper = '/explore/radiology-helper';
  static const String labHelper = '/explore/lab-helper';
  static const String labNormalValues = '/explore/lab-normal-values';
  static const String labEncyclopedia = '/explore/lab-encyclopedia';
  static const String firstAid = '/explore/first-aid';
  static const String booksLibrary = '/explore/books-library';

  // Learn routes
  static const String courseReader = '/learn/course/:id';
  static const String specialtyCourses = '/learn/specialty/:specialtyName';
  static const String moduleLessons = '/learn/module/:id';

  static const String settings = '/settings';
  static const String statistics = '/statistics';
  static const String medicalCalculator = '/medical-calculator';
  static const String bmi = '/medical-calculator/bmi';
  static const String glasgow = '/medical-calculator/glasgow';
  static const String apgar = '/medical-calculator/apgar';
  static const String wells = '/medical-calculator/wells-pe';
  static const String cha2ds2vasc = '/medical-calculator/cha2ds2vasc';
  static const String generic = '/medical-calculator/generic/:id';
  static const String notificationSettings = '/settings/notifications';
  static const String fontSettings = '/settings/font-size';
  static const String srsSettings = '/settings/spaced-repetition';
  static const String notifications = '/notifications';
  static const String productiveBay = '/productive-bay';
  static const String medicalGames = '/explore/medical-games';
  static const String anatomyQuiz = '/explore/anatomy-quiz';
  static const String wordAssociation = '/explore/word-association';
  static const String diagnosisMystery = '/explore/diagnosis-mystery';
  static const String ecgHero = '/explore/ecg-hero';
  static const String pharmaMatch = '/explore/pharma-match';
  static const String labMaster = '/explore/lab-master';
  static const String medicalCrossword = '/explore/medical-crossword';
  static const String surgicalSim = '/explore/surgical-sim';

  // Productive Bay routes
  static const String studyGroups = '/productive-bay/study-groups';
  static const String studyGroupDetails = '/productive-bay/study-groups/:id';
  static const String quizGroupStudy = '/productive-bay/study-groups/:id/quiz';
  static const String planner = '/productive-bay/planner';
  static const String tasks = '/productive-bay/tasks';
  static const String analytics = '/productive-bay/analytics';
  static const String customizeBay = '/productive-bay/customize';
  static const String deepWork = '/productive-bay/deep-work';
  static const String subscription = '/subscription';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfUse = '/terms-of-use';
  static const String faq = '/settings/faq';
}
