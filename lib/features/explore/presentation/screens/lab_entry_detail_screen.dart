import 'package:meducyte_app/export.dart';
import '../../domain/models/lab_encyclopedia_models.dart';

class LabEntryDetailScreen extends StatelessWidget {
  final LabEntry entry;

  const LabEntryDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(isDark, primaryColor, context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDark, primaryColor),
                  const SizedBox(height: 32),
                  if (entry.introduction.isNotEmpty)
                    _buildSection(
                      "Introduction",
                      entry.introduction,
                      Icons.science_outlined,
                      primaryColor,
                      isDark,
                    ),
                  if (entry.collectionPrecautions.isNotEmpty)
                    _buildSection(
                      "Précautions de prélèvement",
                      entry.collectionPrecautions,
                      Icons.biotech_outlined,
                      primaryColor,
                      isDark,
                    ),
                  if (entry.normalValues.isNotEmpty)
                    _buildNormalValues(isDark, primaryColor),
                  if (entry.clinique.isNotEmpty)
                    _buildClinique(
                      context,
                      entry.clinique,
                      primaryColor,
                      isDark,
                    ),
                  if (entry.remarks != null && entry.remarks!.isNotEmpty)
                    _buildSection(
                      "Remarques",
                      entry.remarks!.join("\n\n"),
                      Icons.info_outline,
                      primaryColor,
                      isDark,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark, Color primaryColor, BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: isDark ? Colors.white : Colors.black,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.share_outlined,
            color: isDark ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            entry.category.toUpperCase(),
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          entry.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        if (entry.abbreviation != null) ...[
          const SizedBox(height: 4),
          Text(
            entry.abbreviation!,
            style: TextStyle(
              color: primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSection(
    String title,
    String content,
    IconData icon,
    Color primaryColor,
    bool isDark, {
    bool isList = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isList ? "• $content" : content,
            style: const TextStyle(fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalValues(bool isDark, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                "Valeurs usuelles",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withOpacity(0.2)),
            ),
            child: Column(
              children: entry.normalValues
                  .map(
                    (v) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (v.population != null)
                            Expanded(
                              flex: 2,
                              child: Text(
                                v.population!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          Flexible(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  v.traditionalValue,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (v.siValue != null)
                                  Text(
                                    v.siValue!,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinique(
    BuildContext context,
    String clinique,
    Color primaryColor,
    bool isDark,
  ) {
    if (!clinique.contains("## ")) {
      return _buildSection(
        "Clinique",
        clinique,
        Icons.medical_services_outlined,
        primaryColor,
        isDark,
      );
    }

    List<Widget> children = [
      Row(
        children: [
          Icon(Icons.medical_services_outlined, color: primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(
            "Clinique",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: primaryColor,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
    ];

    List<String> parts = clinique.split("## ");
    if (parts.isNotEmpty && parts[0].trim().isNotEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            parts[0].trim(),
            style: const TextStyle(fontSize: 14, height: 1.6),
          ),
        ),
      );
    }

    for (int i = 1; i < parts.length; i++) {
      String part = parts[i];
      int firstNewline = part.indexOf('\n');
      String title = part;
      String content = "";
      if (firstNewline != -1) {
        title = part.substring(0, firstNewline).trim();
        content = part.substring(firstNewline + 1).trim();
      } else {
        title = title.trim();
      }

      if (title.isNotEmpty) {
        children.add(
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor.withOpacity(0.1)),
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: primaryColor,
                collapsedIconColor: primaryColor,
                title: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: primaryColor,
                  ),
                ),
                children: [
                  if (content.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          content,
                          style: const TextStyle(fontSize: 14, height: 1.6),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
