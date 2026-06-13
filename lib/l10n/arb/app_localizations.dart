import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @nameAZ.
  ///
  /// In en, this message translates to:
  /// **'Name (A-Z)'**
  String get nameAZ;

  /// No description provided for @nameZA.
  ///
  /// In en, this message translates to:
  /// **'Name (Z-A)'**
  String get nameZA;

  /// No description provided for @genericAZ.
  ///
  /// In en, this message translates to:
  /// **'Generic (A-Z)'**
  String get genericAZ;

  /// No description provided for @genericZA.
  ///
  /// In en, this message translates to:
  /// **'Generic (Z-A)'**
  String get genericZA;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @enrichedOnly.
  ///
  /// In en, this message translates to:
  /// **'Enrichis seulement'**
  String get enrichedOnly;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @noDrugsFound.
  ///
  /// In en, this message translates to:
  /// **'No drugs found.'**
  String get noDrugsFound;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @onBoardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn Medicine Smarter'**
  String get onBoardingTitle;

  /// No description provided for @onBoardingDescription.
  ///
  /// In en, this message translates to:
  /// **'Meducyte transforms the way you study with interactive tools, spaced repetition, and real clinical reasoning.'**
  String get onBoardingDescription;

  /// No description provided for @onBoardingConinueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onBoardingConinueBtn;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for drugs, diseases...'**
  String get searchHint;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'IN PROGRESS'**
  String get inProgress;

  /// No description provided for @continueQuiz.
  ///
  /// In en, this message translates to:
  /// **'Continue Quiz'**
  String get continueQuiz;

  /// No description provided for @quickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get quickAccess;

  /// No description provided for @quizTraining.
  ///
  /// In en, this message translates to:
  /// **'Quiz Training'**
  String get quizTraining;

  /// No description provided for @drugDatabase.
  ///
  /// In en, this message translates to:
  /// **'Drug Database'**
  String get drugDatabase;

  /// No description provided for @drugInteractions.
  ///
  /// In en, this message translates to:
  /// **'Drug Interactions'**
  String get drugInteractions;

  /// No description provided for @clinicalGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Clinical Guidelines'**
  String get clinicalGuidelines;

  /// No description provided for @medicalAbbreviations.
  ///
  /// In en, this message translates to:
  /// **'Medical Abbreviations'**
  String get medicalAbbreviations;

  /// No description provided for @observationReport.
  ///
  /// In en, this message translates to:
  /// **'Observation Report'**
  String get observationReport;

  /// No description provided for @clinicalCases.
  ///
  /// In en, this message translates to:
  /// **'Clinical Cases'**
  String get clinicalCases;

  /// No description provided for @medicalCalculator.
  ///
  /// In en, this message translates to:
  /// **'Medical Calculator'**
  String get medicalCalculator;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found for \"{query}\"'**
  String noResultsFound(Object query);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @medicalInsight.
  ///
  /// In en, this message translates to:
  /// **'Medical Insight'**
  String get medicalInsight;

  /// No description provided for @refreshMemory.
  ///
  /// In en, this message translates to:
  /// **'Refresh your memory'**
  String get refreshMemory;

  /// No description provided for @readArticle.
  ///
  /// In en, this message translates to:
  /// **'Read Article'**
  String get readArticle;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoal;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @viewStats.
  ///
  /// In en, this message translates to:
  /// **'View Stats'**
  String get viewStats;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @nextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get nextQuestion;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'CORRECT'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'INCORRECT'**
  String get incorrect;

  /// No description provided for @partiallyCorrect.
  ///
  /// In en, this message translates to:
  /// **'PARTIALLY CORRECT'**
  String get partiallyCorrect;

  /// No description provided for @explanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get explanation;

  /// No description provided for @reportError.
  ///
  /// In en, this message translates to:
  /// **'Report an Error'**
  String get reportError;

  /// No description provided for @selectReason.
  ///
  /// In en, this message translates to:
  /// **'Select a reason'**
  String get selectReason;

  /// No description provided for @reasonTypo.
  ///
  /// In en, this message translates to:
  /// **'Typo / Spelling Error'**
  String get reasonTypo;

  /// No description provided for @reasonInaccurate.
  ///
  /// In en, this message translates to:
  /// **'Inaccurate Information'**
  String get reasonInaccurate;

  /// No description provided for @reasonMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing Information'**
  String get reasonMissing;

  /// No description provided for @reasonUnclearExplanation.
  ///
  /// In en, this message translates to:
  /// **'Unclear Explanation'**
  String get reasonUnclearExplanation;

  /// No description provided for @reasonWrongAnswer.
  ///
  /// In en, this message translates to:
  /// **'Wrong Correct Answer'**
  String get reasonWrongAnswer;

  /// No description provided for @reasonUnclear.
  ///
  /// In en, this message translates to:
  /// **'Unclear Question/Options'**
  String get reasonUnclear;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// No description provided for @otherDescription.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe the error...'**
  String get otherDescription;

  /// No description provided for @sendReport.
  ///
  /// In en, this message translates to:
  /// **'Send Report'**
  String get sendReport;

  /// No description provided for @reportSent.
  ///
  /// In en, this message translates to:
  /// **'Report Sent Successfully!'**
  String get reportSent;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @specialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get specialty;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get profileUpdateFailed;

  /// No description provided for @profileChooseIdentity.
  ///
  /// In en, this message translates to:
  /// **'Choose your identity'**
  String get profileChooseIdentity;

  /// No description provided for @profileSelectAvatarDesc.
  ///
  /// In en, this message translates to:
  /// **'Select the avatar that matches your style'**
  String get profileSelectAvatarDesc;

  /// No description provided for @profileMedicalInterests.
  ///
  /// In en, this message translates to:
  /// **'Medical Interests'**
  String get profileMedicalInterests;

  /// No description provided for @profileSaveInterests.
  ///
  /// In en, this message translates to:
  /// **'Save Interests'**
  String get profileSaveInterests;

  /// No description provided for @profileYearPrefix.
  ///
  /// In en, this message translates to:
  /// **'Year {year}'**
  String profileYearPrefix(Object year);

  /// No description provided for @profileNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get profileNotSpecified;

  /// No description provided for @profileNotDefined.
  ///
  /// In en, this message translates to:
  /// **'Not defined'**
  String get profileNotDefined;

  /// No description provided for @profileNoInterestSelected.
  ///
  /// In en, this message translates to:
  /// **'No interest selected'**
  String get profileNoInterestSelected;

  /// No description provided for @profileStudyHabits.
  ///
  /// In en, this message translates to:
  /// **'Study Habits'**
  String get profileStudyHabits;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// No description provided for @core.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get core;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @highContrast.
  ///
  /// In en, this message translates to:
  /// **'High Contrast'**
  String get highContrast;

  /// No description provided for @userPreferences.
  ///
  /// In en, this message translates to:
  /// **'User Preferences'**
  String get userPreferences;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettingsTitle;

  /// No description provided for @notificationSettingsInfo.
  ///
  /// In en, this message translates to:
  /// **'Customize your alerts to stay focused on your goals without being interrupted.'**
  String get notificationSettingsInfo;

  /// No description provided for @globalNotifications.
  ///
  /// In en, this message translates to:
  /// **'Global Notifications'**
  String get globalNotifications;

  /// No description provided for @productiveBayRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'PRODUCTIVE BAY REMINDERS'**
  String get productiveBayRemindersTitle;

  /// No description provided for @examReminders.
  ///
  /// In en, this message translates to:
  /// **'Exams'**
  String get examReminders;

  /// No description provided for @examRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Alerts 24h before your registered exams.'**
  String get examRemindersDesc;

  /// No description provided for @taskReminders.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get taskReminders;

  /// No description provided for @taskRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Reminders 1h before your task deadlines.'**
  String get taskRemindersDesc;

  /// No description provided for @studyReminders.
  ///
  /// In en, this message translates to:
  /// **'Study Sessions'**
  String get studyReminders;

  /// No description provided for @studyRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Notifications 10 min before a session starts.'**
  String get studyRemindersDesc;

  /// No description provided for @communityNotifications.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get communityNotifications;

  /// No description provided for @communityNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Replies to your comments and mentions.'**
  String get communityNotificationsDesc;

  /// No description provided for @systemSettingsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled in system settings.'**
  String get systemSettingsPrompt;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @fontSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Text & Display Size'**
  String get fontSettingsTitle;

  /// No description provided for @fontSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Adjusting the text size helps improve readability. Changes will apply throughout the app.'**
  String get fontSettingsDesc;

  /// No description provided for @fontPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get fontPreviewTitle;

  /// No description provided for @fontPreviewText.
  ///
  /// In en, this message translates to:
  /// **'Meducyte is an advanced learning platform tailored for medical students. It offers clinical cases, flashcards, and a dedicated workspace to enhance your practical knowledge.'**
  String get fontPreviewText;

  /// No description provided for @twoHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'2 hours ago'**
  String get twoHoursAgo;

  /// No description provided for @fontSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get fontSmall;

  /// No description provided for @fontMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium (Default)'**
  String get fontMedium;

  /// No description provided for @fontLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get fontLarge;

  /// No description provided for @quizFontSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz Text Size'**
  String get quizFontSizeTitle;

  /// No description provided for @courseFontSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Course Text Size'**
  String get courseFontSizeTitle;

  /// No description provided for @shareQuestion.
  ///
  /// In en, this message translates to:
  /// **'Share Question'**
  String get shareQuestion;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get textSize;

  /// No description provided for @syncSettings.
  ///
  /// In en, this message translates to:
  /// **'Sync Settings'**
  String get syncSettings;

  /// No description provided for @spacedRepetition.
  ///
  /// In en, this message translates to:
  /// **'Spaced Repetition'**
  String get spacedRepetition;

  /// No description provided for @studyPlan.
  ///
  /// In en, this message translates to:
  /// **'Study Plan'**
  String get studyPlan;

  /// No description provided for @studyPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Study Plan Settings'**
  String get studyPlanTitle;

  /// No description provided for @studyPlanInfo.
  ///
  /// In en, this message translates to:
  /// **'Configure your daily study targets to control how many new cards and review items you tackle each day.'**
  String get studyPlanInfo;

  /// No description provided for @downloadMode.
  ///
  /// In en, this message translates to:
  /// **'Download Mode'**
  String get downloadMode;

  /// No description provided for @advancedAbout.
  ///
  /// In en, this message translates to:
  /// **'Advanced / About'**
  String get advancedAbout;

  /// No description provided for @securityPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Security & Privacy'**
  String get securityPrivacy;

  /// No description provided for @resetData.
  ///
  /// In en, this message translates to:
  /// **'Reset All Data'**
  String get resetData;

  /// No description provided for @resetDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all settings and local cache'**
  String get resetDataSubtitle;

  /// No description provided for @resetDataWarning.
  ///
  /// In en, this message translates to:
  /// **'This will clear all local settings, cached content, and logout of your account. This action cannot be undone.'**
  String get resetDataWarning;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your account and data'**
  String get deleteAccountSubtitle;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'WARNING: This action is permanent and will delete all your study progress, quiz history, and subscriptions. You cannot undo this.'**
  String get deleteAccountWarning;

  /// No description provided for @deleteConfirmationInstruction.
  ///
  /// In en, this message translates to:
  /// **'To confirm, please type \'DELETE\' below:'**
  String get deleteConfirmationInstruction;

  /// No description provided for @deleteConfirmationHint.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE here'**
  String get deleteConfirmationHint;

  /// No description provided for @dataResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'All local data has been successfully cleared.'**
  String get dataResetSuccess;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been permanently deleted.'**
  String get accountDeletedSuccess;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy & Terms'**
  String get privacyPolicy;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Customer Support'**
  String get support;

  /// No description provided for @rateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate Us'**
  String get rateUs;

  /// No description provided for @rateUsTitle.
  ///
  /// In en, this message translates to:
  /// **'How are we doing?'**
  String get rateUsTitle;

  /// No description provided for @rateUsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps us make Meducyte better for all medical students.'**
  String get rateUsSubtitle;

  /// No description provided for @rateOnStore.
  ///
  /// In en, this message translates to:
  /// **'Rate on App Store'**
  String get rateOnStore;

  /// No description provided for @rateFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get rateFeedback;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @basicPlan.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get basicPlan;

  /// No description provided for @premiumPlan.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumPlan;

  /// No description provided for @comparePlans.
  ///
  /// In en, this message translates to:
  /// **'Compare Plans'**
  String get comparePlans;

  /// No description provided for @featureAcademicModules.
  ///
  /// In en, this message translates to:
  /// **'Academic Modules'**
  String get featureAcademicModules;

  /// No description provided for @featureAiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Smart Assistant'**
  String get featureAiAssistant;

  /// No description provided for @featureClinicalCases.
  ///
  /// In en, this message translates to:
  /// **'Clinical Cases'**
  String get featureClinicalCases;

  /// No description provided for @featureAdvancedStats.
  ///
  /// In en, this message translates to:
  /// **'Advanced Statistics'**
  String get featureAdvancedStats;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @saveQuiz.
  ///
  /// In en, this message translates to:
  /// **'Save Quiz'**
  String get saveQuiz;

  /// No description provided for @saveToCollection.
  ///
  /// In en, this message translates to:
  /// **'Save to Collection'**
  String get saveToCollection;

  /// No description provided for @createCollection.
  ///
  /// In en, this message translates to:
  /// **'Create Collection'**
  String get createCollection;

  /// No description provided for @renameCollection.
  ///
  /// In en, this message translates to:
  /// **'Rename Collection'**
  String get renameCollection;

  /// No description provided for @collectionName.
  ///
  /// In en, this message translates to:
  /// **'Collection Name'**
  String get collectionName;

  /// No description provided for @quizSaved.
  ///
  /// In en, this message translates to:
  /// **'Quiz saved successfully!'**
  String get quizSaved;

  /// No description provided for @myCollections.
  ///
  /// In en, this message translates to:
  /// **'My Collections'**
  String get myCollections;

  /// No description provided for @searchCollections.
  ///
  /// In en, this message translates to:
  /// **'Search collections...'**
  String get searchCollections;

  /// No description provided for @highlight.
  ///
  /// In en, this message translates to:
  /// **'Highlight'**
  String get highlight;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// No description provided for @chooseColor.
  ///
  /// In en, this message translates to:
  /// **'Choose Color'**
  String get chooseColor;

  /// No description provided for @saveNote.
  ///
  /// In en, this message translates to:
  /// **'Save Note'**
  String get saveNote;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get editNote;

  /// No description provided for @editComment.
  ///
  /// In en, this message translates to:
  /// **'Edit Comment'**
  String get editComment;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @interactionSpace.
  ///
  /// In en, this message translates to:
  /// **'Interaction Space'**
  String get interactionSpace;

  /// No description provided for @commentsFeed.
  ///
  /// In en, this message translates to:
  /// **'Comments Feed'**
  String get commentsFeed;

  /// No description provided for @myNotes.
  ///
  /// In en, this message translates to:
  /// **'My Notes'**
  String get myNotes;

  /// No description provided for @noComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Start the conversation!'**
  String get noComments;

  /// No description provided for @noNotes.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any notes to this section yet.'**
  String get noNotes;

  /// No description provided for @addPublicComment.
  ///
  /// In en, this message translates to:
  /// **'Add a public comment...'**
  String get addPublicComment;

  /// No description provided for @selectionReminder.
  ///
  /// In en, this message translates to:
  /// **'Selection Reminder:'**
  String get selectionReminder;

  /// No description provided for @myNote.
  ///
  /// In en, this message translates to:
  /// **'My Note:'**
  String get myNote;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get edited;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @deleteCommentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this comment?'**
  String get deleteCommentConfirm;

  /// No description provided for @questionInfo.
  ///
  /// In en, this message translates to:
  /// **'Question Info'**
  String get questionInfo;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get navLearn;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navSimulation.
  ///
  /// In en, this message translates to:
  /// **'Simulation'**
  String get navSimulation;

  /// No description provided for @productiveBay.
  ///
  /// In en, this message translates to:
  /// **'Productive Bay'**
  String get productiveBay;

  /// No description provided for @focusFatigueAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Focus & Fatigue Analysis (AI)'**
  String get focusFatigueAnalysis;

  /// No description provided for @dashboardHub.
  ///
  /// In en, this message translates to:
  /// **'Dashboard Hub'**
  String get dashboardHub;

  /// No description provided for @deepWorkMode.
  ///
  /// In en, this message translates to:
  /// **'Deep Work Mode'**
  String get deepWorkMode;

  /// No description provided for @examCountdown.
  ///
  /// In en, this message translates to:
  /// **'Exam Countdown'**
  String get examCountdown;

  /// No description provided for @aiPlanner.
  ///
  /// In en, this message translates to:
  /// **'AI Planner'**
  String get aiPlanner;

  /// No description provided for @planner.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get planner;

  /// No description provided for @myTasks.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get myTasks;

  /// No description provided for @urgentTasksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Urgent Tasks'**
  String urgentTasksCount(Object count);

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @studyPatterns.
  ///
  /// In en, this message translates to:
  /// **'Study Patterns'**
  String get studyPatterns;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @studyTogether.
  ///
  /// In en, this message translates to:
  /// **'Study Together'**
  String get studyTogether;

  /// No description provided for @deepWork.
  ///
  /// In en, this message translates to:
  /// **'DEEP WORK'**
  String get deepWork;

  /// No description provided for @shortBreak.
  ///
  /// In en, this message translates to:
  /// **'SHORT BREAK'**
  String get shortBreak;

  /// No description provided for @longBreak.
  ///
  /// In en, this message translates to:
  /// **'LONG BREAK'**
  String get longBreak;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @forest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get forest;

  /// No description provided for @rain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get rain;

  /// No description provided for @waves.
  ///
  /// In en, this message translates to:
  /// **'Waves'**
  String get waves;

  /// No description provided for @focusOn.
  ///
  /// In en, this message translates to:
  /// **'Focus: {task}'**
  String focusOn(Object task);

  /// No description provided for @taskListTitle.
  ///
  /// In en, this message translates to:
  /// **'My Task List'**
  String get taskListTitle;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New Focus Task'**
  String get newTask;

  /// No description provided for @whatWillYouAchieve.
  ///
  /// In en, this message translates to:
  /// **'What will you achieve?'**
  String get whatWillYouAchieve;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @estimatedWork.
  ///
  /// In en, this message translates to:
  /// **'Work Estimation'**
  String get estimatedWork;

  /// No description provided for @addToList.
  ///
  /// In en, this message translates to:
  /// **'Add to My List'**
  String get addToList;

  /// No description provided for @jumpToQuestion.
  ///
  /// In en, this message translates to:
  /// **'Jump to Question'**
  String get jumpToQuestion;

  /// No description provided for @finishQuiz.
  ///
  /// In en, this message translates to:
  /// **'Finish Quiz'**
  String get finishQuiz;

  /// No description provided for @quizResult.
  ///
  /// In en, this message translates to:
  /// **'Quiz Result'**
  String get quizResult;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct Answer'**
  String get correctAnswer;

  /// No description provided for @clinicalCase.
  ///
  /// In en, this message translates to:
  /// **'Clinical Case'**
  String get clinicalCase;

  /// No description provided for @correctAnswers.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correctAnswers;

  /// No description provided for @incorrectAnswers.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrectAnswers;

  /// No description provided for @partiallyCorrectAnswers.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get partiallyCorrectAnswers;

  /// No description provided for @reviewErrors.
  ///
  /// In en, this message translates to:
  /// **'Review Errors'**
  String get reviewErrors;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @keepImproving.
  ///
  /// In en, this message translates to:
  /// **'Keep improving your score!'**
  String get keepImproving;

  /// No description provided for @startQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get startQuiz;

  /// No description provided for @startRevision.
  ///
  /// In en, this message translates to:
  /// **'Start Revision'**
  String get startRevision;

  /// No description provided for @numberOfQuestions.
  ///
  /// In en, this message translates to:
  /// **'Number of Questions'**
  String get numberOfQuestions;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @expert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get expert;

  /// No description provided for @practice.
  ///
  /// In en, this message translates to:
  /// **'PRACTICE'**
  String get practice;

  /// No description provided for @simulation.
  ///
  /// In en, this message translates to:
  /// **'REAL EXAM SIMULATION'**
  String get simulation;

  /// No description provided for @theoretical.
  ///
  /// In en, this message translates to:
  /// **'THEORETICAL'**
  String get theoretical;

  /// No description provided for @clinical.
  ///
  /// In en, this message translates to:
  /// **'CLINICAL'**
  String get clinical;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE'**
  String get explore;

  /// No description provided for @exploreRevision.
  ///
  /// In en, this message translates to:
  /// **'Revise Directly'**
  String get exploreRevision;

  /// No description provided for @simulationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real Exam Environment'**
  String get simulationSubtitle;

  /// No description provided for @finishRevision.
  ///
  /// In en, this message translates to:
  /// **'Finish Revision'**
  String get finishRevision;

  /// No description provided for @studyYear.
  ///
  /// In en, this message translates to:
  /// **'Study Year'**
  String get studyYear;

  /// No description provided for @chapters.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get chapters;

  /// No description provided for @lessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessons;

  /// No description provided for @lesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get lesson;

  /// No description provided for @module.
  ///
  /// In en, this message translates to:
  /// **'Module'**
  String get module;

  /// No description provided for @unitOfIntegratedTeaching.
  ///
  /// In en, this message translates to:
  /// **'Integrated Teaching Unit'**
  String get unitOfIntegratedTeaching;

  /// No description provided for @lessonCompleted.
  ///
  /// In en, this message translates to:
  /// **'Lesson Completed!'**
  String get lessonCompleted;

  /// No description provided for @finishLesson.
  ///
  /// In en, this message translates to:
  /// **'Finish Lesson'**
  String get finishLesson;

  /// No description provided for @lessonCompletedSub.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You\'ve mastered this lesson.'**
  String get lessonCompletedSub;

  /// No description provided for @finishLessonSub.
  ///
  /// In en, this message translates to:
  /// **'Ready to move on? Mark this lesson as studied.'**
  String get finishLessonSub;

  /// No description provided for @markAsUnstudied.
  ///
  /// In en, this message translates to:
  /// **'Mark as unstudied'**
  String get markAsUnstudied;

  /// No description provided for @markAsStudied.
  ///
  /// In en, this message translates to:
  /// **'Mark as studied'**
  String get markAsStudied;

  /// No description provided for @chatbotTitle.
  ///
  /// In en, this message translates to:
  /// **'Meducyte AI'**
  String get chatbotTitle;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChat;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @deleteChat.
  ///
  /// In en, this message translates to:
  /// **'Delete Chat'**
  String get deleteChat;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @askMedicalQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask a medical question...'**
  String get askMedicalQuestion;

  /// No description provided for @chatbotDescription.
  ///
  /// In en, this message translates to:
  /// **'Your Clinical Assistant'**
  String get chatbotDescription;

  /// No description provided for @askYourQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask your question...'**
  String get askYourQuestion;

  /// No description provided for @chatbotError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get chatbotError;

  /// No description provided for @chatSuggestion1.
  ///
  /// In en, this message translates to:
  /// **'How can you help me study?'**
  String get chatSuggestion1;

  /// No description provided for @chatSuggestion2.
  ///
  /// In en, this message translates to:
  /// **'Explain a complex medical concept'**
  String get chatSuggestion2;

  /// No description provided for @chatSuggestion3.
  ///
  /// In en, this message translates to:
  /// **'Summarize a pathology for me'**
  String get chatSuggestion3;

  /// No description provided for @chatSuggestion4.
  ///
  /// In en, this message translates to:
  /// **'Tell me about drug indications'**
  String get chatSuggestion4;

  /// No description provided for @chatHistory.
  ///
  /// In en, this message translates to:
  /// **'Chat History'**
  String get chatHistory;

  /// No description provided for @noHistoryFound.
  ///
  /// In en, this message translates to:
  /// **'No chat history found.'**
  String get noHistoryFound;

  /// No description provided for @databaseStatus.
  ///
  /// In en, this message translates to:
  /// **'Database Status'**
  String get databaseStatus;

  /// No description provided for @registeredDrugs.
  ///
  /// In en, this message translates to:
  /// **'Registered Drugs'**
  String get registeredDrugs;

  /// No description provided for @uniqueDrugPrincipals.
  ///
  /// In en, this message translates to:
  /// **'Unique Active Ingredients'**
  String get uniqueDrugPrincipals;

  /// No description provided for @enrichedClinicalInfos.
  ///
  /// In en, this message translates to:
  /// **'Enriched Clinical Info'**
  String get enrichedClinicalInfos;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @databaseStatistics.
  ///
  /// In en, this message translates to:
  /// **'Database Statistics'**
  String get databaseStatistics;

  /// No description provided for @enrichedOnlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show only drugs with full clinical details'**
  String get enrichedOnlySubtitle;

  /// No description provided for @therapeuticClass.
  ///
  /// In en, this message translates to:
  /// **'Therapeutic Class'**
  String get therapeuticClass;

  /// No description provided for @allClasses.
  ///
  /// In en, this message translates to:
  /// **'All Classes'**
  String get allClasses;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data.'**
  String get errorLoadingData;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @administrativeInfos.
  ///
  /// In en, this message translates to:
  /// **'Admin Details'**
  String get administrativeInfos;

  /// No description provided for @labAndForm.
  ///
  /// In en, this message translates to:
  /// **'Lab & Form'**
  String get labAndForm;

  /// No description provided for @therapeuticIndications.
  ///
  /// In en, this message translates to:
  /// **'Therapeutic Indications'**
  String get therapeuticIndications;

  /// No description provided for @contraindications.
  ///
  /// In en, this message translates to:
  /// **'Contraindications'**
  String get contraindications;

  /// No description provided for @sideEffects.
  ///
  /// In en, this message translates to:
  /// **'Side Effects'**
  String get sideEffects;

  /// No description provided for @mechanismOfAction.
  ///
  /// In en, this message translates to:
  /// **'Mechanism of Action'**
  String get mechanismOfAction;

  /// No description provided for @clinicalInfoUpdating.
  ///
  /// In en, this message translates to:
  /// **'Clinical info is updated daily...'**
  String get clinicalInfoUpdating;

  /// No description provided for @drugNotFound.
  ///
  /// In en, this message translates to:
  /// **'Drug not found'**
  String get drugNotFound;

  /// No description provided for @selectedDrugs.
  ///
  /// In en, this message translates to:
  /// **'Selected Drugs'**
  String get selectedDrugs;

  /// No description provided for @addDrug.
  ///
  /// In en, this message translates to:
  /// **'Add Drug'**
  String get addDrug;

  /// No description provided for @noDrugsSelectedPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select at least two drugs to see interactions.'**
  String get noDrugsSelectedPrompt;

  /// No description provided for @selectTwoDrugsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select at least two drugs to see interactions.'**
  String get selectTwoDrugsPrompt;

  /// No description provided for @noInteractionsFound.
  ///
  /// In en, this message translates to:
  /// **'No known interactions found between selected drugs.'**
  String get noInteractionsFound;

  /// No description provided for @management.
  ///
  /// In en, this message translates to:
  /// **'Management:'**
  String get management;

  /// No description provided for @addDrugToChecker.
  ///
  /// In en, this message translates to:
  /// **'Add Drug to Checker'**
  String get addDrugToChecker;

  /// No description provided for @searchDrugHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a drug...'**
  String get searchDrugHint;

  /// No description provided for @severe.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severe;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// No description provided for @minor.
  ///
  /// In en, this message translates to:
  /// **'Minor'**
  String get minor;

  /// No description provided for @spec_general.
  ///
  /// In en, this message translates to:
  /// **'General Practice'**
  String get spec_general;

  /// No description provided for @spec_cardiology.
  ///
  /// In en, this message translates to:
  /// **'Cardiology'**
  String get spec_cardiology;

  /// No description provided for @spec_neurology.
  ///
  /// In en, this message translates to:
  /// **'Neurology'**
  String get spec_neurology;

  /// No description provided for @spec_anesthesiereanimation.
  ///
  /// In en, this message translates to:
  /// **'Anesthesia and Recovery'**
  String get spec_anesthesiereanimation;

  /// No description provided for @spec_anesthesiereanimationpediatrique.
  ///
  /// In en, this message translates to:
  /// **'Pediatric Anesthesia'**
  String get spec_anesthesiereanimationpediatrique;

  /// No description provided for @spec_biophysiquemedicale.
  ///
  /// In en, this message translates to:
  /// **'Medical Biophysics'**
  String get spec_biophysiquemedicale;

  /// No description provided for @spec_dermatologieetvenereologie.
  ///
  /// In en, this message translates to:
  /// **'Dermatology and Venereology'**
  String get spec_dermatologieetvenereologie;

  /// No description provided for @spec_diabetologieendocrinologieetmaladiesmetaboliques.
  ///
  /// In en, this message translates to:
  /// **'Endocrinology, Diabetes, and Metabolism'**
  String get spec_diabetologieendocrinologieetmaladiesmetaboliques;

  /// No description provided for @spec_epidemiologieetmedecinepreventive.
  ///
  /// In en, this message translates to:
  /// **'Epidemiology and Preventive Medicine'**
  String get spec_epidemiologieetmedecinepreventive;

  /// No description provided for @spec_hepatogastroenterologie.
  ///
  /// In en, this message translates to:
  /// **'Hepato-Gastro-Enterology'**
  String get spec_hepatogastroenterologie;

  /// No description provided for @spec_hematologie.
  ///
  /// In en, this message translates to:
  /// **'Hematology'**
  String get spec_hematologie;

  /// No description provided for @spec_gynecologieobstetrique.
  ///
  /// In en, this message translates to:
  /// **'Gynecology and Obstetrics'**
  String get spec_gynecologieobstetrique;

  /// No description provided for @spec_infectiologie.
  ///
  /// In en, this message translates to:
  /// **'Infectious Diseases'**
  String get spec_infectiologie;

  /// No description provided for @spec_medecineinterne.
  ///
  /// In en, this message translates to:
  /// **'Internal Medicine'**
  String get spec_medecineinterne;

  /// No description provided for @spec_medecinelegaledroitmedicaletethique.
  ///
  /// In en, this message translates to:
  /// **'Legal Medicine and Medical Ethics'**
  String get spec_medecinelegaledroitmedicaletethique;

  /// No description provided for @spec_medecinenucleaireetimageriemoleculaire.
  ///
  /// In en, this message translates to:
  /// **'Nuclear Medicine and Molecular Imaging'**
  String get spec_medecinenucleaireetimageriemoleculaire;

  /// No description provided for @spec_medecinedusport.
  ///
  /// In en, this message translates to:
  /// **'Sports Medicine'**
  String get spec_medecinedusport;

  /// No description provided for @spec_medecinedutravail.
  ///
  /// In en, this message translates to:
  /// **'Occupational Medicine'**
  String get spec_medecinedutravail;

  /// No description provided for @spec_medecinephysiqueetreadaptation.
  ///
  /// In en, this message translates to:
  /// **'Physical Medicine and Rehabilitation'**
  String get spec_medecinephysiqueetreadaptation;

  /// No description provided for @spec_nephrologie.
  ///
  /// In en, this message translates to:
  /// **'Nephrology'**
  String get spec_nephrologie;

  /// No description provided for @spec_oncologiemedicale.
  ///
  /// In en, this message translates to:
  /// **'Medical Oncology'**
  String get spec_oncologiemedicale;

  /// No description provided for @spec_ophtalmologie.
  ///
  /// In en, this message translates to:
  /// **'Ophthalmology'**
  String get spec_ophtalmologie;

  /// No description provided for @spec_orl.
  ///
  /// In en, this message translates to:
  /// **'ENT (Otolaryngology)'**
  String get spec_orl;

  /// No description provided for @spec_pediatrie.
  ///
  /// In en, this message translates to:
  /// **'Pediatrics'**
  String get spec_pediatrie;

  /// No description provided for @spec_psychiatrie.
  ///
  /// In en, this message translates to:
  /// **'Psychiatrie'**
  String get spec_psychiatrie;

  /// No description provided for @spec_pedopsychiatrie.
  ///
  /// In en, this message translates to:
  /// **'Pédopsychiatrie'**
  String get spec_pedopsychiatrie;

  /// No description provided for @spec_pneumophtisiologie.
  ///
  /// In en, this message translates to:
  /// **'Pulmonology and Phthisiology'**
  String get spec_pneumophtisiologie;

  /// No description provided for @spec_radiotherapieoncologie.
  ///
  /// In en, this message translates to:
  /// **'Radiation Oncology'**
  String get spec_radiotherapieoncologie;

  /// No description provided for @spec_rhumatologie.
  ///
  /// In en, this message translates to:
  /// **'Rheumatology'**
  String get spec_rhumatologie;

  /// No description provided for @spec_reanimationmedicale.
  ///
  /// In en, this message translates to:
  /// **'Medical Intensive Care'**
  String get spec_reanimationmedicale;

  /// No description provided for @spec_chirurgiegenerale.
  ///
  /// In en, this message translates to:
  /// **'General Surgery'**
  String get spec_chirurgiegenerale;

  /// No description provided for @spec_chirurgiecardiaque.
  ///
  /// In en, this message translates to:
  /// **'Cardiac Surgery'**
  String get spec_chirurgiecardiaque;

  /// No description provided for @spec_chirurgiemaxillofaciale.
  ///
  /// In en, this message translates to:
  /// **'Maxillofacial Surgery'**
  String get spec_chirurgiemaxillofaciale;

  /// No description provided for @spec_chirurgieneurologique.
  ///
  /// In en, this message translates to:
  /// **'Neurosurgery'**
  String get spec_chirurgieneurologique;

  /// No description provided for @spec_chirurgieorthopediqueettraumatologie.
  ///
  /// In en, this message translates to:
  /// **'Orthopedic Surgery and Traumatology'**
  String get spec_chirurgieorthopediqueettraumatologie;

  /// No description provided for @spec_chirurgiepediatrique.
  ///
  /// In en, this message translates to:
  /// **'Pediatric Surgery'**
  String get spec_chirurgiepediatrique;

  /// No description provided for @spec_chirurgiethoracique.
  ///
  /// In en, this message translates to:
  /// **'Thoracic Surgery'**
  String get spec_chirurgiethoracique;

  /// No description provided for @spec_chirurgieurologique.
  ///
  /// In en, this message translates to:
  /// **'Urological Surgery'**
  String get spec_chirurgieurologique;

  /// No description provided for @spec_chirurgievasculaire.
  ///
  /// In en, this message translates to:
  /// **'Vascular Surgery'**
  String get spec_chirurgievasculaire;

  /// No description provided for @spec_chirurgieplastiquereconstructriceesthetiqueetdebrulologie.
  ///
  /// In en, this message translates to:
  /// **'Plastic, Reconstructive, and Aesthetic Surgery'**
  String get spec_chirurgieplastiquereconstructriceesthetiqueetdebrulologie;

  /// No description provided for @spec_pulmonology.
  ///
  /// In en, this message translates to:
  /// **'Pulmonology'**
  String get spec_pulmonology;

  /// No description provided for @spec_endocrinology.
  ///
  /// In en, this message translates to:
  /// **'Endocrinology'**
  String get spec_endocrinology;

  /// No description provided for @spec_surgery.
  ///
  /// In en, this message translates to:
  /// **'Surgery'**
  String get spec_surgery;

  /// No description provided for @spec_orthopedics.
  ///
  /// In en, this message translates to:
  /// **'Orthopedics'**
  String get spec_orthopedics;

  /// No description provided for @spec_urology.
  ///
  /// In en, this message translates to:
  /// **'Urology'**
  String get spec_urology;

  /// No description provided for @spec_radiology.
  ///
  /// In en, this message translates to:
  /// **'Radiology'**
  String get spec_radiology;

  /// No description provided for @spec_pathology.
  ///
  /// In en, this message translates to:
  /// **'Pathology'**
  String get spec_pathology;

  /// No description provided for @spec_emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency Medicine'**
  String get spec_emergency;

  /// No description provided for @selectSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Select Specialty'**
  String get selectSpecialty;

  /// No description provided for @chooseTemplateDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a template tailored to your medical specialty for faster reporting.'**
  String get chooseTemplateDescription;

  /// No description provided for @addParameter.
  ///
  /// In en, this message translates to:
  /// **'Add a parameter'**
  String get addParameter;

  /// No description provided for @parameterNameHint.
  ///
  /// In en, this message translates to:
  /// **'Parameter name (e.g. CK-MB)'**
  String get parameterNameHint;

  /// No description provided for @addExam.
  ///
  /// In en, this message translates to:
  /// **'Add an exam:'**
  String get addExam;

  /// No description provided for @pendingOrNotProvided.
  ///
  /// In en, this message translates to:
  /// **'- *Pending / Not provided*'**
  String get pendingOrNotProvided;

  /// No description provided for @enterResultHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the result...'**
  String get enterResultHint;

  /// No description provided for @selectExamHint.
  ///
  /// In en, this message translates to:
  /// **'Choose an exam'**
  String get selectExamHint;

  /// No description provided for @observationHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get observationHistory;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @noSavedReports.
  ///
  /// In en, this message translates to:
  /// **'No saved reports found.'**
  String get noSavedReports;

  /// No description provided for @deleteReportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this report?'**
  String get deleteReportConfirm;

  /// No description provided for @reportSaved.
  ///
  /// In en, this message translates to:
  /// **'Report saved successfully!'**
  String get reportSaved;

  /// No description provided for @loadReport.
  ///
  /// In en, this message translates to:
  /// **'Load Report'**
  String get loadReport;

  /// No description provided for @searchPatients.
  ///
  /// In en, this message translates to:
  /// **'Search patients...'**
  String get searchPatients;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @gender_male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get gender_male;

  /// No description provided for @gender_female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get gender_female;

  /// No description provided for @intro_patient_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Patient Name'**
  String get intro_patient_name_hint;

  /// No description provided for @intro_age_hint.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get intro_age_hint;

  /// No description provided for @intro_origin_hint.
  ///
  /// In en, this message translates to:
  /// **'City / Neighborhood'**
  String get intro_origin_hint;

  /// No description provided for @intro_marital_status_hint.
  ///
  /// In en, this message translates to:
  /// **'Marital Status'**
  String get intro_marital_status_hint;

  /// No description provided for @intro_profession_hint.
  ///
  /// In en, this message translates to:
  /// **'Profession'**
  String get intro_profession_hint;

  /// No description provided for @intro_date_hint.
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YYYY'**
  String get intro_date_hint;

  /// No description provided for @intro_signs_hint.
  ///
  /// In en, this message translates to:
  /// **'Clinical Signs'**
  String get intro_signs_hint;

  /// No description provided for @intro_patient_prefix.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get intro_patient_prefix;

  /// No description provided for @intro_age_label_masculine.
  ///
  /// In en, this message translates to:
  /// **'years old'**
  String get intro_age_label_masculine;

  /// No description provided for @intro_age_label_feminine.
  ///
  /// In en, this message translates to:
  /// **'years old'**
  String get intro_age_label_feminine;

  /// No description provided for @intro_age_prefix.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get intro_age_prefix;

  /// No description provided for @intro_origin_prefix.
  ///
  /// In en, this message translates to:
  /// **' residing in '**
  String get intro_origin_prefix;

  /// No description provided for @intro_admitted_masculine.
  ///
  /// In en, this message translates to:
  /// **'admitted on'**
  String get intro_admitted_masculine;

  /// No description provided for @intro_admitted_feminine.
  ///
  /// In en, this message translates to:
  /// **'admitted on'**
  String get intro_admitted_feminine;

  /// No description provided for @intro_date_prefix.
  ///
  /// In en, this message translates to:
  /// **' '**
  String get intro_date_prefix;

  /// No description provided for @intro_for_prefix.
  ///
  /// In en, this message translates to:
  /// **' for: '**
  String get intro_for_prefix;

  /// No description provided for @section_introduction.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get section_introduction;

  /// No description provided for @section_motif.
  ///
  /// In en, this message translates to:
  /// **'Reason for Admission'**
  String get section_motif;

  /// No description provided for @section_history.
  ///
  /// In en, this message translates to:
  /// **'History of the Illness'**
  String get section_history;

  /// No description provided for @section_antecedents.
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get section_antecedents;

  /// No description provided for @section_general_vitals.
  ///
  /// In en, this message translates to:
  /// **'Clinical Exam - General State & Vitals'**
  String get section_general_vitals;

  /// No description provided for @section_paraclinical.
  ///
  /// In en, this message translates to:
  /// **'Paraclinical Exams'**
  String get section_paraclinical;

  /// No description provided for @section_summary.
  ///
  /// In en, this message translates to:
  /// **'Syndromic Summary'**
  String get section_summary;

  /// No description provided for @section_conclusion.
  ///
  /// In en, this message translates to:
  /// **'Conclusion / Management Plan'**
  String get section_conclusion;

  /// No description provided for @vitals_bp.
  ///
  /// In en, this message translates to:
  /// **'BP'**
  String get vitals_bp;

  /// No description provided for @vitals_hr.
  ///
  /// In en, this message translates to:
  /// **'HR'**
  String get vitals_hr;

  /// No description provided for @vitals_rr.
  ///
  /// In en, this message translates to:
  /// **'RR'**
  String get vitals_rr;

  /// No description provided for @vitals_temp.
  ///
  /// In en, this message translates to:
  /// **'Temp'**
  String get vitals_temp;

  /// No description provided for @vitals_spo2.
  ///
  /// In en, this message translates to:
  /// **'SpO2'**
  String get vitals_spo2;

  /// No description provided for @addCustomSection.
  ///
  /// In en, this message translates to:
  /// **'Add custom section'**
  String get addCustomSection;

  /// No description provided for @exam_general_state_label.
  ///
  /// In en, this message translates to:
  /// **'Global Impression / General State'**
  String get exam_general_state_label;

  /// No description provided for @exam_general_state_hint.
  ///
  /// In en, this message translates to:
  /// **'Good general state, conscious, cooperative, well-oriented'**
  String get exam_general_state_hint;

  /// No description provided for @exam_hydration_label.
  ///
  /// In en, this message translates to:
  /// **'Hydration and Nutrition'**
  String get exam_hydration_label;

  /// No description provided for @exam_hydration_hint.
  ///
  /// In en, this message translates to:
  /// **'No dehydration fold, BMI within normal range'**
  String get exam_hydration_hint;

  /// No description provided for @exam_head_neck_label.
  ///
  /// In en, this message translates to:
  /// **'Head and Neck Exam'**
  String get exam_head_neck_label;

  /// No description provided for @exam_head_neck_hint.
  ///
  /// In en, this message translates to:
  /// **'Pink conjunctiva, no icterus, healthy oral cavity'**
  String get exam_head_neck_hint;

  /// No description provided for @exam_respiratory_label.
  ///
  /// In en, this message translates to:
  /// **'Respiratory / Pulmonary Exam'**
  String get exam_respiratory_label;

  /// No description provided for @exam_respiratory_hint.
  ///
  /// In en, this message translates to:
  /// **'Vesicular murmur present and symmetrical'**
  String get exam_respiratory_hint;

  /// No description provided for @exam_cardio_label.
  ///
  /// In en, this message translates to:
  /// **'Cardiovascular Exam'**
  String get exam_cardio_label;

  /// No description provided for @exam_cardio_hint.
  ///
  /// In en, this message translates to:
  /// **'Regular heart sounds, no murmur'**
  String get exam_cardio_hint;

  /// No description provided for @exam_abdominal_label.
  ///
  /// In en, this message translates to:
  /// **'Abdominal Exam'**
  String get exam_abdominal_label;

  /// No description provided for @exam_abdominal_hint.
  ///
  /// In en, this message translates to:
  /// **'Soft abdomen, depressible, painless'**
  String get exam_abdominal_hint;

  /// No description provided for @exam_urogenital_label.
  ///
  /// In en, this message translates to:
  /// **'Urogenital Exam'**
  String get exam_urogenital_label;

  /// No description provided for @exam_urogenital_hint.
  ///
  /// In en, this message translates to:
  /// **'Free lumbar pits'**
  String get exam_urogenital_hint;

  /// No description provided for @exam_locomotor_label.
  ///
  /// In en, this message translates to:
  /// **'Locomotor / Joint Exam'**
  String get exam_locomotor_label;

  /// No description provided for @exam_locomotor_hint.
  ///
  /// In en, this message translates to:
  /// **'Full range of motion, no inflammatory signs'**
  String get exam_locomotor_hint;

  /// No description provided for @exam_neuro_mental_label.
  ///
  /// In en, this message translates to:
  /// **'Neurological / Mental Exam'**
  String get exam_neuro_mental_label;

  /// No description provided for @exam_neuro_mental_hint.
  ///
  /// In en, this message translates to:
  /// **'Full strength and sensation, no meningeal signs'**
  String get exam_neuro_mental_hint;

  /// No description provided for @exam_skin_label.
  ///
  /// In en, this message translates to:
  /// **'Skin / Dermatological Exam'**
  String get exam_skin_label;

  /// No description provided for @exam_skin_hint.
  ///
  /// In en, this message translates to:
  /// **'No suspicious lesions, no purpura'**
  String get exam_skin_hint;

  /// No description provided for @exam_cardio_edema_label.
  ///
  /// In en, this message translates to:
  /// **'Inspection: Edema'**
  String get exam_cardio_edema_label;

  /// No description provided for @exam_cardio_edema_hint.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get exam_cardio_edema_hint;

  /// No description provided for @exam_cardio_cyanosis_label.
  ///
  /// In en, this message translates to:
  /// **'Inspection: Cyanosis'**
  String get exam_cardio_cyanosis_label;

  /// No description provided for @exam_cardio_cyanosis_hint.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get exam_cardio_cyanosis_hint;

  /// No description provided for @exam_neuro_glasgow_label.
  ///
  /// In en, this message translates to:
  /// **'Consciousness (Glasgow)'**
  String get exam_neuro_glasgow_label;

  /// No description provided for @exam_neuro_glasgow_hint.
  ///
  /// In en, this message translates to:
  /// **'15/15'**
  String get exam_neuro_glasgow_hint;

  /// No description provided for @exam_neuro_orient_label.
  ///
  /// In en, this message translates to:
  /// **'Orientation'**
  String get exam_neuro_orient_label;

  /// No description provided for @exam_neuro_orient_hint.
  ///
  /// In en, this message translates to:
  /// **'Well-oriented'**
  String get exam_neuro_orient_hint;

  /// No description provided for @yourJourney.
  ///
  /// In en, this message translates to:
  /// **'Your Journey'**
  String get yourJourney;

  /// No description provided for @noModulesForYear.
  ///
  /// In en, this message translates to:
  /// **'No modules found for this year.'**
  String get noModulesForYear;

  /// No description provided for @accessContent.
  ///
  /// In en, this message translates to:
  /// **'Access Content'**
  String get accessContent;

  /// No description provided for @quickTraining.
  ///
  /// In en, this message translates to:
  /// **'Quick Training'**
  String get quickTraining;

  /// No description provided for @readingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Reading in Progress'**
  String get readingInProgress;

  /// No description provided for @firstYearOrdinal.
  ///
  /// In en, this message translates to:
  /// **'1st Year'**
  String get firstYearOrdinal;

  /// No description provided for @otherYearOrdinal.
  ///
  /// In en, this message translates to:
  /// **'{year}th Year'**
  String otherYearOrdinal(Object year);

  /// No description provided for @noLessonsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No lessons available.'**
  String get noLessonsAvailable;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @modules.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get modules;

  /// No description provided for @quizzes.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizzes;

  /// No description provided for @upgradeToResidencyToUnlockYears.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Residency plan to unlock these years!'**
  String get upgradeToResidencyToUnlockYears;

  /// No description provided for @studyTools.
  ///
  /// In en, this message translates to:
  /// **'Study Tools'**
  String get studyTools;

  /// No description provided for @performanceStats.
  ///
  /// In en, this message translates to:
  /// **'Performance Stats'**
  String get performanceStats;

  /// No description provided for @accuracyLabel.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracyLabel;

  /// No description provided for @streakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakLabel;

  /// No description provided for @daysLabel.
  ///
  /// In en, this message translates to:
  /// **'{days} Days'**
  String daysLabel(Object days);

  /// No description provided for @reviseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'By module or specialty'**
  String get reviseSubtitle;

  /// No description provided for @simulateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real exam environment'**
  String get simulateSubtitle;

  /// No description provided for @revisionModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read and revise content'**
  String get revisionModeSubtitle;

  /// No description provided for @questionDetails.
  ///
  /// In en, this message translates to:
  /// **'Question Details'**
  String get questionDetails;

  /// No description provided for @noQuestionsFound.
  ///
  /// In en, this message translates to:
  /// **'No questions found.'**
  String get noQuestionsFound;

  /// No description provided for @selectPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectPrompt;

  /// No description provided for @deleteHighlight.
  ///
  /// In en, this message translates to:
  /// **'Delete Highlight'**
  String get deleteHighlight;

  /// No description provided for @editNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get editNoteLabel;

  /// No description provided for @flashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get flashcards;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @savedQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Saved Quizzes'**
  String get savedQuizzes;

  /// No description provided for @residencyExam.
  ///
  /// In en, this message translates to:
  /// **'Residency Exam'**
  String get residencyExam;

  /// No description provided for @allOrNothingScore.
  ///
  /// In en, this message translates to:
  /// **'All or\nNothing'**
  String get allOrNothingScore;

  /// No description provided for @partialPointsScore.
  ///
  /// In en, this message translates to:
  /// **'Partial\nPoints'**
  String get partialPointsScore;

  /// No description provided for @unsaveQuestion.
  ///
  /// In en, this message translates to:
  /// **'Unsave Question'**
  String get unsaveQuestion;

  /// No description provided for @unsaveQuestionConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unsave this question?'**
  String get unsaveQuestionConfirmation;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @questionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String questionsCount(Object count);

  /// No description provided for @voiceReader.
  ///
  /// In en, this message translates to:
  /// **'Voice Reader'**
  String get voiceReader;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @voiceSettings.
  ///
  /// In en, this message translates to:
  /// **'Voice Settings'**
  String get voiceSettings;

  /// No description provided for @aiHelper.
  ///
  /// In en, this message translates to:
  /// **'AI Helper'**
  String get aiHelper;

  /// No description provided for @explain.
  ///
  /// In en, this message translates to:
  /// **'Explain'**
  String get explain;

  /// No description provided for @summarize.
  ///
  /// In en, this message translates to:
  /// **'Summarize'**
  String get summarize;

  /// No description provided for @mnemonic.
  ///
  /// In en, this message translates to:
  /// **'Mnemonic'**
  String get mnemonic;

  /// No description provided for @refine.
  ///
  /// In en, this message translates to:
  /// **'Refine'**
  String get refine;

  /// No description provided for @printLesson.
  ///
  /// In en, this message translates to:
  /// **'Print Lesson'**
  String get printLesson;

  /// No description provided for @generatingPdf.
  ///
  /// In en, this message translates to:
  /// **'Generating PDF...'**
  String get generatingPdf;

  /// No description provided for @paragraph.
  ///
  /// In en, this message translates to:
  /// **'Paragraph'**
  String get paragraph;

  /// No description provided for @sq3rTechnique.
  ///
  /// In en, this message translates to:
  /// **'SQ3R Technique'**
  String get sq3rTechnique;

  /// No description provided for @activeRecall.
  ///
  /// In en, this message translates to:
  /// **'Active Recall'**
  String get activeRecall;

  /// No description provided for @moreTools.
  ///
  /// In en, this message translates to:
  /// **'More Tools'**
  String get moreTools;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @reportQuestion.
  ///
  /// In en, this message translates to:
  /// **'Report Question'**
  String get reportQuestion;

  /// No description provided for @quizHub.
  ///
  /// In en, this message translates to:
  /// **'Quiz Hub'**
  String get quizHub;

  /// No description provided for @studyDecks.
  ///
  /// In en, this message translates to:
  /// **'STUDY DECKS'**
  String get studyDecks;

  /// No description provided for @savedQuizzesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Study your personally saved questions'**
  String get savedQuizzesSubtitle;

  /// No description provided for @spacedRepetitionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Focus on cards due for review'**
  String get spacedRepetitionSubtitle;

  /// No description provided for @byModule.
  ///
  /// In en, this message translates to:
  /// **'By Module'**
  String get byModule;

  /// No description provided for @byModuleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate cards from specific modules'**
  String get byModuleSubtitle;

  /// No description provided for @masterYourMemory.
  ///
  /// In en, this message translates to:
  /// **'Master Your Memory'**
  String get masterYourMemory;

  /// No description provided for @flashcardsHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Convert any question into a flashcard and use spaced repetition to never forget.'**
  String get flashcardsHeaderSubtitle;

  /// No description provided for @noSavedQuestionsToStudy.
  ///
  /// In en, this message translates to:
  /// **'No saved questions found to study.'**
  String get noSavedQuestionsToStudy;

  /// No description provided for @errorLoadingQuestions.
  ///
  /// In en, this message translates to:
  /// **'Error loading questions'**
  String get errorLoadingQuestions;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up! No cards due for review.'**
  String get allCaughtUp;

  /// No description provided for @noCardsToStudy.
  ///
  /// In en, this message translates to:
  /// **'No cards to study.'**
  String get noCardsToStudy;

  /// No description provided for @showAnswerToGrade.
  ///
  /// In en, this message translates to:
  /// **'Show the answer to grade yourself'**
  String get showAnswerToGrade;

  /// No description provided for @howWellDidYouRecall.
  ///
  /// In en, this message translates to:
  /// **'HOW WELL DID YOU RECALL THIS?'**
  String get howWellDidYouRecall;

  /// No description provided for @studyComplete.
  ///
  /// In en, this message translates to:
  /// **'STUDY COMPLETE'**
  String get studyComplete;

  /// No description provided for @studySummary.
  ///
  /// In en, this message translates to:
  /// **'You have reviewed {count} cards in {time}'**
  String studySummary(Object count, Object time);

  /// No description provided for @questionLabel.
  ///
  /// In en, this message translates to:
  /// **'QUESTION'**
  String get questionLabel;

  /// No description provided for @tapToFlip.
  ///
  /// In en, this message translates to:
  /// **'TAP TO FLIP'**
  String get tapToFlip;

  /// No description provided for @correctAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'CORRECT ANSWER'**
  String get correctAnswerLabel;

  /// No description provided for @clinicalContext.
  ///
  /// In en, this message translates to:
  /// **'CLINICAL CONTEXT'**
  String get clinicalContext;

  /// No description provided for @nowGradeYourRecall.
  ///
  /// In en, this message translates to:
  /// **'NOW GRADE YOUR RECALL'**
  String get nowGradeYourRecall;

  /// No description provided for @performanceAgain.
  ///
  /// In en, this message translates to:
  /// **'AGAIN'**
  String get performanceAgain;

  /// No description provided for @performanceHard.
  ///
  /// In en, this message translates to:
  /// **'HARD'**
  String get performanceHard;

  /// No description provided for @performanceGood.
  ///
  /// In en, this message translates to:
  /// **'GOOD'**
  String get performanceGood;

  /// No description provided for @performanceEasy.
  ///
  /// In en, this message translates to:
  /// **'EASY'**
  String get performanceEasy;

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @studyByFolder.
  ///
  /// In en, this message translates to:
  /// **'Study questions from a specific folder'**
  String get studyByFolder;

  /// No description provided for @selectModule.
  ///
  /// In en, this message translates to:
  /// **'Select Module'**
  String get selectModule;

  /// No description provided for @selectFolder.
  ///
  /// In en, this message translates to:
  /// **'Select Folder'**
  String get selectFolder;

  /// No description provided for @startNewQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start a new quiz'**
  String get startNewQuiz;

  /// No description provided for @noActiveQuiz.
  ///
  /// In en, this message translates to:
  /// **'No quiz in progress'**
  String get noActiveQuiz;

  /// No description provided for @checkBackTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Check back tomorrow for new reviews.'**
  String get checkBackTomorrow;

  /// No description provided for @srsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your SRS list is empty'**
  String get srsEmptyTitle;

  /// No description provided for @srsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add questions to spaced repetition during your quiz sessions to start your journey.'**
  String get srsEmptySubtitle;

  /// No description provided for @learningLabel.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get learningLabel;

  /// No description provided for @masteredLabel.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get masteredLabel;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'DUE TODAY'**
  String get dueToday;

  /// No description provided for @startReviewCount.
  ///
  /// In en, this message translates to:
  /// **'START REVIEW ({count})'**
  String startReviewCount(Object count);

  /// No description provided for @srsDueTitle.
  ///
  /// In en, this message translates to:
  /// **'Spaced Repetition'**
  String get srsDueTitle;

  /// No description provided for @cardsDueText.
  ///
  /// In en, this message translates to:
  /// **'You have {count} cards due for review'**
  String cardsDueText(Object count);

  /// No description provided for @startReview.
  ///
  /// In en, this message translates to:
  /// **'Start Review'**
  String get startReview;

  /// No description provided for @sessionComplete.
  ///
  /// In en, this message translates to:
  /// **'Session Complete'**
  String get sessionComplete;

  /// No description provided for @greatJob.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get greatJob;

  /// No description provided for @completionTime.
  ///
  /// In en, this message translates to:
  /// **'You completed your review in {time}'**
  String completionTime(Object time);

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'FINISH'**
  String get finish;

  /// No description provided for @resetProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Progress?'**
  String get resetProgressTitle;

  /// No description provided for @resetProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your SRS review data. This action cannot be undone.'**
  String get resetProgressSubtitle;

  /// No description provided for @srsReset.
  ///
  /// In en, this message translates to:
  /// **'RESET'**
  String get srsReset;

  /// No description provided for @srsResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'SRS progress has been reset.'**
  String get srsResetSuccess;

  /// No description provided for @srsSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SRS Settings'**
  String get srsSettingsTitle;

  /// No description provided for @srsSettingsInfo.
  ///
  /// In en, this message translates to:
  /// **'Customize your learning pace and review reminders.'**
  String get srsSettingsInfo;

  /// No description provided for @srsNewCardsTitle.
  ///
  /// In en, this message translates to:
  /// **'New Cards per Day'**
  String get srsNewCardsTitle;

  /// No description provided for @srsNewCardsDesc.
  ///
  /// In en, this message translates to:
  /// **'Control how many new questions are introduced daily.'**
  String get srsNewCardsDesc;

  /// No description provided for @srsReviewLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Review Limit'**
  String get srsReviewLimitTitle;

  /// No description provided for @srsReviewLimitDesc.
  ///
  /// In en, this message translates to:
  /// **'Maximum number of cards to review in a single day.'**
  String get srsReviewLimitDesc;

  /// No description provided for @srsNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Reminders'**
  String get srsNotificationTitle;

  /// No description provided for @srsNotificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified when you have cards due for review.'**
  String get srsNotificationDesc;

  /// No description provided for @srsNotificationTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get srsNotificationTimeTitle;

  /// No description provided for @addedToSrs.
  ///
  /// In en, this message translates to:
  /// **'Added to Spaced Repetition'**
  String get addedToSrs;

  /// No description provided for @errorLoadingQuestionsShort.
  ///
  /// In en, this message translates to:
  /// **'Error loading questions'**
  String get errorLoadingQuestionsShort;

  /// No description provided for @noQuestionsInModule.
  ///
  /// In en, this message translates to:
  /// **'No questions found for this module'**
  String get noQuestionsInModule;

  /// No description provided for @noQuestionsInFolder.
  ///
  /// In en, this message translates to:
  /// **'No questions in this folder'**
  String get noQuestionsInFolder;

  /// No description provided for @premiumContent.
  ///
  /// In en, this message translates to:
  /// **'Premium Content'**
  String get premiumContent;

  /// No description provided for @unlockPremiumDescription.
  ///
  /// In en, this message translates to:
  /// **'This feature is part of our premium content. Subscribe now to get full access!'**
  String get unlockPremiumDescription;

  /// No description provided for @discoverPlans.
  ///
  /// In en, this message translates to:
  /// **'Discover Plans'**
  String get discoverPlans;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

  /// No description provided for @testFeatures.
  ///
  /// In en, this message translates to:
  /// **'Test Features'**
  String get testFeatures;

  /// No description provided for @sendTestNotification.
  ///
  /// In en, this message translates to:
  /// **'Send a test notification'**
  String get sendTestNotification;

  /// No description provided for @selectBestOption.
  ///
  /// In en, this message translates to:
  /// **'Select the best option'**
  String get selectBestOption;

  /// No description provided for @correctionMode.
  ///
  /// In en, this message translates to:
  /// **'Correction mode'**
  String get correctionMode;

  /// No description provided for @instantCorrection.
  ///
  /// In en, this message translates to:
  /// **'Instant Correction'**
  String get instantCorrection;

  /// No description provided for @instantCorrectionDesc.
  ///
  /// In en, this message translates to:
  /// **'See results immediately after each question'**
  String get instantCorrectionDesc;

  /// No description provided for @deferredCorrection.
  ///
  /// In en, this message translates to:
  /// **'Deferred Correction'**
  String get deferredCorrection;

  /// No description provided for @deferredCorrectionDesc.
  ///
  /// In en, this message translates to:
  /// **'See results only after finishing the quiz'**
  String get deferredCorrectionDesc;

  /// No description provided for @personalNote.
  ///
  /// In en, this message translates to:
  /// **'Personal Note'**
  String get personalNote;

  /// No description provided for @communityComments.
  ///
  /// In en, this message translates to:
  /// **'Community Comments'**
  String get communityComments;

  /// No description provided for @saveQuestion.
  ///
  /// In en, this message translates to:
  /// **'Save Question'**
  String get saveQuestion;

  /// No description provided for @removeFromSrs.
  ///
  /// In en, this message translates to:
  /// **'Remove from Spaced Repetition'**
  String get removeFromSrs;

  /// No description provided for @removedFromSrs.
  ///
  /// In en, this message translates to:
  /// **'Removed from Spaced Repetition'**
  String get removedFromSrs;

  /// No description provided for @exploreDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover resources, clinical tools, and our global medical community.'**
  String get exploreDescription;

  /// No description provided for @medicalWorld.
  ///
  /// In en, this message translates to:
  /// **'Medical World'**
  String get medicalWorld;

  /// No description provided for @externalResources.
  ///
  /// In en, this message translates to:
  /// **'Resources & Community'**
  String get externalResources;

  /// No description provided for @interpretationHelpers.
  ///
  /// In en, this message translates to:
  /// **'Interpretation Helpers'**
  String get interpretationHelpers;

  /// No description provided for @caseOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Case of the Day'**
  String get caseOfTheDay;

  /// No description provided for @medicalNews.
  ///
  /// In en, this message translates to:
  /// **'Medical News'**
  String get medicalNews;

  /// No description provided for @clinicalPearls.
  ///
  /// In en, this message translates to:
  /// **'Clinical Pearls'**
  String get clinicalPearls;

  /// No description provided for @quickCalcHub.
  ///
  /// In en, this message translates to:
  /// **'Quick Calculators'**
  String get quickCalcHub;

  /// No description provided for @joinOfficialDrive.
  ///
  /// In en, this message translates to:
  /// **'Join Official Drive'**
  String get joinOfficialDrive;

  /// No description provided for @joinTelegram.
  ///
  /// In en, this message translates to:
  /// **'Join Telegram Community'**
  String get joinTelegram;

  /// No description provided for @booksLibrary.
  ///
  /// In en, this message translates to:
  /// **'Medical Books'**
  String get booksLibrary;

  /// No description provided for @booksLibraryDesc.
  ///
  /// In en, this message translates to:
  /// **'Download medical books and manuals'**
  String get booksLibraryDesc;

  /// No description provided for @firstAid.
  ///
  /// In en, this message translates to:
  /// **'First Aid'**
  String get firstAid;

  /// No description provided for @firstAidDesc.
  ///
  /// In en, this message translates to:
  /// **'Life-saving techniques and emergencies'**
  String get firstAidDesc;

  /// No description provided for @ecgInterpretation.
  ///
  /// In en, this message translates to:
  /// **'ECG Interpretation Helper'**
  String get ecgInterpretation;

  /// No description provided for @radiologyHelper.
  ///
  /// In en, this message translates to:
  /// **'Radiology Guide (Chest X-Ray)'**
  String get radiologyHelper;

  /// No description provided for @labInterpretation.
  ///
  /// In en, this message translates to:
  /// **'Laboratory Interpretation Helper'**
  String get labInterpretation;

  /// No description provided for @simulationDescription.
  ///
  /// In en, this message translates to:
  /// **'Practice medicine in a safe environment.'**
  String get simulationDescription;

  /// No description provided for @aiPatientInteraction.
  ///
  /// In en, this message translates to:
  /// **'AI Patient Interaction'**
  String get aiPatientInteraction;

  /// No description provided for @ecosExamSimulator.
  ///
  /// In en, this message translates to:
  /// **'ECOS Exam Simulator'**
  String get ecosExamSimulator;

  /// No description provided for @emergencyRoomChallenge.
  ///
  /// In en, this message translates to:
  /// **'Emergency Room Challenge'**
  String get emergencyRoomChallenge;

  /// No description provided for @virtualWardRounds.
  ///
  /// In en, this message translates to:
  /// **'Virtual Ward Rounds'**
  String get virtualWardRounds;

  /// No description provided for @diagnosticChallenge.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic Challenge'**
  String get diagnosticChallenge;

  /// No description provided for @proceduralGuide.
  ///
  /// In en, this message translates to:
  /// **'Procedural Simulator'**
  String get proceduralGuide;

  /// No description provided for @globalLeaderboards.
  ///
  /// In en, this message translates to:
  /// **'Global Leaderboards'**
  String get globalLeaderboards;

  /// No description provided for @aiPatientDesc.
  ///
  /// In en, this message translates to:
  /// **'Interact with AI patients'**
  String get aiPatientDesc;

  /// No description provided for @ecosDesc.
  ///
  /// In en, this message translates to:
  /// **'Prepare for clinical exams'**
  String get ecosDesc;

  /// No description provided for @erChallengeDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage medical emergencies'**
  String get erChallengeDesc;

  /// No description provided for @wardRoundsDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage your own ward'**
  String get wardRoundsDesc;

  /// No description provided for @diagnosticChallengeDesc.
  ///
  /// In en, this message translates to:
  /// **'Master medical imaging'**
  String get diagnosticChallengeDesc;

  /// No description provided for @proceduralGuideDesc.
  ///
  /// In en, this message translates to:
  /// **'Learn clinical procedures'**
  String get proceduralGuideDesc;

  /// No description provided for @leaderboardsDesc.
  ///
  /// In en, this message translates to:
  /// **'Challenge other students'**
  String get leaderboardsDesc;

  /// No description provided for @coreSimulations.
  ///
  /// In en, this message translates to:
  /// **'Core Simulations'**
  String get coreSimulations;

  /// No description provided for @specializedExams.
  ///
  /// In en, this message translates to:
  /// **'Specialized Exams'**
  String get specializedExams;

  /// No description provided for @driveDescription.
  ///
  /// In en, this message translates to:
  /// **'Thousands of medical documents'**
  String get driveDescription;

  /// No description provided for @telegramDescription.
  ///
  /// In en, this message translates to:
  /// **'Join our active community'**
  String get telegramDescription;

  /// No description provided for @caseOfDayDescription.
  ///
  /// In en, this message translates to:
  /// **'Daily clinical reasoning'**
  String get caseOfDayDescription;

  /// No description provided for @medicalNewsDescription.
  ///
  /// In en, this message translates to:
  /// **'Latest medical breakthroughs'**
  String get medicalNewsDescription;

  /// No description provided for @clinicalPearlsDescription.
  ///
  /// In en, this message translates to:
  /// **'Daily medical tips and tricks'**
  String get clinicalPearlsDescription;

  /// No description provided for @calcHubDescription.
  ///
  /// In en, this message translates to:
  /// **'Essential medical calculators'**
  String get calcHubDescription;

  /// No description provided for @interactiveLearning.
  ///
  /// In en, this message translates to:
  /// **'Interactive Learning'**
  String get interactiveLearning;

  /// No description provided for @questionNavigation.
  ///
  /// In en, this message translates to:
  /// **'Question Navigation'**
  String get questionNavigation;

  /// No description provided for @correction.
  ///
  /// In en, this message translates to:
  /// **'Correction'**
  String get correction;

  /// No description provided for @ecgInterpretationReport.
  ///
  /// In en, this message translates to:
  /// **'ECG Interpretation Report'**
  String get ecgInterpretationReport;

  /// No description provided for @ecgAnalysisReport.
  ///
  /// In en, this message translates to:
  /// **'ECG ANALYSIS REPORT'**
  String get ecgAnalysisReport;

  /// No description provided for @ecgCase.
  ///
  /// In en, this message translates to:
  /// **'Case'**
  String get ecgCase;

  /// No description provided for @ecgAiActive.
  ///
  /// In en, this message translates to:
  /// **'AI ACTIVE'**
  String get ecgAiActive;

  /// No description provided for @ecgHeartRate.
  ///
  /// In en, this message translates to:
  /// **'HEART RATE'**
  String get ecgHeartRate;

  /// No description provided for @ecgQtcInterval.
  ///
  /// In en, this message translates to:
  /// **'QTC INTERVAL'**
  String get ecgQtcInterval;

  /// No description provided for @ecgRhythmAnalysis.
  ///
  /// In en, this message translates to:
  /// **'RHYTHM ANALYSIS'**
  String get ecgRhythmAnalysis;

  /// No description provided for @ecgAiConfidence.
  ///
  /// In en, this message translates to:
  /// **'AI CONFIDENCE'**
  String get ecgAiConfidence;

  /// No description provided for @ecgLeadClinicalGrid.
  ///
  /// In en, this message translates to:
  /// **'12-LEAD CLINICAL GRID'**
  String get ecgLeadClinicalGrid;

  /// No description provided for @ecgGuidedInterpretation.
  ///
  /// In en, this message translates to:
  /// **'Guided Interpretation Checklist'**
  String get ecgGuidedInterpretation;

  /// No description provided for @ecgShareReport.
  ///
  /// In en, this message translates to:
  /// **'Share Report'**
  String get ecgShareReport;

  /// No description provided for @ecgEducationalTool.
  ///
  /// In en, this message translates to:
  /// **'Educational Tool Only'**
  String get ecgEducationalTool;

  /// No description provided for @ecgEducationalToolDesc.
  ///
  /// In en, this message translates to:
  /// **'This interactive guide is designed strictly for medical trainees. It is NOT a certified medical device and must never be used for clinical diagnosis.'**
  String get ecgEducationalToolDesc;

  /// No description provided for @ecgSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'ECG Reference Source'**
  String get ecgSourceTitle;

  /// No description provided for @ecgSourceCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get ecgSourceCamera;

  /// No description provided for @ecgSourceGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get ecgSourceGallery;

  /// No description provided for @ecgSourceDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get ecgSourceDraw;

  /// No description provided for @ecgSourceClear.
  ///
  /// In en, this message translates to:
  /// **'Clear Image'**
  String get ecgSourceClear;

  /// No description provided for @ecgStatusNormal.
  ///
  /// In en, this message translates to:
  /// **'NORMAL'**
  String get ecgStatusNormal;

  /// No description provided for @ecgStatusStable.
  ///
  /// In en, this message translates to:
  /// **'STABLE'**
  String get ecgStatusStable;

  /// No description provided for @ecgStatusClear.
  ///
  /// In en, this message translates to:
  /// **'CLEAR'**
  String get ecgStatusClear;

  /// No description provided for @ecgStatusIschemia.
  ///
  /// In en, this message translates to:
  /// **'ISCHEMIA'**
  String get ecgStatusIschemia;

  /// No description provided for @ecgChapterRateRhythm.
  ///
  /// In en, this message translates to:
  /// **'1. Rate & Rhythm'**
  String get ecgChapterRateRhythm;

  /// No description provided for @ecgChapterAxisIntervals.
  ///
  /// In en, this message translates to:
  /// **'2. Axis & Intervals'**
  String get ecgChapterAxisIntervals;

  /// No description provided for @ecgChapterIschemiaInfarction.
  ///
  /// In en, this message translates to:
  /// **'3. Ischemia & Infarctus'**
  String get ecgChapterIschemiaInfarction;

  /// No description provided for @ecgChapterHypertrophyConduction.
  ///
  /// In en, this message translates to:
  /// **'4. Hypertrophy & Conduction'**
  String get ecgChapterHypertrophyConduction;

  /// No description provided for @ecgChapterPatternRecognition.
  ///
  /// In en, this message translates to:
  /// **'5. Pattern Recognition'**
  String get ecgChapterPatternRecognition;

  /// No description provided for @ecgChapterClinicalCorrelation.
  ///
  /// In en, this message translates to:
  /// **'6. Clinical Correlation'**
  String get ecgChapterClinicalCorrelation;

  /// No description provided for @ecgRrCalculator.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate Calculator (Regular Rhythm)'**
  String get ecgRrCalculator;

  /// No description provided for @ecgSmallSquares.
  ///
  /// In en, this message translates to:
  /// **'Small Squares (R-R)'**
  String get ecgSmallSquares;

  /// No description provided for @ecgQtcCalculator.
  ///
  /// In en, this message translates to:
  /// **'QTc Bazett Calculator'**
  String get ecgQtcCalculator;

  /// No description provided for @ecgQtInterval.
  ///
  /// In en, this message translates to:
  /// **'QT Interval (Small Squares)'**
  String get ecgQtInterval;

  /// No description provided for @ecgProlonged.
  ///
  /// In en, this message translates to:
  /// **'Prolonged'**
  String get ecgProlonged;

  /// No description provided for @ecgNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get ecgNormal;

  /// No description provided for @ecgLeadI.
  ///
  /// In en, this message translates to:
  /// **'Lead I'**
  String get ecgLeadI;

  /// No description provided for @ecgLeadaVF.
  ///
  /// In en, this message translates to:
  /// **'Lead aVF'**
  String get ecgLeadaVF;

  /// No description provided for @ecgPositive.
  ///
  /// In en, this message translates to:
  /// **'Positive (+)'**
  String get ecgPositive;

  /// No description provided for @ecgNegative.
  ///
  /// In en, this message translates to:
  /// **'Negative (-)'**
  String get ecgNegative;

  /// No description provided for @ecgEquivocal.
  ///
  /// In en, this message translates to:
  /// **'Equivocal'**
  String get ecgEquivocal;

  /// No description provided for @ecgTerritoryLateral.
  ///
  /// In en, this message translates to:
  /// **'Lateral'**
  String get ecgTerritoryLateral;

  /// No description provided for @ecgTerritoryInferior.
  ///
  /// In en, this message translates to:
  /// **'Inferior'**
  String get ecgTerritoryInferior;

  /// No description provided for @ecgTerritorySeptal.
  ///
  /// In en, this message translates to:
  /// **'Septal'**
  String get ecgTerritorySeptal;

  /// No description provided for @ecgTerritoryAnterior.
  ///
  /// In en, this message translates to:
  /// **'Anterior'**
  String get ecgTerritoryAnterior;

  /// No description provided for @ecgTerritoryReciprocal.
  ///
  /// In en, this message translates to:
  /// **'Reciprocal'**
  String get ecgTerritoryReciprocal;

  /// No description provided for @ecgAbnormalLeadsDetected.
  ///
  /// In en, this message translates to:
  /// **'Abnormalities detected in leads'**
  String get ecgAbnormalLeadsDetected;

  /// No description provided for @ecgCheckRhythmRegular.
  ///
  /// In en, this message translates to:
  /// **'Is the rhythm regular?'**
  String get ecgCheckRhythmRegular;

  /// No description provided for @ecgCheckRhythmRegularDesc.
  ///
  /// In en, this message translates to:
  /// **'Check if the distance between consecutive R waves is consistent.'**
  String get ecgCheckRhythmRegularDesc;

  /// No description provided for @ecgCheckPWave.
  ///
  /// In en, this message translates to:
  /// **'Is there a P wave before every QRS?'**
  String get ecgCheckPWave;

  /// No description provided for @ecgCheckPWaveDesc.
  ///
  /// In en, this message translates to:
  /// **'Confirms rhythm originated in the Sinus Node.'**
  String get ecgCheckPWaveDesc;

  /// No description provided for @ecgLeadIDirection.
  ///
  /// In en, this message translates to:
  /// **'Lead I (QRS direction)'**
  String get ecgLeadIDirection;

  /// No description provided for @ecgLeadaVFDirection.
  ///
  /// In en, this message translates to:
  /// **'Lead aVF (QRS direction)'**
  String get ecgLeadaVFDirection;

  /// No description provided for @ecgCurrentAxis.
  ///
  /// In en, this message translates to:
  /// **'Current Axis'**
  String get ecgCurrentAxis;

  /// No description provided for @ecgCheckStElevation.
  ///
  /// In en, this message translates to:
  /// **'ST Elevation > 1mm?'**
  String get ecgCheckStElevation;

  /// No description provided for @ecgCheckStElevationDesc.
  ///
  /// In en, this message translates to:
  /// **'Look for J-point elevation in contiguous leads.'**
  String get ecgCheckStElevationDesc;

  /// No description provided for @ecgCheckStDepression.
  ///
  /// In en, this message translates to:
  /// **'ST Depression?'**
  String get ecgCheckStDepression;

  /// No description provided for @ecgCheckStDepressionDesc.
  ///
  /// In en, this message translates to:
  /// **'Significant if horizontal or down-sloping > 0.5mm.'**
  String get ecgCheckStDepressionDesc;

  /// No description provided for @ecgCheckTWaveInversion.
  ///
  /// In en, this message translates to:
  /// **'T-Wave Inversion?'**
  String get ecgCheckTWaveInversion;

  /// No description provided for @ecgCheckTWaveInversionDesc.
  ///
  /// In en, this message translates to:
  /// **'Symmetrical inversion in V1-V6 suggests ischemia.'**
  String get ecgCheckTWaveInversionDesc;

  /// No description provided for @ecgCheckQrsWide.
  ///
  /// In en, this message translates to:
  /// **'QRS > 120ms (3 small sq)?'**
  String get ecgCheckQrsWide;

  /// No description provided for @ecgCheckQrsWideDesc.
  ///
  /// In en, this message translates to:
  /// **'Consider Bundle Branch Blocks.'**
  String get ecgCheckQrsWideDesc;

  /// No description provided for @ecgCheckSokolow.
  ///
  /// In en, this message translates to:
  /// **'Sokolow-Lyon Criteria?'**
  String get ecgCheckSokolow;

  /// No description provided for @ecgCheckSokolowDesc.
  ///
  /// In en, this message translates to:
  /// **'S in V1 + R in V5/V6 > 35mm suggests LVH.'**
  String get ecgCheckSokolowDesc;

  /// No description provided for @ecgCheckHyperkalemia.
  ///
  /// In en, this message translates to:
  /// **'Hyperkalemia Patterns?'**
  String get ecgCheckHyperkalemia;

  /// No description provided for @ecgCheckHyperkalemiaDesc.
  ///
  /// In en, this message translates to:
  /// **'Peaked T-waves, flattened P-waves, wide QRS.'**
  String get ecgCheckHyperkalemiaDesc;

  /// No description provided for @ecgCheckPe.
  ///
  /// In en, this message translates to:
  /// **'Pulmonary Embolism (S1Q3T3)?'**
  String get ecgCheckPe;

  /// No description provided for @ecgCheckPeDesc.
  ///
  /// In en, this message translates to:
  /// **'Deep S in I, Q in III, inverted T in III.'**
  String get ecgCheckPeDesc;

  /// No description provided for @ecgCheckBrugada.
  ///
  /// In en, this message translates to:
  /// **'Brugada Pattern?'**
  String get ecgCheckBrugada;

  /// No description provided for @ecgCheckBrugadaDesc.
  ///
  /// In en, this message translates to:
  /// **'Coved ST elevation followed by inverted T in V1-V2.'**
  String get ecgCheckBrugadaDesc;

  /// No description provided for @ecgCheckChestPain.
  ///
  /// In en, this message translates to:
  /// **'Chest Pain / Dyspnea?'**
  String get ecgCheckChestPain;

  /// No description provided for @ecgCheckChestPainDesc.
  ///
  /// In en, this message translates to:
  /// **'Symptoms must correlate with ECG findings.'**
  String get ecgCheckChestPainDesc;

  /// No description provided for @ecgCheckPreviousEcg.
  ///
  /// In en, this message translates to:
  /// **'Previous ECG available?'**
  String get ecgCheckPreviousEcg;

  /// No description provided for @ecgCheckPreviousEcgDesc.
  ///
  /// In en, this message translates to:
  /// **'Comparison is key to identifying acute changes.'**
  String get ecgCheckPreviousEcgDesc;

  /// No description provided for @ecgChapterPWavePr.
  ///
  /// In en, this message translates to:
  /// **'3. P Wave & PR Interval'**
  String get ecgChapterPWavePr;

  /// No description provided for @ecgChapterQrs.
  ///
  /// In en, this message translates to:
  /// **'4. QRS Complex'**
  String get ecgChapterQrs;

  /// No description provided for @ecgChapterStTWave.
  ///
  /// In en, this message translates to:
  /// **'5. ST Segment & T Wave'**
  String get ecgChapterStTWave;

  /// No description provided for @ecgChapterQtInterval.
  ///
  /// In en, this message translates to:
  /// **'6. QT Interval (QTc)'**
  String get ecgChapterQtInterval;

  /// No description provided for @ecgChapterBlockHypertrophy.
  ///
  /// In en, this message translates to:
  /// **'7. Bundle Branch & Hypertrophy'**
  String get ecgChapterBlockHypertrophy;

  /// No description provided for @ecgChapterTerritories.
  ///
  /// In en, this message translates to:
  /// **'8. Infarction Territories'**
  String get ecgChapterTerritories;

  /// No description provided for @ecgChapterElectrolytes.
  ///
  /// In en, this message translates to:
  /// **'9. Electrolytes & ECG'**
  String get ecgChapterElectrolytes;

  /// No description provided for @ecgStatusAnalyzed.
  ///
  /// In en, this message translates to:
  /// **'ANALYZED'**
  String get ecgStatusAnalyzed;

  /// No description provided for @ecgStatusNoIschemia.
  ///
  /// In en, this message translates to:
  /// **'NO ISCHEMIA'**
  String get ecgStatusNoIschemia;

  /// No description provided for @ecgStatusAbsent.
  ///
  /// In en, this message translates to:
  /// **'ABSENT'**
  String get ecgStatusAbsent;

  /// No description provided for @ecgStatusUnremarkable.
  ///
  /// In en, this message translates to:
  /// **'UNREMARKABLE'**
  String get ecgStatusUnremarkable;

  /// No description provided for @ecgPWaveLeadII.
  ///
  /// In en, this message translates to:
  /// **'P Wave (Lead II)'**
  String get ecgPWaveLeadII;

  /// No description provided for @ecgCheckPMitrale.
  ///
  /// In en, this message translates to:
  /// **'P wave duration < 120ms (3 small sq)?'**
  String get ecgCheckPMitrale;

  /// No description provided for @ecgCheckPMitraleDesc.
  ///
  /// In en, this message translates to:
  /// **'Long duration suggests left atrial enlargement (P mitrale).'**
  String get ecgCheckPMitraleDesc;

  /// No description provided for @ecgCheckPPulmonale.
  ///
  /// In en, this message translates to:
  /// **'P wave amplitude < 2.5mm (2.5 small sq)?'**
  String get ecgCheckPPulmonale;

  /// No description provided for @ecgCheckPPulmonaleDesc.
  ///
  /// In en, this message translates to:
  /// **'Tall P waves suggest right atrial enlargement (P pulmonale).'**
  String get ecgCheckPPulmonaleDesc;

  /// No description provided for @ecgPrInterval.
  ///
  /// In en, this message translates to:
  /// **'PR Interval'**
  String get ecgPrInterval;

  /// No description provided for @ecgCheckPrDuration.
  ///
  /// In en, this message translates to:
  /// **'PR interval between 120-200ms (3-5 small sq)?'**
  String get ecgCheckPrDuration;

  /// No description provided for @ecgCheckPrDurationDesc.
  ///
  /// In en, this message translates to:
  /// **'Short PR (<120ms) suggests WPW. Long PR (>200ms) suggests 1st degree block.'**
  String get ecgCheckPrDurationDesc;

  /// No description provided for @ecgCheckQrsDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration < 120ms (3 small squares)?'**
  String get ecgCheckQrsDuration;

  /// No description provided for @ecgCheckQrsDurationDesc.
  ///
  /// In en, this message translates to:
  /// **'Wide QRS (>120ms) indicates a Bundle Branch Block.'**
  String get ecgCheckQrsDurationDesc;

  /// No description provided for @ecgCheckPathologicalQ.
  ///
  /// In en, this message translates to:
  /// **'Pathological Q waves absent (>1 small sq)?'**
  String get ecgCheckPathologicalQ;

  /// No description provided for @ecgCheckPathologicalQDesc.
  ///
  /// In en, this message translates to:
  /// **'A large Q wave suggests a previous myocardial infarction.'**
  String get ecgCheckPathologicalQDesc;

  /// No description provided for @ecgCheckQrsAmplitude.
  ///
  /// In en, this message translates to:
  /// **'QRS amplitude normal?'**
  String get ecgCheckQrsAmplitude;

  /// No description provided for @ecgCheckQrsAmplitudeDesc.
  ///
  /// In en, this message translates to:
  /// **'Low voltage suggests effusion/obesity. High voltage suggests hypertrophy.'**
  String get ecgCheckQrsAmplitudeDesc;

  /// No description provided for @ecgStSegmentIschemia.
  ///
  /// In en, this message translates to:
  /// **'ST Segment (Ischemia/Infarct)'**
  String get ecgStSegmentIschemia;

  /// No description provided for @ecgCheckStIsoelectric.
  ///
  /// In en, this message translates to:
  /// **'Is ST at the isoelectric line?'**
  String get ecgCheckStIsoelectric;

  /// No description provided for @ecgCheckStIsoelectricDesc.
  ///
  /// In en, this message translates to:
  /// **'Deviation from the baseline suggests myocardial injury.'**
  String get ecgCheckStIsoelectricDesc;

  /// No description provided for @ecgTWave.
  ///
  /// In en, this message translates to:
  /// **'T Wave'**
  String get ecgTWave;

  /// No description provided for @ecgCheckTWaveUpright.
  ///
  /// In en, this message translates to:
  /// **'T waves upright (except aVR/V1)?'**
  String get ecgCheckTWaveUpright;

  /// No description provided for @ecgCheckTWaveUprightDesc.
  ///
  /// In en, this message translates to:
  /// **'Inverted T waves can indicate ischemia or strain.'**
  String get ecgCheckTWaveUprightDesc;

  /// No description provided for @ecgBazettCalculator.
  ///
  /// In en, this message translates to:
  /// **'Bazett Calculator'**
  String get ecgBazettCalculator;

  /// No description provided for @ecgQtSmallSquares.
  ///
  /// In en, this message translates to:
  /// **'QT (small squares)'**
  String get ecgQtSmallSquares;

  /// No description provided for @ecgWarningQtProlonged.
  ///
  /// In en, this message translates to:
  /// **'WARNING: QTc is prolonged. Risk of Torsades de Pointes.'**
  String get ecgWarningQtProlonged;

  /// No description provided for @ecgCheckQtHalfRr.
  ///
  /// In en, this message translates to:
  /// **'Is QT < half of R-R interval?'**
  String get ecgCheckQtHalfRr;

  /// No description provided for @ecgCheckQtHalfRrDesc.
  ///
  /// In en, this message translates to:
  /// **'Quick visual rule for estimating QT length.'**
  String get ecgCheckQtHalfRrDesc;

  /// No description provided for @ecgBundleBranchBlocks.
  ///
  /// In en, this message translates to:
  /// **'Bundle Branch Blocks'**
  String get ecgBundleBranchBlocks;

  /// No description provided for @ecgWilliamMarrow.
  ///
  /// In en, this message translates to:
  /// **'WiLLiaM MaRRoW Rule:\n- W in V1, M in V6 -> LBBB\n- M in V1, W in V6 -> RBBB'**
  String get ecgWilliamMarrow;

  /// No description provided for @ecgCheckV1MsShape.
  ///
  /// In en, this message translates to:
  /// **'V1: rsR\' pattern (M shape)?'**
  String get ecgCheckV1MsShape;

  /// No description provided for @ecgCheckV1MsShapeDesc.
  ///
  /// In en, this message translates to:
  /// **'Indicates Right Bundle Branch Block (RBBB).'**
  String get ecgCheckV1MsShapeDesc;

  /// No description provided for @ecgCheckV6SlurredS.
  ///
  /// In en, this message translates to:
  /// **'V6: Slurred S wave?'**
  String get ecgCheckV6SlurredS;

  /// No description provided for @ecgCheckV6SlurredSDesc.
  ///
  /// In en, this message translates to:
  /// **'Associated finding in RBBB.'**
  String get ecgCheckV6SlurredSDesc;

  /// No description provided for @ecgLeftVentricularHypertrophy.
  ///
  /// In en, this message translates to:
  /// **'Left Ventricular Hypertrophy (LVH)'**
  String get ecgLeftVentricularHypertrophy;

  /// No description provided for @ecgCheckSokolowLyon.
  ///
  /// In en, this message translates to:
  /// **'S in V1 + R in V5/V6 > 35mm?'**
  String get ecgCheckSokolowLyon;

  /// No description provided for @ecgCheckSokolowLyonDesc.
  ///
  /// In en, this message translates to:
  /// **'Standard Sokolow-Lyon criteria for LVH.'**
  String get ecgCheckSokolowLyonDesc;

  /// No description provided for @ecgCoronaryTerritories.
  ///
  /// In en, this message translates to:
  /// **'Coronary Territories'**
  String get ecgCoronaryTerritories;

  /// No description provided for @ecgTerritoryMap.
  ///
  /// In en, this message translates to:
  /// **'Inferior: II, III, aVF\nLateral: I, aVL, V5, V6\nAnterior: V1-V4'**
  String get ecgTerritoryMap;

  /// No description provided for @ecgElectrolytesTarget.
  ///
  /// In en, this message translates to:
  /// **'Current Target'**
  String get ecgElectrolytesTarget;

  /// No description provided for @ecgHyperkalemia.
  ///
  /// In en, this message translates to:
  /// **'Hyperkalemia:'**
  String get ecgHyperkalemia;

  /// No description provided for @ecgHyperkalemiaDesc.
  ///
  /// In en, this message translates to:
  /// **'Peaked T waves, QRS widening, loss of P wave.'**
  String get ecgHyperkalemiaDesc;

  /// No description provided for @ecgHypokalemia.
  ///
  /// In en, this message translates to:
  /// **'Hypokalemia:'**
  String get ecgHypokalemia;

  /// No description provided for @ecgHypokalemiaDesc.
  ///
  /// In en, this message translates to:
  /// **'U waves, flattened/inverted T waves, ST depression.'**
  String get ecgHypokalemiaDesc;

  /// No description provided for @ecgCalciumTitle.
  ///
  /// In en, this message translates to:
  /// **'Calcium (Ca2+)'**
  String get ecgCalciumTitle;

  /// No description provided for @ecgHypercalcemia.
  ///
  /// In en, this message translates to:
  /// **'Hypercalcemia: Short QT interval.'**
  String get ecgHypercalcemia;

  /// No description provided for @ecgHypocalcemia.
  ///
  /// In en, this message translates to:
  /// **'Hypocalcemia: Long QT interval.'**
  String get ecgHypocalcemia;

  /// No description provided for @ecgPdfCriteria.
  ///
  /// In en, this message translates to:
  /// **'Criteria'**
  String get ecgPdfCriteria;

  /// No description provided for @ecgPdfEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Evaluation'**
  String get ecgPdfEvaluation;

  /// No description provided for @ecgPdfYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get ecgPdfYes;

  /// No description provided for @ecgPdfNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get ecgPdfNo;

  /// No description provided for @ecgPdfUnanswered.
  ///
  /// In en, this message translates to:
  /// **'Unanswered'**
  String get ecgPdfUnanswered;

  /// No description provided for @ecgPdfResponses.
  ///
  /// In en, this message translates to:
  /// **'Interpretation Responses'**
  String get ecgPdfResponses;

  /// No description provided for @ecgPdfDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Note: This report is for educational purposes only and does not constitute a clinical diagnosis.'**
  String get ecgPdfDisclaimer;

  /// No description provided for @ecgAxisNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal Axis'**
  String get ecgAxisNormal;

  /// No description provided for @ecgAxisLad.
  ///
  /// In en, this message translates to:
  /// **'Left Axis Deviation (LAD)'**
  String get ecgAxisLad;

  /// No description provided for @ecgAxisRad.
  ///
  /// In en, this message translates to:
  /// **'Right Axis Deviation (RAD)'**
  String get ecgAxisRad;

  /// No description provided for @ecgAxisExtreme.
  ///
  /// In en, this message translates to:
  /// **'Extreme Axis'**
  String get ecgAxisExtreme;

  /// No description provided for @ecgAxisIndeterminate.
  ///
  /// In en, this message translates to:
  /// **'Indeterminate'**
  String get ecgAxisIndeterminate;

  /// No description provided for @ecgPdfDeducedAxis.
  ///
  /// In en, this message translates to:
  /// **'Deduced Axis'**
  String get ecgPdfDeducedAxis;

  /// No description provided for @ecgBpm.
  ///
  /// In en, this message translates to:
  /// **'BPM'**
  String get ecgBpm;

  /// No description provided for @ecgClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get ecgClear;

  /// No description provided for @ecgPdfReportTitle.
  ///
  /// In en, this message translates to:
  /// **'ECG Interpretation Report'**
  String get ecgPdfReportTitle;

  /// No description provided for @radInterpretationReport.
  ///
  /// In en, this message translates to:
  /// **'Radiology Interpretation Report'**
  String get radInterpretationReport;

  /// No description provided for @radAnalysisReport.
  ///
  /// In en, this message translates to:
  /// **'RADIOLOGY ANALYSIS REPORT'**
  String get radAnalysisReport;

  /// No description provided for @radCase.
  ///
  /// In en, this message translates to:
  /// **'Case'**
  String get radCase;

  /// No description provided for @radAiActive.
  ///
  /// In en, this message translates to:
  /// **'AI ACTIVE'**
  String get radAiActive;

  /// No description provided for @radEducationalTool.
  ///
  /// In en, this message translates to:
  /// **'Educational Tool Only'**
  String get radEducationalTool;

  /// No description provided for @radEducationalToolDesc.
  ///
  /// In en, this message translates to:
  /// **'This interactive guide is designed strictly for medical trainees. It is NOT a certified medical device and must never be used for clinical diagnosis.'**
  String get radEducationalToolDesc;

  /// No description provided for @radShareReport.
  ///
  /// In en, this message translates to:
  /// **'Share Report'**
  String get radShareReport;

  /// No description provided for @radGuidedInterpretation.
  ///
  /// In en, this message translates to:
  /// **'Radiology Interpretation Checklist'**
  String get radGuidedInterpretation;

  /// No description provided for @radSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Radiology Reference Source'**
  String get radSourceTitle;

  /// No description provided for @radSourceCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get radSourceCamera;

  /// No description provided for @radSourceGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get radSourceGallery;

  /// No description provided for @radSourceDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get radSourceDraw;

  /// No description provided for @radSourceClear.
  ///
  /// In en, this message translates to:
  /// **'Clear Image'**
  String get radSourceClear;

  /// No description provided for @radStatusNormal.
  ///
  /// In en, this message translates to:
  /// **'NORMAL'**
  String get radStatusNormal;

  /// No description provided for @radStatusStable.
  ///
  /// In en, this message translates to:
  /// **'STABLE'**
  String get radStatusStable;

  /// No description provided for @radStatusClear.
  ///
  /// In en, this message translates to:
  /// **'CLEAR'**
  String get radStatusClear;

  /// No description provided for @radChapterAirway.
  ///
  /// In en, this message translates to:
  /// **'A - Airway'**
  String get radChapterAirway;

  /// No description provided for @radChapterBreathing.
  ///
  /// In en, this message translates to:
  /// **'B - Breathing'**
  String get radChapterBreathing;

  /// No description provided for @radChapterCirculation.
  ///
  /// In en, this message translates to:
  /// **'C - Circulation'**
  String get radChapterCirculation;

  /// No description provided for @radChapterDiaphragm.
  ///
  /// In en, this message translates to:
  /// **'D - Diaphragm'**
  String get radChapterDiaphragm;

  /// No description provided for @radChapterEverythingElse.
  ///
  /// In en, this message translates to:
  /// **'E - Everything Else (Bones & Soft Tissues)'**
  String get radChapterEverythingElse;

  /// No description provided for @radCheckTracheaCentral.
  ///
  /// In en, this message translates to:
  /// **'Is the trachea central?'**
  String get radCheckTracheaCentral;

  /// No description provided for @radCheckTracheaCentralDesc.
  ///
  /// In en, this message translates to:
  /// **'Check for deviation away from (tension pneumothorax) or towards (atelectasis) a lesion.'**
  String get radCheckTracheaCentralDesc;

  /// No description provided for @radCheckLungsExpanded.
  ///
  /// In en, this message translates to:
  /// **'Are the lungs well expanded?'**
  String get radCheckLungsExpanded;

  /// No description provided for @radCheckLungsExpandedDesc.
  ///
  /// In en, this message translates to:
  /// **'Ensure you can see at least 10 posterior ribs to confirm good inspiration.'**
  String get radCheckLungsExpandedDesc;

  /// No description provided for @radCheckCostophrenicAngles.
  ///
  /// In en, this message translates to:
  /// **'Are costophrenic angles sharp?'**
  String get radCheckCostophrenicAngles;

  /// No description provided for @radCheckCostophrenicAnglesDesc.
  ///
  /// In en, this message translates to:
  /// **'Blunting suggests pleural effusion or previous scarring.'**
  String get radCheckCostophrenicAnglesDesc;

  /// No description provided for @radCheckHeartSize.
  ///
  /// In en, this message translates to:
  /// **'Is the heart size normal?'**
  String get radCheckHeartSize;

  /// No description provided for @radCheckHeartSizeDesc.
  ///
  /// In en, this message translates to:
  /// **'Cardiothoracic Ratio (CTR) should be less than 0.5 on a PA film.'**
  String get radCheckHeartSizeDesc;

  /// No description provided for @radCheckDiaphragmPosition.
  ///
  /// In en, this message translates to:
  /// **'Is the diaphragm position normal?'**
  String get radCheckDiaphragmPosition;

  /// No description provided for @radCheckDiaphragmPositionDesc.
  ///
  /// In en, this message translates to:
  /// **'Right hemidiaphragm is usually slightly higher (due to the liver).'**
  String get radCheckDiaphragmPositionDesc;

  /// No description provided for @radCheckBonesSoftTissues.
  ///
  /// In en, this message translates to:
  /// **'Bones and soft tissues unremarkable?'**
  String get radCheckBonesSoftTissues;

  /// No description provided for @radCheckBonesSoftTissuesDesc.
  ///
  /// In en, this message translates to:
  /// **'Check for fractures, surgical emphysema, or foreign bodies.'**
  String get radCheckBonesSoftTissuesDesc;

  /// No description provided for @radLearnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get radLearnMore;

  /// No description provided for @radTipAirwayTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing the Airway'**
  String get radTipAirwayTitle;

  /// No description provided for @radTipAirwayDesc.
  ///
  /// In en, this message translates to:
  /// **'The trachea should be midline. Deviation *away* from a pathology suggests tension pneumothorax or large effusion. Deviation *towards* suggests collapse or fibrosis. Identify the carina (NG tubes should be below it).'**
  String get radTipAirwayDesc;

  /// No description provided for @radTipBreathingTitle.
  ///
  /// In en, this message translates to:
  /// **'Evaluating the Lungs'**
  String get radTipBreathingTitle;

  /// No description provided for @radTipBreathingDesc.
  ///
  /// In en, this message translates to:
  /// **'Count the ribs: 10 posterior ribs indicate good inspiration. Compare lung fields for symmetry in density. Look for pleural lines (pneumothorax) or consolidations (pneumonia).'**
  String get radTipBreathingDesc;

  /// No description provided for @radTipCirculationTitle.
  ///
  /// In en, this message translates to:
  /// **'Heart & Mediastinum'**
  String get radTipCirculationTitle;

  /// No description provided for @radTipCirculationDesc.
  ///
  /// In en, this message translates to:
  /// **'The Cardiothoracic Ratio (CTR) should be < 50% on a PA film. The \'Silhouette Sign\' helps localize opacities: if the right heart border is lost, the opacity is in the middle lobe.'**
  String get radTipCirculationDesc;

  /// No description provided for @radTipDiaphragmTitle.
  ///
  /// In en, this message translates to:
  /// **'The Diaphragm'**
  String get radTipDiaphragmTitle;

  /// No description provided for @radTipDiaphragmDesc.
  ///
  /// In en, this message translates to:
  /// **'The right hemidiaphragm is higher than the left. \'Air under the diaphragm\' (pneumoperitoneum) is a surgical emergency. Ensure costophrenic angles are acute and not blunted.'**
  String get radTipDiaphragmDesc;

  /// No description provided for @radTipEverythingElseTitle.
  ///
  /// In en, this message translates to:
  /// **'Extra-thoracic Structures'**
  String get radTipEverythingElseTitle;

  /// No description provided for @radTipEverythingElseDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan the bones (ribs, clavicles) for fractures or lytic lesions. Check soft tissues for surgical emphysema (air pockets). Finally, systematically trace every line, tube, and drain.'**
  String get radTipEverythingElseDesc;

  /// No description provided for @radChapterDiagnosisGuide.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis Guide'**
  String get radChapterDiagnosisGuide;

  /// No description provided for @radDiagnosisPneumonia.
  ///
  /// In en, this message translates to:
  /// **'Pneumonia'**
  String get radDiagnosisPneumonia;

  /// No description provided for @radDiagnosisPneumoniaDesc.
  ///
  /// In en, this message translates to:
  /// **'Look for consolidation, air bronchograms, and silhouette signs.'**
  String get radDiagnosisPneumoniaDesc;

  /// No description provided for @radDiagnosisHeartFailure.
  ///
  /// In en, this message translates to:
  /// **'Heart Failure (Edema)'**
  String get radDiagnosisHeartFailure;

  /// No description provided for @radDiagnosisHeartFailureDesc.
  ///
  /// In en, this message translates to:
  /// **'Look for cardiomegaly, Kerley B lines, and pleural effusion.'**
  String get radDiagnosisHeartFailureDesc;

  /// No description provided for @radDiagnosisPneumothorax.
  ///
  /// In en, this message translates to:
  /// **'Pneumothorax'**
  String get radDiagnosisPneumothorax;

  /// No description provided for @radDiagnosisPneumothoraxDesc.
  ///
  /// In en, this message translates to:
  /// **'Identify a visible pleural line without distal lung markings.'**
  String get radDiagnosisPneumothoraxDesc;

  /// No description provided for @radDiagnosisEffusion.
  ///
  /// In en, this message translates to:
  /// **'Pleural Effusion'**
  String get radDiagnosisEffusion;

  /// No description provided for @radDiagnosisEffusionDesc.
  ///
  /// In en, this message translates to:
  /// **'Look for blunted costophrenic angles and meniscus signs.'**
  String get radDiagnosisEffusionDesc;

  /// No description provided for @radDiagnosisAtelectasis.
  ///
  /// In en, this message translates to:
  /// **'Atelectasis (Collapse)'**
  String get radDiagnosisAtelectasis;

  /// No description provided for @radDiagnosisAtelectasisDesc.
  ///
  /// In en, this message translates to:
  /// **'Look for volume loss, tracheal deviation towards the lesion, and linear opacities.'**
  String get radDiagnosisAtelectasisDesc;

  /// No description provided for @radSyndromeParietal.
  ///
  /// In en, this message translates to:
  /// **'Parietal Syndrome'**
  String get radSyndromeParietal;

  /// No description provided for @radSyndromeParietalDesc.
  ///
  /// In en, this message translates to:
  /// **'**Definition**:\nThe set of radiological signs corresponding to a lesion of the thoracic wall (soft tissues or bones).\n\n**Radiological Semiology**:\n* **Soft tissues**: Peripheral opacity of watery density, homogeneous, sharp contour if tangential, smooth \'pente douce\' connection.\n* **Bone lesions**: Osteolytic or condensing (bone lysis, notch-type rib erosion, pathological fracture).\n\n**Description of images (Illustrated Semiology)**:\n* **Peripheral opacity**: Water-density, homogeneous.\n* **Wall connection**: Smooth \'pente douce\' with an obtuse connection angle.\n* **Pleural line sign**: Sharp interface with the lung parenchyma.\n* **Dimensions**: Horizontal diameter (base) of the opacity almost as large as its vertical diameter.\n* **Associated signs**: Bone lesions (rib lysis) often present; the opacity moves with the rib cage.'**
  String get radSyndromeParietalDesc;

  /// No description provided for @radSyndromePleural.
  ///
  /// In en, this message translates to:
  /// **'Pleural Syndrome'**
  String get radSyndromePleural;

  /// No description provided for @radSyndromePleuralDesc.
  ///
  /// In en, this message translates to:
  /// **'**Definition**:\nSigns reflecting the presence of liquid, air, or abnormal tissue between the pleural layers.\n\n**Semiology**:\n* **Free liquid effusion (Pleurisy)**: Basal opacity in a sheet, effaces costophrenic angles. Damoiseau\'s curve (concave upwards). Mobile with position changes. No bronchogram.\n* **Pneumothorax (Air)**: Peripheral avascular hyperlucency (black area without markings), visceral pleural line (fine bordering line).\n* **Hydro-pneumothorax**: Horizontal air-fluid level.\n\n**Description of images (Illustrated Semiology)**:\n* **Damoiseau\'s line**: Upper limit concave upwards and inwards of the liquid effusion.\n* **Avascular hyperlucency**: Black area without any vascular markings (PTX).\n* **Bordering line**: Fine line corresponding to the visceral pleura limiting the lung retracted towards the hilum.'**
  String get radSyndromePleuralDesc;

  /// No description provided for @radSyndromeAlveolar.
  ///
  /// In en, this message translates to:
  /// **'Alveolar Syndrome'**
  String get radSyndromeAlveolar;

  /// No description provided for @radSyndromeAlveolarDesc.
  ///
  /// In en, this message translates to:
  /// **'**Definition**:\nFilling of the alveoli with fluid (water, pus, blood) or cells.\n\n**Characteristic Semiology**:\n* **Water-density opacity**.\n* **Blurred limits** (unless against a fissure).\n* **Confluence** (diffusion via Kohn pores).\n* **Systematization** (specific anatomical territory).\n* **Air bronchogram**: Patent bronchi within the opacity.\n\n**Description of images (Illustrated Semiology)**:\n* **Cloudy or cottony appearance**: Typical blurred-limit opacities.\n* **Confluence**: Tendency of lesions to merge.\n* **Bronchogram & Alveologram**: Visibility of clear bronchi and alveoli within the white opacity.\n* **Butterfly wings**: Symmetrical perihilar opacities respecting the periphery (Pulmonary Edema).'**
  String get radSyndromeAlveolarDesc;

  /// No description provided for @radSyndromeInterstitial.
  ///
  /// In en, this message translates to:
  /// **'Interstitial Syndrome'**
  String get radSyndromeInterstitial;

  /// No description provided for @radSyndromeInterstitialDesc.
  ///
  /// In en, this message translates to:
  /// **'**Definition**:\nPresence of fluid or abnormal cells in the pulmonary interstitium.\n\n**Semiological Features**:\n* **Sharp limits**.\n* **Non-confluent**, non-systematized.\n* **No air bronchogram**.\n* Slow evolution.\n\n**Description of images (Illustrated Semiology)**:\n* **Kerley lines (B)**: Septal thickening visible at the base as short horizontal lines.\n* **Reticulations**: \'Net-like\' mesh appearance.\n* **Ground glass**: Subtle increase in lung density not effacing the vessels.\n* **Honeycombing**: Grouped small cystic lucencies (terminal stage of fibrosis).'**
  String get radSyndromeInterstitialDesc;

  /// No description provided for @radSyndromeBronchial.
  ///
  /// In en, this message translates to:
  /// **'Bronchial Syndrome'**
  String get radSyndromeBronchial;

  /// No description provided for @radSyndromeBronchialDesc.
  ///
  /// In en, this message translates to:
  /// **'**Definition**:\nSet of signs related to bronchial pathology (thickening, dilation, or obstruction).\n\n**Direct Signs**:\n* **Tram lines and Rings**: Thickening of the bronchial walls.\n* **Signet ring**: Bronchial diameter > Adjacent artery diameter.\n\n**Indirect Signs**:\n* **Atelectasis**: Systematic retractile opacity.\n* **Trapping**: Localized expiratory hyperlucency.\n\n**Description of images (Illustrated Semiology)**:\n* **Tram line sign**: Wall thickening in longitudinal view.\n* **Ring sign**: Wall thickening in transverse view.\n* **Signet ring sign**: Bronchial dilation (bronchiectasis) with bronchial diameter greater than the artery.\n* **Retractile opacity**: Atelectasis with mediastinal shift and fissural displacement towards the lesion.'**
  String get radSyndromeBronchialDesc;

  /// No description provided for @radSyndromeCavitary.
  ///
  /// In en, this message translates to:
  /// **'Cavitary Syndrome'**
  String get radSyndromeCavitary;

  /// No description provided for @radSyndromeCavitaryDesc.
  ///
  /// In en, this message translates to:
  /// **'**Definition**:\nPresence of a lucency (cavity) within an area of opacity or the parenchyma.\n\n**Semiology**:\n* **Wall**: Fixed or variable thickness. Thin (< 3mm) or thick (> 15mm).\n* **Air-fluid level**: Horizontal line (air above, liquid below).\n* **Grelot sign**: Mobile mass inside the cavity.\n\n**Description of images (Illustrated Semiology)**:\n* **Lucency image**: Area of transparency (black) within the parenchyma.\n* **Air-fluid level**: Strict horizontal limit between air and liquid.\n* **Grelot sign**: Mobile mass (e.g., aspergillome) within a cavity.\n* **Nénuphar sign**: Floating membrane typical of a ruptured hydatid cyst.'**
  String get radSyndromeCavitaryDesc;

  /// No description provided for @radSyndromeMediastinal.
  ///
  /// In en, this message translates to:
  /// **'Mediastinal Syndrome'**
  String get radSyndromeMediastinal;

  /// No description provided for @radSyndromeMediastinalDesc.
  ///
  /// In en, this message translates to:
  /// **'**Definition**:\nSigns reflecting the presence of a mass or effusion in the mediastinum.\n\n**Localization Signs**:\n* **Sharp, convex outer border** towards the lung.\n* **Silhouette sign**: Effacement of a border in contact with a structure of the same density.\n* **Iceberg sign**: Thoraco-abdominal mass departing from the spine.\n\n**Description of images (Illustrated Semiology)**:\n* **Silhouette sign**: Blurring of borders between two structures of same density in contact.\n* **Cervicothoracic sign**: Opacity exceeding the upper border of the clavicle (indicates posterior position).\n* **Iceberg sign (thoraco-abdominal)**: Mass departing from the spine below the diaphragm.\n* **Hilar overlay sign**: Visibility of vessels through the opacity (indicates ant/post position relative to the hilum).'**
  String get radSyndromeMediastinalDesc;

  /// No description provided for @radResetFindings.
  ///
  /// In en, this message translates to:
  /// **'Reset Findings'**
  String get radResetFindings;

  /// No description provided for @radTechnicalQuality.
  ///
  /// In en, this message translates to:
  /// **'Technical Quality Check (CRIP)'**
  String get radTechnicalQuality;

  /// No description provided for @radDifferentialDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Differential Diagnosis'**
  String get radDifferentialDiagnosis;

  /// No description provided for @radCommonEtiologies.
  ///
  /// In en, this message translates to:
  /// **'Common Etiologies'**
  String get radCommonEtiologies;

  /// No description provided for @radRelatedSyndromes.
  ///
  /// In en, this message translates to:
  /// **'Related to Syndromes:'**
  String get radRelatedSyndromes;

  /// No description provided for @radSemiologySigns.
  ///
  /// In en, this message translates to:
  /// **'Semiology (Signs)'**
  String get radSemiologySigns;

  /// No description provided for @radClinicalPearls.
  ///
  /// In en, this message translates to:
  /// **'Clinical Pearls'**
  String get radClinicalPearls;

  /// No description provided for @radSyndromeProbabilityAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Syndrome Probability Analysis'**
  String get radSyndromeProbabilityAnalysis;

  /// No description provided for @radSignsCount.
  ///
  /// In en, this message translates to:
  /// **'{score}/{total} signs'**
  String radSignsCount(Object score, Object total);

  /// No description provided for @radObjective.
  ///
  /// In en, this message translates to:
  /// **'Objective: {target}'**
  String radObjective(Object target);

  /// No description provided for @radSemiologyCourse.
  ///
  /// In en, this message translates to:
  /// **'Semiology Course'**
  String get radSemiologyCourse;

  /// No description provided for @labAnalysisReport.
  ///
  /// In en, this message translates to:
  /// **'LABORATORY ANALYSIS REPORT'**
  String get labAnalysisReport;

  /// No description provided for @labGuidedInterpretation.
  ///
  /// In en, this message translates to:
  /// **'Bio Interpretation Checklist'**
  String get labGuidedInterpretation;

  /// No description provided for @labChapterHematology.
  ///
  /// In en, this message translates to:
  /// **'Hematology (CBC)'**
  String get labChapterHematology;

  /// No description provided for @labChapterElectrolytes.
  ///
  /// In en, this message translates to:
  /// **'Electrolytes'**
  String get labChapterElectrolytes;

  /// No description provided for @labChapterBloodGas.
  ///
  /// In en, this message translates to:
  /// **'Blood Gas'**
  String get labChapterBloodGas;

  /// No description provided for @labChapterRenal.
  ///
  /// In en, this message translates to:
  /// **'Renal Function'**
  String get labChapterRenal;

  /// No description provided for @labChapterHepatic.
  ///
  /// In en, this message translates to:
  /// **'Liver Function'**
  String get labChapterHepatic;

  /// No description provided for @labChapterInflammatory.
  ///
  /// In en, this message translates to:
  /// **'Inflammatory Markers'**
  String get labChapterInflammatory;

  /// No description provided for @labCheckAnemia.
  ///
  /// In en, this message translates to:
  /// **'Hemoglobin (Anemia?)'**
  String get labCheckAnemia;

  /// No description provided for @labCheckAnemiaDesc.
  ///
  /// In en, this message translates to:
  /// **'Decrease in Hb based on age and sex.'**
  String get labCheckAnemiaDesc;

  /// No description provided for @labCheckPlq.
  ///
  /// In en, this message translates to:
  /// **'Platelets (Hemostasis?)'**
  String get labCheckPlq;

  /// No description provided for @labCheckPlqDesc.
  ///
  /// In en, this message translates to:
  /// **'Search for thrombocytopenia or thrombocytosis.'**
  String get labCheckPlqDesc;

  /// No description provided for @labCheckK.
  ///
  /// In en, this message translates to:
  /// **'Potassium (Dyskalemia?)'**
  String get labCheckK;

  /// No description provided for @labCheckKDesc.
  ///
  /// In en, this message translates to:
  /// **'Vital emergency if severe anomaly (ECG).'**
  String get labCheckKDesc;

  /// No description provided for @labCheckNa.
  ///
  /// In en, this message translates to:
  /// **'Sodium (Hydration?)'**
  String get labCheckNa;

  /// No description provided for @labCheckNaDesc.
  ///
  /// In en, this message translates to:
  /// **'Reflects intracellular hydration status.'**
  String get labCheckNaDesc;

  /// No description provided for @labCheckCreat.
  ///
  /// In en, this message translates to:
  /// **'Creatinine (GFR?)'**
  String get labCheckCreat;

  /// No description provided for @labCheckCreatDesc.
  ///
  /// In en, this message translates to:
  /// **'Evaluate renal function and filtration rate.'**
  String get labCheckCreatDesc;

  /// No description provided for @labCheckCRP.
  ///
  /// In en, this message translates to:
  /// **'CRP (Inflammation?)'**
  String get labCheckCRP;

  /// No description provided for @labCheckCRPDesc.
  ///
  /// In en, this message translates to:
  /// **'Rapid marker of acute inflammation.'**
  String get labCheckCRPDesc;

  /// No description provided for @labCheckPH.
  ///
  /// In en, this message translates to:
  /// **'pH and Blood Gas'**
  String get labCheckPH;

  /// No description provided for @labCheckPHDesc.
  ///
  /// In en, this message translates to:
  /// **'Search for acidosis or alkalosis.'**
  String get labCheckPHDesc;

  /// No description provided for @labCheckLiver.
  ///
  /// In en, this message translates to:
  /// **'Transaminases (Cytolysis?)'**
  String get labCheckLiver;

  /// No description provided for @labCheckLiverDesc.
  ///
  /// In en, this message translates to:
  /// **'Increase in ALT/AST.'**
  String get labCheckLiverDesc;

  /// No description provided for @labCheckCholestasis.
  ///
  /// In en, this message translates to:
  /// **'ALP / GGT (Cholestasis?)'**
  String get labCheckCholestasis;

  /// No description provided for @labCheckCholestasisDesc.
  ///
  /// In en, this message translates to:
  /// **'Obstruction or biliary involvement.'**
  String get labCheckCholestasisDesc;

  /// No description provided for @labTipHematologyTitle.
  ///
  /// In en, this message translates to:
  /// **'CBC Analysis'**
  String get labTipHematologyTitle;

  /// No description provided for @labTipHematologyDesc.
  ///
  /// In en, this message translates to:
  /// **'Hemoglobin defines anemia. MCV/MCHC guide the diagnosis. Platelets are vital for hemostasis.'**
  String get labTipHematologyDesc;

  /// No description provided for @labTipElectrolytesTitle.
  ///
  /// In en, this message translates to:
  /// **'Electrolytes'**
  String get labTipElectrolytesTitle;

  /// No description provided for @labTipElectrolytesDesc.
  ///
  /// In en, this message translates to:
  /// **'Potassium (K+) is the most dangerous. Sodium (Na+) reflects water. Always check associated renal function.'**
  String get labTipElectrolytesDesc;

  /// No description provided for @labTipInflammatoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Inflammatory Markers'**
  String get labTipInflammatoryTitle;

  /// No description provided for @labTipInflammatoryDesc.
  ///
  /// In en, this message translates to:
  /// **'CRP rises and falls quickly. ESR is slower. Neutrophilia suggests bacterial infection.'**
  String get labTipInflammatoryDesc;

  /// No description provided for @labSyndromeInflammatory.
  ///
  /// In en, this message translates to:
  /// **'Inflammatory Syndrome'**
  String get labSyndromeInflammatory;

  /// No description provided for @labSyndromeAnemia.
  ///
  /// In en, this message translates to:
  /// **'Anemia'**
  String get labSyndromeAnemia;

  /// No description provided for @labSyndromeThrombopenia.
  ///
  /// In en, this message translates to:
  /// **'Thrombopenia'**
  String get labSyndromeThrombopenia;

  /// No description provided for @labSyndromeHyperkalemia.
  ///
  /// In en, this message translates to:
  /// **'Hyperkalemia'**
  String get labSyndromeHyperkalemia;

  /// No description provided for @labSyndromeHypokalemia.
  ///
  /// In en, this message translates to:
  /// **'Hypokalemia'**
  String get labSyndromeHypokalemia;

  /// No description provided for @labSyndromeIRA.
  ///
  /// In en, this message translates to:
  /// **'Acute Renal Failure'**
  String get labSyndromeIRA;

  /// No description provided for @labSyndromeAcidosis.
  ///
  /// In en, this message translates to:
  /// **'Metabolic Acidosis'**
  String get labSyndromeAcidosis;

  /// No description provided for @labSyndromeDehydration.
  ///
  /// In en, this message translates to:
  /// **'Dehydration'**
  String get labSyndromeDehydration;

  /// No description provided for @labSyndromeCholestasis.
  ///
  /// In en, this message translates to:
  /// **'Cholestase'**
  String get labSyndromeCholestasis;

  /// No description provided for @labSyndromeCytolysis.
  ///
  /// In en, this message translates to:
  /// **'Liver Cytolysis'**
  String get labSyndromeCytolysis;

  /// No description provided for @labResetFindings.
  ///
  /// In en, this message translates to:
  /// **'Reset Results'**
  String get labResetFindings;

  /// No description provided for @labEncyclopedia.
  ///
  /// In en, this message translates to:
  /// **'Lab Encyclopedia'**
  String get labEncyclopedia;

  /// No description provided for @labEncyclopediaDesc.
  ///
  /// In en, this message translates to:
  /// **'250 detailed laboratory exams'**
  String get labEncyclopediaDesc;

  /// No description provided for @labChapterGasometry.
  ///
  /// In en, this message translates to:
  /// **'Blood Gas (ABG)'**
  String get labChapterGasometry;

  /// No description provided for @labChapterHepatorenal.
  ///
  /// In en, this message translates to:
  /// **'Hepatic & Renal Panel'**
  String get labChapterHepatorenal;

  /// No description provided for @labTipGasometryTitle.
  ///
  /// In en, this message translates to:
  /// **'Arterial Blood Gases'**
  String get labTipGasometryTitle;

  /// No description provided for @labTipGasometryDesc.
  ///
  /// In en, this message translates to:
  /// **'pH < 7.35 is acidosis. Check if metabolic (low HCO3-) or respiratory (high pCO2). Elevated lactate signals poor perfusion.'**
  String get labTipGasometryDesc;

  /// No description provided for @labTipHepatorenalTitle.
  ///
  /// In en, this message translates to:
  /// **'Hepatic & Renal Function'**
  String get labTipHepatorenalTitle;

  /// No description provided for @labTipHepatorenalDesc.
  ///
  /// In en, this message translates to:
  /// **'ASAT > ALAT suggests alcoholic origin. Isolated GGT rise = alcohol or medications. Creatinine rise: always check urea and diuresis.'**
  String get labTipHepatorenalDesc;

  /// No description provided for @labSyndromeProbability.
  ///
  /// In en, this message translates to:
  /// **'Syndrome Probability Analysis'**
  String get labSyndromeProbability;

  /// No description provided for @labCommonEtiologies.
  ///
  /// In en, this message translates to:
  /// **'Common Etiologies'**
  String get labCommonEtiologies;

  /// No description provided for @labRelatedSyndromes.
  ///
  /// In en, this message translates to:
  /// **'Related to Syndromes:'**
  String get labRelatedSyndromes;

  /// No description provided for @viewInEncyclopedia.
  ///
  /// In en, this message translates to:
  /// **'View in Encyclopedia'**
  String get viewInEncyclopedia;

  /// No description provided for @labNormalValues.
  ///
  /// In en, this message translates to:
  /// **'Normal Values'**
  String get labNormalValues;

  /// No description provided for @searchParameter.
  ///
  /// In en, this message translates to:
  /// **'Search parameter...'**
  String get searchParameter;

  /// No description provided for @unitSI.
  ///
  /// In en, this message translates to:
  /// **'SI Unit'**
  String get unitSI;

  /// No description provided for @unitTrad.
  ///
  /// In en, this message translates to:
  /// **'Trad. Unit'**
  String get unitTrad;

  /// No description provided for @paramReference.
  ///
  /// In en, this message translates to:
  /// **'Reference Sheet'**
  String get paramReference;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @notificationToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notificationToday;

  /// No description provided for @notificationYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notificationYesterday;

  /// No description provided for @notificationEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get notificationEarlier;

  /// No description provided for @noNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get noNotificationsTitle;

  /// No description provided for @noNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You have no new notifications.'**
  String get noNotificationsSubtitle;

  /// No description provided for @notificationTypeContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get notificationTypeContent;

  /// No description provided for @notificationTypeCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get notificationTypeCommunity;

  /// No description provided for @notificationTypePerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get notificationTypePerformance;

  /// No description provided for @notificationTypeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get notificationTypeSystem;

  /// No description provided for @clearAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Clear All Notifications'**
  String get clearAllNotifications;

  /// No description provided for @clearAllNotificationsConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete all your notifications?'**
  String get clearAllNotificationsConfirmation;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @markRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as Read'**
  String get markRead;

  /// No description provided for @markUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark as Unread'**
  String get markUnread;

  /// No description provided for @studyGroups.
  ///
  /// In en, this message translates to:
  /// **'Study Groups'**
  String get studyGroups;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE'**
  String get available;

  /// No description provided for @myProgression.
  ///
  /// In en, this message translates to:
  /// **'MY PROGRESSION'**
  String get myProgression;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'CREATE A GROUP'**
  String get createGroup;

  /// No description provided for @popularRooms.
  ///
  /// In en, this message translates to:
  /// **'POPULAR ROOMS'**
  String get popularRooms;

  /// No description provided for @recommendedRooms.
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED ROOMS'**
  String get recommendedRooms;

  /// No description provided for @joinRoom.
  ///
  /// In en, this message translates to:
  /// **'JOIN'**
  String get joinRoom;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'MEMBERS'**
  String get members;

  /// No description provided for @pomodoros.
  ///
  /// In en, this message translates to:
  /// **'POMODOROS'**
  String get pomodoros;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'DETAILS'**
  String get details;

  /// No description provided for @waitingForSession.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Session'**
  String get waitingForSession;

  /// No description provided for @adminWillStartSession.
  ///
  /// In en, this message translates to:
  /// **'The group admin will start a study battle soon. Get ready!'**
  String get adminWillStartSession;

  /// No description provided for @theoreticalOnly.
  ///
  /// In en, this message translates to:
  /// **'Theoretical Only'**
  String get theoreticalOnly;

  /// No description provided for @clinicalOnly.
  ///
  /// In en, this message translates to:
  /// **'Clinical Only'**
  String get clinicalOnly;

  /// No description provided for @selectStudyYear.
  ///
  /// In en, this message translates to:
  /// **'Select Study Year'**
  String get selectStudyYear;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupName;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Description (Goal, specialty...)'**
  String get descriptionHint;

  /// No description provided for @groupColor.
  ///
  /// In en, this message translates to:
  /// **'Group Color'**
  String get groupColor;

  /// No description provided for @createRoom.
  ///
  /// In en, this message translates to:
  /// **'CREATE ROOM'**
  String get createRoom;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get pleaseEnterTitle;

  /// No description provided for @liveSession.
  ///
  /// In en, this message translates to:
  /// **'LIVE SESSION'**
  String get liveSession;

  /// No description provided for @liveQuizBattles.
  ///
  /// In en, this message translates to:
  /// **'Ongoing Quiz Battles'**
  String get liveQuizBattles;

  /// No description provided for @inviteFriend.
  ///
  /// In en, this message translates to:
  /// **'Invite a Friend'**
  String get inviteFriend;

  /// No description provided for @startGStudy.
  ///
  /// In en, this message translates to:
  /// **'START A G-STUDY SESSION'**
  String get startGStudy;

  /// No description provided for @liveQuizBattleInfo.
  ///
  /// In en, this message translates to:
  /// **'Live Quiz Battle • +500 XP'**
  String get liveQuizBattleInfo;

  /// No description provided for @liveFocus.
  ///
  /// In en, this message translates to:
  /// **'LIVE FOCUS'**
  String get liveFocus;

  /// No description provided for @groupGoals.
  ///
  /// In en, this message translates to:
  /// **'GROUP GOALS'**
  String get groupGoals;

  /// No description provided for @meducytesWall.
  ///
  /// In en, this message translates to:
  /// **'MEDUCYTES WALL'**
  String get meducytesWall;

  /// No description provided for @sendEncouragement.
  ///
  /// In en, this message translates to:
  /// **'Send an encouragement...'**
  String get sendEncouragement;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @aloneInBattle.
  ///
  /// In en, this message translates to:
  /// **'Alone in the battle for now...'**
  String get aloneInBattle;

  /// No description provided for @liveBattle.
  ///
  /// In en, this message translates to:
  /// **'LIVE BATTLE'**
  String get liveBattle;

  /// No description provided for @questionOf.
  ///
  /// In en, this message translates to:
  /// **'QUESTION {current} OF {total}'**
  String questionOf(Object current, Object total);

  /// No description provided for @yourScore.
  ///
  /// In en, this message translates to:
  /// **'YOUR SCORE: {score}'**
  String yourScore(Object score);

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'EXCELLENT!'**
  String get excellent;

  /// No description provided for @oopsNotQuite.
  ///
  /// In en, this message translates to:
  /// **'OOPS, NOT QUITE...'**
  String get oopsNotQuite;

  /// No description provided for @preparingBattle.
  ///
  /// In en, this message translates to:
  /// **'PREPARING BATTLE...'**
  String get preparingBattle;

  /// No description provided for @battleAboutToStart.
  ///
  /// In en, this message translates to:
  /// **'THE BATTLE IS ABOUT TO START'**
  String get battleAboutToStart;

  /// No description provided for @getReadyTenQuestions.
  ///
  /// In en, this message translates to:
  /// **'Get ready! 10 Questions on the module'**
  String get getReadyTenQuestions;

  /// No description provided for @participantsReady.
  ///
  /// In en, this message translates to:
  /// **'{count} Participants ready'**
  String participantsReady(Object count);

  /// No description provided for @battleFinished.
  ///
  /// In en, this message translates to:
  /// **'BATTLE FINISHED!'**
  String get battleFinished;

  /// No description provided for @backToGroup.
  ///
  /// In en, this message translates to:
  /// **'BACK TO GROUP'**
  String get backToGroup;

  /// No description provided for @searchByNameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email...'**
  String get searchByNameOrEmail;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @invitationSent.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent!'**
  String get invitationSent;

  /// No description provided for @invitationError.
  ///
  /// In en, this message translates to:
  /// **'Error sending invitation'**
  String get invitationError;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'INVITE'**
  String get invite;

  /// No description provided for @selectTopic.
  ///
  /// In en, this message translates to:
  /// **'Select a Topic'**
  String get selectTopic;

  /// No description provided for @chooseModuleForBattle.
  ///
  /// In en, this message translates to:
  /// **'Choose a module for the Battle'**
  String get chooseModuleForBattle;

  /// No description provided for @searchRoomHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a room or topic...'**
  String get searchRoomHint;

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED FOR YOU'**
  String get recommendedForYou;

  /// No description provided for @onlineSuffix.
  ///
  /// In en, this message translates to:
  /// **'ONLINE'**
  String get onlineSuffix;

  /// No description provided for @yourSummary.
  ///
  /// In en, this message translates to:
  /// **'YOUR SUMMARY'**
  String get yourSummary;

  /// No description provided for @myActiveGroups.
  ///
  /// In en, this message translates to:
  /// **'MY ACTIVE GROUPS'**
  String get myActiveGroups;

  /// No description provided for @noActiveGroups.
  ///
  /// In en, this message translates to:
  /// **'NO ACTIVE GROUPS'**
  String get noActiveGroups;

  /// No description provided for @pomodorosToday.
  ///
  /// In en, this message translates to:
  /// **'Pomodoros collected today'**
  String get pomodorosToday;

  /// No description provided for @syncingStats.
  ///
  /// In en, this message translates to:
  /// **'Global statistics being synchronized...'**
  String get syncingStats;

  /// No description provided for @silent.
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get silent;

  /// No description provided for @focus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focus;

  /// No description provided for @qcmBattle.
  ///
  /// In en, this message translates to:
  /// **'QCM Battle'**
  String get qcmBattle;

  /// No description provided for @categoryMedicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get categoryMedicine;

  /// No description provided for @categorySurgery.
  ///
  /// In en, this message translates to:
  /// **'Surgery'**
  String get categorySurgery;

  /// No description provided for @categoryGyneco.
  ///
  /// In en, this message translates to:
  /// **'Gynecology'**
  String get categoryGyneco;

  /// No description provided for @categoryPaces.
  ///
  /// In en, this message translates to:
  /// **'PACES'**
  String get categoryPaces;

  /// No description provided for @categoryExam.
  ///
  /// In en, this message translates to:
  /// **'Exams'**
  String get categoryExam;

  /// No description provided for @roomNameLabel.
  ///
  /// In en, this message translates to:
  /// **'ROOM NAME'**
  String get roomNameLabel;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION (OPTIONAL)'**
  String get descriptionOptional;

  /// No description provided for @sessionType.
  ///
  /// In en, this message translates to:
  /// **'SESSION TYPE'**
  String get sessionType;

  /// No description provided for @themeColorLabel.
  ///
  /// In en, this message translates to:
  /// **'THEME COLOR'**
  String get themeColorLabel;

  /// No description provided for @medicalCategory.
  ///
  /// In en, this message translates to:
  /// **'MEDICAL CATEGORY'**
  String get medicalCategory;

  /// No description provided for @roomCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'ROOM CREATED SUCCESSFULLY'**
  String get roomCreatedSuccess;

  /// No description provided for @roomCreationError.
  ///
  /// In en, this message translates to:
  /// **'ERROR DURING CREATION'**
  String get roomCreationError;

  /// No description provided for @topRated.
  ///
  /// In en, this message translates to:
  /// **'TOP RATED'**
  String get topRated;

  /// No description provided for @trending.
  ///
  /// In en, this message translates to:
  /// **'TRENDING'**
  String get trending;

  /// No description provided for @allCaps.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get allCaps;

  /// No description provided for @activeSession.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE SESSION'**
  String get activeSession;

  /// No description provided for @participantsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Meducytes in battle'**
  String participantsCount(Object count);

  /// No description provided for @beFirstToEncourage.
  ///
  /// In en, this message translates to:
  /// **'BE THE FIRST TO ENCOURAGE THE GROUP!'**
  String get beFirstToEncourage;

  /// No description provided for @groupTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'TYPE'**
  String get groupTypeLabel;

  /// No description provided for @inProgressCount.
  ///
  /// In en, this message translates to:
  /// **'{count} IN PROGRESS'**
  String inProgressCount(Object count);

  /// No description provided for @aiOptimizedPlanning.
  ///
  /// In en, this message translates to:
  /// **'AI has optimized your planning based on your weaknesses and exams.'**
  String get aiOptimizedPlanning;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'D-{days}'**
  String daysRemaining(Object days);

  /// No description provided for @applyPlanning.
  ///
  /// In en, this message translates to:
  /// **'Apply this planning'**
  String get applyPlanning;

  /// No description provided for @nextSession.
  ///
  /// In en, this message translates to:
  /// **'NEXT SESSION'**
  String get nextSession;

  /// No description provided for @noSession.
  ///
  /// In en, this message translates to:
  /// **'No session'**
  String get noSession;

  /// No description provided for @noUrgentTask.
  ///
  /// In en, this message translates to:
  /// **'No urgent task'**
  String get noUrgentTask;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @nextExam.
  ///
  /// In en, this message translates to:
  /// **'NEXT EXAM'**
  String get nextExam;

  /// No description provided for @setExamDate.
  ///
  /// In en, this message translates to:
  /// **'Set Exam Date'**
  String get setExamDate;

  /// No description provided for @editExam.
  ///
  /// In en, this message translates to:
  /// **'Edit Exam'**
  String get editExam;

  /// No description provided for @selectDateAndHour.
  ///
  /// In en, this message translates to:
  /// **'Select Date & Hour'**
  String get selectDateAndHour;

  /// No description provided for @examTitle.
  ///
  /// In en, this message translates to:
  /// **'Exam Title'**
  String get examTitle;

  /// No description provided for @noExam.
  ///
  /// In en, this message translates to:
  /// **'No exam'**
  String get noExam;

  /// No description provided for @pomodoroLabel.
  ///
  /// In en, this message translates to:
  /// **'POMODORO'**
  String get pomodoroLabel;

  /// No description provided for @personalization.
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get personalization;

  /// No description provided for @pomodoroWork.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get pomodoroWork;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorLabel;

  /// No description provided for @newStudyModuleTask.
  ///
  /// In en, this message translates to:
  /// **'New study module'**
  String get newStudyModuleTask;

  /// No description provided for @addSmartTask.
  ///
  /// In en, this message translates to:
  /// **'Add smart task'**
  String get addSmartTask;

  /// No description provided for @urgentLabel.
  ///
  /// In en, this message translates to:
  /// **'URGENT'**
  String get urgentLabel;

  /// No description provided for @examLabel.
  ///
  /// In en, this message translates to:
  /// **'EXAM'**
  String get examLabel;

  /// No description provided for @optionalLabel.
  ///
  /// In en, this message translates to:
  /// **'OPTIONAL'**
  String get optionalLabel;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @taskDeselected.
  ///
  /// In en, this message translates to:
  /// **'Task deselected'**
  String get taskDeselected;

  /// No description provided for @focusOnTask.
  ///
  /// In en, this message translates to:
  /// **'Focus on: {task}'**
  String focusOnTask(Object task);

  /// No description provided for @optimalConcentrationMsg.
  ///
  /// In en, this message translates to:
  /// **'Optimal concentration. Continue on Cardiology for another 45 min.'**
  String get optimalConcentrationMsg;

  /// No description provided for @loadLabel.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get loadLabel;

  /// No description provided for @capacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacityLabel;

  /// No description provided for @breakDueLabel.
  ///
  /// In en, this message translates to:
  /// **'Break Due'**
  String get breakDueLabel;

  /// No description provided for @focusPeak.
  ///
  /// In en, this message translates to:
  /// **'Focus Peak'**
  String get focusPeak;

  /// No description provided for @focusStable.
  ///
  /// In en, this message translates to:
  /// **'Focus Stable'**
  String get focusStable;

  /// No description provided for @lightFatigue.
  ///
  /// In en, this message translates to:
  /// **'Light Fatigue'**
  String get lightFatigue;

  /// No description provided for @burnoutRisk.
  ///
  /// In en, this message translates to:
  /// **'Burnout Risk'**
  String get burnoutRisk;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @noPriorityTask.
  ///
  /// In en, this message translates to:
  /// **'No priority task'**
  String get noPriorityTask;

  /// No description provided for @studyStreak.
  ///
  /// In en, this message translates to:
  /// **'Study Streak'**
  String get studyStreak;

  /// No description provided for @pomodoroToday.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro Today'**
  String get pomodoroToday;

  /// No description provided for @totalHours.
  ///
  /// In en, this message translates to:
  /// **'Total Hours'**
  String get totalHours;

  /// No description provided for @moduleEfficiency.
  ///
  /// In en, this message translates to:
  /// **'Module Efficiency'**
  String get moduleEfficiency;

  /// No description provided for @wind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get wind;

  /// No description provided for @cafe.
  ///
  /// In en, this message translates to:
  /// **'Cafe'**
  String get cafe;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @brownNoise.
  ///
  /// In en, this message translates to:
  /// **'Brown Noise'**
  String get brownNoise;

  /// No description provided for @productiveBayTitle.
  ///
  /// In en, this message translates to:
  /// **'The Productive Bay'**
  String get productiveBayTitle;

  /// No description provided for @searchError.
  ///
  /// In en, this message translates to:
  /// **'Error during search'**
  String get searchError;

  /// No description provided for @editSession.
  ///
  /// In en, this message translates to:
  /// **'Edit Session'**
  String get editSession;

  /// No description provided for @planSession.
  ///
  /// In en, this message translates to:
  /// **'Plan Session'**
  String get planSession;

  /// No description provided for @weeklyPriorityObjectives.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY PRIORITY OBJECTIVES'**
  String get weeklyPriorityObjectives;

  /// No description provided for @weeklyObjectives.
  ///
  /// In en, this message translates to:
  /// **'Weekly Objectives'**
  String get weeklyObjectives;

  /// No description provided for @confidenceLevelQuestion.
  ///
  /// In en, this message translates to:
  /// **'What is your confidence level?'**
  String get confidenceLevelQuestion;

  /// No description provided for @difficultConceptQuestion.
  ///
  /// In en, this message translates to:
  /// **'What was the most difficult concept today?'**
  String get difficultConceptQuestion;

  /// No description provided for @finishSession.
  ///
  /// In en, this message translates to:
  /// **'Finish session'**
  String get finishSession;

  /// No description provided for @startQuickRevision.
  ///
  /// In en, this message translates to:
  /// **'Start Quick Revision'**
  String get startQuickRevision;

  /// No description provided for @customizeHub.
  ///
  /// In en, this message translates to:
  /// **'Customize Hub'**
  String get customizeHub;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @groupGoalsHint.
  ///
  /// In en, this message translates to:
  /// **'Goals, room rules...'**
  String get groupGoalsHint;

  /// No description provided for @yearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearLabel;

  /// No description provided for @monthlyView.
  ///
  /// In en, this message translates to:
  /// **'Monthly View'**
  String get monthlyView;

  /// No description provided for @weeklyView.
  ///
  /// In en, this message translates to:
  /// **'Weekly View'**
  String get weeklyView;

  /// No description provided for @dailyView.
  ///
  /// In en, this message translates to:
  /// **'Daily View'**
  String get dailyView;

  /// No description provided for @newSession.
  ///
  /// In en, this message translates to:
  /// **'New Session'**
  String get newSession;

  /// No description provided for @studySubject.
  ///
  /// In en, this message translates to:
  /// **'Study Subject'**
  String get studySubject;

  /// No description provided for @subjectHint.
  ///
  /// In en, this message translates to:
  /// **'Subject (e.g. Cardiology)'**
  String get subjectHint;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @deleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLabel;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @weekLabel.
  ///
  /// In en, this message translates to:
  /// **'Week {start} - {end}'**
  String weekLabel(Object end, Object start);

  /// No description provided for @defaultObjective1.
  ///
  /// In en, this message translates to:
  /// **'Master ECG branch blocks'**
  String get defaultObjective1;

  /// No description provided for @defaultObjective2.
  ///
  /// In en, this message translates to:
  /// **'Finish Pneumology module'**
  String get defaultObjective2;

  /// No description provided for @defaultObjective3.
  ///
  /// In en, this message translates to:
  /// **'Practice 50 Cardiology MCQs'**
  String get defaultObjective3;

  /// No description provided for @aiPrefix.
  ///
  /// In en, this message translates to:
  /// **'AI: {title}'**
  String aiPrefix(Object title);

  /// No description provided for @highPriorityTaskReason.
  ///
  /// In en, this message translates to:
  /// **'High priority task due soon'**
  String get highPriorityTaskReason;

  /// No description provided for @optimalTimeReason.
  ///
  /// In en, this message translates to:
  /// **'Optimal time for this task'**
  String get optimalTimeReason;

  /// No description provided for @noTasksReason.
  ///
  /// In en, this message translates to:
  /// **'No pending tasks found. Time to discover something new!'**
  String get noTasksReason;

  /// No description provided for @exploreModulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore new modules'**
  String get exploreModulesTitle;

  /// No description provided for @exportPlannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinical Planner Export'**
  String get exportPlannerTitle;

  /// No description provided for @clinicalRevisionPlanner.
  ///
  /// In en, this message translates to:
  /// **'CLINICAL REVISION PLANNER'**
  String get clinicalRevisionPlanner;

  /// No description provided for @weekOf.
  ///
  /// In en, this message translates to:
  /// **'Week of {date}'**
  String weekOf(Object date);

  /// No description provided for @hourTitle.
  ///
  /// In en, this message translates to:
  /// **'HOUR'**
  String get hourTitle;

  /// No description provided for @clinicalNotesReminders.
  ///
  /// In en, this message translates to:
  /// **'CLINICAL NOTES & REMINDERS'**
  String get clinicalNotesReminders;

  /// No description provided for @intensityTrackerAi.
  ///
  /// In en, this message translates to:
  /// **'INTENSITY TRACKER (AI)'**
  String get intensityTrackerAi;

  /// No description provided for @authWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Meducyte'**
  String get authWelcomeTitle;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your clinical excellence journey starts here.'**
  String get authWelcomeSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'dr.meducyte@example.com'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get authPasswordHint;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get authOr;

  /// No description provided for @authContinueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get authContinueGoogle;

  /// No description provided for @authContinueApple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get authContinueApple;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account?'**
  String get authNoAccount;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignUp;

  /// No description provided for @authSocialSoon.
  ///
  /// In en, this message translates to:
  /// **'{platform} Sign-in integrated soon'**
  String authSocialSoon(Object platform);

  /// No description provided for @authBiometricSuccess.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication successful'**
  String get authBiometricSuccess;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccount;

  /// No description provided for @authCreateAccountSub.
  ///
  /// In en, this message translates to:
  /// **'Your journey to clinical mastery begins.'**
  String get authCreateAccountSub;

  /// No description provided for @authStudySchedule.
  ///
  /// In en, this message translates to:
  /// **'Set your study schedule'**
  String get authStudySchedule;

  /// No description provided for @authStudyScheduleSub.
  ///
  /// In en, this message translates to:
  /// **'Consistency is key for medical residency prep.'**
  String get authStudyScheduleSub;

  /// No description provided for @authDailyStartTime.
  ///
  /// In en, this message translates to:
  /// **'Daily Start Time'**
  String get authDailyStartTime;

  /// No description provided for @authTargetDuration.
  ///
  /// In en, this message translates to:
  /// **'Target Study Duration'**
  String get authTargetDuration;

  /// No description provided for @authHours.
  ///
  /// In en, this message translates to:
  /// **'HOURS'**
  String get authHours;

  /// No description provided for @authMinutes.
  ///
  /// In en, this message translates to:
  /// **'MINUTES'**
  String get authMinutes;

  /// No description provided for @authDailyCommitment.
  ///
  /// In en, this message translates to:
  /// **'Daily commitment set for {time}.'**
  String authDailyCommitment(Object time);

  /// No description provided for @authStudyGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal: {h}h {m}m of focused study.'**
  String authStudyGoal(Object h, Object m);

  /// No description provided for @authInterests.
  ///
  /// In en, this message translates to:
  /// **'What are your medical interests?'**
  String get authInterests;

  /// No description provided for @authInterestsSub.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply to personalize your feed.'**
  String get authInterestsSub;

  /// No description provided for @authMedicalSpec.
  ///
  /// In en, this message translates to:
  /// **'Medical Specialties'**
  String get authMedicalSpec;

  /// No description provided for @authSurgicalSpec.
  ///
  /// In en, this message translates to:
  /// **'Surgical Specialties'**
  String get authSurgicalSpec;

  /// No description provided for @authOtherDisciplines.
  ///
  /// In en, this message translates to:
  /// **'Other Disciplines'**
  String get authOtherDisciplines;

  /// No description provided for @authLearningStyleSub.
  ///
  /// In en, this message translates to:
  /// **'Choose the best fit for your learning style.'**
  String get authLearningStyleSub;

  /// No description provided for @authPasswordStrength.
  ///
  /// In en, this message translates to:
  /// **'Password strength'**
  String get authPasswordStrength;

  /// No description provided for @authStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get authStrengthWeak;

  /// No description provided for @authStrengthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get authStrengthFair;

  /// No description provided for @authStrengthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get authStrengthGood;

  /// No description provided for @authStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get authStrengthStrong;

  /// No description provided for @authStrengthNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get authStrengthNone;

  /// No description provided for @authStrengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Strength: {label}'**
  String authStrengthLabel(Object label);

  /// No description provided for @authGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us what\'s your goal?'**
  String get authGoalTitle;

  /// No description provided for @authGoalAce.
  ///
  /// In en, this message translates to:
  /// **'Ace my exams efficiently'**
  String get authGoalAce;

  /// No description provided for @authGoalUnderstand.
  ///
  /// In en, this message translates to:
  /// **'Understand medicine deeply'**
  String get authGoalUnderstand;

  /// No description provided for @authGoalPractical.
  ///
  /// In en, this message translates to:
  /// **'Learn practical clinical skills'**
  String get authGoalPractical;

  /// No description provided for @authGoalHabit.
  ///
  /// In en, this message translates to:
  /// **'Build a daily study habit'**
  String get authGoalHabit;

  /// No description provided for @authHeardFromTitle.
  ///
  /// In en, this message translates to:
  /// **'How did you hear about us?'**
  String get authHeardFromTitle;

  /// No description provided for @authHeardFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get authHeardFriend;

  /// No description provided for @authHeardSocial.
  ///
  /// In en, this message translates to:
  /// **'Social Media'**
  String get authHeardSocial;

  /// No description provided for @authHeardSchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get authHeardSchool;

  /// No description provided for @authHeardOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get authHeardOther;

  /// No description provided for @authQuizPreferenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Quizzes & Medical Learning'**
  String get authQuizPreferenceTitle;

  /// No description provided for @authQuizDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily Quizzes'**
  String get authQuizDaily;

  /// No description provided for @authQuizWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly Quizzes'**
  String get authQuizWeekly;

  /// No description provided for @authQuizVideo.
  ///
  /// In en, this message translates to:
  /// **'Video Learning'**
  String get authQuizVideo;

  /// No description provided for @authQuizPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF Notes'**
  String get authQuizPdf;

  /// No description provided for @authFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get authFullName;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get authYear;

  /// No description provided for @authSelectYear.
  ///
  /// In en, this message translates to:
  /// **'Select Year'**
  String get authSelectYear;

  /// No description provided for @authMobileOptional.
  ///
  /// In en, this message translates to:
  /// **'Mobile (optional)'**
  String get authMobileOptional;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPassword;

  /// No description provided for @authPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authPasswordsDoNotMatch;

  /// No description provided for @authPassAtLeast8.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get authPassAtLeast8;

  /// No description provided for @authPassUppercase.
  ///
  /// In en, this message translates to:
  /// **'One uppercase letter'**
  String get authPassUppercase;

  /// No description provided for @authPassNumber.
  ///
  /// In en, this message translates to:
  /// **'One number'**
  String get authPassNumber;

  /// No description provided for @authPassSpecial.
  ///
  /// In en, this message translates to:
  /// **'One special character (!@#\$^*~)'**
  String get authPassSpecial;

  /// No description provided for @authAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get authAcceptTerms;

  /// No description provided for @authTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get authTermsOfUse;

  /// No description provided for @authPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get authPrivacyPolicy;

  /// No description provided for @authAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get authAnd;

  /// No description provided for @authBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get authBack;

  /// No description provided for @authContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authContinue;

  /// No description provided for @authFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get authFinish;

  /// No description provided for @authVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get authVerifyEmail;

  /// No description provided for @authResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authResetPassword;

  /// No description provided for @authVerifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get authVerifyYourEmail;

  /// No description provided for @authResetYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Your Password'**
  String get authResetYourPassword;

  /// No description provided for @authEnterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit OTP sent to:'**
  String get authEnterOtp;

  /// No description provided for @authNoCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get authNoCode;

  /// No description provided for @authResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}'**
  String authResendIn(Object seconds);

  /// No description provided for @authResendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get authResendOtp;

  /// No description provided for @authInvalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 6-digit OTP'**
  String get authInvalidOtp;

  /// No description provided for @authEmailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully!'**
  String get authEmailVerified;

  /// No description provided for @authOtpVerified.
  ///
  /// In en, this message translates to:
  /// **'OTP verified! Set your new password.'**
  String get authOtpVerified;

  /// No description provided for @authOtpSent.
  ///
  /// In en, this message translates to:
  /// **'OTP sent successfully!'**
  String get authOtpSent;

  /// No description provided for @authPrivacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get authPrivacyPolicyTitle;

  /// No description provided for @authPrivacySection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Information We Collect'**
  String get authPrivacySection1Title;

  /// No description provided for @authPrivacySection1Content.
  ///
  /// In en, this message translates to:
  /// **'We collect information you provide directly to us, such as your name, email address, and medical specialty when you create an account. We also collect data on your study progress and quiz performance to personalize your learning experience.'**
  String get authPrivacySection1Content;

  /// No description provided for @authPrivacySection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. How We Use Your Information'**
  String get authPrivacySection2Title;

  /// No description provided for @authPrivacySection2Content.
  ///
  /// In en, this message translates to:
  /// **'Your information is used to provide and enhance our services, track your academic progress, and provide AI-driven study recommendations. We do not sell your personal data to third parties.'**
  String get authPrivacySection2Content;

  /// No description provided for @authPrivacySection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Data Security'**
  String get authPrivacySection3Title;

  /// No description provided for @authPrivacySection3Content.
  ///
  /// In en, this message translates to:
  /// **'We implement appropriate security measures to protect your personal information from unauthorized access, alteration, or disclosure. However, no internet transmission is 100% secure.'**
  String get authPrivacySection3Content;

  /// No description provided for @authPrivacySection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Your Rights'**
  String get authPrivacySection4Title;

  /// No description provided for @authPrivacySection4Content.
  ///
  /// In en, this message translates to:
  /// **'You have the right to access, correct, or delete your personal data at any time through your account settings. You may also contact us to request data portability.'**
  String get authPrivacySection4Content;

  /// No description provided for @authPrivacySection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Contact Us'**
  String get authPrivacySection5Title;

  /// No description provided for @authPrivacySection5Content.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions about this Privacy Policy, please contact us at contact@meducyte.com.'**
  String get authPrivacySection5Content;

  /// No description provided for @authPrivacyLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: October 2023'**
  String get authPrivacyLastUpdated;

  /// No description provided for @authTermsOfUseTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use & Usage Conditions'**
  String get authTermsOfUseTitle;

  /// No description provided for @authTermsSection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Acceptance of Terms'**
  String get authTermsSection1Title;

  /// No description provided for @authTermsSection1Content.
  ///
  /// In en, this message translates to:
  /// **'By accessing and using Meducyte, you agree to be bound by these terms. If you do not agree to these terms, you should not use the services.'**
  String get authTermsSection1Content;

  /// No description provided for @authTermsSection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Medical Disclaimer'**
  String get authTermsSection2Title;

  /// No description provided for @authTermsSection2Content.
  ///
  /// In en, this message translates to:
  /// **'Meducyte is an educational tool and should not be used as a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of a physician or other qualified health provider with any questions you may have regarding a medical condition.'**
  String get authTermsSection2Content;

  /// No description provided for @authTermsSection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. User Accounts'**
  String get authTermsSection3Title;

  /// No description provided for @authTermsSection3Content.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for maintaining the confidentiality of your account and password. You also agree to provide accurate, current, and complete information.'**
  String get authTermsSection3Content;

  /// No description provided for @authTermsSection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Intellectual Property'**
  String get authTermsSection4Title;

  /// No description provided for @authTermsSection4Content.
  ///
  /// In en, this message translates to:
  /// **'All content, including medical information, quizzes, and graphics, are the intellectual property of Meducyte. You may not reproduce or distribute this content without prior written consent.'**
  String get authTermsSection4Content;

  /// No description provided for @authTermsSection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Limitation of Liability'**
  String get authTermsSection5Title;

  /// No description provided for @authTermsSection5Content.
  ///
  /// In en, this message translates to:
  /// **'Meducyte and its affiliates shall not be liable for any indirect, incidental, special, or consequential damages resulting from the use or inability to use our services.'**
  String get authTermsSection5Content;

  /// No description provided for @authTermsLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: October 2023'**
  String get authTermsLastUpdated;

  /// No description provided for @authFaculteTitle.
  ///
  /// In en, this message translates to:
  /// **'Which CHU / Faculty do you attend?'**
  String get authFaculteTitle;

  /// No description provided for @authFaculteSub.
  ///
  /// In en, this message translates to:
  /// **'Meducyte is currently exclusive to Constantine students for maximum CHU alignment.'**
  String get authFaculteSub;

  /// No description provided for @authClinicalStageTitle.
  ///
  /// In en, this message translates to:
  /// **'Which Rotation (Stage) are you in?'**
  String get authClinicalStageTitle;

  /// No description provided for @authClinicalStageSub.
  ///
  /// In en, this message translates to:
  /// **'This prioritizes clinical cases and flashcards for your current CHU department.'**
  String get authClinicalStageSub;

  /// No description provided for @authExamDateTitle.
  ///
  /// In en, this message translates to:
  /// **'When is your next major exam?'**
  String get authExamDateTitle;

  /// No description provided for @authExamDateSub.
  ///
  /// In en, this message translates to:
  /// **'Set a countdown for your next EMD or Concours to build your study plan.'**
  String get authExamDateSub;

  /// No description provided for @authCurrentFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'What are you studying right now?'**
  String get authCurrentFocusTitle;

  /// No description provided for @authCurrentFocusSub.
  ///
  /// In en, this message translates to:
  /// **'Select the module you are currently preparing for your CHU\'s EMD.'**
  String get authCurrentFocusSub;

  /// No description provided for @authDailyChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Activate \'EMD du Jour\'?'**
  String get authDailyChallengeTitle;

  /// No description provided for @authDailyChallengeSub.
  ///
  /// In en, this message translates to:
  /// **'Receive one high-yield clinical question every day at your chosen time.'**
  String get authDailyChallengeSub;

  /// No description provided for @authCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Show profile to your Faculty?'**
  String get authCommunityTitle;

  /// No description provided for @authCommunitySub.
  ///
  /// In en, this message translates to:
  /// **'Join study groups for your CHU and see who else is studying the same module.'**
  String get authCommunitySub;

  /// No description provided for @authStatusExtern.
  ///
  /// In en, this message translates to:
  /// **'Extern (4th-6th Year)'**
  String get authStatusExtern;

  /// No description provided for @authStatusIntern.
  ///
  /// In en, this message translates to:
  /// **'Intern (7th Year)'**
  String get authStatusIntern;

  /// No description provided for @authStatusResident.
  ///
  /// In en, this message translates to:
  /// **'Resident'**
  String get authStatusResident;

  /// No description provided for @authStatusDoctor.
  ///
  /// In en, this message translates to:
  /// **'General Practitioner'**
  String get authStatusDoctor;

  /// No description provided for @authStageCardio.
  ///
  /// In en, this message translates to:
  /// **'Cardiology'**
  String get authStageCardio;

  /// No description provided for @authStageSurgery.
  ///
  /// In en, this message translates to:
  /// **'Surgery'**
  String get authStageSurgery;

  /// No description provided for @authStagePediatrics.
  ///
  /// In en, this message translates to:
  /// **'Pediatrics'**
  String get authStagePediatrics;

  /// No description provided for @authStageInternal.
  ///
  /// In en, this message translates to:
  /// **'Internal Medicine'**
  String get authStageInternal;

  /// No description provided for @authStageGyneco.
  ///
  /// In en, this message translates to:
  /// **'Gynecology & Obstetrics'**
  String get authStageGyneco;

  /// No description provided for @authStageEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency Medicine'**
  String get authStageEmergency;

  /// No description provided for @authExamEMD.
  ///
  /// In en, this message translates to:
  /// **'Next EMD'**
  String get authExamEMD;

  /// No description provided for @authExamConcours.
  ///
  /// In en, this message translates to:
  /// **'Concours de Résidanat'**
  String get authExamConcours;

  /// No description provided for @authFaculteAlgiers.
  ///
  /// In en, this message translates to:
  /// **'Faculty of Algiers'**
  String get authFaculteAlgiers;

  /// No description provided for @authFaculteOran.
  ///
  /// In en, this message translates to:
  /// **'Faculty of Oran'**
  String get authFaculteOran;

  /// No description provided for @authFaculteConstantine.
  ///
  /// In en, this message translates to:
  /// **'Faculty of Constantine'**
  String get authFaculteConstantine;

  /// No description provided for @authFaculteAnnaba.
  ///
  /// In en, this message translates to:
  /// **'Faculty of Annaba'**
  String get authFaculteAnnaba;

  /// No description provided for @authFaculteSetif.
  ///
  /// In en, this message translates to:
  /// **'Faculty of Setif'**
  String get authFaculteSetif;

  /// No description provided for @authFaculteTizi.
  ///
  /// In en, this message translates to:
  /// **'Faculty of Tizi Ouzou'**
  String get authFaculteTizi;

  /// No description provided for @authFaculteOther.
  ///
  /// In en, this message translates to:
  /// **'Other Faculty'**
  String get authFaculteOther;

  /// No description provided for @authHowHeardTitle.
  ///
  /// In en, this message translates to:
  /// **'How did you hear about us?'**
  String get authHowHeardTitle;

  /// No description provided for @authHowHeardSub.
  ///
  /// In en, this message translates to:
  /// **'Help us grow the Meducyte community for all Algerian medical students.'**
  String get authHowHeardSub;

  /// No description provided for @authIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'Meducyte Identity'**
  String get authIdentityTitle;

  /// No description provided for @authIdentitySub.
  ///
  /// In en, this message translates to:
  /// **'Create your unique Notion-style persona.'**
  String get authIdentitySub;

  /// No description provided for @authIdentityTabHead.
  ///
  /// In en, this message translates to:
  /// **'Shape'**
  String get authIdentityTabHead;

  /// No description provided for @authIdentityTabHair.
  ///
  /// In en, this message translates to:
  /// **'Hair'**
  String get authIdentityTabHair;

  /// No description provided for @authIdentityTabFace.
  ///
  /// In en, this message translates to:
  /// **'Face'**
  String get authIdentityTabFace;

  /// No description provided for @authIdentityTabColor.
  ///
  /// In en, this message translates to:
  /// **'Aura'**
  String get authIdentityTabColor;

  /// No description provided for @profileLearningGoal.
  ///
  /// In en, this message translates to:
  /// **'Learning Goal'**
  String get profileLearningGoal;

  /// No description provided for @profileHeardFrom.
  ///
  /// In en, this message translates to:
  /// **'How you heard about us'**
  String get profileHeardFrom;

  /// No description provided for @profileQuizPreference.
  ///
  /// In en, this message translates to:
  /// **'Quiz Preference'**
  String get profileQuizPreference;

  /// No description provided for @profileStudyTime.
  ///
  /// In en, this message translates to:
  /// **'Daily Study Time'**
  String get profileStudyTime;

  /// No description provided for @profileStudyDuration.
  ///
  /// In en, this message translates to:
  /// **'Study Session Duration'**
  String get profileStudyDuration;

  /// No description provided for @profileInterests.
  ///
  /// In en, this message translates to:
  /// **'Medical Interests'**
  String get profileInterests;

  /// No description provided for @profileNextExam.
  ///
  /// In en, this message translates to:
  /// **'Next Major Exam'**
  String get profileNextExam;

  /// No description provided for @profileDailyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge Enabled'**
  String get profileDailyChallenge;

  /// No description provided for @profileShowToFaculty.
  ///
  /// In en, this message translates to:
  /// **'Visible to Faculty'**
  String get profileShowToFaculty;

  /// No description provided for @simTechnicalOverlay.
  ///
  /// In en, this message translates to:
  /// **'TECHNICAL OVERLAY'**
  String get simTechnicalOverlay;

  /// No description provided for @simMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More Options'**
  String get simMoreOptions;

  /// No description provided for @simDifferentialChecklist.
  ///
  /// In en, this message translates to:
  /// **'Differential Checklist'**
  String get simDifferentialChecklist;

  /// No description provided for @simTechnicalOptions.
  ///
  /// In en, this message translates to:
  /// **'Technical Options'**
  String get simTechnicalOptions;

  /// No description provided for @simTextScaling.
  ///
  /// In en, this message translates to:
  /// **'Text Scaling'**
  String get simTextScaling;

  /// No description provided for @simHighContrastMode.
  ///
  /// In en, this message translates to:
  /// **'High Contrast Mode'**
  String get simHighContrastMode;

  /// No description provided for @simClinicalObservation.
  ///
  /// In en, this message translates to:
  /// **'Clinical Observation'**
  String get simClinicalObservation;

  /// No description provided for @simReportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a Problem'**
  String get simReportProblem;

  /// No description provided for @simSelectSpecialtyDiff.
  ///
  /// In en, this message translates to:
  /// **'Select a specialty for the differential diagnosis'**
  String get simSelectSpecialtyDiff;

  /// No description provided for @simCheckSuspectedPathologies.
  ///
  /// In en, this message translates to:
  /// **'Check all suspected pathologies. These will be reviewed at the end of the simulation.'**
  String get simCheckSuspectedPathologies;

  /// No description provided for @simClinicalObservationReport.
  ///
  /// In en, this message translates to:
  /// **'Clinical Observation Report'**
  String get simClinicalObservationReport;

  /// No description provided for @simReportCopiedClipboard.
  ///
  /// In en, this message translates to:
  /// **'A formatted medical observation has been copied to your clipboard.'**
  String get simReportCopiedClipboard;

  /// No description provided for @simReportABug.
  ///
  /// In en, this message translates to:
  /// **'Report a Bug'**
  String get simReportABug;

  /// No description provided for @simReportBugDescription.
  ///
  /// In en, this message translates to:
  /// **'Please describe the problem you encountered during this simulation.'**
  String get simReportBugDescription;

  /// No description provided for @simReportBugMetadata.
  ///
  /// In en, this message translates to:
  /// **'Session ID, pathology, and current vitals will be included in the report.'**
  String get simReportBugMetadata;

  /// No description provided for @simDescribeIssueHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue...'**
  String get simDescribeIssueHint;

  /// No description provided for @simThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you'**
  String get simThankYou;

  /// No description provided for @simReportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your report has been submitted.'**
  String get simReportSubmitted;

  /// No description provided for @simPatientBriefing.
  ///
  /// In en, this message translates to:
  /// **'Patient Briefing'**
  String get simPatientBriefing;

  /// No description provided for @simAiConsultation.
  ///
  /// In en, this message translates to:
  /// **'AI Consultation'**
  String get simAiConsultation;

  /// No description provided for @simTechnicalDebug.
  ///
  /// In en, this message translates to:
  /// **'Technical Debug Overlay'**
  String get simTechnicalDebug;

  /// No description provided for @simStartMission.
  ///
  /// In en, this message translates to:
  /// **'START MISSION'**
  String get simStartMission;

  /// No description provided for @simNextStep.
  ///
  /// In en, this message translates to:
  /// **'NEXT STEP'**
  String get simNextStep;

  /// No description provided for @simCurriculumFocus.
  ///
  /// In en, this message translates to:
  /// **'Curriculum Focus'**
  String get simCurriculumFocus;

  /// No description provided for @simCaseSelection.
  ///
  /// In en, this message translates to:
  /// **'Case Selection'**
  String get simCaseSelection;

  /// No description provided for @simSetting.
  ///
  /// In en, this message translates to:
  /// **'Simulation Setting'**
  String get simSetting;

  /// No description provided for @simFinalBriefing.
  ///
  /// In en, this message translates to:
  /// **'Final Briefing'**
  String get simFinalBriefing;

  /// No description provided for @simBackToSimulations.
  ///
  /// In en, this message translates to:
  /// **'BACK TO SIMULATIONS'**
  String get simBackToSimulations;

  /// No description provided for @simChooseModuleDesc.
  ///
  /// In en, this message translates to:
  /// **'Select a module from your curriculum. The AI will pull relevant patient cases from this specialty.'**
  String get simChooseModuleDesc;

  /// No description provided for @simNoCasesFound.
  ///
  /// In en, this message translates to:
  /// **'No cases found for this module in the database.'**
  String get simNoCasesFound;

  /// No description provided for @simChooseClinicalCase.
  ///
  /// In en, this message translates to:
  /// **'Choose a clinical case'**
  String get simChooseClinicalCase;

  /// No description provided for @simSimParameters.
  ///
  /// In en, this message translates to:
  /// **'Simulation Parameters'**
  String get simSimParameters;

  /// No description provided for @simClinicalSetting.
  ///
  /// In en, this message translates to:
  /// **'Clinical Setting'**
  String get simClinicalSetting;

  /// No description provided for @simSimDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Simulation Difficulty'**
  String get simSimDifficulty;

  /// No description provided for @simReadyToInitialize.
  ///
  /// In en, this message translates to:
  /// **'Ready to initialize?'**
  String get simReadyToInitialize;

  /// No description provided for @simDemographicsPersonalityDesc.
  ///
  /// In en, this message translates to:
  /// **'Patient demographics and personality are pre-defined in the database for this specific clinical case.'**
  String get simDemographicsPersonalityDesc;

  /// No description provided for @simEnterRoomDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter the room and begin the anamnesis to discover the patient\'s identity and history.'**
  String get simEnterRoomDesc;

  /// No description provided for @simCase.
  ///
  /// In en, this message translates to:
  /// **'Case'**
  String get simCase;

  /// No description provided for @simLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get simLocation;

  /// No description provided for @simDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get simDifficulty;

  /// No description provided for @simSaveList.
  ///
  /// In en, this message translates to:
  /// **'SAVE LIST'**
  String get simSaveList;

  /// No description provided for @simDescribeIssue.
  ///
  /// In en, this message translates to:
  /// **'What went wrong? Our technical team will review the session state.'**
  String get simDescribeIssue;

  /// No description provided for @simDiagnosticData.
  ///
  /// In en, this message translates to:
  /// **'DIAGNOSTIC DATA (AUTO-ATTACHED)'**
  String get simDiagnosticData;

  /// No description provided for @simSubmitReport.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT REPORT'**
  String get simSubmitReport;

  /// No description provided for @simReportSent.
  ///
  /// In en, this message translates to:
  /// **'Report sent. Thank you for your feedback!'**
  String get simReportSent;

  /// No description provided for @simCopyAndClose.
  ///
  /// In en, this message translates to:
  /// **'COPY & CLOSE'**
  String get simCopyAndClose;

  /// No description provided for @simObservationCopied.
  ///
  /// In en, this message translates to:
  /// **'Observation copied to clipboard'**
  String get simObservationCopied;

  /// No description provided for @simDifferentialDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'DIFFERENTIAL DIAGNOSIS'**
  String get simDifferentialDiagnosis;

  /// No description provided for @simListDifferentialsHint.
  ///
  /// In en, this message translates to:
  /// **'List your differentials here...'**
  String get simListDifferentialsHint;

  /// No description provided for @simEmergencyRoom.
  ///
  /// In en, this message translates to:
  /// **'Emergency Room'**
  String get simEmergencyRoom;

  /// No description provided for @simEmergencyRoomDesc.
  ///
  /// In en, this message translates to:
  /// **'Acute presentations, limited initial data.'**
  String get simEmergencyRoomDesc;

  /// No description provided for @simOutpatientClinic.
  ///
  /// In en, this message translates to:
  /// **'Outpatient Clinic'**
  String get simOutpatientClinic;

  /// No description provided for @simOutpatientClinicDesc.
  ///
  /// In en, this message translates to:
  /// **'Routine consultation, emphasis on history.'**
  String get simOutpatientClinicDesc;

  /// No description provided for @simInterview.
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get simInterview;

  /// No description provided for @simExam.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get simExam;

  /// No description provided for @simLabs.
  ///
  /// In en, this message translates to:
  /// **'Labs'**
  String get simLabs;

  /// No description provided for @simAuscultation.
  ///
  /// In en, this message translates to:
  /// **'Auscultation'**
  String get simAuscultation;

  /// No description provided for @simPalpation.
  ///
  /// In en, this message translates to:
  /// **'Palpation'**
  String get simPalpation;

  /// No description provided for @simPercussion.
  ///
  /// In en, this message translates to:
  /// **'Percussion'**
  String get simPercussion;

  /// No description provided for @simNeurologicalExam.
  ///
  /// In en, this message translates to:
  /// **'Neurological Exam'**
  String get simNeurologicalExam;

  /// No description provided for @simPupillaryReflex.
  ///
  /// In en, this message translates to:
  /// **'Pupillary Reflex'**
  String get simPupillaryReflex;

  /// No description provided for @simJVP.
  ///
  /// In en, this message translates to:
  /// **'Jugular Venous Pressure'**
  String get simJVP;

  /// No description provided for @simRevealInterpretation.
  ///
  /// In en, this message translates to:
  /// **'Reveal Expert Interpretation'**
  String get simRevealInterpretation;

  /// No description provided for @simSaveContinue.
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get simSaveContinue;

  /// No description provided for @simSubmitFinalDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT FINAL DIAGNOSIS'**
  String get simSubmitFinalDiagnosis;

  /// No description provided for @simFinalDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Final Diagnosis'**
  String get simFinalDiagnosis;

  /// No description provided for @simEnterPathology.
  ///
  /// In en, this message translates to:
  /// **'Enter your suspected pathology...'**
  String get simEnterPathology;

  /// No description provided for @simInterviewHint.
  ///
  /// In en, this message translates to:
  /// **'Interview the patient...'**
  String get simInterviewHint;

  /// No description provided for @simPatientThinking.
  ///
  /// In en, this message translates to:
  /// **'Patient is thinking...'**
  String get simPatientThinking;

  /// No description provided for @simPerformExamination.
  ///
  /// In en, this message translates to:
  /// **'PERFORM EXAMINATION'**
  String get simPerformExamination;

  /// No description provided for @simLatestFinding.
  ///
  /// In en, this message translates to:
  /// **'LATEST FINDING'**
  String get simLatestFinding;

  /// No description provided for @simSearchInvestigations.
  ///
  /// In en, this message translates to:
  /// **'Search investigations...'**
  String get simSearchInvestigations;

  /// No description provided for @simDiagnosticResults.
  ///
  /// In en, this message translates to:
  /// **'DIAGNOSTIC RESULTS'**
  String get simDiagnosticResults;

  /// No description provided for @simAiClinicalTutor.
  ///
  /// In en, this message translates to:
  /// **'AI CLINICAL TUTOR'**
  String get simAiClinicalTutor;

  /// No description provided for @simAskTutorFindings.
  ///
  /// In en, this message translates to:
  /// **'ASK THE TUTOR ABOUT FINDINGS'**
  String get simAskTutorFindings;

  /// No description provided for @simWhySignificant.
  ///
  /// In en, this message translates to:
  /// **'Why is this result significant in this case?'**
  String get simWhySignificant;

  /// No description provided for @simYourInterpretation.
  ///
  /// In en, this message translates to:
  /// **'YOUR INTERPRETATION'**
  String get simYourInterpretation;

  /// No description provided for @simEnterFinding.
  ///
  /// In en, this message translates to:
  /// **'Enter your clinical finding or interpretation...'**
  String get simEnterFinding;

  /// No description provided for @simRefRange.
  ///
  /// In en, this message translates to:
  /// **'REF RANGE'**
  String get simRefRange;

  /// No description provided for @simNoDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No clinical data available for this investigation.'**
  String get simNoDataAvailable;

  /// No description provided for @simRetrievingData.
  ///
  /// In en, this message translates to:
  /// **'Retrieving clinical data...'**
  String get simRetrievingData;

  /// No description provided for @simLoadingAudio.
  ///
  /// In en, this message translates to:
  /// **'LOADING CLINICAL AUDIO...'**
  String get simLoadingAudio;

  /// No description provided for @simPlayingAuscultation.
  ///
  /// In en, this message translates to:
  /// **'PLAYING AUSCULTATION...'**
  String get simPlayingAuscultation;

  /// No description provided for @simReadyToListen.
  ///
  /// In en, this message translates to:
  /// **'READY TO LISTEN'**
  String get simReadyToListen;

  /// No description provided for @simInterpretation.
  ///
  /// In en, this message translates to:
  /// **'INTERPRETATION'**
  String get simInterpretation;

  /// No description provided for @simExpertInterpretation.
  ///
  /// In en, this message translates to:
  /// **'EXPERT INTERPRETATION'**
  String get simExpertInterpretation;

  /// No description provided for @simViewMedia.
  ///
  /// In en, this message translates to:
  /// **'VIEW {mediaType}'**
  String simViewMedia(Object mediaType);

  /// No description provided for @simClinicalReasoningTutor.
  ///
  /// In en, this message translates to:
  /// **'CLINICAL REASONING TUTOR'**
  String get simClinicalReasoningTutor;

  /// No description provided for @simWelcomeDoctor.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Doctor.'**
  String get simWelcomeDoctor;

  /// No description provided for @simTutorHelp.
  ///
  /// In en, this message translates to:
  /// **'I can help you interpret findings, suggest differential diagnoses, or explain the pathophysiology of this case. How can I assist you?'**
  String get simTutorHelp;

  /// No description provided for @simSuggestedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Suggested Questions:'**
  String get simSuggestedQuestions;

  /// No description provided for @simAskTutorHint.
  ///
  /// In en, this message translates to:
  /// **'Ask the tutor...'**
  String get simAskTutorHint;

  /// No description provided for @simTutorDiff.
  ///
  /// In en, this message translates to:
  /// **'What are the most likely differentials?'**
  String get simTutorDiff;

  /// No description provided for @simTutorEcg.
  ///
  /// In en, this message translates to:
  /// **'Can you explain the significance of the ECG findings?'**
  String get simTutorEcg;

  /// No description provided for @simTutorManagement.
  ///
  /// In en, this message translates to:
  /// **'What would be my next priority in management?'**
  String get simTutorManagement;

  /// No description provided for @simSessionExported.
  ///
  /// In en, this message translates to:
  /// **'Session Log Exported'**
  String get simSessionExported;

  /// No description provided for @simCancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get simCancel;

  /// No description provided for @simSubmit.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT'**
  String get simSubmit;

  /// No description provided for @simClose.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get simClose;

  /// No description provided for @labBiochemistry.
  ///
  /// In en, this message translates to:
  /// **'Biochemistry'**
  String get labBiochemistry;

  /// No description provided for @labHematology.
  ///
  /// In en, this message translates to:
  /// **'Hematology'**
  String get labHematology;

  /// No description provided for @labCardiac.
  ///
  /// In en, this message translates to:
  /// **'Cardiac'**
  String get labCardiac;

  /// No description provided for @labRadiology.
  ///
  /// In en, this message translates to:
  /// **'Radiology'**
  String get labRadiology;

  /// No description provided for @labMicrobiology.
  ///
  /// In en, this message translates to:
  /// **'Microbiology'**
  String get labMicrobiology;

  /// No description provided for @labOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get labOthers;

  /// No description provided for @labBloodGlucose.
  ///
  /// In en, this message translates to:
  /// **'Blood Glucose'**
  String get labBloodGlucose;

  /// No description provided for @labUreaElectrolytes.
  ///
  /// In en, this message translates to:
  /// **'Urea & Electrolytes'**
  String get labUreaElectrolytes;

  /// No description provided for @labLiverFunction.
  ///
  /// In en, this message translates to:
  /// **'Liver Function Tests'**
  String get labLiverFunction;

  /// No description provided for @labCrp.
  ///
  /// In en, this message translates to:
  /// **'CRP'**
  String get labCrp;

  /// No description provided for @labHba1c.
  ///
  /// In en, this message translates to:
  /// **'HbA1c'**
  String get labHba1c;

  /// No description provided for @labLipidProfile.
  ///
  /// In en, this message translates to:
  /// **'Lipid Profile'**
  String get labLipidProfile;

  /// No description provided for @labFbc.
  ///
  /// In en, this message translates to:
  /// **'Full Blood Count'**
  String get labFbc;

  /// No description provided for @labCoagulation.
  ///
  /// In en, this message translates to:
  /// **'Coagulation Profile'**
  String get labCoagulation;

  /// No description provided for @labDdimer.
  ///
  /// In en, this message translates to:
  /// **'D-Dimer'**
  String get labDdimer;

  /// No description provided for @labBloodFilm.
  ///
  /// In en, this message translates to:
  /// **'Blood Film'**
  String get labBloodFilm;

  /// No description provided for @labTroponin.
  ///
  /// In en, this message translates to:
  /// **'Troponin I/T'**
  String get labTroponin;

  /// No description provided for @labNtProBnp.
  ///
  /// In en, this message translates to:
  /// **'NT-proBNP'**
  String get labNtProBnp;

  /// No description provided for @labEcg.
  ///
  /// In en, this message translates to:
  /// **'ECG (12-Lead)'**
  String get labEcg;

  /// No description provided for @labEcho.
  ///
  /// In en, this message translates to:
  /// **'Echocardiogram'**
  String get labEcho;

  /// No description provided for @labCardiacEnzymes.
  ///
  /// In en, this message translates to:
  /// **'Cardiac enzymes'**
  String get labCardiacEnzymes;

  /// No description provided for @labCxr.
  ///
  /// In en, this message translates to:
  /// **'Chest X-Ray'**
  String get labCxr;

  /// No description provided for @labAxr.
  ///
  /// In en, this message translates to:
  /// **'Abdominal X-Ray'**
  String get labAxr;

  /// No description provided for @labCtBrain.
  ///
  /// In en, this message translates to:
  /// **'CT Brain'**
  String get labCtBrain;

  /// No description provided for @labCtpa.
  ///
  /// In en, this message translates to:
  /// **'CT Pulmonary Angio'**
  String get labCtpa;

  /// No description provided for @labAbdoUs.
  ///
  /// In en, this message translates to:
  /// **'Abdominal Ultrasound'**
  String get labAbdoUs;

  /// No description provided for @labMriBrain.
  ///
  /// In en, this message translates to:
  /// **'MRI Brain'**
  String get labMriBrain;

  /// No description provided for @labBloodCultures.
  ///
  /// In en, this message translates to:
  /// **'Blood Cultures'**
  String get labBloodCultures;

  /// No description provided for @labUrineCulture.
  ///
  /// In en, this message translates to:
  /// **'Urine Culture'**
  String get labUrineCulture;

  /// No description provided for @labSputumCulture.
  ///
  /// In en, this message translates to:
  /// **'Sputum Culture'**
  String get labSputumCulture;

  /// No description provided for @labPcr.
  ///
  /// In en, this message translates to:
  /// **'PCR COVID/Flu'**
  String get labPcr;

  /// No description provided for @labUrinalysis.
  ///
  /// In en, this message translates to:
  /// **'Urinalysis'**
  String get labUrinalysis;

  /// No description provided for @labAbg.
  ///
  /// In en, this message translates to:
  /// **'Arterial Blood Gas'**
  String get labAbg;

  /// No description provided for @labPeakFlow.
  ///
  /// In en, this message translates to:
  /// **'Peak Flow'**
  String get labPeakFlow;

  /// No description provided for @simAllSpecialties.
  ///
  /// In en, this message translates to:
  /// **'All Specialties'**
  String get simAllSpecialties;

  /// No description provided for @simSearchPathology.
  ///
  /// In en, this message translates to:
  /// **'Search for a pathology or symptoms...'**
  String get simSearchPathology;

  /// No description provided for @peakFocusMsg.
  ///
  /// In en, this message translates to:
  /// **'Excellent focus. Ready to tackle complex topics!'**
  String get peakFocusMsg;

  /// No description provided for @lightFatigueMsg.
  ///
  /// In en, this message translates to:
  /// **'Light fatigue detected. Consider switching subjects or taking a short break.'**
  String get lightFatigueMsg;

  /// No description provided for @burnoutRiskMsg.
  ///
  /// In en, this message translates to:
  /// **'High fatigue. Take a real break to recharge your batteries.'**
  String get burnoutRiskMsg;

  /// No description provided for @elapsedTime.
  ///
  /// In en, this message translates to:
  /// **'Elapsed Time'**
  String get elapsedTime;

  /// No description provided for @averagePace.
  ///
  /// In en, this message translates to:
  /// **'Average Pace'**
  String get averagePace;

  /// No description provided for @recommendedReview.
  ///
  /// In en, this message translates to:
  /// **'Recommended Review'**
  String get recommendedReview;

  /// No description provided for @perfectScore.
  ///
  /// In en, this message translates to:
  /// **'Perfect Score!'**
  String get perfectScore;

  /// No description provided for @perfectScoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations, you have mastered all notions of this quiz!'**
  String get perfectScoreSubtitle;

  /// No description provided for @reviewMistakes.
  ///
  /// In en, this message translates to:
  /// **'Review Mistakes'**
  String get reviewMistakes;

  /// No description provided for @restartQuiz.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restartQuiz;

  /// No description provided for @performanceExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get performanceExcellent;

  /// No description provided for @performanceVeryGood.
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get performanceVeryGood;

  /// No description provided for @performanceAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get performanceAverage;

  /// No description provided for @performanceNeedsWork.
  ///
  /// In en, this message translates to:
  /// **'Needs Work'**
  String get performanceNeedsWork;

  /// No description provided for @feedbackNeedsWork.
  ///
  /// In en, this message translates to:
  /// **'Take your time to review the corrections to improve.'**
  String get feedbackNeedsWork;

  /// No description provided for @feedbackExcellent.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You have mastered this topic perfectly.'**
  String get feedbackExcellent;

  /// No description provided for @feedbackVeryGood.
  ///
  /// In en, this message translates to:
  /// **'Great job! You are almost there.'**
  String get feedbackVeryGood;

  /// No description provided for @feedbackAverage.
  ///
  /// In en, this message translates to:
  /// **'Good foundation, keep reviewing!'**
  String get feedbackAverage;

  /// No description provided for @questionsDetailsList.
  ///
  /// In en, this message translates to:
  /// **'Question Details'**
  String get questionsDetailsList;

  /// No description provided for @fatigueSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Fatigue Settings'**
  String get fatigueSettingsTitle;

  /// No description provided for @fatigueAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Fatigue Analysis'**
  String get fatigueAnalysis;

  /// No description provided for @fatigueAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable real-time tracking of mental load based on study sessions, quiz performance, and recovery breaks.'**
  String get fatigueAnalysisDesc;

  /// No description provided for @fatigueSensitivity.
  ///
  /// In en, this message translates to:
  /// **'Fatigue Sensitivity'**
  String get fatigueSensitivity;

  /// No description provided for @fatigueSensitivityDesc.
  ///
  /// In en, this message translates to:
  /// **'Adjust how fast cognitive load builds up during work and quizzes.'**
  String get fatigueSensitivityDesc;

  /// No description provided for @sensitivityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get sensitivityLow;

  /// No description provided for @sensitivityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get sensitivityMedium;

  /// No description provided for @sensitivityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get sensitivityHigh;

  /// No description provided for @fatigueAlerts.
  ///
  /// In en, this message translates to:
  /// **'Fatigue Alert Notifications'**
  String get fatigueAlerts;

  /// No description provided for @fatigueAlertsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications when fatigue levels indicate a break is due.'**
  String get fatigueAlertsDesc;

  /// No description provided for @fatigueAnalysisSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable automatic cognitive fatigue tracking'**
  String get fatigueAnalysisSubtitle;

  /// No description provided for @sensitivityLowDesc.
  ///
  /// In en, this message translates to:
  /// **'Fatigue builds up 50% slower'**
  String get sensitivityLowDesc;

  /// No description provided for @sensitivityMediumDesc.
  ///
  /// In en, this message translates to:
  /// **'Standard recommended settings'**
  String get sensitivityMediumDesc;

  /// No description provided for @sensitivityHighDesc.
  ///
  /// In en, this message translates to:
  /// **'Fatigue builds up 50% faster'**
  String get sensitivityHighDesc;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @faqHowCanWeHelp.
  ///
  /// In en, this message translates to:
  /// **'How can we help you?'**
  String get faqHowCanWeHelp;

  /// No description provided for @faqSearchDesc.
  ///
  /// In en, this message translates to:
  /// **'Search our frequently asked questions'**
  String get faqSearchDesc;

  /// No description provided for @faqCategoryAccountPremium.
  ///
  /// In en, this message translates to:
  /// **'Account & Premium'**
  String get faqCategoryAccountPremium;

  /// No description provided for @faqCategoryStudyFeatures.
  ///
  /// In en, this message translates to:
  /// **'Study Features'**
  String get faqCategoryStudyFeatures;

  /// No description provided for @faqCategoryCommunityGroups.
  ///
  /// In en, this message translates to:
  /// **'Community & Groups'**
  String get faqCategoryCommunityGroups;

  /// No description provided for @faqStillHaveQuestions.
  ///
  /// In en, this message translates to:
  /// **'Still have questions?'**
  String get faqStillHaveQuestions;

  /// No description provided for @faqContactSupport.
  ///
  /// In en, this message translates to:
  /// **'CONTACT HUMAN SUPPORT'**
  String get faqContactSupport;

  /// No description provided for @faqQ1.
  ///
  /// In en, this message translates to:
  /// **'How do I upgrade to Premium?'**
  String get faqQ1;

  /// No description provided for @faqA1.
  ///
  /// In en, this message translates to:
  /// **'You can upgrade by clicking on the Profile tab or selecting any premium feature (like unlimited AI Chat). We support various payment methods including Chargily for Algerian Dinars.'**
  String get faqA1;

  /// No description provided for @faqQ2.
  ///
  /// In en, this message translates to:
  /// **'Can I use Meducyte on multiple devices?'**
  String get faqQ2;

  /// No description provided for @faqA2.
  ///
  /// In en, this message translates to:
  /// **'Yes! Your data is synced to your account. Simply log in on your new device to continue your study journey.'**
  String get faqA2;

  /// No description provided for @faqQ3.
  ///
  /// In en, this message translates to:
  /// **'How does Spaced Repetition work?'**
  String get faqQ3;

  /// No description provided for @faqA3.
  ///
  /// In en, this message translates to:
  /// **'Meducyte uses advanced algorithms to track your performance. We show you difficult questions more often and easy ones less frequently to optimize your memory retention.'**
  String get faqA3;

  /// No description provided for @faqQ4.
  ///
  /// In en, this message translates to:
  /// **'What is the AI Medical Tutor?'**
  String get faqQ4;

  /// No description provided for @faqA4.
  ///
  /// In en, this message translates to:
  /// **'Medu-AI is our custom chatbot trained on medical literature. It can explain complex concepts, help you interpret labs, or guide you through clinical cases.'**
  String get faqA4;

  /// No description provided for @faqQ5.
  ///
  /// In en, this message translates to:
  /// **'Does Meducyte follow the Algerian curriculum?'**
  String get faqQ5;

  /// No description provided for @faqA5.
  ///
  /// In en, this message translates to:
  /// **'Yes, our question bank and course structure are specifically designed to align with the curriculum modules of Algerian medical faculties.'**
  String get faqA5;

  /// No description provided for @faqQ6.
  ///
  /// In en, this message translates to:
  /// **'How to start a Group Study?'**
  String get faqQ6;

  /// No description provided for @faqA6.
  ///
  /// In en, this message translates to:
  /// **'Head to the \'Productive Bay\' and select \'Study Groups\'. You can create a private group and invite your comrades via a unique code or link.'**
  String get faqA6;

  /// No description provided for @faqQ7.
  ///
  /// In en, this message translates to:
  /// **'Is there a Meducyte community?'**
  String get faqQ7;

  /// No description provided for @faqA7.
  ///
  /// In en, this message translates to:
  /// **'Yes! Join our official Telegram channel to stay updated and discuss with thousands of medical students across Algeria.'**
  String get faqA7;

  /// No description provided for @statsPerformanceTrend.
  ///
  /// In en, this message translates to:
  /// **'Performance Trend'**
  String get statsPerformanceTrend;

  /// No description provided for @statsSpecialtyAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Specialty Accuracy'**
  String get statsSpecialtyAccuracy;

  /// No description provided for @statsTotalAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Total Accuracy'**
  String get statsTotalAccuracy;

  /// No description provided for @statsQuizzesDone.
  ///
  /// In en, this message translates to:
  /// **'Quizzes Done'**
  String get statsQuizzesDone;

  /// No description provided for @statsQuestions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get statsQuestions;

  /// No description provided for @statsStreak.
  ///
  /// In en, this message translates to:
  /// **'Study Streak'**
  String get statsStreak;

  /// No description provided for @chatTrialLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Trial Limit'**
  String get chatTrialLimitTitle;

  /// No description provided for @chatTrialLimitDesc.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the limit of 5 trial messages. Upgrade to Premium for unlimited access to the AI Medical Tutor.'**
  String get chatTrialLimitDesc;

  /// No description provided for @chatUpgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get chatUpgradeNow;

  /// No description provided for @chatTrialBadge.
  ///
  /// In en, this message translates to:
  /// **'TRIAL'**
  String get chatTrialBadge;

  /// No description provided for @chatMessagesCount.
  ///
  /// In en, this message translates to:
  /// **'• {count}/5 messages'**
  String chatMessagesCount(Object count);

  /// No description provided for @chatClearHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Start a new conversation and clear history?'**
  String get chatClearHistoryConfirm;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @freeBadge.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get freeBadge;

  /// No description provided for @studyNote.
  ///
  /// In en, this message translates to:
  /// **'Study Note'**
  String get studyNote;

  /// No description provided for @emptyNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Empty note. Tap to edit.'**
  String get emptyNoteHint;

  /// No description provided for @premiumFeature.
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get premiumFeature;

  /// No description provided for @upgradeToUnlockAi.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to a higher tier to unlock high-level AI tools and full module access.'**
  String get upgradeToUnlockAi;

  /// No description provided for @viewPlans.
  ///
  /// In en, this message translates to:
  /// **'View Plans'**
  String get viewPlans;

  /// No description provided for @zenModeEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable Zen Mode'**
  String get zenModeEnable;

  /// No description provided for @zenModeDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable Zen Mode'**
  String get zenModeDisable;

  /// No description provided for @sepiaThemeEnable.
  ///
  /// In en, this message translates to:
  /// **'Sepia Paper Theme'**
  String get sepiaThemeEnable;

  /// No description provided for @sepiaThemeDisable.
  ///
  /// In en, this message translates to:
  /// **'Standard Theme'**
  String get sepiaThemeDisable;

  /// No description provided for @autoScrollStart.
  ///
  /// In en, this message translates to:
  /// **'Start Auto-Scroll'**
  String get autoScrollStart;

  /// No description provided for @autoScrollPause.
  ///
  /// In en, this message translates to:
  /// **'Pause Auto-Scroll'**
  String get autoScrollPause;

  /// No description provided for @scrollSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Scroll Speed: {speed}x'**
  String scrollSpeedLabel(Object speed);

  /// No description provided for @adjustTextSize.
  ///
  /// In en, this message translates to:
  /// **'Adjust Text Size'**
  String get adjustTextSize;

  /// No description provided for @printPdfExport.
  ///
  /// In en, this message translates to:
  /// **'Print / PDF Export'**
  String get printPdfExport;

  /// No description provided for @reportContent.
  ///
  /// In en, this message translates to:
  /// **'Report Content'**
  String get reportContent;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// No description provided for @aiExplain.
  ///
  /// In en, this message translates to:
  /// **'AI Explain'**
  String get aiExplain;

  /// No description provided for @aiSummarize.
  ///
  /// In en, this message translates to:
  /// **'AI Summarize'**
  String get aiSummarize;

  /// No description provided for @aiMnemonic.
  ///
  /// In en, this message translates to:
  /// **'AI Mnemonic'**
  String get aiMnemonic;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get deleteNote;

  /// No description provided for @highlightColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Highlight Color'**
  String get highlightColorTitle;

  /// No description provided for @highlightOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Highlight Options'**
  String get highlightOptionsTitle;

  /// No description provided for @sq3rReadingModeTitle.
  ///
  /// In en, this message translates to:
  /// **'SQ3R Reading Mode'**
  String get sq3rReadingModeTitle;

  /// No description provided for @returnToSq3r.
  ///
  /// In en, this message translates to:
  /// **'Return to SQ3R'**
  String get returnToSq3r;

  /// No description provided for @tapToZoom.
  ///
  /// In en, this message translates to:
  /// **'Tap to zoom'**
  String get tapToZoom;

  /// No description provided for @loadingImage.
  ///
  /// In en, this message translates to:
  /// **'Loading image…'**
  String get loadingImage;

  /// No description provided for @imageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get imageUnavailable;

  /// No description provided for @sectionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sections'**
  String sectionsCount(Object count);

  /// No description provided for @dummyLoadingLessonTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading dummy lesson title...'**
  String get dummyLoadingLessonTitle;

  /// No description provided for @dummyLoadingParagraphTitle.
  ///
  /// In en, this message translates to:
  /// **'Dummy paragraph number {number}'**
  String dummyLoadingParagraphTitle(Object number);

  /// No description provided for @dummyLoadingParagraphContent.
  ///
  /// In en, this message translates to:
  /// **'Loading dummy paragraph content for the active lesson...'**
  String get dummyLoadingParagraphContent;

  /// No description provided for @sectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Section {number}'**
  String sectionLabel(Object number);

  /// No description provided for @tableLabel.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get tableLabel;

  /// No description provided for @loadingModuleA.
  ///
  /// In en, this message translates to:
  /// **'Loading Module A…'**
  String get loadingModuleA;

  /// No description provided for @loadingModuleB.
  ///
  /// In en, this message translates to:
  /// **'Loading Module B…'**
  String get loadingModuleB;

  /// No description provided for @loadingModuleC.
  ///
  /// In en, this message translates to:
  /// **'Loading Module C…'**
  String get loadingModuleC;

  /// No description provided for @loadingLessonA.
  ///
  /// In en, this message translates to:
  /// **'Loading Lesson A…'**
  String get loadingLessonA;

  /// No description provided for @loadingLessonB.
  ///
  /// In en, this message translates to:
  /// **'Loading Lesson B…'**
  String get loadingLessonB;

  /// No description provided for @loadingLessonC.
  ///
  /// In en, this message translates to:
  /// **'Loading Lesson C…'**
  String get loadingLessonC;

  /// No description provided for @loadingSourceA.
  ///
  /// In en, this message translates to:
  /// **'Loading Source A…'**
  String get loadingSourceA;

  /// No description provided for @loadingSourceB.
  ///
  /// In en, this message translates to:
  /// **'Loading Source B…'**
  String get loadingSourceB;

  /// No description provided for @modulesError.
  ///
  /// In en, this message translates to:
  /// **'Modules Error: {error}'**
  String modulesError(String error);

  /// No description provided for @lessonsError.
  ///
  /// In en, this message translates to:
  /// **'Lessons Error: {error}'**
  String lessonsError(String error);

  /// No description provided for @revisionMode.
  ///
  /// In en, this message translates to:
  /// **'Revision Mode'**
  String get revisionMode;

  /// No description provided for @showAnswersDirectly.
  ///
  /// In en, this message translates to:
  /// **'Show answers directly'**
  String get showAnswersDirectly;

  /// No description provided for @allOrNothing.
  ///
  /// In en, this message translates to:
  /// **'All or nothing'**
  String get allOrNothing;

  /// No description provided for @partialPoints.
  ///
  /// In en, this message translates to:
  /// **'Partial points'**
  String get partialPoints;

  /// No description provided for @examDuration.
  ///
  /// In en, this message translates to:
  /// **'Exam duration'**
  String get examDuration;

  /// No description provided for @durationNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get durationNone;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(String minutes);

  /// No description provided for @questionCount.
  ///
  /// In en, this message translates to:
  /// **'Number of questions'**
  String get questionCount;

  /// No description provided for @questionCountAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get questionCountAll;

  /// No description provided for @questionCountCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get questionCountCustom;

  /// No description provided for @preciseNumber.
  ///
  /// In en, this message translates to:
  /// **'Precise number:'**
  String get preciseNumber;

  /// No description provided for @enterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get enterNumber;

  /// No description provided for @freeTrialLimitDesc.
  ///
  /// In en, this message translates to:
  /// **'Free Trial: 10 questions per session'**
  String get freeTrialLimitDesc;

  /// No description provided for @modulesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} modules'**
  String modulesCount(String count);

  /// No description provided for @maximumItemsAllowed.
  ///
  /// In en, this message translates to:
  /// **'Maximum {count} items allowed'**
  String maximumItemsAllowed(String count);

  /// No description provided for @loadingQuestion.
  ///
  /// In en, this message translates to:
  /// **'Loading question, please wait…'**
  String get loadingQuestion;

  /// No description provided for @dummyLoadingOption.
  ///
  /// In en, this message translates to:
  /// **'Dummy loading option {number}'**
  String dummyLoadingOption(int number);

  /// No description provided for @sessionSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Session saved successfully'**
  String get sessionSavedSuccess;

  /// No description provided for @quitQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Quit the quiz?'**
  String get quitQuizTitle;

  /// No description provided for @quitQuizBody.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save your progress to resume later or abandon this session?'**
  String get quitQuizBody;

  /// No description provided for @saveAndQuit.
  ///
  /// In en, this message translates to:
  /// **'Save and quit'**
  String get saveAndQuit;

  /// No description provided for @quitWithoutSaving.
  ///
  /// In en, this message translates to:
  /// **'Quit without saving'**
  String get quitWithoutSaving;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTask;

  /// No description provided for @editSubTask.
  ///
  /// In en, this message translates to:
  /// **'Edit sub-task'**
  String get editSubTask;

  /// No description provided for @subTaskName.
  ///
  /// In en, this message translates to:
  /// **'Sub-task name'**
  String get subTaskName;

  /// No description provided for @subTasksLabel.
  ///
  /// In en, this message translates to:
  /// **'Sub-tasks'**
  String get subTasksLabel;

  /// No description provided for @addSubTaskHint.
  ///
  /// In en, this message translates to:
  /// **'Add a sub-task…'**
  String get addSubTaskHint;

  /// No description provided for @editLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editLabel;

  /// No description provided for @deleteTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get deleteTaskTitle;

  /// No description provided for @deleteTaskConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'{title}\'?'**
  String deleteTaskConfirm(String title);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @compileAndCopy.
  ///
  /// In en, this message translates to:
  /// **'Compile & Copy'**
  String get compileAndCopy;

  /// No description provided for @examHelp.
  ///
  /// In en, this message translates to:
  /// **'Exam Help'**
  String get examHelp;

  /// No description provided for @newExamSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'New Exam Section'**
  String get newExamSectionTitle;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @reportCleared.
  ///
  /// In en, this message translates to:
  /// **'Report cleared'**
  String get reportCleared;

  /// No description provided for @clearReportQuestion.
  ///
  /// In en, this message translates to:
  /// **'Clear Report?'**
  String get clearReportQuestion;

  /// No description provided for @clearReportConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear the entire observation report? This cannot be undone.'**
  String get clearReportConfirmDesc;

  /// No description provided for @reportCopiedClipboard.
  ///
  /// In en, this message translates to:
  /// **'Report copied to clipboard'**
  String get reportCopiedClipboard;

  /// No description provided for @examNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Exam Name'**
  String get examNameTitle;

  /// No description provided for @pelvicUltrasoundExample.
  ///
  /// In en, this message translates to:
  /// **'Ex: Pelvic ultrasound'**
  String get pelvicUltrasoundExample;

  /// No description provided for @otherOption.
  ///
  /// In en, this message translates to:
  /// **'Other...'**
  String get otherOption;

  /// No description provided for @newSectionHint.
  ///
  /// In en, this message translates to:
  /// **'Section name (e.g. ENT Exam)'**
  String get newSectionHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
