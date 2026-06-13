import 'package:meducyte_app/export.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.helpCenter),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(context, l10n),
          const SizedBox(height: 32),
          _buildCategory(context, l10n.faqCategoryAccountPremium, [
            _FaqItem(l10n.faqQ1, l10n.faqA1),
            _FaqItem(l10n.faqQ2, l10n.faqA2),
          ]),
          const SizedBox(height: 24),
          _buildCategory(context, l10n.faqCategoryStudyFeatures, [
            _FaqItem(l10n.faqQ3, l10n.faqA3),
            _FaqItem(l10n.faqQ4, l10n.faqA4),
            _FaqItem(l10n.faqQ5, l10n.faqA5),
          ]),
          const SizedBox(height: 24),
          _buildCategory(context, l10n.faqCategoryCommunityGroups, [
            _FaqItem(l10n.faqQ6, l10n.faqA6),
            _FaqItem(l10n.faqQ7, l10n.faqA7),
          ]),
          const SizedBox(height: 48),
          Center(
            child: Text(
              l10n.faqStillHaveQuestions,
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
              },
              child: Text(l10n.faqContactSupport),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
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
        Text(
          l10n.faqHowCanWeHelp,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.faqSearchDesc,
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
