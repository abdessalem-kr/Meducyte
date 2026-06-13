import 'package:meducyte_app/export.dart';

class ReadingSettingsBottomSheet extends ConsumerWidget {
  final String title;
  final String currentSize;
  final Function(String) onSizeChanged;
  final String? currentFontFamily;
  final Function(String)? onFontFamilyChanged;

  const ReadingSettingsBottomSheet({
    super.key,
    required this.title,
    required this.currentSize,
    required this.onSizeChanged,
    this.currentFontFamily,
    this.onFontFamilyChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    // Parse the scale value
    double scale = 1.0;
    final double? parsed = double.tryParse(currentSize);
    if (parsed != null) {
      scale = parsed;
    } else if (currentSize == 'Small' || currentSize == 'Petit') {
      scale = 0.85;
    } else if (currentSize == 'Large' || currentSize == 'Grand') {
      scale = 1.25;
    }

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
          Text(
            l10n.courseFontSizeTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Iconsax.text,
                size: 16,
                color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.primary.withOpacity(0.15),
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withOpacity(0.12),
                    valueIndicatorColor: AppColors.primary,
                    valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                  ),
                  child: Slider(
                    value: scale,
                    min: 0.7,
                    max: 1.6,
                    divisions: 9,
                    label: '${(scale * 100).round()}%',
                    onChanged: (val) {
                      onSizeChanged(val.toStringAsFixed(2));
                    },
                  ),
                ),
              ),
              Icon(
                Iconsax.text,
                size: 28,
                color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${(scale * 100).round()}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          if (onFontFamilyChanged != null) ...[
            const SizedBox(height: 24),
            Text(
              "Font Family",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildFontCard(
                  context: context,
                  fontFamily: 'Inter',
                  displayName: 'Inter',
                  textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  isDark: isDark,
                ),
                _buildFontCard(
                  context: context,
                  fontFamily: 'Roboto',
                  displayName: 'Roboto',
                  textStyle: GoogleFonts.roboto(fontWeight: FontWeight.w500),
                  isDark: isDark,
                ),
                _buildFontCard(
                  context: context,
                  fontFamily: 'EB Garamond',
                  displayName: 'EB Garamond',
                  textStyle: GoogleFonts.ebGaramond(fontWeight: FontWeight.w500),
                  isDark: isDark,
                ),
                _buildFontCard(
                  context: context,
                  fontFamily: 'OpenDyslexic',
                  displayName: 'OpenDyslexic',
                  textStyle: const TextStyle(
                    fontFamily: 'OpenDyslexic',
                    fontWeight: FontWeight.w500,
                  ),
                  isDark: isDark,
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFontCard({
    required BuildContext context,
    required String fontFamily,
    required String displayName,
    required TextStyle textStyle,
    required bool isDark,
  }) {
    final isSelected = currentFontFamily == fontFamily;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (onFontFamilyChanged != null) {
            onFontFamilyChanged!(fontFamily);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.42,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayName,
                  style: textStyle.copyWith(
                    fontSize: 15,
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? Colors.white : Colors.black),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 18,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
