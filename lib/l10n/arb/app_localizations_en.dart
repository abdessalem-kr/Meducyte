// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get all => 'All';

  @override
  String get sortBy => 'Sort by';

  @override
  String get nameAZ => 'Name (A-Z)';

  @override
  String get nameZA => 'Name (Z-A)';

  @override
  String get genericAZ => 'Generic (A-Z)';

  @override
  String get genericZA => 'Generic (Z-A)';

  @override
  String get filters => 'Filters';

  @override
  String get enrichedOnly => 'Enrichis seulement';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get noDrugsFound => 'No drugs found.';

  @override
  String get category => 'Category';

  @override
  String get onBoardingTitle => 'Learn Medicine Smarter';

  @override
  String get onBoardingDescription =>
      'Meducyte transforms the way you study with interactive tools, spaced repetition, and real clinical reasoning.';

  @override
  String get onBoardingConinueBtn => 'Continue';

  @override
  String get searchHint => 'Search for drugs, diseases...';

  @override
  String get search => 'Search';

  @override
  String get inProgress => 'IN PROGRESS';

  @override
  String get continueQuiz => 'Continue Quiz';

  @override
  String get quickAccess => 'Quick Access';

  @override
  String get quizTraining => 'Quiz Training';

  @override
  String get drugDatabase => 'Drug Database';

  @override
  String get drugInteractions => 'Drug Interactions';

  @override
  String get clinicalGuidelines => 'Clinical Guidelines';

  @override
  String get medicalAbbreviations => 'Medical Abbreviations';

  @override
  String get observationReport => 'Observation Report';

  @override
  String get clinicalCases => 'Clinical Cases';

  @override
  String get medicalCalculator => 'Medical Calculator';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String noResultsFound(Object query) {
    return 'No results found for \"$query\"';
  }

  @override
  String get settings => 'Settings';

  @override
  String get statistics => 'Statistics';

  @override
  String get medicalInsight => 'Medical Insight';

  @override
  String get refreshMemory => 'Refresh your memory';

  @override
  String get readArticle => 'Read Article';

  @override
  String get dailyGoal => 'Daily Goal';

  @override
  String get activity => 'Activity';

  @override
  String get viewStats => 'View Stats';

  @override
  String get viewDetails => 'View Details';

  @override
  String get accuracy => 'Accuracy';

  @override
  String get previous => 'Previous';

  @override
  String get verify => 'Verify';

  @override
  String get nextQuestion => 'Next Question';

  @override
  String get correct => 'Correct';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get partiallyCorrect => 'Partially Correct';

  @override
  String get explanation => 'Explanation';

  @override
  String get reportError => 'Report an Error';

  @override
  String get selectReason => 'Select a reason';

  @override
  String get reasonTypo => 'Typo / Spelling Error';

  @override
  String get reasonInaccurate => 'Inaccurate Information';

  @override
  String get reasonMissing => 'Missing Information';

  @override
  String get reasonUnclearExplanation => 'Unclear Explanation';

  @override
  String get reasonWrongAnswer => 'Wrong Correct Answer';

  @override
  String get reasonUnclear => 'Unclear Question/Options';

  @override
  String get reasonOther => 'Other';

  @override
  String get otherDescription => 'Briefly describe the error...';

  @override
  String get sendReport => 'Send Report';

  @override
  String get reportSent => 'Report Sent Successfully!';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get year => 'Year';

  @override
  String get specialty => 'Specialty';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully!';

  @override
  String get profileUpdateFailed => 'Failed to update profile';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get core => 'Core';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get language => 'Language';

  @override
  String get fontSize => 'Font Size';

  @override
  String get highContrast => 'High Contrast';

  @override
  String get userPreferences => 'User Preferences';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationSettingsTitle => 'Notification Settings';

  @override
  String get notificationSettingsInfo =>
      'Customize your alerts to stay focused on your goals without being interrupted.';

  @override
  String get globalNotifications => 'Global Notifications';

  @override
  String get productiveBayRemindersTitle => 'PRODUCTIVE BAY REMINDERS';

  @override
  String get examReminders => 'Exams';

  @override
  String get examRemindersDesc => 'Alerts 24h before your registered exams.';

  @override
  String get taskReminders => 'Tasks';

  @override
  String get taskRemindersDesc => 'Reminders 1h before your task deadlines.';

  @override
  String get studyReminders => 'Study Sessions';

  @override
  String get studyRemindersDesc =>
      'Notifications 10 min before a session starts.';

  @override
  String get communityNotifications => 'Community';

  @override
  String get communityNotificationsDesc =>
      'Replies to your comments and mentions.';

  @override
  String get systemSettingsPrompt =>
      'Notifications are disabled in system settings.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get fontSettingsTitle => 'Text & Display Size';

  @override
  String get fontSettingsDesc =>
      'Adjusting the text size helps improve readability. Changes will apply throughout the app.';

  @override
  String get fontPreviewTitle => 'Preview';

  @override
  String get fontPreviewText =>
      'Meducyte is an advanced learning platform tailored for medical students. It offers clinical cases, flashcards, and a dedicated workspace to enhance your practical knowledge.';

  @override
  String get fontSmall => 'Small';

  @override
  String get fontMedium => 'Medium (Default)';

  @override
  String get fontLarge => 'Large';

  @override
  String get quizFontSizeTitle => 'Quiz Text Size';

  @override
  String get courseFontSizeTitle => 'Course Text Size';

  @override
  String get shareQuestion => 'Share Question';

  @override
  String get textSize => 'Text Size';

  @override
  String get syncSettings => 'Sync Settings';

  @override
  String get spacedRepetition => 'Spaced Repetition';

  @override
  String get studyPlan => 'Study Plan';

  @override
  String get downloadMode => 'Download Mode';

  @override
  String get advancedAbout => 'Advanced / About';

  @override
  String get securityPrivacy => 'Security & Privacy';

  @override
  String get resetData => 'Reset All Data';

  @override
  String get resetDataSubtitle => 'Clear all settings and local cache';

  @override
  String get resetDataWarning =>
      'This will clear all local settings, cached content, and logout of your account. This action cannot be undone.';

  @override
  String get deleteAccountTitle => 'Delete My Account';

  @override
  String get deleteAccountSubtitle =>
      'Permanently remove your account and data';

  @override
  String get deleteAccountWarning =>
      'WARNING: This action is permanent and will delete all your study progress, quiz history, and subscriptions. You cannot undo this.';

  @override
  String get deleteConfirmationInstruction =>
      'To confirm, please type \'DELETE\' below:';

  @override
  String get deleteConfirmationHint => 'Type DELETE here';

  @override
  String get dataResetSuccess =>
      'All local data has been successfully cleared.';

  @override
  String get accountDeletedSuccess =>
      'Your account has been permanently deleted.';

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Privacy Policy & Terms';

  @override
  String get support => 'Customer Support';

  @override
  String get rateUs => 'Rate Us';

  @override
  String get rateUsTitle => 'How are we doing?';

  @override
  String get rateUsSubtitle =>
      'Your feedback helps us make Meducyte better for all medical students.';

  @override
  String get rateOnStore => 'Rate on App Store';

  @override
  String get rateFeedback => 'Send Feedback';

  @override
  String get subscription => 'Subscription';

  @override
  String get basicPlan => 'Basic';

  @override
  String get premiumPlan => 'Premium';

  @override
  String get comparePlans => 'Compare Plans';

  @override
  String get featureAcademicModules => 'Academic Modules';

  @override
  String get featureAiAssistant => 'AI Smart Assistant';

  @override
  String get featureClinicalCases => 'Clinical Cases';

  @override
  String get featureAdvancedStats => 'Advanced Statistics';

  @override
  String get logout => 'Logout';

  @override
  String get saveQuiz => 'Save Quiz';

  @override
  String get saveToCollection => 'Save to Collection';

  @override
  String get createCollection => 'Create Collection';

  @override
  String get renameCollection => 'Rename Collection';

  @override
  String get collectionName => 'Collection Name';

  @override
  String get quizSaved => 'Quiz saved successfully!';

  @override
  String get myCollections => 'My Collections';

  @override
  String get searchCollections => 'Search collections...';

  @override
  String get highlight => 'Highlight';

  @override
  String get addNote => 'Add Note';

  @override
  String get chooseColor => 'Choose Color';

  @override
  String get saveNote => 'Save Note';

  @override
  String get editNote => 'Edit Note';

  @override
  String get editComment => 'Edit Comment';

  @override
  String get cancel => 'Cancel';

  @override
  String get interactionSpace => 'Interaction Space';

  @override
  String get commentsFeed => 'Comments Feed';

  @override
  String get myNotes => 'My Notes';

  @override
  String get noComments => 'No comments yet. Start the conversation!';

  @override
  String get noNotes => 'You haven\'t added any notes to this section yet.';

  @override
  String get addPublicComment => 'Add a public comment...';

  @override
  String get selectionReminder => 'Selection Reminder:';

  @override
  String get myNote => 'My Note:';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get edited => 'Edited';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get deleteCommentConfirm =>
      'Are you sure you want to delete this comment?';

  @override
  String get questionInfo => 'Question Info';

  @override
  String get source => 'Source';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get navHome => 'Home';

  @override
  String get navLearn => 'Learn';

  @override
  String get navExplore => 'Explore';

  @override
  String get navSimulation => 'Simulation';

  @override
  String get productiveBay => 'Productive Bay';

  @override
  String get focusFatigueAnalysis => 'Focus & Fatigue Analysis (AI)';

  @override
  String get dashboardHub => 'Dashboard Hub';

  @override
  String get deepWorkMode => 'Deep Work Mode';

  @override
  String get examCountdown => 'Exam Countdown';

  @override
  String get aiPlanner => 'AI Planner';

  @override
  String get planner => 'Planner';

  @override
  String get myTasks => 'My Tasks';

  @override
  String urgentTasksCount(Object count) {
    return '$count Urgent Tasks';
  }

  @override
  String get analytics => 'Analytics';

  @override
  String get studyPatterns => 'Study Patterns';

  @override
  String get groups => 'Groups';

  @override
  String get studyTogether => 'Study Together';

  @override
  String get deepWork => 'DEEP WORK';

  @override
  String get shortBreak => 'SHORT BREAK';

  @override
  String get longBreak => 'LONG BREAK';

  @override
  String get start => 'Start';

  @override
  String get none => 'None';

  @override
  String get forest => 'Forest';

  @override
  String get rain => 'Rain';

  @override
  String get waves => 'Waves';

  @override
  String focusOn(Object task) {
    return 'Focus: $task';
  }

  @override
  String get taskListTitle => 'My Task List';

  @override
  String get newTask => 'New Focus Task';

  @override
  String get whatWillYouAchieve => 'What will you achieve?';

  @override
  String get priority => 'Priority';

  @override
  String get estimatedWork => 'Work Estimation';

  @override
  String get addToList => 'Add to My List';

  @override
  String get jumpToQuestion => 'Jump to Question';

  @override
  String get finishQuiz => 'Finish Quiz';

  @override
  String get quizResult => 'Quiz Result';

  @override
  String get score => 'Score';

  @override
  String get correctAnswer => 'Correct Answer';

  @override
  String get clinicalCase => 'Clinical Case';

  @override
  String get correctAnswers => 'Correct';

  @override
  String get incorrectAnswers => 'Incorrect';

  @override
  String get partiallyCorrectAnswers => 'Partial';

  @override
  String get reviewErrors => 'Review Errors';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get keepImproving => 'Keep improving your score!';

  @override
  String get startQuiz => 'Start Quiz';

  @override
  String get startRevision => 'Start Revision';

  @override
  String get numberOfQuestions => 'Number of Questions';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get expert => 'Expert';

  @override
  String get practice => 'PRACTICE';

  @override
  String get simulation => 'REAL EXAM SIMULATION';

  @override
  String get theoretical => 'THEORETICAL';

  @override
  String get clinical => 'CLINICAL';

  @override
  String get explore => 'EXPLORE';

  @override
  String get exploreRevision => 'Revise Directly';

  @override
  String get simulationSubtitle => 'Real Exam Environment';

  @override
  String get finishRevision => 'Finish Revision';

  @override
  String get studyYear => 'Study Year';

  @override
  String get chapters => 'Chapters';

  @override
  String get lessons => 'Lessons';

  @override
  String get lesson => 'Lesson';

  @override
  String get module => 'Module';

  @override
  String get unitOfIntegratedTeaching => 'Integrated Teaching Unit';

  @override
  String get lessonCompleted => 'Lesson Completed!';

  @override
  String get finishLesson => 'Finish Lesson';

  @override
  String get lessonCompletedSub =>
      'Congratulations! You\'ve mastered this lesson.';

  @override
  String get finishLessonSub =>
      'Ready to move on? Mark this lesson as studied.';

  @override
  String get markAsUnstudied => 'Mark as unstudied';

  @override
  String get markAsStudied => 'Mark as studied';

  @override
  String get chatbotTitle => 'Meducyte AI';

  @override
  String get online => 'Online';

  @override
  String get newChat => 'New Chat';

  @override
  String get history => 'History';

  @override
  String get deleteChat => 'Delete Chat';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get askMedicalQuestion => 'Ask a medical question...';

  @override
  String get chatbotDescription => 'Your Clinical Assistant';

  @override
  String get askYourQuestion => 'Ask your question...';

  @override
  String get chatbotError => 'Something went wrong. Please try again.';

  @override
  String get chatSuggestion1 => 'How can you help me study?';

  @override
  String get chatSuggestion2 => 'Explain a complex medical concept';

  @override
  String get chatSuggestion3 => 'Summarize a pathology for me';

  @override
  String get chatSuggestion4 => 'Tell me about drug indications';

  @override
  String get chatHistory => 'Chat History';

  @override
  String get noHistoryFound => 'No chat history found.';

  @override
  String get databaseStatus => 'Database Status';

  @override
  String get registeredDrugs => 'Registered Drugs';

  @override
  String get uniqueDrugPrincipals => 'Unique Active Ingredients';

  @override
  String get enrichedClinicalInfos => 'Enriched Clinical Info';

  @override
  String get close => 'Close';

  @override
  String get databaseStatistics => 'Database Statistics';

  @override
  String get enrichedOnlySubtitle =>
      'Show only drugs with full clinical details';

  @override
  String get therapeuticClass => 'Therapeutic Class';

  @override
  String get allClasses => 'All Classes';

  @override
  String get errorLoadingData => 'Error loading data.';

  @override
  String get general => 'General';

  @override
  String get administrativeInfos => 'Admin Details';

  @override
  String get labAndForm => 'Lab & Form';

  @override
  String get therapeuticIndications => 'Therapeutic Indications';

  @override
  String get contraindications => 'Contraindications';

  @override
  String get sideEffects => 'Side Effects';

  @override
  String get mechanismOfAction => 'Mechanism of Action';

  @override
  String get clinicalInfoUpdating => 'Clinical info is updated daily...';

  @override
  String get drugNotFound => 'Drug not found';

  @override
  String get selectedDrugs => 'Selected Drugs';

  @override
  String get addDrug => 'Add Drug';

  @override
  String get noDrugsSelectedPrompt =>
      'Select at least two drugs to see interactions.';

  @override
  String get selectTwoDrugsPrompt =>
      'Select at least two drugs to see interactions.';

  @override
  String get noInteractionsFound =>
      'No known interactions found between selected drugs.';

  @override
  String get management => 'Management:';

  @override
  String get addDrugToChecker => 'Add Drug to Checker';

  @override
  String get searchDrugHint => 'Search for a drug...';

  @override
  String get severe => 'Severe';

  @override
  String get moderate => 'Moderate';

  @override
  String get minor => 'Minor';

  @override
  String get spec_general => 'General Practice';

  @override
  String get spec_cardiology => 'Cardiology';

  @override
  String get spec_neurology => 'Neurology';

  @override
  String get spec_anesthesiereanimation => 'Anesthesia and Recovery';

  @override
  String get spec_anesthesiereanimationpediatrique => 'Pediatric Anesthesia';

  @override
  String get spec_biophysiquemedicale => 'Medical Biophysics';

  @override
  String get spec_dermatologieetvenereologie => 'Dermatology and Venereology';

  @override
  String get spec_diabetologieendocrinologieetmaladiesmetaboliques =>
      'Endocrinology, Diabetes, and Metabolism';

  @override
  String get spec_epidemiologieetmedecinepreventive =>
      'Epidemiology and Preventive Medicine';

  @override
  String get spec_hepatogastroenterologie => 'Hepato-Gastro-Enterology';

  @override
  String get spec_hematologie => 'Hematology';

  @override
  String get spec_gynecologieobstetrique => 'Gynecology and Obstetrics';

  @override
  String get spec_infectiologie => 'Infectious Diseases';

  @override
  String get spec_medecineinterne => 'Internal Medicine';

  @override
  String get spec_medecinelegaledroitmedicaletethique =>
      'Legal Medicine and Medical Ethics';

  @override
  String get spec_medecinenucleaireetimageriemoleculaire =>
      'Nuclear Medicine and Molecular Imaging';

  @override
  String get spec_medecinedusport => 'Sports Medicine';

  @override
  String get spec_medecinedutravail => 'Occupational Medicine';

  @override
  String get spec_medecinephysiqueetreadaptation =>
      'Physical Medicine and Rehabilitation';

  @override
  String get spec_nephrologie => 'Nephrology';

  @override
  String get spec_oncologiemedicale => 'Medical Oncology';

  @override
  String get spec_ophtalmologie => 'Ophthalmology';

  @override
  String get spec_orl => 'ENT (Otolaryngology)';

  @override
  String get spec_pediatrie => 'Pediatrics';

  @override
  String get spec_psychiatrie => 'Psychiatrie';

  @override
  String get spec_pedopsychiatrie => 'Pédopsychiatrie';

  @override
  String get spec_pneumophtisiologie => 'Pulmonology and Phthisiology';

  @override
  String get spec_radiotherapieoncologie => 'Radiation Oncology';

  @override
  String get spec_rhumatologie => 'Rheumatology';

  @override
  String get spec_reanimationmedicale => 'Medical Intensive Care';

  @override
  String get spec_chirurgiegenerale => 'General Surgery';

  @override
  String get spec_chirurgiecardiaque => 'Cardiac Surgery';

  @override
  String get spec_chirurgiemaxillofaciale => 'Maxillofacial Surgery';

  @override
  String get spec_chirurgieneurologique => 'Neurosurgery';

  @override
  String get spec_chirurgieorthopediqueettraumatologie =>
      'Orthopedic Surgery and Traumatology';

  @override
  String get spec_chirurgiepediatrique => 'Pediatric Surgery';

  @override
  String get spec_chirurgiethoracique => 'Thoracic Surgery';

  @override
  String get spec_chirurgieurologique => 'Urological Surgery';

  @override
  String get spec_chirurgievasculaire => 'Vascular Surgery';

  @override
  String get spec_chirurgieplastiquereconstructriceesthetiqueetdebrulologie =>
      'Plastic, Reconstructive, and Aesthetic Surgery';

  @override
  String get spec_pulmonology => 'Pulmonology';

  @override
  String get spec_endocrinology => 'Endocrinology';

  @override
  String get spec_surgery => 'Surgery';

  @override
  String get spec_orthopedics => 'Orthopedics';

  @override
  String get spec_urology => 'Urology';

  @override
  String get spec_radiology => 'Radiology';

  @override
  String get spec_pathology => 'Pathology';

  @override
  String get spec_emergency => 'Emergency Medicine';

  @override
  String get selectSpecialty => 'Select Specialty';

  @override
  String get chooseTemplateDescription =>
      'Choose a template tailored to your medical specialty for faster reporting.';

  @override
  String get addParameter => 'Add a parameter';

  @override
  String get parameterNameHint => 'Parameter name (e.g. CK-MB)';

  @override
  String get addExam => 'Add an exam:';

  @override
  String get pendingOrNotProvided => '- *Pending / Not provided*';

  @override
  String get enterResultHint => 'Enter the result...';

  @override
  String get selectExamHint => 'Choose an exam';

  @override
  String get observationHistory => 'History';

  @override
  String get save => 'Save';

  @override
  String get noSavedReports => 'No saved reports found.';

  @override
  String get deleteReportConfirm =>
      'Are you sure you want to delete this report?';

  @override
  String get reportSaved => 'Report saved successfully!';

  @override
  String get loadReport => 'Load Report';

  @override
  String get searchPatients => 'Search patients...';

  @override
  String get gender => 'Gender';

  @override
  String get gender_male => 'Male';

  @override
  String get gender_female => 'Female';

  @override
  String get intro_patient_name_hint => 'Patient Name';

  @override
  String get intro_age_hint => 'Age';

  @override
  String get intro_origin_hint => 'City / Neighborhood';

  @override
  String get intro_marital_status_hint => 'Marital Status';

  @override
  String get intro_profession_hint => 'Profession';

  @override
  String get intro_date_hint => 'DD/MM/YYYY';

  @override
  String get intro_signs_hint => 'Clinical Signs';

  @override
  String get intro_patient_prefix => 'Patient';

  @override
  String get intro_age_label_masculine => 'years old';

  @override
  String get intro_age_label_feminine => 'years old';

  @override
  String get intro_age_prefix => ', ';

  @override
  String get intro_origin_prefix => ' residing in ';

  @override
  String get intro_admitted_masculine => 'admitted on';

  @override
  String get intro_admitted_feminine => 'admitted on';

  @override
  String get intro_date_prefix => ' ';

  @override
  String get intro_for_prefix => ' for: ';

  @override
  String get section_introduction => 'Introduction';

  @override
  String get section_motif => 'Reason for Admission';

  @override
  String get section_history => 'History of the Illness';

  @override
  String get section_antecedents => 'Medical History';

  @override
  String get section_general_vitals => 'Clinical Exam - General State & Vitals';

  @override
  String get section_paraclinical => 'Paraclinical Exams';

  @override
  String get section_summary => 'Syndromic Summary';

  @override
  String get section_conclusion => 'Conclusion / Management Plan';

  @override
  String get vitals_bp => 'BP';

  @override
  String get vitals_hr => 'HR';

  @override
  String get vitals_rr => 'RR';

  @override
  String get vitals_temp => 'Temp';

  @override
  String get vitals_spo2 => 'SpO2';

  @override
  String get addCustomSection => 'Add custom section';

  @override
  String get exam_general_state_label => 'Global Impression / General State';

  @override
  String get exam_general_state_hint =>
      'Good general state, conscious, cooperative, well-oriented';

  @override
  String get exam_hydration_label => 'Hydration and Nutrition';

  @override
  String get exam_hydration_hint =>
      'No dehydration fold, BMI within normal range';

  @override
  String get exam_head_neck_label => 'Head and Neck Exam';

  @override
  String get exam_head_neck_hint =>
      'Pink conjunctiva, no icterus, healthy oral cavity';

  @override
  String get exam_respiratory_label => 'Respiratory / Pulmonary Exam';

  @override
  String get exam_respiratory_hint =>
      'Vesicular murmur present and symmetrical';

  @override
  String get exam_cardio_label => 'Cardiovascular Exam';

  @override
  String get exam_cardio_hint => 'Regular heart sounds, no murmur';

  @override
  String get exam_abdominal_label => 'Abdominal Exam';

  @override
  String get exam_abdominal_hint => 'Soft abdomen, depressible, painless';

  @override
  String get exam_urogenital_label => 'Urogenital Exam';

  @override
  String get exam_urogenital_hint => 'Free lumbar pits';

  @override
  String get exam_locomotor_label => 'Locomotor / Joint Exam';

  @override
  String get exam_locomotor_hint =>
      'Full range of motion, no inflammatory signs';

  @override
  String get exam_neuro_mental_label => 'Neurological / Mental Exam';

  @override
  String get exam_neuro_mental_hint =>
      'Full strength and sensation, no meningeal signs';

  @override
  String get exam_skin_label => 'Skin / Dermatological Exam';

  @override
  String get exam_skin_hint => 'No suspicious lesions, no purpura';

  @override
  String get exam_cardio_edema_label => 'Inspection: Edema';

  @override
  String get exam_cardio_edema_hint => 'Absent';

  @override
  String get exam_cardio_cyanosis_label => 'Inspection: Cyanosis';

  @override
  String get exam_cardio_cyanosis_hint => 'Absent';

  @override
  String get exam_neuro_glasgow_label => 'Consciousness (Glasgow)';

  @override
  String get exam_neuro_glasgow_hint => '15/15';

  @override
  String get exam_neuro_orient_label => 'Orientation';

  @override
  String get exam_neuro_orient_hint => 'Well-oriented';

  @override
  String get yourJourney => 'Your Journey';

  @override
  String get noModulesForYear => 'No modules found for this year.';

  @override
  String get accessContent => 'Access Content';

  @override
  String get quickTraining => 'Quick Training';

  @override
  String get readingInProgress => 'Reading in Progress';

  @override
  String get firstYearOrdinal => '1st Year';

  @override
  String otherYearOrdinal(Object year) {
    return '${year}th Year';
  }

  @override
  String get noLessonsAvailable => 'No lessons available.';

  @override
  String get loading => 'Loading...';

  @override
  String get modules => 'Modules';

  @override
  String get quizzes => 'Quizzes';

  @override
  String get upgradeToResidencyToUnlockYears =>
      'Upgrade to Residency plan to unlock these years!';

  @override
  String get studyTools => 'Study Tools';

  @override
  String get performanceStats => 'Performance Stats';

  @override
  String get accuracyLabel => 'Accuracy';

  @override
  String get streakLabel => 'Streak';

  @override
  String daysLabel(Object days) {
    return '$days Days';
  }

  @override
  String get reviseSubtitle => 'By module or specialty';

  @override
  String get simulateSubtitle => 'Real exam environment';

  @override
  String get revisionModeSubtitle => 'Read and revise content';

  @override
  String get questionDetails => 'Question Details';

  @override
  String get noQuestionsFound => 'No questions found.';

  @override
  String get selectPrompt => 'Select';

  @override
  String get deleteHighlight => 'Remove Highlight';

  @override
  String get editNoteLabel => 'Edit Note';

  @override
  String get flashcards => 'Flashcards';

  @override
  String get notes => 'Notes';

  @override
  String get savedQuizzes => 'Saved Quizzes';

  @override
  String get residencyExam => 'Residency Exam';

  @override
  String get allOrNothingScore => 'All or\nNothing';

  @override
  String get partialPointsScore => 'Partial\nPoints';

  @override
  String get unsaveQuestion => 'Unsave Question';

  @override
  String get unsaveQuestionConfirmation =>
      'Are you sure you want to unsave this question?';

  @override
  String get confirm => 'Confirm';

  @override
  String questionsCount(Object count) {
    return '$count questions';
  }

  @override
  String get voiceReader => 'Voice Reader';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get stop => 'Stop';

  @override
  String get speed => 'Speed';

  @override
  String get print => 'Print';

  @override
  String get voiceSettings => 'Voice Settings';

  @override
  String get aiHelper => 'AI Helper';

  @override
  String get explain => 'Explain';

  @override
  String get summarize => 'Summarize';

  @override
  String get mnemonic => 'Mnemonic';

  @override
  String get refine => 'Refine';

  @override
  String get printLesson => 'Print Lesson';

  @override
  String get generatingPdf => 'Generating PDF...';

  @override
  String get paragraph => 'Paragraph';

  @override
  String get sq3rTechnique => 'SQ3R Technique';

  @override
  String get activeRecall => 'Active Recall';

  @override
  String get moreTools => 'More Tools';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get reportQuestion => 'Report Question';

  @override
  String get quizHub => 'Quiz Hub';

  @override
  String get studyDecks => 'STUDY DECKS';

  @override
  String get savedQuizzesSubtitle => 'Study your personally saved questions';

  @override
  String get spacedRepetitionSubtitle => 'Focus on cards due for review';

  @override
  String get byModule => 'By Module';

  @override
  String get byModuleSubtitle => 'Generate cards from specific modules';

  @override
  String get masterYourMemory => 'Master Your Memory';

  @override
  String get flashcardsHeaderSubtitle =>
      'Convert any question into a flashcard and use spaced repetition to never forget.';

  @override
  String get noSavedQuestionsToStudy => 'No saved questions found to study.';

  @override
  String get errorLoadingQuestions => 'Error loading questions';

  @override
  String get allCaughtUp => 'All caught up! No cards due for review.';

  @override
  String get noCardsToStudy => 'No cards to study.';

  @override
  String get showAnswerToGrade => 'Show the answer to grade yourself';

  @override
  String get howWellDidYouRecall => 'HOW WELL DID YOU RECALL THIS?';

  @override
  String get studyComplete => 'STUDY COMPLETE';

  @override
  String studySummary(Object count, Object time) {
    return 'You have reviewed $count cards in $time';
  }

  @override
  String get questionLabel => 'QUESTION';

  @override
  String get tapToFlip => 'TAP TO FLIP';

  @override
  String get correctAnswerLabel => 'CORRECT ANSWER';

  @override
  String get clinicalContext => 'CLINICAL CONTEXT';

  @override
  String get nowGradeYourRecall => 'NOW GRADE YOUR RECALL';

  @override
  String get performanceAgain => 'AGAIN';

  @override
  String get performanceHard => 'HARD';

  @override
  String get performanceGood => 'GOOD';

  @override
  String get performanceEasy => 'EASY';

  @override
  String get folders => 'Folders';

  @override
  String get studyByFolder => 'Study questions from a specific folder';

  @override
  String get selectModule => 'Select Module';

  @override
  String get selectFolder => 'Select Folder';

  @override
  String get startNewQuiz => 'Start a new quiz';

  @override
  String get noActiveQuiz => 'No quiz in progress';

  @override
  String get checkBackTomorrow => 'Check back tomorrow for new reviews.';

  @override
  String get srsEmptyTitle => 'Your SRS list is empty';

  @override
  String get srsEmptySubtitle =>
      'Add questions to spaced repetition during your quiz sessions to start your journey.';

  @override
  String get learningLabel => 'Learning';

  @override
  String get masteredLabel => 'Mastered';

  @override
  String get totalLabel => 'Total';

  @override
  String get dueToday => 'DUE TODAY';

  @override
  String startReviewCount(Object count) {
    return 'START REVIEW ($count)';
  }

  @override
  String get srsDueTitle => 'Spaced Repetition';

  @override
  String cardsDueText(Object count) {
    return 'You have $count cards due for review';
  }

  @override
  String get startReview => 'Start Review';

  @override
  String get sessionComplete => 'Session Complete';

  @override
  String get greatJob => 'Great job!';

  @override
  String completionTime(Object time) {
    return 'You completed your review in $time';
  }

  @override
  String get finish => 'FINISH';

  @override
  String get resetProgressTitle => 'Reset Progress?';

  @override
  String get resetProgressSubtitle =>
      'This will permanently delete all your SRS review data. This action cannot be undone.';

  @override
  String get srsReset => 'RESET';

  @override
  String get srsResetSuccess => 'SRS progress has been reset.';

  @override
  String get srsSettingsTitle => 'SRS Settings';

  @override
  String get srsSettingsInfo =>
      'Customize your learning pace and review reminders.';

  @override
  String get srsNewCardsTitle => 'New Cards per Day';

  @override
  String get srsNewCardsDesc =>
      'Control how many new questions are introduced daily.';

  @override
  String get srsReviewLimitTitle => 'Daily Review Limit';

  @override
  String get srsReviewLimitDesc =>
      'Maximum number of cards to review in a single day.';

  @override
  String get srsNotificationTitle => 'Review Reminders';

  @override
  String get srsNotificationDesc =>
      'Get notified when you have cards due for review.';

  @override
  String get srsNotificationTimeTitle => 'Reminder Time';

  @override
  String get addedToSrs => 'Added to Spaced Repetition';

  @override
  String get errorLoadingQuestionsShort => 'Error loading questions';

  @override
  String get noQuestionsInModule => 'No questions found for this module';

  @override
  String get noQuestionsInFolder => 'No questions in this folder';

  @override
  String get premiumContent => 'Premium Content';

  @override
  String get unlockPremiumDescription =>
      'This feature is part of our premium content. Subscribe now to get full access!';

  @override
  String get discoverPlans => 'Discover Plans';

  @override
  String get maybeLater => 'Maybe Later';

  @override
  String get testFeatures => 'Test Features';

  @override
  String get selectBestOption => 'Select the best option';

  @override
  String get correctionMode => 'Correction Mode';

  @override
  String get instantCorrection => 'Instant Correction';

  @override
  String get instantCorrectionDesc =>
      'See results immediately after each question';

  @override
  String get deferredCorrection => 'Deferred Correction';

  @override
  String get deferredCorrectionDesc =>
      'See results only after finishing the quiz';

  @override
  String get personalNote => 'Personal Note';

  @override
  String get communityComments => 'Community Comments';

  @override
  String get saveQuestion => 'Save Question';

  @override
  String get removeFromSrs => 'Remove from Spaced Repetition';

  @override
  String get removedFromSrs => 'Removed from Spaced Repetition';

  @override
  String get exploreDescription =>
      'Discover resources, clinical tools, and our global medical community.';

  @override
  String get medicalWorld => 'Medical World';

  @override
  String get externalResources => 'Resources & Community';

  @override
  String get interpretationHelpers => 'Interpretation Helpers';

  @override
  String get caseOfTheDay => 'Case of the Day';

  @override
  String get medicalNews => 'Medical News';

  @override
  String get clinicalPearls => 'Clinical Pearls';

  @override
  String get quickCalcHub => 'Quick Calculators';

  @override
  String get joinOfficialDrive => 'Join Official Drive';

  @override
  String get joinTelegram => 'Join Telegram Community';

  @override
  String get booksLibrary => 'Medical Books';

  @override
  String get booksLibraryDesc => 'Download medical books and manuals';

  @override
  String get firstAid => 'First Aid';

  @override
  String get firstAidDesc => 'Life-saving techniques and emergencies';

  @override
  String get ecgInterpretation => 'ECG Interpretation Helper';

  @override
  String get radiologyHelper => 'Radiology Guide (Chest X-Ray)';

  @override
  String get labInterpretation => 'Laboratory Interpretation Helper';

  @override
  String get simulationDescription =>
      'Practice medicine in a safe environment.';

  @override
  String get aiPatientInteraction => 'AI Patient Interaction';

  @override
  String get ecosExamSimulator => 'ECOS Exam Simulator';

  @override
  String get emergencyRoomChallenge => 'Emergency Room Challenge';

  @override
  String get virtualWardRounds => 'Virtual Ward Rounds';

  @override
  String get diagnosticChallenge => 'Diagnostic Challenge';

  @override
  String get proceduralGuide => 'Procedural Simulator';

  @override
  String get globalLeaderboards => 'Global Leaderboards';

  @override
  String get aiPatientDesc => 'Interact with AI patients';

  @override
  String get ecosDesc => 'Prepare for clinical exams';

  @override
  String get erChallengeDesc => 'Manage medical emergencies';

  @override
  String get wardRoundsDesc => 'Manage your own ward';

  @override
  String get diagnosticChallengeDesc => 'Master medical imaging';

  @override
  String get proceduralGuideDesc => 'Learn clinical procedures';

  @override
  String get leaderboardsDesc => 'Challenge other students';

  @override
  String get coreSimulations => 'Core Simulations';

  @override
  String get specializedExams => 'Specialized Exams';

  @override
  String get driveDescription => 'Thousands of medical documents';

  @override
  String get telegramDescription => 'Join our active community';

  @override
  String get caseOfDayDescription => 'Daily clinical reasoning';

  @override
  String get medicalNewsDescription => 'Latest medical breakthroughs';

  @override
  String get clinicalPearlsDescription => 'Daily medical tips and tricks';

  @override
  String get calcHubDescription => 'Essential medical calculators';

  @override
  String get interactiveLearning => 'Interactive Learning';

  @override
  String get questionNavigation => 'Question Navigation';

  @override
  String get correction => 'Correction';

  @override
  String get ecgInterpretationReport => 'ECG Interpretation Report';

  @override
  String get ecgAnalysisReport => 'ECG ANALYSIS REPORT';

  @override
  String get ecgCase => 'Case';

  @override
  String get ecgAiActive => 'AI ACTIVE';

  @override
  String get ecgHeartRate => 'HEART RATE';

  @override
  String get ecgQtcInterval => 'QTC INTERVAL';

  @override
  String get ecgRhythmAnalysis => 'RHYTHM ANALYSIS';

  @override
  String get ecgAiConfidence => 'AI CONFIDENCE';

  @override
  String get ecgLeadClinicalGrid => '12-LEAD CLINICAL GRID';

  @override
  String get ecgGuidedInterpretation => 'Guided Interpretation Checklist';

  @override
  String get ecgShareReport => 'Share Report';

  @override
  String get ecgEducationalTool => 'Educational Tool Only';

  @override
  String get ecgEducationalToolDesc =>
      'This interactive guide is designed strictly for medical trainees. It is NOT a certified medical device and must never be used for clinical diagnosis.';

  @override
  String get ecgSourceTitle => 'ECG Reference Source';

  @override
  String get ecgSourceCamera => 'Camera';

  @override
  String get ecgSourceGallery => 'Gallery';

  @override
  String get ecgSourceDraw => 'Draw';

  @override
  String get ecgSourceClear => 'Clear Image';

  @override
  String get ecgStatusNormal => 'NORMAL';

  @override
  String get ecgStatusStable => 'STABLE';

  @override
  String get ecgStatusClear => 'CLEAR';

  @override
  String get ecgStatusIschemia => 'ISCHEMIA';

  @override
  String get ecgChapterRateRhythm => '1. Rate & Rhythm';

  @override
  String get ecgChapterAxisIntervals => '2. Axis & Intervals';

  @override
  String get ecgChapterIschemiaInfarction => '3. Ischemia & Infarctus';

  @override
  String get ecgChapterHypertrophyConduction => '4. Hypertrophy & Conduction';

  @override
  String get ecgChapterPatternRecognition => '5. Pattern Recognition';

  @override
  String get ecgChapterClinicalCorrelation => '6. Clinical Correlation';

  @override
  String get ecgRrCalculator => 'Heart Rate Calculator (Regular Rhythm)';

  @override
  String get ecgSmallSquares => 'Small Squares (R-R)';

  @override
  String get ecgQtcCalculator => 'QTc Bazett Calculator';

  @override
  String get ecgQtInterval => 'QT Interval (Small Squares)';

  @override
  String get ecgProlonged => 'Prolonged';

  @override
  String get ecgNormal => 'Normal';

  @override
  String get ecgLeadI => 'Lead I';

  @override
  String get ecgLeadaVF => 'Lead aVF';

  @override
  String get ecgPositive => 'Positive (+)';

  @override
  String get ecgNegative => 'Negative (-)';

  @override
  String get ecgEquivocal => 'Equivocal';

  @override
  String get ecgTerritoryLateral => 'Lateral';

  @override
  String get ecgTerritoryInferior => 'Inferior';

  @override
  String get ecgTerritorySeptal => 'Septal';

  @override
  String get ecgTerritoryAnterior => 'Anterior';

  @override
  String get ecgTerritoryReciprocal => 'Reciprocal';

  @override
  String get ecgAbnormalLeadsDetected => 'Abnormalities detected in leads';

  @override
  String get ecgCheckRhythmRegular => 'Is the rhythm regular?';

  @override
  String get ecgCheckRhythmRegularDesc =>
      'Check if the distance between consecutive R waves is consistent.';

  @override
  String get ecgCheckPWave => 'Is there a P wave before every QRS?';

  @override
  String get ecgCheckPWaveDesc =>
      'Confirms rhythm originated in the Sinus Node.';

  @override
  String get ecgLeadIDirection => 'Lead I (QRS direction)';

  @override
  String get ecgLeadaVFDirection => 'Lead aVF (QRS direction)';

  @override
  String get ecgCurrentAxis => 'Current Axis';

  @override
  String get ecgCheckStElevation => 'ST Elevation > 1mm?';

  @override
  String get ecgCheckStElevationDesc =>
      'Look for J-point elevation in contiguous leads.';

  @override
  String get ecgCheckStDepression => 'ST Depression?';

  @override
  String get ecgCheckStDepressionDesc =>
      'Significant if horizontal or down-sloping > 0.5mm.';

  @override
  String get ecgCheckTWaveInversion => 'T-Wave Inversion?';

  @override
  String get ecgCheckTWaveInversionDesc =>
      'Symmetrical inversion in V1-V6 suggests ischemia.';

  @override
  String get ecgCheckQrsWide => 'QRS > 120ms (3 small sq)?';

  @override
  String get ecgCheckQrsWideDesc => 'Consider Bundle Branch Blocks.';

  @override
  String get ecgCheckSokolow => 'Sokolow-Lyon Criteria?';

  @override
  String get ecgCheckSokolowDesc => 'S in V1 + R in V5/V6 > 35mm suggests LVH.';

  @override
  String get ecgCheckHyperkalemia => 'Hyperkalemia Patterns?';

  @override
  String get ecgCheckHyperkalemiaDesc =>
      'Peaked T-waves, flattened P-waves, wide QRS.';

  @override
  String get ecgCheckPe => 'Pulmonary Embolism (S1Q3T3)?';

  @override
  String get ecgCheckPeDesc => 'Deep S in I, Q in III, inverted T in III.';

  @override
  String get ecgCheckBrugada => 'Brugada Pattern?';

  @override
  String get ecgCheckBrugadaDesc =>
      'Coved ST elevation followed by inverted T in V1-V2.';

  @override
  String get ecgCheckChestPain => 'Chest Pain / Dyspnea?';

  @override
  String get ecgCheckChestPainDesc =>
      'Symptoms must correlate with ECG findings.';

  @override
  String get ecgCheckPreviousEcg => 'Previous ECG available?';

  @override
  String get ecgCheckPreviousEcgDesc =>
      'Comparison is key to identifying acute changes.';

  @override
  String get ecgChapterPWavePr => '3. P Wave & PR Interval';

  @override
  String get ecgChapterQrs => '4. QRS Complex';

  @override
  String get ecgChapterStTWave => '5. ST Segment & T Wave';

  @override
  String get ecgChapterQtInterval => '6. QT Interval (QTc)';

  @override
  String get ecgChapterBlockHypertrophy => '7. Bundle Branch & Hypertrophy';

  @override
  String get ecgChapterTerritories => '8. Infarction Territories';

  @override
  String get ecgChapterElectrolytes => '9. Electrolytes & ECG';

  @override
  String get ecgStatusAnalyzed => 'ANALYZED';

  @override
  String get ecgStatusNoIschemia => 'NO ISCHEMIA';

  @override
  String get ecgStatusAbsent => 'ABSENT';

  @override
  String get ecgStatusUnremarkable => 'UNREMARKABLE';

  @override
  String get ecgPWaveLeadII => 'P Wave (Lead II)';

  @override
  String get ecgCheckPMitrale => 'P wave duration < 120ms (3 small sq)?';

  @override
  String get ecgCheckPMitraleDesc =>
      'Long duration suggests left atrial enlargement (P mitrale).';

  @override
  String get ecgCheckPPulmonale => 'P wave amplitude < 2.5mm (2.5 small sq)?';

  @override
  String get ecgCheckPPulmonaleDesc =>
      'Tall P waves suggest right atrial enlargement (P pulmonale).';

  @override
  String get ecgPrInterval => 'PR Interval';

  @override
  String get ecgCheckPrDuration =>
      'PR interval between 120-200ms (3-5 small sq)?';

  @override
  String get ecgCheckPrDurationDesc =>
      'Short PR (<120ms) suggests WPW. Long PR (>200ms) suggests 1st degree block.';

  @override
  String get ecgCheckQrsDuration => 'Duration < 120ms (3 small squares)?';

  @override
  String get ecgCheckQrsDurationDesc =>
      'Wide QRS (>120ms) indicates a Bundle Branch Block.';

  @override
  String get ecgCheckPathologicalQ =>
      'Pathological Q waves absent (>1 small sq)?';

  @override
  String get ecgCheckPathologicalQDesc =>
      'A large Q wave suggests a previous myocardial infarction.';

  @override
  String get ecgCheckQrsAmplitude => 'QRS amplitude normal?';

  @override
  String get ecgCheckQrsAmplitudeDesc =>
      'Low voltage suggests effusion/obesity. High voltage suggests hypertrophy.';

  @override
  String get ecgStSegmentIschemia => 'ST Segment (Ischemia/Infarct)';

  @override
  String get ecgCheckStIsoelectric => 'Is ST at the isoelectric line?';

  @override
  String get ecgCheckStIsoelectricDesc =>
      'Deviation from the baseline suggests myocardial injury.';

  @override
  String get ecgTWave => 'T Wave';

  @override
  String get ecgCheckTWaveUpright => 'T waves upright (except aVR/V1)?';

  @override
  String get ecgCheckTWaveUprightDesc =>
      'Inverted T waves can indicate ischemia or strain.';

  @override
  String get ecgBazettCalculator => 'Bazett Calculator';

  @override
  String get ecgQtSmallSquares => 'QT (small squares)';

  @override
  String get ecgWarningQtProlonged =>
      'WARNING: QTc is prolonged. Risk of Torsades de Pointes.';

  @override
  String get ecgCheckQtHalfRr => 'Is QT < half of R-R interval?';

  @override
  String get ecgCheckQtHalfRrDesc =>
      'Quick visual rule for estimating QT length.';

  @override
  String get ecgBundleBranchBlocks => 'Bundle Branch Blocks';

  @override
  String get ecgWilliamMarrow =>
      'WiLLiaM MaRRoW Rule:\n- W in V1, M in V6 -> LBBB\n- M in V1, W in V6 -> RBBB';

  @override
  String get ecgCheckV1MsShape => 'V1: rsR\' pattern (M shape)?';

  @override
  String get ecgCheckV1MsShapeDesc =>
      'Indicates Right Bundle Branch Block (RBBB).';

  @override
  String get ecgCheckV6SlurredS => 'V6: Slurred S wave?';

  @override
  String get ecgCheckV6SlurredSDesc => 'Associated finding in RBBB.';

  @override
  String get ecgLeftVentricularHypertrophy =>
      'Left Ventricular Hypertrophy (LVH)';

  @override
  String get ecgCheckSokolowLyon => 'S in V1 + R in V5/V6 > 35mm?';

  @override
  String get ecgCheckSokolowLyonDesc =>
      'Standard Sokolow-Lyon criteria for LVH.';

  @override
  String get ecgCoronaryTerritories => 'Coronary Territories';

  @override
  String get ecgTerritoryMap =>
      'Inferior: II, III, aVF\nLateral: I, aVL, V5, V6\nAnterior: V1-V4';

  @override
  String get ecgElectrolytesTarget => 'Current Target';

  @override
  String get ecgHyperkalemia => 'Hyperkalemia:';

  @override
  String get ecgHyperkalemiaDesc =>
      'Peaked T waves, QRS widening, loss of P wave.';

  @override
  String get ecgHypokalemia => 'Hypokalemia:';

  @override
  String get ecgHypokalemiaDesc =>
      'U waves, flattened/inverted T waves, ST depression.';

  @override
  String get ecgCalciumTitle => 'Calcium (Ca2+)';

  @override
  String get ecgHypercalcemia => 'Hypercalcemia: Short QT interval.';

  @override
  String get ecgHypocalcemia => 'Hypocalcemia: Long QT interval.';

  @override
  String get ecgPdfCriteria => 'Criteria';

  @override
  String get ecgPdfEvaluation => 'Evaluation';

  @override
  String get ecgPdfYes => 'Yes';

  @override
  String get ecgPdfNo => 'No';

  @override
  String get ecgPdfUnanswered => 'Unanswered';

  @override
  String get ecgPdfResponses => 'Interpretation Responses';

  @override
  String get ecgPdfDisclaimer =>
      'Note: This report is for educational purposes only and does not constitute a clinical diagnosis.';

  @override
  String get ecgAxisNormal => 'Normal Axis';

  @override
  String get ecgAxisLad => 'Left Axis Deviation (LAD)';

  @override
  String get ecgAxisRad => 'Right Axis Deviation (RAD)';

  @override
  String get ecgAxisExtreme => 'Extreme Axis';

  @override
  String get ecgAxisIndeterminate => 'Indeterminate';

  @override
  String get ecgPdfDeducedAxis => 'Deduced Axis';

  @override
  String get ecgBpm => 'BPM';

  @override
  String get ecgClear => 'Clear';

  @override
  String get ecgPdfReportTitle => 'ECG Interpretation Report';

  @override
  String get radInterpretationReport => 'Radiology Interpretation Report';

  @override
  String get radAnalysisReport => 'RADIOLOGY ANALYSIS REPORT';

  @override
  String get radCase => 'Case';

  @override
  String get radAiActive => 'AI ACTIVE';

  @override
  String get radEducationalTool => 'Educational Tool Only';

  @override
  String get radEducationalToolDesc =>
      'This interactive guide is designed strictly for medical trainees. It is NOT a certified medical device and must never be used for clinical diagnosis.';

  @override
  String get radShareReport => 'Share Report';

  @override
  String get radGuidedInterpretation => 'Radiology Interpretation Checklist';

  @override
  String get radSourceTitle => 'Radiology Reference Source';

  @override
  String get radSourceCamera => 'Camera';

  @override
  String get radSourceGallery => 'Gallery';

  @override
  String get radSourceDraw => 'Draw';

  @override
  String get radSourceClear => 'Clear Image';

  @override
  String get radStatusNormal => 'NORMAL';

  @override
  String get radStatusStable => 'STABLE';

  @override
  String get radStatusClear => 'CLEAR';

  @override
  String get radChapterAirway => 'A - Airway';

  @override
  String get radChapterBreathing => 'B - Breathing';

  @override
  String get radChapterCirculation => 'C - Circulation';

  @override
  String get radChapterDiaphragm => 'D - Diaphragm';

  @override
  String get radChapterEverythingElse =>
      'E - Everything Else (Bones & Soft Tissues)';

  @override
  String get radCheckTracheaCentral => 'Is the trachea central?';

  @override
  String get radCheckTracheaCentralDesc =>
      'Check for deviation away from (tension pneumothorax) or towards (atelectasis) a lesion.';

  @override
  String get radCheckLungsExpanded => 'Are the lungs well expanded?';

  @override
  String get radCheckLungsExpandedDesc =>
      'Ensure you can see at least 10 posterior ribs to confirm good inspiration.';

  @override
  String get radCheckCostophrenicAngles => 'Are costophrenic angles sharp?';

  @override
  String get radCheckCostophrenicAnglesDesc =>
      'Blunting suggests pleural effusion or previous scarring.';

  @override
  String get radCheckHeartSize => 'Is the heart size normal?';

  @override
  String get radCheckHeartSizeDesc =>
      'Cardiothoracic Ratio (CTR) should be less than 0.5 on a PA film.';

  @override
  String get radCheckDiaphragmPosition => 'Is the diaphragm position normal?';

  @override
  String get radCheckDiaphragmPositionDesc =>
      'Right hemidiaphragm is usually slightly higher (due to the liver).';

  @override
  String get radCheckBonesSoftTissues => 'Bones and soft tissues unremarkable?';

  @override
  String get radCheckBonesSoftTissuesDesc =>
      'Check for fractures, surgical emphysema, or foreign bodies.';

  @override
  String get radLearnMore => 'Learn More';

  @override
  String get radTipAirwayTitle => 'Analyzing the Airway';

  @override
  String get radTipAirwayDesc =>
      'The trachea should be midline. Deviation *away* from a pathology suggests tension pneumothorax or large effusion. Deviation *towards* suggests collapse or fibrosis. Identify the carina (NG tubes should be below it).';

  @override
  String get radTipBreathingTitle => 'Evaluating the Lungs';

  @override
  String get radTipBreathingDesc =>
      'Count the ribs: 10 posterior ribs indicate good inspiration. Compare lung fields for symmetry in density. Look for pleural lines (pneumothorax) or consolidations (pneumonia).';

  @override
  String get radTipCirculationTitle => 'Heart & Mediastinum';

  @override
  String get radTipCirculationDesc =>
      'The Cardiothoracic Ratio (CTR) should be < 50% on a PA film. The \'Silhouette Sign\' helps localize opacities: if the right heart border is lost, the opacity is in the middle lobe.';

  @override
  String get radTipDiaphragmTitle => 'The Diaphragm';

  @override
  String get radTipDiaphragmDesc =>
      'The right hemidiaphragm is higher than the left. \'Air under the diaphragm\' (pneumoperitoneum) is a surgical emergency. Ensure costophrenic angles are acute and not blunted.';

  @override
  String get radTipEverythingElseTitle => 'Extra-thoracic Structures';

  @override
  String get radTipEverythingElseDesc =>
      'Scan the bones (ribs, clavicles) for fractures or lytic lesions. Check soft tissues for surgical emphysema (air pockets). Finally, systematically trace every line, tube, and drain.';

  @override
  String get radChapterDiagnosisGuide => 'Diagnosis Guide';

  @override
  String get radDiagnosisPneumonia => 'Pneumonia';

  @override
  String get radDiagnosisPneumoniaDesc =>
      'Look for consolidation, air bronchograms, and silhouette signs.';

  @override
  String get radDiagnosisHeartFailure => 'Heart Failure (Edema)';

  @override
  String get radDiagnosisHeartFailureDesc =>
      'Look for cardiomegaly, Kerley B lines, and pleural effusion.';

  @override
  String get radDiagnosisPneumothorax => 'Pneumothorax';

  @override
  String get radDiagnosisPneumothoraxDesc =>
      'Identify a visible pleural line without distal lung markings.';

  @override
  String get radDiagnosisEffusion => 'Pleural Effusion';

  @override
  String get radDiagnosisEffusionDesc =>
      'Look for blunted costophrenic angles and meniscus signs.';

  @override
  String get radDiagnosisAtelectasis => 'Atelectasis (Collapse)';

  @override
  String get radDiagnosisAtelectasisDesc =>
      'Look for volume loss, tracheal deviation towards the lesion, and linear opacities.';

  @override
  String get radSyndromeParietal => 'Parietal Syndrome';

  @override
  String get radSyndromeParietalDesc =>
      '**Definition**:\nThe set of radiological signs corresponding to a lesion of the thoracic wall (soft tissues or bones).\n\n**Radiological Semiology**:\n* **Soft tissues**: Peripheral opacity of watery density, homogeneous, sharp contour if tangential, smooth \'pente douce\' connection.\n* **Bone lesions**: Osteolytic or condensing (bone lysis, notch-type rib erosion, pathological fracture).\n\n**Description of images (Illustrated Semiology)**:\n* **Peripheral opacity**: Water-density, homogeneous.\n* **Wall connection**: Smooth \'pente douce\' with an obtuse connection angle.\n* **Pleural line sign**: Sharp interface with the lung parenchyma.\n* **Dimensions**: Horizontal diameter (base) of the opacity almost as large as its vertical diameter.\n* **Associated signs**: Bone lesions (rib lysis) often present; the opacity moves with the rib cage.';

  @override
  String get radSyndromePleural => 'Pleural Syndrome';

  @override
  String get radSyndromePleuralDesc =>
      '**Definition**:\nSigns reflecting the presence of liquid, air, or abnormal tissue between the pleural layers.\n\n**Semiology**:\n* **Free liquid effusion (Pleurisy)**: Basal opacity in a sheet, effaces costophrenic angles. Damoiseau\'s curve (concave upwards). Mobile with position changes. No bronchogram.\n* **Pneumothorax (Air)**: Peripheral avascular hyperlucency (black area without markings), visceral pleural line (fine bordering line).\n* **Hydro-pneumothorax**: Horizontal air-fluid level.\n\n**Description of images (Illustrated Semiology)**:\n* **Damoiseau\'s line**: Upper limit concave upwards and inwards of the liquid effusion.\n* **Avascular hyperlucency**: Black area without any vascular markings (PTX).\n* **Bordering line**: Fine line corresponding to the visceral pleura limiting the lung retracted towards the hilum.';

  @override
  String get radSyndromeAlveolar => 'Alveolar Syndrome';

  @override
  String get radSyndromeAlveolarDesc =>
      '**Definition**:\nFilling of the alveoli with fluid (water, pus, blood) or cells.\n\n**Characteristic Semiology**:\n* **Water-density opacity**.\n* **Blurred limits** (unless against a fissure).\n* **Confluence** (diffusion via Kohn pores).\n* **Systematization** (specific anatomical territory).\n* **Air bronchogram**: Patent bronchi within the opacity.\n\n**Description of images (Illustrated Semiology)**:\n* **Cloudy or cottony appearance**: Typical blurred-limit opacities.\n* **Confluence**: Tendency of lesions to merge.\n* **Bronchogram & Alveologram**: Visibility of clear bronchi and alveoli within the white opacity.\n* **Butterfly wings**: Symmetrical perihilar opacities respecting the periphery (Pulmonary Edema).';

  @override
  String get radSyndromeInterstitial => 'Interstitial Syndrome';

  @override
  String get radSyndromeInterstitialDesc =>
      '**Definition**:\nPresence of fluid or abnormal cells in the pulmonary interstitium.\n\n**Semiological Features**:\n* **Sharp limits**.\n* **Non-confluent**, non-systematized.\n* **No air bronchogram**.\n* Slow evolution.\n\n**Description of images (Illustrated Semiology)**:\n* **Kerley lines (B)**: Septal thickening visible at the base as short horizontal lines.\n* **Reticulations**: \'Net-like\' mesh appearance.\n* **Ground glass**: Subtle increase in lung density not effacing the vessels.\n* **Honeycombing**: Grouped small cystic lucencies (terminal stage of fibrosis).';

  @override
  String get radSyndromeBronchial => 'Bronchial Syndrome';

  @override
  String get radSyndromeBronchialDesc =>
      '**Definition**:\nSet of signs related to bronchial pathology (thickening, dilation, or obstruction).\n\n**Direct Signs**:\n* **Tram lines and Rings**: Thickening of the bronchial walls.\n* **Signet ring**: Bronchial diameter > Adjacent artery diameter.\n\n**Indirect Signs**:\n* **Atelectasis**: Systematic retractile opacity.\n* **Trapping**: Localized expiratory hyperlucency.\n\n**Description of images (Illustrated Semiology)**:\n* **Tram line sign**: Wall thickening in longitudinal view.\n* **Ring sign**: Wall thickening in transverse view.\n* **Signet ring sign**: Bronchial dilation (bronchiectasis) with bronchial diameter greater than the artery.\n* **Retractile opacity**: Atelectasis with mediastinal shift and fissural displacement towards the lesion.';

  @override
  String get radSyndromeCavitary => 'Cavitary Syndrome';

  @override
  String get radSyndromeCavitaryDesc =>
      '**Definition**:\nPresence of a lucency (cavity) within an area of opacity or the parenchyma.\n\n**Semiology**:\n* **Wall**: Fixed or variable thickness. Thin (< 3mm) or thick (> 15mm).\n* **Air-fluid level**: Horizontal line (air above, liquid below).\n* **Grelot sign**: Mobile mass inside the cavity.\n\n**Description of images (Illustrated Semiology)**:\n* **Lucency image**: Area of transparency (black) within the parenchyma.\n* **Air-fluid level**: Strict horizontal limit between air and liquid.\n* **Grelot sign**: Mobile mass (e.g., aspergillome) within a cavity.\n* **Nénuphar sign**: Floating membrane typical of a ruptured hydatid cyst.';

  @override
  String get radSyndromeMediastinal => 'Mediastinal Syndrome';

  @override
  String get radSyndromeMediastinalDesc =>
      '**Definition**:\nSigns reflecting the presence of a mass or effusion in the mediastinum.\n\n**Localization Signs**:\n* **Sharp, convex outer border** towards the lung.\n* **Silhouette sign**: Effacement of a border in contact with a structure of the same density.\n* **Iceberg sign**: Thoraco-abdominal mass departing from the spine.\n\n**Description of images (Illustrated Semiology)**:\n* **Silhouette sign**: Blurring of borders between two structures of same density in contact.\n* **Cervicothoracic sign**: Opacity exceeding the upper border of the clavicle (indicates posterior position).\n* **Iceberg sign (thoraco-abdominal)**: Mass departing from the spine below the diaphragm.\n* **Hilar overlay sign**: Visibility of vessels through the opacity (indicates ant/post position relative to the hilum).';

  @override
  String get radResetFindings => 'Reset Findings';

  @override
  String get radTechnicalQuality => 'Technical Quality Check (CRIP)';

  @override
  String get radDifferentialDiagnosis => 'Differential Diagnosis';

  @override
  String get radCommonEtiologies => 'Common Etiologies';

  @override
  String get radRelatedSyndromes => 'Related to Syndromes:';

  @override
  String get radSemiologySigns => 'Semiology (Signs)';

  @override
  String get radClinicalPearls => 'Clinical Pearls';

  @override
  String get radSyndromeProbabilityAnalysis => 'Syndrome Probability Analysis';

  @override
  String radSignsCount(Object score, Object total) {
    return '$score/$total signs';
  }

  @override
  String radObjective(Object target) {
    return 'Objective: $target';
  }

  @override
  String get radSemiologyCourse => 'Semiology Course';

  @override
  String get labAnalysisReport => 'LABORATORY ANALYSIS REPORT';

  @override
  String get labGuidedInterpretation => 'Bio Interpretation Checklist';

  @override
  String get labChapterHematology => 'Hematology (CBC)';

  @override
  String get labChapterElectrolytes => 'Electrolytes';

  @override
  String get labChapterBloodGas => 'Blood Gas';

  @override
  String get labChapterRenal => 'Renal Function';

  @override
  String get labChapterHepatic => 'Liver Function';

  @override
  String get labChapterInflammatory => 'Inflammatory Markers';

  @override
  String get labCheckAnemia => 'Hemoglobin (Anemia?)';

  @override
  String get labCheckAnemiaDesc => 'Decrease in Hb based on age and sex.';

  @override
  String get labCheckPlq => 'Platelets (Hemostasis?)';

  @override
  String get labCheckPlqDesc =>
      'Search for thrombocytopenia or thrombocytosis.';

  @override
  String get labCheckK => 'Potassium (Dyskalemia?)';

  @override
  String get labCheckKDesc => 'Vital emergency if severe anomaly (ECG).';

  @override
  String get labCheckNa => 'Sodium (Hydration?)';

  @override
  String get labCheckNaDesc => 'Reflects intracellular hydration status.';

  @override
  String get labCheckCreat => 'Creatinine (GFR?)';

  @override
  String get labCheckCreatDesc =>
      'Evaluate renal function and filtration rate.';

  @override
  String get labCheckCRP => 'CRP (Inflammation?)';

  @override
  String get labCheckCRPDesc => 'Rapid marker of acute inflammation.';

  @override
  String get labCheckPH => 'pH and Blood Gas';

  @override
  String get labCheckPHDesc => 'Search for acidosis or alkalosis.';

  @override
  String get labCheckLiver => 'Transaminases (Cytolysis?)';

  @override
  String get labCheckLiverDesc => 'Increase in ALT/AST.';

  @override
  String get labCheckCholestasis => 'ALP / GGT (Cholestasis?)';

  @override
  String get labCheckCholestasisDesc => 'Obstruction or biliary involvement.';

  @override
  String get labTipHematologyTitle => 'CBC Analysis';

  @override
  String get labTipHematologyDesc =>
      'Hemoglobin defines anemia. MCV/MCHC guide the diagnosis. Platelets are vital for hemostasis.';

  @override
  String get labTipElectrolytesTitle => 'Electrolytes';

  @override
  String get labTipElectrolytesDesc =>
      'Potassium (K+) is the most dangerous. Sodium (Na+) reflects water. Always check associated renal function.';

  @override
  String get labTipInflammatoryTitle => 'Inflammatory Markers';

  @override
  String get labTipInflammatoryDesc =>
      'CRP rises and falls quickly. ESR is slower. Neutrophilia suggests bacterial infection.';

  @override
  String get labSyndromeInflammatory => 'Inflammatory Syndrome';

  @override
  String get labSyndromeAnemia => 'Anemia';

  @override
  String get labSyndromeThrombopenia => 'Thrombopenia';

  @override
  String get labSyndromeHyperkalemia => 'Hyperkalemia';

  @override
  String get labSyndromeHypokalemia => 'Hypokalemia';

  @override
  String get labSyndromeIRA => 'Acute Renal Failure';

  @override
  String get labSyndromeAcidosis => 'Metabolic Acidosis';

  @override
  String get labSyndromeDehydration => 'Dehydration';

  @override
  String get labSyndromeCholestasis => 'Cholestase';

  @override
  String get labSyndromeCytolysis => 'Liver Cytolysis';

  @override
  String get labResetFindings => 'Reset Results';

  @override
  String get labEncyclopedia => 'Lab Encyclopedia';

  @override
  String get labEncyclopediaDesc => '250 detailed laboratory exams';

  @override
  String get labChapterGasometry => 'Blood Gas (ABG)';

  @override
  String get labChapterHepatorenal => 'Hepatic & Renal Panel';

  @override
  String get labTipGasometryTitle => 'Arterial Blood Gases';

  @override
  String get labTipGasometryDesc =>
      'pH < 7.35 is acidosis. Check if metabolic (low HCO3-) or respiratory (high pCO2). Elevated lactate signals poor perfusion.';

  @override
  String get labTipHepatorenalTitle => 'Hepatic & Renal Function';

  @override
  String get labTipHepatorenalDesc =>
      'ASAT > ALAT suggests alcoholic origin. Isolated GGT rise = alcohol or medications. Creatinine rise: always check urea and diuresis.';

  @override
  String get labSyndromeProbability => 'Syndrome Probability Analysis';

  @override
  String get labCommonEtiologies => 'Common Etiologies';

  @override
  String get labRelatedSyndromes => 'Related to Syndromes:';

  @override
  String get viewInEncyclopedia => 'View in Encyclopedia';

  @override
  String get labNormalValues => 'Normal Values';

  @override
  String get searchParameter => 'Search parameter...';

  @override
  String get unitSI => 'SI Unit';

  @override
  String get unitTrad => 'Trad. Unit';

  @override
  String get paramReference => 'Reference Sheet';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get notificationToday => 'Today';

  @override
  String get notificationYesterday => 'Yesterday';

  @override
  String get notificationEarlier => 'Earlier';

  @override
  String get noNotificationsTitle => 'All caught up!';

  @override
  String get noNotificationsSubtitle => 'You have no new notifications.';

  @override
  String get notificationTypeContent => 'Content';

  @override
  String get notificationTypeCommunity => 'Community';

  @override
  String get notificationTypePerformance => 'Performance';

  @override
  String get notificationTypeSystem => 'System';

  @override
  String get clearAllNotifications => 'Clear All Notifications';

  @override
  String get clearAllNotificationsConfirmation =>
      'Are you sure you want to permanently delete all your notifications?';

  @override
  String get clearAll => 'Clear All';

  @override
  String get markRead => 'Mark as Read';

  @override
  String get markUnread => 'Mark as Unread';

  @override
  String get studyGroups => 'Study Groups';

  @override
  String get available => 'AVAILABLE';

  @override
  String get myProgression => 'MY PROGRESSION';

  @override
  String get createGroup => 'CREATE A GROUP';

  @override
  String get popularRooms => 'POPULAR ROOMS';

  @override
  String get recommendedRooms => 'RECOMMENDED ROOMS';

  @override
  String get joinRoom => 'JOIN';

  @override
  String get members => 'MEMBERS';

  @override
  String get pomodoros => 'POMODOROS';

  @override
  String get details => 'DETAILS';

  @override
  String get waitingForSession => 'Waiting for Session';

  @override
  String get adminWillStartSession =>
      'The group admin will start a study battle soon. Get ready!';

  @override
  String get theoreticalOnly => 'Theoretical Only';

  @override
  String get clinicalOnly => 'Clinical Only';

  @override
  String get selectStudyYear => 'Select Study Year';

  @override
  String get groupName => 'Group Name';

  @override
  String get descriptionHint => 'Description (Goal, specialty...)';

  @override
  String get groupColor => 'Group Color';

  @override
  String get createRoom => 'CREATE ROOM';

  @override
  String get pleaseEnterTitle => 'Please enter a title';

  @override
  String get liveSession => 'LIVE SESSION';

  @override
  String get liveQuizBattles => 'Ongoing Quiz Battles';

  @override
  String get inviteFriend => 'Invite a Friend';

  @override
  String get startGStudy => 'START A G-STUDY SESSION';

  @override
  String get liveQuizBattleInfo => 'Live Quiz Battle • +500 XP';

  @override
  String get liveFocus => 'LIVE FOCUS';

  @override
  String get groupGoals => 'GROUP GOALS';

  @override
  String get meducytesWall => 'MEDUCYTES WALL';

  @override
  String get sendEncouragement => 'Send an encouragement...';

  @override
  String get you => 'You';

  @override
  String get aloneInBattle => 'Alone in the battle for now...';

  @override
  String get liveBattle => 'LIVE BATTLE';

  @override
  String questionOf(Object current, Object total) {
    return 'QUESTION $current OF $total';
  }

  @override
  String yourScore(Object score) {
    return 'YOUR SCORE: $score';
  }

  @override
  String get excellent => 'EXCELLENT!';

  @override
  String get oopsNotQuite => 'OOPS, NOT QUITE...';

  @override
  String get preparingBattle => 'PREPARING BATTLE...';

  @override
  String get battleAboutToStart => 'THE BATTLE IS ABOUT TO START';

  @override
  String get getReadyTenQuestions => 'Get ready! 10 Questions on the module';

  @override
  String participantsReady(Object count) {
    return '$count Participants ready';
  }

  @override
  String get battleFinished => 'BATTLE FINISHED!';

  @override
  String get backToGroup => 'BACK TO GROUP';

  @override
  String get searchByNameOrEmail => 'Search by name or email...';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get invitationSent => 'Invitation sent!';

  @override
  String get invitationError => 'Error sending invitation';

  @override
  String get invite => 'INVITE';

  @override
  String get selectTopic => 'Select a Topic';

  @override
  String get chooseModuleForBattle => 'Choose a module for the Battle';

  @override
  String get searchRoomHint => 'Search for a room or topic...';

  @override
  String get recommendedForYou => 'RECOMMENDED FOR YOU';

  @override
  String get onlineSuffix => 'ONLINE';

  @override
  String get yourSummary => 'YOUR SUMMARY';

  @override
  String get myActiveGroups => 'MY ACTIVE GROUPS';

  @override
  String get noActiveGroups => 'NO ACTIVE GROUPS';

  @override
  String get pomodorosToday => 'Pomodoros collected today';

  @override
  String get syncingStats => 'Global statistics being synchronized...';

  @override
  String get silent => 'Silent';

  @override
  String get focus => 'Focus';

  @override
  String get qcmBattle => 'QCM Battle';

  @override
  String get categoryMedicine => 'Medicine';

  @override
  String get categorySurgery => 'Surgery';

  @override
  String get categoryGyneco => 'Gynecology';

  @override
  String get categoryPaces => 'PACES';

  @override
  String get categoryExam => 'Exams';

  @override
  String get roomNameLabel => 'ROOM NAME';

  @override
  String get descriptionOptional => 'DESCRIPTION (OPTIONAL)';

  @override
  String get sessionType => 'SESSION TYPE';

  @override
  String get themeColorLabel => 'THEME COLOR';

  @override
  String get medicalCategory => 'MEDICAL CATEGORY';

  @override
  String get roomCreatedSuccess => 'ROOM CREATED SUCCESSFULLY';

  @override
  String get roomCreationError => 'ERROR DURING CREATION';

  @override
  String get topRated => 'TOP RATED';

  @override
  String get trending => 'TRENDING';

  @override
  String get allCaps => 'ALL';

  @override
  String get activeSession => 'ACTIVE SESSION';

  @override
  String participantsCount(Object count) {
    return '$count Meducytes in battle';
  }

  @override
  String get beFirstToEncourage => 'BE THE FIRST TO ENCOURAGE THE GROUP!';

  @override
  String get groupTypeLabel => 'TYPE';

  @override
  String inProgressCount(Object count) {
    return '$count IN PROGRESS';
  }

  @override
  String get aiOptimizedPlanning =>
      'AI has optimized your planning based on your weaknesses and exams.';

  @override
  String daysRemaining(Object days) {
    return 'D-$days';
  }

  @override
  String get applyPlanning => 'Apply this planning';

  @override
  String get nextSession => 'NEXT SESSION';

  @override
  String get noSession => 'No session';

  @override
  String get noUrgentTask => 'No urgent task';

  @override
  String get days => 'Days';

  @override
  String get nextExam => 'NEXT EXAM';

  @override
  String get setExamDate => 'Set Exam Date';

  @override
  String get editExam => 'Edit Exam';

  @override
  String get selectDateAndHour => 'Select Date & Hour';

  @override
  String get examTitle => 'Exam Title';

  @override
  String get noExam => 'No exam';

  @override
  String get pomodoroLabel => 'POMODORO';

  @override
  String get personalization => 'Personalization';

  @override
  String get pomodoroWork => 'Focus';

  @override
  String get done => 'Done';

  @override
  String get errorLabel => 'Error';

  @override
  String get newStudyModuleTask => 'New study module';

  @override
  String get addSmartTask => 'Add smart task';

  @override
  String get urgentLabel => 'URGENT';

  @override
  String get examLabel => 'EXAM';

  @override
  String get optionalLabel => 'OPTIONAL';

  @override
  String get todayLabel => 'Today';

  @override
  String get taskDeselected => 'Task deselected';

  @override
  String focusOnTask(Object task) {
    return 'Focus on: $task';
  }

  @override
  String get optimalConcentrationMsg =>
      'Optimal concentration. Continue on Cardiology for another 45 min.';

  @override
  String get loadLabel => 'Load';

  @override
  String get capacityLabel => 'Capacity';

  @override
  String get breakDueLabel => 'Break Due';

  @override
  String get focusPeak => 'Focus Peak';

  @override
  String get focusStable => 'Focus Stable';

  @override
  String get lightFatigue => 'Light Fatigue';

  @override
  String get burnoutRisk => 'Burnout Risk';

  @override
  String get viewAll => 'View all';

  @override
  String get noPriorityTask => 'No priority task';

  @override
  String get studyStreak => 'Study Streak';

  @override
  String get pomodoroToday => 'Pomodoro Today';

  @override
  String get totalHours => 'Total Hours';

  @override
  String get moduleEfficiency => 'Module Efficiency';

  @override
  String get wind => 'Wind';

  @override
  String get cafe => 'Cafe';

  @override
  String get library => 'Library';

  @override
  String get brownNoise => 'Brown Noise';

  @override
  String get productiveBayTitle => 'The Productive Bay';

  @override
  String get searchError => 'Error during search';

  @override
  String get editSession => 'Edit Session';

  @override
  String get planSession => 'Plan Session';

  @override
  String get weeklyPriorityObjectives => 'WEEKLY PRIORITY OBJECTIVES';

  @override
  String get weeklyObjectives => 'Weekly Objectives';

  @override
  String get confidenceLevelQuestion => 'What is your confidence level?';

  @override
  String get difficultConceptQuestion =>
      'What was the most difficult concept today?';

  @override
  String get finishSession => 'Finish session';

  @override
  String get startQuickRevision => 'Start Quick Revision';

  @override
  String get customizeHub => 'Customize Hub';

  @override
  String get noDescription => 'No description';

  @override
  String get groupGoalsHint => 'Goals, room rules...';

  @override
  String get yearLabel => 'Year';

  @override
  String get monthlyView => 'Monthly View';

  @override
  String get weeklyView => 'Weekly View';

  @override
  String get dailyView => 'Daily View';

  @override
  String get newSession => 'New Session';

  @override
  String get studySubject => 'Study Subject';

  @override
  String get subjectHint => 'Subject (e.g. Cardiology)';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get deleteLabel => 'Delete';

  @override
  String get typeLabel => 'Type';

  @override
  String get colorLabel => 'Color';

  @override
  String weekLabel(Object end, Object start) {
    return 'Week $start - $end';
  }

  @override
  String get defaultObjective1 => 'Master ECG branch blocks';

  @override
  String get defaultObjective2 => 'Finish Pneumology module';

  @override
  String get defaultObjective3 => 'Practice 50 Cardiology MCQs';

  @override
  String aiPrefix(Object title) {
    return 'AI: $title';
  }

  @override
  String get highPriorityTaskReason => 'High priority task due soon';

  @override
  String get optimalTimeReason => 'Optimal time for this task';

  @override
  String get noTasksReason =>
      'No pending tasks found. Time to discover something new!';

  @override
  String get exploreModulesTitle => 'Explore new modules';

  @override
  String get exportPlannerTitle => 'Clinical Planner Export';

  @override
  String get clinicalRevisionPlanner => 'CLINICAL REVISION PLANNER';

  @override
  String weekOf(Object date) {
    return 'Week of $date';
  }

  @override
  String get hourTitle => 'HOUR';

  @override
  String get clinicalNotesReminders => 'CLINICAL NOTES & REMINDERS';

  @override
  String get intensityTrackerAi => 'INTENSITY TRACKER (AI)';

  @override
  String get authWelcomeTitle => 'Meducyte';

  @override
  String get authWelcomeSubtitle =>
      'Your clinical excellence journey starts here.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'dr.meducyte@example.com';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => '••••••••';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authOr => 'OR';

  @override
  String get authContinueGoogle => 'Google';

  @override
  String get authContinueApple => 'Apple';

  @override
  String get authNoAccount => 'Don’t have an account?';

  @override
  String get authSignUp => 'Sign Up';

  @override
  String authSocialSoon(Object platform) {
    return '$platform Sign-in integrated soon';
  }

  @override
  String get authBiometricSuccess => 'Biometric authentication successful';

  @override
  String get authCreateAccount => 'Create Account';

  @override
  String get authCreateAccountSub => 'Your journey to clinical mastery begins.';

  @override
  String get authStudySchedule => 'Set your study schedule';

  @override
  String get authStudyScheduleSub =>
      'Consistency is key for medical residency prep.';

  @override
  String get authDailyStartTime => 'Daily Start Time';

  @override
  String get authTargetDuration => 'Target Study Duration';

  @override
  String get authHours => 'HOURS';

  @override
  String get authMinutes => 'MINUTES';

  @override
  String authDailyCommitment(Object time) {
    return 'Daily commitment set for $time.';
  }

  @override
  String authStudyGoal(Object h, Object m) {
    return 'Goal: ${h}h ${m}m of focused study.';
  }

  @override
  String get authInterests => 'What are your medical interests?';

  @override
  String get authInterestsSub =>
      'Select all that apply to personalize your feed.';

  @override
  String get authMedicalSpec => 'Medical Specialties';

  @override
  String get authSurgicalSpec => 'Surgical Specialties';

  @override
  String get authOtherDisciplines => 'Other Disciplines';

  @override
  String get authLearningStyleSub =>
      'Choose the best fit for your learning style.';

  @override
  String get authPasswordStrength => 'Password strength';

  @override
  String get authStrengthWeak => 'Weak';

  @override
  String get authStrengthFair => 'Fair';

  @override
  String get authStrengthGood => 'Good';

  @override
  String get authStrengthStrong => 'Strong';

  @override
  String get authStrengthNone => 'None';

  @override
  String authStrengthLabel(Object label) {
    return 'Strength: $label';
  }

  @override
  String get authGoalTitle => 'Tell us what\'s your goal?';

  @override
  String get authGoalAce => 'Ace my exams efficiently';

  @override
  String get authGoalUnderstand => 'Understand medicine deeply';

  @override
  String get authGoalPractical => 'Learn practical clinical skills';

  @override
  String get authGoalHabit => 'Build a daily study habit';

  @override
  String get authHeardFromTitle => 'How did you hear about us?';

  @override
  String get authHeardFriend => 'Friend';

  @override
  String get authHeardSocial => 'Social Media';

  @override
  String get authHeardSchool => 'School';

  @override
  String get authHeardOther => 'Other';

  @override
  String get authQuizPreferenceTitle => 'Quizzes & Medical Learning';

  @override
  String get authQuizDaily => 'Daily Quizzes';

  @override
  String get authQuizWeekly => 'Weekly Quizzes';

  @override
  String get authQuizVideo => 'Video Learning';

  @override
  String get authQuizPdf => 'PDF Notes';

  @override
  String get authFullName => 'Full Name';

  @override
  String get authEmail => 'Email';

  @override
  String get authYear => 'Year';

  @override
  String get authSelectYear => 'Select Year';

  @override
  String get authMobileOptional => 'Mobile (optional)';

  @override
  String get authConfirmPassword => 'Confirm Password';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get authPassAtLeast8 => 'At least 8 characters';

  @override
  String get authPassUppercase => 'One uppercase letter';

  @override
  String get authPassNumber => 'One number';

  @override
  String get authPassSpecial => 'One special character (!@#\$^*~)';

  @override
  String get authAcceptTerms => 'I accept the ';

  @override
  String get authTermsOfUse => 'Terms of Use';

  @override
  String get authPrivacyPolicy => 'Privacy Policy';

  @override
  String get authAnd => ' and ';

  @override
  String get authBack => 'Back';

  @override
  String get authContinue => 'Continue';

  @override
  String get authFinish => 'Finish';

  @override
  String get authVerifyEmail => 'Verify Email';

  @override
  String get authResetPassword => 'Reset Password';

  @override
  String get authVerifyYourEmail => 'Verify Your Email';

  @override
  String get authResetYourPassword => 'Reset Your Password';

  @override
  String get authEnterOtp => 'Enter the 6-digit OTP sent to:';

  @override
  String get authNoCode => 'Didn\'t receive the code?';

  @override
  String authResendIn(Object seconds) {
    return 'Resend in $seconds';
  }

  @override
  String get authResendOtp => 'Resend OTP';

  @override
  String get authInvalidOtp => 'Please enter a valid 6-digit OTP';

  @override
  String get authEmailVerified => 'Email verified successfully!';

  @override
  String get authOtpVerified => 'OTP verified! Set your new password.';

  @override
  String get authOtpSent => 'OTP sent successfully!';

  @override
  String get authPrivacyPolicyTitle => 'Privacy Policy';

  @override
  String get authPrivacySection1Title => '1. Information We Collect';

  @override
  String get authPrivacySection1Content =>
      'We collect information you provide directly to us, such as your name, email address, and medical specialty when you create an account. We also collect data on your study progress and quiz performance to personalize your learning experience.';

  @override
  String get authPrivacySection2Title => '2. How We Use Your Information';

  @override
  String get authPrivacySection2Content =>
      'Your information is used to provide and enhance our services, track your academic progress, and provide AI-driven study recommendations. We do not sell your personal data to third parties.';

  @override
  String get authPrivacySection3Title => '3. Data Security';

  @override
  String get authPrivacySection3Content =>
      'We implement appropriate security measures to protect your personal information from unauthorized access, alteration, or disclosure. However, no internet transmission is 100% secure.';

  @override
  String get authPrivacySection4Title => '4. Your Rights';

  @override
  String get authPrivacySection4Content =>
      'You have the right to access, correct, or delete your personal data at any time through your account settings. You may also contact us to request data portability.';

  @override
  String get authPrivacySection5Title => '5. Contact Us';

  @override
  String get authPrivacySection5Content =>
      'If you have any questions about this Privacy Policy, please contact us at contact@meducyte.com.';

  @override
  String get authPrivacyLastUpdated => 'Last updated: October 2023';

  @override
  String get authTermsOfUseTitle => 'Terms of Use & Usage Conditions';

  @override
  String get authTermsSection1Title => '1. Acceptance of Terms';

  @override
  String get authTermsSection1Content =>
      'By accessing and using Meducyte, you agree to be bound by these terms. If you do not agree to these terms, you should not use the services.';

  @override
  String get authTermsSection2Title => '2. Medical Disclaimer';

  @override
  String get authTermsSection2Content =>
      'Meducyte is an educational tool and should not be used as a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of a physician or other qualified health provider with any questions you may have regarding a medical condition.';

  @override
  String get authTermsSection3Title => '3. User Accounts';

  @override
  String get authTermsSection3Content =>
      'You are responsible for maintaining the confidentiality of your account and password. You also agree to provide accurate, current, and complete information.';

  @override
  String get authTermsSection4Title => '4. Intellectual Property';

  @override
  String get authTermsSection4Content =>
      'All content, including medical information, quizzes, and graphics, are the intellectual property of Meducyte. You may not reproduce or distribute this content without prior written consent.';

  @override
  String get authTermsSection5Title => '5. Limitation of Liability';

  @override
  String get authTermsSection5Content =>
      'Meducyte and its affiliates shall not be liable for any indirect, incidental, special, or consequential damages resulting from the use or inability to use our services.';

  @override
  String get authTermsLastUpdated => 'Last updated: October 2023';

  @override
  String get authFaculteTitle => 'Which CHU / Faculty do you attend?';

  @override
  String get authFaculteSub =>
      'Meducyte is currently exclusive to Constantine students for maximum CHU alignment.';

  @override
  String get authClinicalStageTitle => 'Which Rotation (Stage) are you in?';

  @override
  String get authClinicalStageSub =>
      'This prioritizes clinical cases and flashcards for your current CHU department.';

  @override
  String get authExamDateTitle => 'When is your next major exam?';

  @override
  String get authExamDateSub =>
      'Set a countdown for your next EMD or Concours to build your study plan.';

  @override
  String get authCurrentFocusTitle => 'What are you studying right now?';

  @override
  String get authCurrentFocusSub =>
      'Select the module you are currently preparing for your CHU\'s EMD.';

  @override
  String get authDailyChallengeTitle => 'Activate \'EMD du Jour\'?';

  @override
  String get authDailyChallengeSub =>
      'Receive one high-yield clinical question every day at your chosen time.';

  @override
  String get authCommunityTitle => 'Show profile to your Faculty?';

  @override
  String get authCommunitySub =>
      'Join study groups for your CHU and see who else is studying the same module.';

  @override
  String get authStatusExtern => 'Extern (4th-6th Year)';

  @override
  String get authStatusIntern => 'Intern (7th Year)';

  @override
  String get authStatusResident => 'Resident';

  @override
  String get authStatusDoctor => 'General Practitioner';

  @override
  String get authStageCardio => 'Cardiology';

  @override
  String get authStageSurgery => 'Surgery';

  @override
  String get authStagePediatrics => 'Pediatrics';

  @override
  String get authStageInternal => 'Internal Medicine';

  @override
  String get authStageGyneco => 'Gynecology & Obstetrics';

  @override
  String get authStageEmergency => 'Emergency Medicine';

  @override
  String get authExamEMD => 'Next EMD';

  @override
  String get authExamConcours => 'Concours de Résidanat';

  @override
  String get authFaculteAlgiers => 'Faculty of Algiers';

  @override
  String get authFaculteOran => 'Faculty of Oran';

  @override
  String get authFaculteConstantine => 'Faculty of Constantine';

  @override
  String get authFaculteAnnaba => 'Faculty of Annaba';

  @override
  String get authFaculteSetif => 'Faculty of Setif';

  @override
  String get authFaculteTizi => 'Faculty of Tizi Ouzou';

  @override
  String get authFaculteOther => 'Other Faculty';

  @override
  String get authHowHeardTitle => 'How did you hear about us?';

  @override
  String get authHowHeardSub =>
      'Help us grow the Meducyte community for all Algerian medical students.';

  @override
  String get authIdentityTitle => 'Meducyte Identity';

  @override
  String get authIdentitySub => 'Create your unique Notion-style persona.';

  @override
  String get authIdentityTabHead => 'Shape';

  @override
  String get authIdentityTabHair => 'Hair';

  @override
  String get authIdentityTabFace => 'Face';

  @override
  String get authIdentityTabColor => 'Aura';

  @override
  String get profileLearningGoal => 'Learning Goal';

  @override
  String get profileHeardFrom => 'How you heard about us';

  @override
  String get profileQuizPreference => 'Quiz Preference';

  @override
  String get profileStudyTime => 'Daily Study Time';

  @override
  String get profileStudyDuration => 'Study Session Duration';

  @override
  String get profileInterests => 'Medical Interests';

  @override
  String get profileNextExam => 'Next Major Exam';

  @override
  String get profileDailyChallenge => 'Daily Challenge Enabled';

  @override
  String get profileShowToFaculty => 'Visible to Faculty';

  @override
  String get simTechnicalOverlay => 'TECHNICAL OVERLAY';

  @override
  String get simMoreOptions => 'More Options';

  @override
  String get simDifferentialChecklist => 'Differential Checklist';

  @override
  String get simTechnicalOptions => 'Technical Options';

  @override
  String get simTextScaling => 'Text Scaling';

  @override
  String get simHighContrastMode => 'High Contrast Mode';

  @override
  String get simClinicalObservation => 'Clinical Observation';

  @override
  String get simReportProblem => 'Report a Problem';

  @override
  String get simSelectSpecialtyDiff =>
      'Select a specialty for the differential diagnosis';

  @override
  String get simCheckSuspectedPathologies =>
      'Check all suspected pathologies. These will be reviewed at the end of the simulation.';

  @override
  String get simClinicalObservationReport => 'Clinical Observation Report';

  @override
  String get simReportCopiedClipboard =>
      'A formatted medical observation has been copied to your clipboard.';

  @override
  String get simReportABug => 'Report a Bug';

  @override
  String get simReportBugDescription =>
      'Please describe the problem you encountered during this simulation.';

  @override
  String get simReportBugMetadata =>
      'Session ID, pathology, and current vitals will be included in the report.';

  @override
  String get simDescribeIssueHint => 'Describe the issue...';

  @override
  String get simThankYou => 'Thank you';

  @override
  String get simReportSubmitted => 'Your report has been submitted.';

  @override
  String get simPatientBriefing => 'Patient Briefing';

  @override
  String get simAiConsultation => 'AI Consultation';

  @override
  String get simTechnicalDebug => 'Technical Debug Overlay';

  @override
  String get simStartMission => 'START MISSION';

  @override
  String get simNextStep => 'NEXT STEP';

  @override
  String get simCurriculumFocus => 'Curriculum Focus';

  @override
  String get simCaseSelection => 'Case Selection';

  @override
  String get simSetting => 'Simulation Setting';

  @override
  String get simFinalBriefing => 'Final Briefing';

  @override
  String get simBackToSimulations => 'BACK TO SIMULATIONS';

  @override
  String get simChooseModuleDesc =>
      'Select a module from your curriculum. The AI will pull relevant patient cases from this specialty.';

  @override
  String get simNoCasesFound =>
      'No cases found for this module in the database.';

  @override
  String get simChooseClinicalCase => 'Choose a clinical case';

  @override
  String get simSimParameters => 'Simulation Parameters';

  @override
  String get simClinicalSetting => 'Clinical Setting';

  @override
  String get simSimDifficulty => 'Simulation Difficulty';

  @override
  String get simReadyToInitialize => 'Ready to initialize?';

  @override
  String get simDemographicsPersonalityDesc =>
      'Patient demographics and personality are pre-defined in the database for this specific clinical case.';

  @override
  String get simEnterRoomDesc =>
      'Enter the room and begin the anamnesis to discover the patient\'s identity and history.';

  @override
  String get simCase => 'Case';

  @override
  String get simLocation => 'Location';

  @override
  String get simDifficulty => 'Difficulty';

  @override
  String get simSaveList => 'SAVE LIST';

  @override
  String get simDescribeIssue =>
      'What went wrong? Our technical team will review the session state.';

  @override
  String get simDiagnosticData => 'DIAGNOSTIC DATA (AUTO-ATTACHED)';

  @override
  String get simSubmitReport => 'SUBMIT REPORT';

  @override
  String get simReportSent => 'Report sent. Thank you for your feedback!';

  @override
  String get simCopyAndClose => 'COPY & CLOSE';

  @override
  String get simObservationCopied => 'Observation copied to clipboard';

  @override
  String get simDifferentialDiagnosis => 'DIFFERENTIAL DIAGNOSIS';

  @override
  String get simListDifferentialsHint => 'List your differentials here...';

  @override
  String get simEmergencyRoom => 'Emergency Room';

  @override
  String get simEmergencyRoomDesc =>
      'Acute presentations, limited initial data.';

  @override
  String get simOutpatientClinic => 'Outpatient Clinic';

  @override
  String get simOutpatientClinicDesc =>
      'Routine consultation, emphasis on history.';

  @override
  String get simInterview => 'Interview';

  @override
  String get simExam => 'Exam';

  @override
  String get simLabs => 'Labs';

  @override
  String get simAuscultation => 'Auscultation';

  @override
  String get simPalpation => 'Palpation';

  @override
  String get simPercussion => 'Percussion';

  @override
  String get simNeurologicalExam => 'Neurological Exam';

  @override
  String get simPupillaryReflex => 'Pupillary Reflex';

  @override
  String get simJVP => 'Jugular Venous Pressure';

  @override
  String get simRevealInterpretation => 'Reveal Expert Interpretation';

  @override
  String get simSaveContinue => 'Save & Continue';

  @override
  String get simSubmitFinalDiagnosis => 'SUBMIT FINAL DIAGNOSIS';

  @override
  String get simFinalDiagnosis => 'Final Diagnosis';

  @override
  String get simEnterPathology => 'Enter your suspected pathology...';

  @override
  String get simInterviewHint => 'Interview the patient...';

  @override
  String get simPatientThinking => 'Patient is thinking...';

  @override
  String get simPerformExamination => 'PERFORM EXAMINATION';

  @override
  String get simLatestFinding => 'LATEST FINDING';

  @override
  String get simSearchInvestigations => 'Search investigations...';

  @override
  String get simDiagnosticResults => 'DIAGNOSTIC RESULTS';

  @override
  String get simAiClinicalTutor => 'AI CLINICAL TUTOR';

  @override
  String get simAskTutorFindings => 'ASK THE TUTOR ABOUT FINDINGS';

  @override
  String get simWhySignificant =>
      'Why is this result significant in this case?';

  @override
  String get simYourInterpretation => 'YOUR INTERPRETATION';

  @override
  String get simEnterFinding =>
      'Enter your clinical finding or interpretation...';

  @override
  String get simRefRange => 'REF RANGE';

  @override
  String get simNoDataAvailable =>
      'No clinical data available for this investigation.';

  @override
  String get simRetrievingData => 'Retrieving clinical data...';

  @override
  String get simLoadingAudio => 'LOADING CLINICAL AUDIO...';

  @override
  String get simPlayingAuscultation => 'PLAYING AUSCULTATION...';

  @override
  String get simReadyToListen => 'READY TO LISTEN';

  @override
  String get simInterpretation => 'INTERPRETATION';

  @override
  String get simExpertInterpretation => 'EXPERT INTERPRETATION';

  @override
  String simViewMedia(Object mediaType) {
    return 'VIEW $mediaType';
  }

  @override
  String get simClinicalReasoningTutor => 'CLINICAL REASONING TUTOR';

  @override
  String get simWelcomeDoctor => 'Welcome, Doctor.';

  @override
  String get simTutorHelp =>
      'I can help you interpret findings, suggest differential diagnoses, or explain the pathophysiology of this case. How can I assist you?';

  @override
  String get simSuggestedQuestions => 'Suggested Questions:';

  @override
  String get simAskTutorHint => 'Ask the tutor...';

  @override
  String get simTutorDiff => 'What are the most likely differentials?';

  @override
  String get simTutorEcg =>
      'Can you explain the significance of the ECG findings?';

  @override
  String get simTutorManagement =>
      'What would be my next priority in management?';

  @override
  String get simSessionExported => 'Session Log Exported';

  @override
  String get simCancel => 'CANCEL';

  @override
  String get simSubmit => 'SUBMIT';

  @override
  String get simClose => 'CLOSE';

  @override
  String get labBiochemistry => 'Biochemistry';

  @override
  String get labHematology => 'Hematology';

  @override
  String get labCardiac => 'Cardiac';

  @override
  String get labRadiology => 'Radiology';

  @override
  String get labMicrobiology => 'Microbiology';

  @override
  String get labOthers => 'Others';

  @override
  String get labBloodGlucose => 'Blood Glucose';

  @override
  String get labUreaElectrolytes => 'Urea & Electrolytes';

  @override
  String get labLiverFunction => 'Liver Function Tests';

  @override
  String get labCrp => 'CRP';

  @override
  String get labHba1c => 'HbA1c';

  @override
  String get labLipidProfile => 'Lipid Profile';

  @override
  String get labFbc => 'Full Blood Count';

  @override
  String get labCoagulation => 'Coagulation Profile';

  @override
  String get labDdimer => 'D-Dimer';

  @override
  String get labBloodFilm => 'Blood Film';

  @override
  String get labTroponin => 'Troponin I/T';

  @override
  String get labNtProBnp => 'NT-proBNP';

  @override
  String get labEcg => 'ECG (12-Lead)';

  @override
  String get labEcho => 'Echocardiogram';

  @override
  String get labCardiacEnzymes => 'Cardiac enzymes';

  @override
  String get labCxr => 'Chest X-Ray';

  @override
  String get labAxr => 'Abdominal X-Ray';

  @override
  String get labCtBrain => 'CT Brain';

  @override
  String get labCtpa => 'CT Pulmonary Angio';

  @override
  String get labAbdoUs => 'Abdominal Ultrasound';

  @override
  String get labMriBrain => 'MRI Brain';

  @override
  String get labBloodCultures => 'Blood Cultures';

  @override
  String get labUrineCulture => 'Urine Culture';

  @override
  String get labSputumCulture => 'Sputum Culture';

  @override
  String get labPcr => 'PCR COVID/Flu';

  @override
  String get labUrinalysis => 'Urinalysis';

  @override
  String get labAbg => 'Arterial Blood Gas';

  @override
  String get labPeakFlow => 'Peak Flow';

  @override
  String get simAllSpecialties => 'All Specialties';

  @override
  String get simSearchPathology => 'Search for a pathology or symptoms...';
}
