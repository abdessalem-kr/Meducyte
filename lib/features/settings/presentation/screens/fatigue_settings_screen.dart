import 'package:meducyte_app/export.dart';

class FatigueSettingsScreen extends ConsumerWidget {
  const FatigueSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(appSettingsProvider);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.grey[50],
      appBar: AppBar(
        title: Text(l10n.fatigueSettingsTitle),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildInfoCard(context, l10n),
          const SizedBox(height: 24),

          _buildSectionHeader(l10n.fatigueAnalysis.toUpperCase(), theme),
          const SizedBox(height: 12),
          _buildCardWrapper(
            isDark: isDark,
            child: _buildSettingsToggle(
              icon: Iconsax.flash_1,
              title: l10n.fatigueAnalysis,
              subtitle: l10n.fatigueAnalysisSubtitle,
              value: settings.fatigueAnalysisEnabled,
              onChanged: (v) => ref
                  .read(appSettingsProvider.notifier)
                  .toggleFatigueAnalysis(v),
            ),
          ),

          if (settings.fatigueAnalysisEnabled) ...[
            const SizedBox(height: 32),
            _buildSectionHeader(l10n.fatigueSensitivity.toUpperCase(), theme),
            const SizedBox(height: 12),
            _buildSensitivityOption(
              context: context,
              value: 'Low',
              title: l10n.sensitivityLow,
              desc: l10n.sensitivityLowDesc,
              selected: settings.fatigueSensitivity == 'Low',
              onTap: () => ref
                  .read(appSettingsProvider.notifier)
                  .setFatigueSensitivity('Low'),
              isDark: isDark,
            ),
            _buildSensitivityOption(
              context: context,
              value: 'Medium',
              title: l10n.sensitivityMedium,
              desc: l10n.sensitivityMediumDesc,
              selected: settings.fatigueSensitivity == 'Medium',
              onTap: () => ref
                  .read(appSettingsProvider.notifier)
                  .setFatigueSensitivity('Medium'),
              isDark: isDark,
            ),
            _buildSensitivityOption(
              context: context,
              value: 'High',
              title: l10n.sensitivityHigh,
              desc: l10n.sensitivityHighDesc,
              selected: settings.fatigueSensitivity == 'High',
              onTap: () => ref
                  .read(appSettingsProvider.notifier)
                  .setFatigueSensitivity('High'),
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(l10n.notifications.toUpperCase(), theme),
            const SizedBox(height: 12),
            _buildCardWrapper(
              isDark: isDark,
              child: _buildSettingsToggle(
                icon: Iconsax.notification,
                title: l10n.fatigueAlerts,
                subtitle: l10n.fatigueAlertsDesc,
                value: settings.fatigueNotificationsEnabled,
                onChanged: (v) => ref
                    .read(appSettingsProvider.notifier)
                    .toggleFatigueNotifications(v),
              ),
            ),
          ],
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
        borderRadius: BorderRadius.circular(20),
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

  Widget _buildInfoCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
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
          const Icon(Iconsax.flash_15, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.fatigueAnalysisDesc,
              style: const TextStyle(
                color: Colors.white,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSensitivityOption({
    required BuildContext context,
    required String value,
    required String title,
    required String desc,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.08)
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: selected ? AppColors.primary : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 22,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: Colors.grey.shade400,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
