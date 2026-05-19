import 'package:meducyte_app/export.dart';

class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return Wrap(
      spacing: 8.0,
      children: [
        //System theme
        ChoiceChip(
          showCheckmark: false,
          label: const Text('System'),
          selected: themeMode == ThemeMode.system,
          onSelected: (_) {
            ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
          },
        ),
        //Light theme
        ChoiceChip(
          showCheckmark: false,
          label: const Text('Light'),
          selected: themeMode == ThemeMode.light,
          onSelected: (_) {
            ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
          },
        ),
        //Dark theme
        ChoiceChip(
          showCheckmark: false,
          label: const Text('Dark'),
          selected: themeMode == ThemeMode.dark,
          onSelected: (_) {
            ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
          },
        ),
      ],
    );
  }
}
