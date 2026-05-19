import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/notifications/application/services/notification_service.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen>
    with WidgetsBindingObserver {
  bool _isSystemPermissionGranted = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    final granted = await ref
        .read(notificationServiceProvider)
        .isPermissionGranted();
    if (mounted) {
      setState(() {
        _isSystemPermissionGranted = granted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(appSettingsProvider);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.grey[50],
      appBar: AppBar(
        title: Text(l10n.notificationSettingsTitle),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          if (!_isSystemPermissionGranted) _buildPermissionWarning(l10n, theme),

          _buildInfoCard(context, l10n, isDark),
          const SizedBox(height: 24),

          _buildSectionHeader(l10n.core.toUpperCase(), theme),
          const SizedBox(height: 12),
          _buildCardWrapper(
            isDark: isDark,
            child: SettingsTile(
              id: 'global_notify',
              icon: Iconsax.notification,
              title: l10n.globalNotifications,
              isSwitch: true,
              switchValue: settings.notificationsEnabled,
              onSwitchChanged: (v) =>
                  ref.read(appSettingsProvider.notifier).toggleNotifications(v),
            ),
          ),

          const SizedBox(height: 32),
          _buildSectionHeader(l10n.productiveBayRemindersTitle, theme),
          const SizedBox(height: 12),
          _buildCardWrapper(
            isDark: isDark,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: settings.notificationsEnabled ? 1.0 : 0.5,
              child: AbsorbPointer(
                absorbing: !settings.notificationsEnabled,
                child: Column(
                  children: [
                    _buildSettingsItem(
                      icon: Iconsax.calendar,
                      title: l10n.examReminders,
                      subtitle: l10n.examRemindersDesc,
                      value: settings.examNotificationsEnabled,
                      onChanged: (v) => ref
                          .read(appSettingsProvider.notifier)
                          .toggleExamNotifications(v),
                    ),
                    _buildDivider(isDark),
                    _buildSettingsItem(
                      icon: Iconsax.task,
                      title: l10n.taskReminders,
                      subtitle: l10n.taskRemindersDesc,
                      value: settings.taskNotificationsEnabled,
                      onChanged: (v) => ref
                          .read(appSettingsProvider.notifier)
                          .toggleTaskNotifications(v),
                    ),
                    _buildDivider(isDark),
                    _buildSettingsItem(
                      icon: Iconsax.timer_1,
                      title: l10n.studyReminders,
                      subtitle: l10n.studyRemindersDesc,
                      value: settings.studyNotificationsEnabled,
                      onChanged: (v) => ref
                          .read(appSettingsProvider.notifier)
                          .toggleStudyNotifications(v),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
          _buildSectionHeader(l10n.communityNotifications.toUpperCase(), theme),
          const SizedBox(height: 12),
          _buildCardWrapper(
            isDark: isDark,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: settings.notificationsEnabled ? 1.0 : 0.5,
              child: AbsorbPointer(
                absorbing: !settings.notificationsEnabled,
                child: _buildSettingsItem(
                  icon: Iconsax.messages_1,
                  title: l10n.interactionSpace,
                  subtitle: l10n.communityNotificationsDesc,
                  value: settings.communityNotificationsEnabled,
                  onChanged: (v) => ref
                      .read(appSettingsProvider.notifier)
                      .toggleCommunityNotifications(v),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),

          //Test button for"production readiness"
          Center(
            child: TextButton.icon(
              onPressed: () =>
                  ref.read(notificationServiceProvider).simulateNotification(),
              icon: const Icon(Iconsax.flash_1, size: 18),
              label: const Text("Envoyer une notification de test"),
              style: TextButton.styleFrom(
                foregroundColor: theme.hintColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPermissionWarning(AppLocalizations l10n, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.errorLight.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.warning_2, color: AppColors.errorLight, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.systemSettingsPrompt,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.errorLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () =>
                ref.read(notificationServiceProvider).openSettings(),
            child: Text(
              l10n.openSettings,
              style: const TextStyle(
                color: AppColors.errorLight,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
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
      indent: 56,
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
          const Icon(Iconsax.info_circle, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.notificationSettingsInfo,
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

  Widget _buildSettingsItem({
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
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    height: 1.2,
                  ),
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
}
