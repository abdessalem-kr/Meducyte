import 'package:meducyte_app/export.dart';

class ReadingSettingsBottomSheet extends ConsumerWidget {
  final String title;
  final String currentSize;
  final Function(String) onSizeChanged;

  const ReadingSettingsBottomSheet({
    super.key,
    required this.title,
    required this.currentSize,
    required this.onSizeChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.text_italic, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSizeOption(
            context: context,
            icon: Iconsax.text_italic,
            label: l10n.fontSmall,
            value: 'Small',
            isSelected: currentSize == 'Small' || currentSize == 'Petit',
            fontSize: 14,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildSizeOption(
            context: context,
            icon: Iconsax.text_italic,
            label: l10n.fontMedium,
            value: 'Medium',
            isSelected: currentSize == 'Medium' || currentSize == 'Moyen',
            fontSize: 16,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildSizeOption(
            context: context,
            icon: Iconsax.text_italic,
            label: l10n.fontLarge,
            value: 'Large',
            isSelected: currentSize == 'Large' || currentSize == 'Grand',
            fontSize: 20,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSizeOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required bool isSelected,
    required double fontSize,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        onSizeChanged(value);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? Colors.white70 : Colors.black54),
              size: fontSize,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.white : Colors.black),
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
