import 'package:meducyte_app/export.dart';

class SrsSettingsScreen extends ConsumerWidget {
  const SrsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(appSettingsProvider);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.grey[50],
      appBar: AppBar(
        title: Text(l10n.srsSettingsTitle),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildInfoCard(context, l10n),
          const SizedBox(height: 24),

          _buildSectionHeader(l10n.studyPlan.toUpperCase(), theme),
          const SizedBox(height: 12),
          _buildCardWrapper(
            isDark: isDark,
            child: Column(
              children: [
                _buildSliderItem(
                  context: context,
                  icon: Iconsax.add_circle,
                  title: l10n.srsNewCardsTitle,
                  subtitle: l10n.srsNewCardsDesc,
                  value: settings.srsNewCardsPerDay.toDouble(),
                  min: 5,
                  max: 100,
                  divisions: 19,
                  label: '${settings.srsNewCardsPerDay}',
                  onChanged: (v) => ref
                      .read(appSettingsProvider.notifier)
                      .setSrsNewCardsPerDay(v.toInt()),
                ),
                _buildDivider(isDark),
                _buildSliderItem(
                  context: context,
                  icon: Iconsax.refresh_circle,
                  title: l10n.srsReviewLimitTitle,
                  subtitle: l10n.srsReviewLimitDesc,
                  value: settings.srsReviewLimit.toDouble(),
                  min: 20,
                  max: 500,
                  divisions: 24,
                  label: '${settings.srsReviewLimit}',
                  onChanged: (v) => ref
                      .read(appSettingsProvider.notifier)
                      .setSrsReviewLimit(v.toInt()),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          _buildSectionHeader(l10n.notifications.toUpperCase(), theme),
          const SizedBox(height: 12),
          _buildCardWrapper(
            isDark: isDark,
            child: Column(
              children: [
                _buildSettingsToggle(
                  icon: Iconsax.notification,
                  title: l10n.srsNotificationTitle,
                  subtitle: l10n.srsNotificationDesc,
                  value: settings.srsNotifyEnabled,
                  onChanged: (v) =>
                      ref.read(appSettingsProvider.notifier).toggleSrsNotify(v),
                ),
                if (settings.srsNotifyEnabled) ...[
                  _buildDivider(isDark),
                  _buildTimePickerItem(
                    context: context,
                    ref: ref,
                    title: l10n.srsNotificationTimeTitle,
                    currentTime: settings.srsNotifyTime,
                    isDark: isDark,
                  ),
                ],
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

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 56,
      endIndent: 16,
      color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
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
              l10n.srsSettingsInfo,
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

  Widget _buildSliderItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider.adaptive(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppColors.primary,
            onChanged: onChanged,
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

  Widget _buildTimePickerItem({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String currentTime,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () async {
        final timeParts = currentTime.split(':');
        final currentTod = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );

        final picked = await showTimePicker(
          context: context,
          initialTime: currentTod,
        );

        if (picked != null) {
          final formatted =
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          ref.read(appSettingsProvider.notifier).setSrsNotifyTime(formatted);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            const SizedBox(width: 48), //Align with icons above
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                currentTime,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
