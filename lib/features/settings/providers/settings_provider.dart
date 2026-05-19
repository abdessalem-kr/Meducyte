import 'package:meducyte_app/export.dart';

// ---AppSettings Model---
class AppSettings extends Equatable {
  final bool notificationsEnabled;
  final bool highContrastEnabled;
  final bool syncSettingsEnabled;
  final String fontSize; //Small,Medium,Large
  final String quizFontSize; //Small,Medium,Large
  final String courseFontSize; //Small,Medium,Large
  final String downloadMode; //Wi-Fi only,cellular

  //Granular Notification Toggles
  final bool examNotificationsEnabled;
  final bool taskNotificationsEnabled;
  final bool studyNotificationsEnabled;
  final bool communityNotificationsEnabled;

  //Spaced Repetition Settings
  final int srsNewCardsPerDay;
  final int srsReviewLimit;
  final bool srsNotifyEnabled;
  final String srsNotifyTime;

  const AppSettings({
    required this.notificationsEnabled,
    required this.highContrastEnabled,
    required this.syncSettingsEnabled,
    required this.fontSize,
    this.quizFontSize = 'Medium',
    this.courseFontSize = 'Medium',
    required this.downloadMode,
    this.examNotificationsEnabled = true,
    this.taskNotificationsEnabled = true,
    this.studyNotificationsEnabled = true,
    this.communityNotificationsEnabled = true,
    this.srsNewCardsPerDay = 20,
    this.srsReviewLimit = 100,
    this.srsNotifyEnabled = true,
    this.srsNotifyTime = '09:00',
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? highContrastEnabled,
    bool? syncSettingsEnabled,
    String? fontSize,
    String? quizFontSize,
    String? courseFontSize,
    String? downloadMode,
    bool? examNotificationsEnabled,
    bool? taskNotificationsEnabled,
    bool? studyNotificationsEnabled,
    bool? communityNotificationsEnabled,
    int? srsNewCardsPerDay,
    int? srsReviewLimit,
    bool? srsNotifyEnabled,
    String? srsNotifyTime,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      highContrastEnabled: highContrastEnabled ?? this.highContrastEnabled,
      syncSettingsEnabled: syncSettingsEnabled ?? this.syncSettingsEnabled,
      fontSize: fontSize ?? this.fontSize,
      quizFontSize: quizFontSize ?? this.quizFontSize,
      courseFontSize: courseFontSize ?? this.courseFontSize,
      downloadMode: downloadMode ?? this.downloadMode,
      examNotificationsEnabled:
          examNotificationsEnabled ?? this.examNotificationsEnabled,
      taskNotificationsEnabled:
          taskNotificationsEnabled ?? this.taskNotificationsEnabled,
      studyNotificationsEnabled:
          studyNotificationsEnabled ?? this.studyNotificationsEnabled,
      communityNotificationsEnabled:
          communityNotificationsEnabled ?? this.communityNotificationsEnabled,
      srsNewCardsPerDay: srsNewCardsPerDay ?? this.srsNewCardsPerDay,
      srsReviewLimit: srsReviewLimit ?? this.srsReviewLimit,
      srsNotifyEnabled: srsNotifyEnabled ?? this.srsNotifyEnabled,
      srsNotifyTime: srsNotifyTime ?? this.srsNotifyTime,
    );
  }

  @override
  List<Object?> get props => [
    notificationsEnabled,
    highContrastEnabled,
    syncSettingsEnabled,
    fontSize,
    quizFontSize,
    courseFontSize,
    downloadMode,
    examNotificationsEnabled,
    taskNotificationsEnabled,
    studyNotificationsEnabled,
    communityNotificationsEnabled,
    srsNewCardsPerDay,
    srsReviewLimit,
    srsNotifyEnabled,
    srsNotifyTime,
  ];
}

