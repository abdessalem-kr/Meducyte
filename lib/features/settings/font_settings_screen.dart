import 'package:meducyte_app/export.dart';

class FontSettingsScreen extends ConsumerWidget {
  const FontSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(appSettingsProvider);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    final String currentFontSize = settings.fontSize;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.grey[50],
      appBar: AppBar(
        title: Text(l10n.fontSettingsTitle),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildInfoCard(context, l10n, isDark),
          const SizedBox(height: 24),
          _buildSectionHeader(l10n.fontPreviewTitle.toUpperCase(), theme),
          const SizedBox(height: 12),
          _buildPreviewCard(context, l10n, isDark),
          const SizedBox(height: 32),
          _buildCardWrapper(
            isDark: isDark,
            child: Column(
              children: [
                _buildSizeOption(
                  context: context,
                  ref: ref,
                  title: l10n.fontSmall,
                  value: 'Small',
                  currentValue: currentFontSize,
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildSizeOption(
                  context: context,
                  ref: ref,
                  title: l10n.fontMedium,
                  value: 'Medium',
                  currentValue: currentFontSize,
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildSizeOption(
                  context: context,
                  ref: ref,
                  title: l10n.fontLarge,
                  value: 'Large',
                  currentValue: currentFontSize,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.hintColor,
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCardWrapper({required bool isDark, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: isDark
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.05),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Iconsax.text_italic, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.fontSettingsDesc,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.95),
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withOpacity(0.5)
            : AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.primary.withOpacity(0.2),
          style: BorderStyle.solid,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: const Icon(
                  Icons.medical_services,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Meducyte",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Il y a 2 heures",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.fontPreviewText,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeOption({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String value,
    required String currentValue,
    required bool isDark,
  }) {
    final isSelected =
        value == currentValue ||
        (value == 'Medium' && currentValue == 'Moyen') ||
        (value == 'Small' && currentValue == 'Petit') ||
        (value == 'Large' && currentValue == 'Grand');

    return InkWell(
      onTap: () {
        ref.read(appSettingsProvider.notifier).setFontSize(value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: value == 'Small'
                      ? 14
                      : (value == 'Large' ? 18 : 16),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 24,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
