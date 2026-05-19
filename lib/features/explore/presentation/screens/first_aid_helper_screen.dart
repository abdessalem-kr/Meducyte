import 'package:meducyte_app/export.dart';
import '../../domain/models/first_aid_mapping.dart';

class FirstAidHelperScreen extends StatefulWidget {
  const FirstAidHelperScreen({super.key});

  @override
  State<FirstAidHelperScreen> createState() => _FirstAidHelperScreenState();
}

class _FirstAidHelperScreenState extends State<FirstAidHelperScreen> {
  String _searchQuery = "";
  FirstAidCategory? _selectedCategory;

  List<FirstAidTopic> get _filteredTopics {
    return FirstAidMapping.topics.where((topic) {
      final matchesSearch =
          topic.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          topic.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == null || topic.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(isDark, primaryColor, l10n),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(isDark, l10n),
                  const SizedBox(height: 24),
                  _buildCategoryFilter(isDark, primaryColor, l10n),
                  const SizedBox(height: 24),
                  _buildDisclaimerCard(isDark, primaryColor, l10n),
                ],
              ),
            ),
          ),
          if (_filteredTopics.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Text(
                    l10n.noResultsFound(_searchQuery),
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildTopicCard(
                    _filteredTopics[index],
                    isDark,
                    primaryColor,
                    l10n,
                  ),
                  childCount: _filteredTopics.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark, Color primaryColor, AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      stretch: true,
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
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.firstAid,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              "GUIDE D'URGENCES",
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 10,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        background: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                Iconsax.hospital,
                size: 160,
                color: primaryColor.withOpacity(0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          icon: const Icon(Iconsax.search_normal_1, size: 20),
          hintText: "Rechercher un geste...",
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: Theme.of(context).hintColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _filterChip(null, "Tous", isDark, primaryColor),
          const SizedBox(width: 8),
          _filterChip(
            FirstAidCategory.lifeSaving,
            "Vital",
            isDark,
            primaryColor,
          ),
          const SizedBox(width: 8),
          _filterChip(FirstAidCategory.traumas, "Trauma", isDark, primaryColor),
          const SizedBox(width: 8),
          _filterChip(
            FirstAidCategory.medical,
            "Médical",
            isDark,
            primaryColor,
          ),
          const SizedBox(width: 8),
          _filterChip(
            FirstAidCategory.environment,
            "Extérieur",
            isDark,
            primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    FirstAidCategory? category,
    String label,
    bool isDark,
    Color primaryColor,
  ) {
    final isSelected = _selectedCategory == category;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) =>
          setState(() => _selectedCategory = selected ? category : null),
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      selectedColor: primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected
            ? primaryColor
            : (isDark ? Colors.white70 : Colors.black54),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? primaryColor
              : (isDark ? Colors.white12 : Colors.black12),
        ),
      ),
    );
  }

  Widget _buildDisclaimerCard(
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.errorLight.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Iconsax.info_circle,
            color: AppColors.errorLight,
            size: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AVERTISSEMENT",
                  style: TextStyle(
                    color: AppColors.errorLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "En cas d'urgence,contactez immédiatement les secours(15,18,112).Ces fiches sont des rappels et ne remplacent pas une formation certifiée.",
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: AppColors.errorLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(
    FirstAidTopic topic,
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTopicDetail(topic, isDark, primaryColor, l10n),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(topic.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getCategoryIcon(topic.category),
                    color: _getCategoryColor(topic.category),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        topic.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Iconsax.arrow_right_3,
                  color: Theme.of(context).hintColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(FirstAidCategory category) {
    switch (category) {
      case FirstAidCategory.lifeSaving:
        return AppColors.errorLight;
      case FirstAidCategory.traumas:
        return const Color(0xFFF57C00);
      case FirstAidCategory.medical:
        return AppColors.secondaryLight;
      case FirstAidCategory.environment:
        return const Color(0xFF43A047);
    }
  }

  IconData _getCategoryIcon(FirstAidCategory category) {
    switch (category) {
      case FirstAidCategory.lifeSaving:
        return Iconsax.activity;
      case FirstAidCategory.traumas:
        return Iconsax.warning_2;
      case FirstAidCategory.medical:
        return Iconsax.hospital;
      case FirstAidCategory.environment:
        return Iconsax.info_circle;
    }
  }

  void _showTopicDetail(
    FirstAidTopic topic,
    bool isDark,
    Color primaryColor,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FirstAidDetailSheet(topic: topic),
    );
  }
}

class _FirstAidDetailSheet extends StatelessWidget {
  final FirstAidTopic topic;
  const _FirstAidDetailSheet({required this.topic});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: CustomScrollView(
          controller: controller,
          slivers: [
            _buildHandle(isDark),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, isDark, primaryColor),
                    const SizedBox(height: 24),
                    if (topic.imageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          topic.imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              color: primaryColor.withOpacity(0.05),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 100,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Iconsax.image, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text(
                                      "L'image n'a pas puêtre chargée",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (topic.warnings.isNotEmpty) _buildWarningsBox(isDark),
                    const SizedBox(height: 24),
                    if (topic.clinicalPearls.isNotEmpty)
                      _buildClinicalPearls(isDark, primaryColor),
                    const SizedBox(height: 32),
                    _buildSectionTitle("LESÉTAPES DU SECOURS"),
                    const SizedBox(height: 16),
                    ...topic.steps.map(
                      (step) => _buildStepCard(step, isDark, primaryColor),
                    ),
                    const SizedBox(height: 32),
                    if (topic.callForHelp.isNotEmpty)
                      _buildCallAction(context, primaryColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(bool isDark) {
    return SliverToBoxAdapter(
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: isDark ? Colors.white12 : Colors.black12,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getCategoryLabel(topic.category),
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          topic.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        const SizedBox(height: 8),
        Text(
          topic.description,
          style: const TextStyle(color: Colors.grey, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildWarningsBox(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warningLight.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Iconsax.warning_2, color: AppColors.warningLight, size: 20),
              SizedBox(width: 8),
              Text(
                "ATTENTION/DANGER",
                style: TextStyle(
                  color: AppColors.warningLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...topic.warnings.map(
            (w) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "• ",
                    style: TextStyle(color: AppColors.warningLight),
                  ),
                  Expanded(
                    child: Text(
                      w,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.warningLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalPearls(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.lamp_on, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                "PERLES CLINIQUES",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...topic.clinicalPearls.map(
            (pearl) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "• ",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      pearl,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(FirstAidStep step, bool isDark, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.03),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              "${step.number}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  step.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (step.icon != null) ...[
            const SizedBox(width: 8),
            Icon(step.icon, color: primaryColor.withOpacity(0.3), size: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildCallAction(BuildContext context, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            "ALERTE SECOURS",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            topic.callForHelp.first,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Iconsax.call),
            label: const Text("APPELER LE 15"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.errorLight,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: Colors.grey,
      ),
    );
  }

  String _getCategoryLabel(FirstAidCategory category) {
    switch (category) {
      case FirstAidCategory.lifeSaving:
        return "URGENCE VITALE";
      case FirstAidCategory.traumas:
        return "TRAUMATOLOGIE";
      case FirstAidCategory.medical:
        return "URGENCE MÉDICALE";
      case FirstAidCategory.environment:
        return "RISQUES ENVIR.";
    }
  }
}
