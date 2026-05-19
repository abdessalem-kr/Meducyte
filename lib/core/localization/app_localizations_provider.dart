import 'package:meducyte_app/export.dart';

final appLocalizationsProvider = FutureProvider<AppLocalizations>((ref) async {
  final locale = ref.watch(localeProvider);
  return AppLocalizations.delegate.load(locale);
});
