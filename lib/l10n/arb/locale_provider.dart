import 'dart:ui';
import 'package:meducyte_app/export.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  static const _languageKey = 'selected_language';

  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString(_languageKey);
    if (savedLang != null) {
      state = Locale(savedLang);
    } else {
      //Auto-detect device language
      final systemLocale = PlatformDispatcher.instance.locale;
      if (['en', 'fr'].contains(systemLocale.languageCode)) {
        state = Locale(systemLocale.languageCode);
      } else {
        state = const Locale('en');
      }
    }
  }

  Future<void> setLocale(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, langCode);
    state = Locale(langCode);
  }
}
