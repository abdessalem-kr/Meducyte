import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/bay_settings_provider.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/settings_models.dart';

class CustomizeBayPage extends ConsumerWidget {
  const CustomizeBayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(baySettingsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("Personnaliser le Hub"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: sections.length,
        onReorder: (oldIndex, newIndex) {
          ref.read(baySettingsProvider.notifier).reorder(oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          final section = sections[index];
          return _buildSectionTile(context, ref, section, isDark, index);
        },
      ),
    );
  }

  Widget _buildSectionTile(
    BuildContext context,
    WidgetRef ref,
    BaySection section,
    bool isDark,
    int index,
  ) {
    final theme = Theme.of(context);
    return Container(
      key: ValueKey(section.id),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(_getIconForType(section.type), color: theme.primaryColor),
        title: Text(
          section.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          section.isEnabled ? "Activé" : "Désactivé",
          style: TextStyle(
            color: section.isEnabled ? Colors.green : Colors.grey,
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: section.isEnabled,
              activeColor: theme.primaryColor,
              onChanged: (val) {
                ref
                    .read(baySettingsProvider.notifier)
                    .toggleVisibility(section.id);
              },
            ),
            const SizedBox(width: 8),
            ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(BaySectionType type) {
    switch (type) {
      case BaySectionType.fatigueTracker:
        return Iconsax.mask;
      case BaySectionType.navigationHub:
        return Iconsax.category;
      case BaySectionType.pomodoroTimer:
        return Iconsax.timer_1;
      case BaySectionType.examCountdown:
        return Iconsax.clock;
      case BaySectionType.flashcardPulse:
        return Iconsax.flash;
      case BaySectionType.aiScheduler:
        return Iconsax.magic_star;
    }
  }
}
