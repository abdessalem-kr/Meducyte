import 'package:meducyte_app/export.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = ref.watch(appSettingsProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.textTheme.titleLarge?.color,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ------------------PROFILE BANNER------------------
            const ProfilBanner(),
            const SizedBox(height: 24),

            // ------------------CORE------------------
            SectionHeader(title: l10n.core),
            SectionContainer(
              children: [
                SettingsTile(
                  id: '01',
                  isDropdown: true,
                  dropdownButton: DropdownButton<ThemeMode>(
                    icon: const Icon(Icons.arrow_drop_down_rounded, size: 32),
                    underline: const SizedBox.shrink(),
                    borderRadius: BorderRadius.circular(12),
                    value: ref.watch(themeModeProvider),
                    items: ThemeMode.values.map((mode) {
                      return DropdownMenuItem(
                        value: mode,
                        child: Text(
                          mode.name.toUpperCase(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(themeModeProvider.notifier)
                            .setThemeMode(value);
                      }
                    },
                  ),
                  icon: Iconsax.lamp_on,
                  title: l10n.themeMode,
                ),
                SettingsTile(
                  id: '02',
                  icon: Iconsax.global,
                  title: l10n.language,
                  value: locale.languageCode == 'en' ? "English" : "Français",
                  onTap: () => _showLanguageDialog(context, ref),
                ),
                SettingsTile(
                  id: '03',
                  icon: Iconsax.text_italic,
                  title: l10n.fontSize,
                  value: settings.fontSize,
                  onTap: () => context.push(AppRoutes.fontSettings),
                ),
                SettingsTile(
                  id: '04',
                  icon: Iconsax.eye,
                  title: l10n.highContrast,
                  isSwitch: true,
                  switchValue: settings.highContrastEnabled,
                  onSwitchChanged: (v) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .toggleHighContrast(v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ------------------USER PREFERENCES------------------
            SectionHeader(title: l10n.userPreferences),
            SectionContainer(
              children: [
                SettingsTile(
                  id: '05',
                  icon: Iconsax.notification,
                  title: l10n.notifications,
                  onTap: () => context.push(AppRoutes.notificationSettings),
                ),
                SettingsTile(
                  id: '06',
                  icon: Iconsax.cloud_change,
                  title: l10n.syncSettings,
                  isSwitch: true,
                  switchValue: settings.syncSettingsEnabled,
                  onSwitchChanged: (v) {
                    ref.read(appSettingsProvider.notifier).toggleSync(v);
                  },
                ),
                SettingsTile(
                  id: '07',
                  icon: Iconsax.repeat,
                  title: l10n.spacedRepetition,
                  onTap: () => context.push(AppRoutes.srsSettings),
                ),
                SettingsTile(
                  id: '07_fatigue',
                  icon: Iconsax.flash_1,
                  title: l10n.fatigueSettingsTitle,
                  onTap: () => context.push(AppRoutes.fatigueSettings),
                ),
                SettingsTile(
                  id: '08',
                  icon: Iconsax.calendar,
                  title: l10n.studyPlan,
                  onTap: () => context.push(AppRoutes.studyPlanSettings),
                ),
                SettingsTile(
                  id: '09',
                  icon: Iconsax.receive_square_2,
                  title: l10n.downloadMode,
                  value: settings.downloadMode,
                  onTap: () => _showDownloadModeDialog(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ------------------ADVANCED/ABOUT------------------
            SectionHeader(title: l10n.advancedAbout),
            SectionContainer(
              children: [
                SettingsTile(
                  id: '10',
                  icon: Iconsax.info_circle,
                  title: l10n.version,
                  value: "v1.0.0",
                ),
                SettingsTile(
                  id: '11',
                  icon: Iconsax.document_text,
                  title: l10n.authPrivacyPolicy,
                  onTap: () => context.push(AppRoutes.privacyPolicy),
                ),
                SettingsTile(
                  id: '11-terms',
                  icon: Iconsax.document_code,
                  title: l10n.authTermsOfUse,
                  onTap: () => context.push(AppRoutes.termsOfUse),
                ),
                SettingsTile(
                  id: '12',
                  icon: Iconsax.user_tag,
                  title: l10n.support,
                  onTap: () => _showSupportOptions(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ------------------SECURITY&PRIVACY------------------
            SectionHeader(title: l10n.securityPrivacy),
            SectionContainer(
              children: [
                SettingsTile(
                  id: '13-reset',
                  icon: Iconsax.refresh,
                  title: l10n.resetData,
                  subtitle: l10n.resetDataSubtitle,
                  onTap: () => _showResetDataConfirmation(context, ref),
                ),
                SettingsTile(
                  id: '14-delete',
                  icon: Iconsax.user_remove,
                  title: l10n.deleteAccountTitle,
                  subtitle: l10n.deleteAccountSubtitle,
                  onTap: () => _showDeleteAccountConfirmation(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ------------------OTHER------------------
            SectionHeader(title: l10n.advancedAbout),
            SectionContainer(
              children: [
                SettingsTile(
                  id: '15-rate',
                  icon: Iconsax.star,
                  title: l10n.rateUs,
                  onTap: () => _showRateUsSheet(context),
                ),
                SettingsTile(
                  id: '16-sub',
                  icon: Iconsax.crown,
                  title: l10n.subscription,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SubscriptionScreen(),
                      ),
                    );
                  },
                ),
                SettingsTile(
                  id: 'logout',
                  icon: Iconsax.logout,
                  title: l10n.logout,
                  onTap: () {
                    ref.read(authControllerProvider.notifier).logout();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                ref.read(localeProvider.notifier).setLocale('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Français'),
              onTap: () {
                ref.read(localeProvider.notifier).setLocale('fr');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDownloadModeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Wi-Fi only', 'Wi-Fi&Cellular'].map((mode) {
            return ListTile(
              title: Text(mode),
              onTap: () {
                ref.read(appSettingsProvider.notifier).setDownloadMode(mode);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSupportOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Support Hub',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'How can we assist your medical journey today?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            //Option 1:FAQ/Help Center
            _buildSupportTile(
              context,
              icon: Iconsax.info_circle,
              title: "Help Center(FAQ)",
              subtitle: "Browse through common questions&guides",
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.faq);
              },
            ),
            const SizedBox(height: 12),

            //Option 2:Email Support
            _buildSupportTile(
              context,
              icon: Iconsax.message_text_1,
              title: "Email Support",
              subtitle: "Talk to a human for account or payment issues",
              onTap: () async {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'contact@meducyte.com',
                  query: encodeQueryParameters({
                    'subject': 'Meducyte Support Request',
                    'body': '\n\n---\nApp Version:v1.0.0\nDevice:Mobile',
                  }),
                );
                if (await canLaunchUrl(emailLaunchUri)) {
                  await launchUrl(emailLaunchUri);
                }
                if (context.mounted) Navigator.pop(context);
              },
              isPrimary: true,
            ),

            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CLOSE',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPrimary
              ? primaryColor.withOpacity(0.05)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPrimary
                ? primaryColor.withOpacity(0.2)
                : Theme.of(context).dividerColor.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPrimary
                    ? primaryColor
                    : (isDark ? Colors.white12 : Colors.white),
                shape: BoxShape.circle,
                boxShadow: isPrimary
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Icon(
                icon,
                color: isPrimary ? Colors.white : primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  void _showResetDataConfirmation(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const warningColor = Colors.orange;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: warningColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.refresh, color: warningColor, size: 32),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.resetData,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.resetDataWarning,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref.read(appSettingsProvider.notifier).resetAllData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.dataResetSuccess),
                      backgroundColor: warningColor,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: warningColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.reset.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 40,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.trash, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.deleteAccountTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.deleteAccountWarning,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.deleteConfirmationInstruction,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                onChanged: (val) => setState(() {}),
                decoration: InputDecoration(
                  hintText: l10n.deleteConfirmationHint,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.white10 : Colors.grey[50],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed:
                    textController.text.trim().toUpperCase() == 'DELETE' ||
                        textController.text.trim().toUpperCase() == 'SUPPRIMER'
                    ? () async {
                        Navigator.pop(context);
                        try {
                          await ref
                              .read(authControllerProvider.notifier)
                              .deleteAccount();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.accountDeletedSuccess),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: Colors.red.withOpacity(0.1),
                  disabledForegroundColor: Colors.red.withOpacity(0.3),
                ),
                child: Text(
                  l10n.deleteLabel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.cancel.toUpperCase(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRateUsSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    int selectedRating = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.rateUsTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.rateUsSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  final isSelected = starIndex <= selectedRating;
                  return IconButton(
                    onPressed: () => setState(() => selectedRating = starIndex),
                    icon: Icon(
                      isSelected
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: isSelected ? Colors.amber : Colors.grey[300],
                      size: 40,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: selectedRating == 0
                    ? null
                    : () async {
                        Navigator.pop(context);
                        if (selectedRating >= 4) {
                          _redirectToStore();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Thank you for your valuable feedback!',
                              ),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  selectedRating >= 4
                      ? l10n.rateOnStore.toUpperCase()
                      : l10n.rateFeedback.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.cancel.toUpperCase(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _redirectToStore() async {
    const String iosUrl = 'https://apps.apple.com/app/id-meducyte-app';
    const String androidUrl =
        'https://play.google.com/store/apps/details?id=com.meducyte.app';

    final Uri url = Uri.parse(Platform.isIOS ? iosUrl : androidUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
