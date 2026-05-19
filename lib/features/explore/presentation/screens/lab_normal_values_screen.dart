import 'package:meducyte_app/export.dart';
import '../../domain/models/lab_normal_values_data.dart';

class LabNormalValuesScreen extends StatefulWidget {
  const LabNormalValuesScreen({super.key});

  @override
  State<LabNormalValuesScreen> createState() => _LabNormalValuesScreenState();
}

class _LabNormalValuesScreenState extends State<LabNormalValuesScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  bool _useSI = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final l10n = AppLocalizations.of(context)!;

    final categories = LabNormalValuesData.entries
        .map((e) => e.category)
        .toSet()
        .toList();
    categories.sort();

    final filteredEntries = LabNormalValuesData.entries.where((e) {
      final matchesSearch = e.parameter.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesCategory =
          _selectedCategory == null || e.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(isDark, primaryColor, l10n),
          SliverToBoxAdapter(
            child: _buildFilters(isDark, primaryColor, categories),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final entry = filteredEntries[index];
                //Show category header if it's the first entry of that category
                bool showHeader =
                    index == 0 ||
                    filteredEntries[index - 1].category != entry.category;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showHeader)
                      _buildCategoryHeader(entry.category, primaryColor),
                    _buildEntryCard(entry, isDark, primaryColor),
                  ],
                );
              }, childCount: filteredEntries.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark, Color primaryColor, AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      stretch: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.blurBackground,
          StretchMode.zoomBackground,
        ],
        background: Padding(
          padding: const EdgeInsets.fromLTRB(24, 80, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.labNormalValues,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildSearchBar(isDark, l10n),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            children: [
              Text(
                _useSI ? l10n.unitSI : l10n.unitTrad,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Switch(
                value: _useSI,
                activeColor: primaryColor,
                onChanged: (val) => setState(() => _useSI = val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark, AppLocalizations l10n) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: l10n.searchParameter,
          hintStyle: TextStyle(
            color: isDark
                ? Colors.white.withOpacity(0.3)
                : Colors.black.withOpacity(0.3),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark
                ? Colors.white.withOpacity(0.3)
                : Colors.black.withOpacity(0.3),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilters(
    bool isDark,
    Color primaryColor,
    List<String> categories,
  ) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final category = isAll ? null : categories[index - 1];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(isAll ? 'Tout' : category!),
              selected: isSelected,
              onSelected: (val) =>
                  setState(() => _selectedCategory = val ? category : null),
              backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
              selectedColor: primaryColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected
                    ? primaryColor
                    : (isDark ? Colors.white70 : Colors.black54),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? primaryColor : Colors.transparent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryHeader(String category, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            category.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(
    LabNormalValueEntry entry,
    bool isDark,
    Color primaryColor,
  ) {
    final value = _useSI
        ? (entry.siValue.isEmpty ? entry.tradValue : entry.siValue)
        : entry.tradValue;

    //Special grid for Hematology
    if (entry.category == 'Hématologie(Grille)') {
      return _buildHematologyGrid(entry, isDark, primaryColor);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.parameter,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (entry.siValue.isNotEmpty &&
                    entry.siValue != entry.tradValue)
                  Text(
                    _useSI ? entry.tradValue : entry.siValue,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? Colors.white.withOpacity(0.3)
                          : Colors.black.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHematologyGrid(
    LabNormalValueEntry entry,
    bool isDark,
    Color primaryColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.parameter,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 16),
          _buildPopulationRow('Homme', entry.men ?? '-', primaryColor, isDark),
          _buildPopulationRow(
            'Femme',
            entry.women ?? '-',
            primaryColor,
            isDark,
          ),
          _buildPopulationRow(
            'Enfant',
            entry.children ?? '-',
            primaryColor,
            isDark,
          ),
          _buildPopulationRow(
            'N-Né',
            entry.neonates ?? '-',
            primaryColor,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPopulationRow(
    String label,
    String value,
    Color primaryColor,
    bool isDark,
  ) {
    if (value == '-' || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
