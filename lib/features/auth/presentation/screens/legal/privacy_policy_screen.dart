import 'package:meducyte_app/export.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.authPrivacyPolicyTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              context.l10n.authPrivacySection1Title,
              context.l10n.authPrivacySection1Content,
            ),
            _buildSection(
              context,
              context.l10n.authPrivacySection2Title,
              context.l10n.authPrivacySection2Content,
            ),
            _buildSection(
              context,
              context.l10n.authPrivacySection3Title,
              context.l10n.authPrivacySection3Content,
            ),
            _buildSection(
              context,
              context.l10n.authPrivacySection4Title,
              context.l10n.authPrivacySection4Content,
            ),
            _buildSection(
              context,
              context.l10n.authPrivacySection5Title,
              context.l10n.authPrivacySection5Content,
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                context.l10n.authPrivacyLastUpdated,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
