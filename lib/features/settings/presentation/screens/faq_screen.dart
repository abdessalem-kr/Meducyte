import 'package:meducyte_app/export.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Help Center'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(context),
          const SizedBox(height: 32),
          _buildCategory(context, 'Account&Premium', [
            _FaqItem(
              'How do I upgrade to Premium?',
              'You can upgrade by clicking on the Profile tab or selecting any premium feature(like unlimited AI Chat).We support various payment methods including Chargily for Algerian Dinars.',
            ),
            _FaqItem(
              'Can I use Meducyte on multiple devices?',
              'Yes!Your data is synced to your account.Simply log in on your new device to continue your study journey.',
            ),
          ]),
          const SizedBox(height: 24),
          _buildCategory(context, 'Study Features', [
            _FaqItem(
              'How does Spaced Repetition work?',
              'Meducyte uses advanced algorithms to track your performance.We show you difficult questions more often and easy ones less frequently to optimize your memory retention.',
            ),
            _FaqItem(
              'What is the AI Medical Tutor?',
              'Medu-AI is our custom chatbot trained on medical literature.It can explain complex concepts,help you interpret labs,or guide you through clinical cases.',
            ),
            _FaqItem(
              'Does Meducyte follow the Algerian curriculum?',
              'Yes,our question bank and course structure are specifically designed to align with the curriculum modules of Algerian medical faculties.',
            ),
          ]),
          const SizedBox(height: 24),
          _buildCategory(context, 'Community&Groups', [
            _FaqItem(
              'How to start a Group Study?',
              "Head to the'Productive Bay'and select'Study Groups'.You can create a private group and invite your comrades via a unique code or link.",
            ),
            _FaqItem(
              'Is there a Meducyte community?',
              'Yes!Join our official Telegram channel to stay updated and discuss with thousands of medical students across Algeria.',
            ),
          ]),
          const SizedBox(height: 48),
          Center(
            child: Text(
              "Still have questions?",
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {
                //Navigate back and open support sheet logic would go here
                //For now,just a placeholder
              },
              child: const Text('CONTACT HUMAN SUPPORT'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Iconsax.info_circle, color: primaryColor, size: 48),
        ),
        const SizedBox(height: 20),
        const Text(
          "How can we help you?",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "Search our frequently asked questions",
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildCategory(
    BuildContext context,
    String title,
    List<_FaqItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.05),
            ),
          ),
          child: Column(
            children: items.map((item) => _FaqTile(item: item)).toList(),
          ),
        ),
      ],
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  _FaqItem(this.question, this.answer);
}

class _FaqTile extends StatelessWidget {
  final _FaqItem item;

  const _FaqTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        item.question,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedAlignment: Alignment.topLeft,
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      shape: const RoundedRectangleBorder(side: BorderSide.none),
      collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
      children: [
        Text(
          item.answer,
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: Theme.of(context).hintColor,
          ),
        ),
      ],
    );
  }
}