// ---AppSettings Notifier---
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  static const _notificationsKey = 'settings_notifications';
  static const _highContrastKey = 'settings_high_contrast';
  static const _syncKey = 'settings_sync';
  static const _fontSizeKey = 'settings_font_size';
  static const _quizFontSizeKey = 'settings_quiz_font_size';
  static const _courseFontSizeKey = 'settings_course_font_size';
  static const _downloadModeKey = 'settings_download_mode';

  static const _examNotifyKey = 'settings_exam_notify';
  static const _taskNotifyKey = 'settings_task_notify';
  static const _studyNotifyKey = 'settings_study_notify';
  static const _communityNotifyKey = 'settings_community_notify';

  static const _srsNewCardsKey = 'settings_srs_new_cards';
  static const _srsReviewLimitKey = 'settings_srs_review_limit';
  static const _srsNotifyKey = 'settings_srs_notify';
  static const _srsNotifyTimeKey = 'settings_srs_notify_time';

  AppSettingsNotifier()
    : super(
        const AppSettings(
          notificationsEnabled: true,
          highContrastEnabled: false,
          syncSettingsEnabled: true,
          fontSize: 'Medium',
          downloadMode: 'Wi-Fi only',
        ),
      ) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      notificationsEnabled: prefs.getBool(_notificationsKey),
      highContrastEnabled: prefs.getBool(_highContrastKey),
      syncSettingsEnabled: prefs.getBool(_syncKey),
      fontSize: prefs.getString(_fontSizeKey),
      quizFontSize: prefs.getString(_quizFontSizeKey),
      courseFontSize: prefs.getString(_courseFontSizeKey),
      downloadMode: prefs.getString(_downloadModeKey),
      examNotificationsEnabled: prefs.getBool(_examNotifyKey),
      taskNotificationsEnabled: prefs.getBool(_taskNotifyKey),
      studyNotificationsEnabled: prefs.getBool(_studyNotifyKey),
      communityNotificationsEnabled: prefs.getBool(_communityNotifyKey),
      srsNewCardsPerDay: prefs.getInt(_srsNewCardsKey) ?? 20,
      srsReviewLimit: prefs.getInt(_srsReviewLimitKey) ?? 100,
      srsNotifyEnabled: prefs.getBool(_srsNotifyKey) ?? true,
      srsNotifyTime: prefs.getString(_srsNotifyTimeKey) ?? '09:00',
    );
  }

  Future<void> toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
    state = state.copyWith(notificationsEnabled: value);
  }

  Future<void> toggleExamNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_examNotifyKey, value);
    state = state.copyWith(examNotificationsEnabled: value);
  }

  Future<void> toggleTaskNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_taskNotifyKey, value);
    state = state.copyWith(taskNotificationsEnabled: value);
  }

  Future<void> toggleStudyNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_studyNotifyKey, value);
    state = state.copyWith(studyNotificationsEnabled: value);
  }

  Future<void> toggleCommunityNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_communityNotifyKey, value);
    state = state.copyWith(communityNotificationsEnabled: value);
  }

  Future<void> toggleHighContrast(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_highContrastKey, value);
    state = state.copyWith(highContrastEnabled: value);
  }

  Future<void> toggleSync(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_syncKey, value);
    state = state.copyWith(syncSettingsEnabled: value);
  }

  Future<void> setFontSize(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontSizeKey, value);
    state = state.copyWith(fontSize: value);
  }

  Future<void> setQuizFontSize(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_quizFontSizeKey, value);
    state = state.copyWith(quizFontSize: value);
  }

  Future<void> setCourseFontSize(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_courseFontSizeKey, value);
    state = state.copyWith(courseFontSize: value);
  }

  Future<void> setDownloadMode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_downloadModeKey, value);
    state = state.copyWith(downloadMode: value);
  }

  Future<void> setSrsNewCardsPerDay(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_srsNewCardsKey, value);
    state = state.copyWith(srsNewCardsPerDay: value);
  }

  Future<void> setSrsReviewLimit(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_srsReviewLimitKey, value);
    state = state.copyWith(srsReviewLimit: value);
  }

  Future<void> toggleSrsNotify(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_srsNotifyKey, value);
    state = state.copyWith(srsNotifyEnabled: value);
  }

  Future<void> setSrsNotifyTime(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_srsNotifyTimeKey, value);
    state = state.copyWith(srsNotifyTime: value);
  }

  Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = const AppSettings(
      notificationsEnabled: true,
      highContrastEnabled: false,
      syncSettingsEnabled: true,
      fontSize: 'Medium',
      downloadMode: 'Wi-Fi only',
      srsNewCardsPerDay: 20,
      srsReviewLimit: 100,
      srsNotifyEnabled: true,
      srsNotifyTime: '09:00',
    );
  }
}

// ---Providers---
final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
      return AppSettingsNotifier();
    });

//Expansion state for a specific tile
final expansionProvider = StateProvider.family<bool, String>(
  (ref, key) => false,
);
