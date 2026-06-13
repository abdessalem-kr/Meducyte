import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:meducyte_app/core/routes/routes.dart';
import 'package:meducyte_app/features/observation/data/models/specialty_config.dart';
import 'package:meducyte_app/features/observation/data/models/specialty_localization.dart';
import 'package:meducyte_app/features/observation/data/providers/pathology_assistant_provider.dart';
import 'package:meducyte_app/features/observation/data/services/pathology_directory_service.dart';
import 'package:meducyte_app/features/observation/presentation/widgets/pathology_detail_sheet.dart';

class PathologyDirectoryScreen extends ConsumerStatefulWidget {
  const PathologyDirectoryScreen({super.key});

  @override
  ConsumerState<PathologyDirectoryScreen> createState() => _PathologyDirectoryScreenState();
}

class _PathologyDirectoryScreenState extends ConsumerState<PathologyDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  Map<MedicalSpecialty, List<PathologyGuide>> _allPathologies = {};
  Map<MedicalSpecialty, List<PathologyGuide>> _filteredPathologies = {};
  final Set<MedicalSpecialty> _expandedSpecialties = {};

  @override
  void initState() {
    super.initState();
    _loadPathologies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPathologies() async {
    try {
      final data = await PathologyDirectoryService.getAllPathologies();
      setState(() {
        _allPathologies = data;
        _filteredPathologies = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredPathologies = _allPathologies;
        _expandedSpecialties.clear();
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    final Map<MedicalSpecialty, List<PathologyGuide>> temp = {};
    int matchCount = 0;

    for (final entry in _allPathologies.entries) {
      final matches = entry.value.where((p) {
        final nameMatch = p.name.toLowerCase().contains(lowerQuery);
        final descMatch = p.description?.toLowerCase().contains(lowerQuery) ?? false;
        return nameMatch || descMatch;
      }).toList();

      if (matches.isNotEmpty) {
        temp[entry.key] = matches;
        matchCount += matches.length;
      }
    }

    // Dynamic generation if 0 database matches
    if (matchCount == 0 && query.trim().isNotEmpty) {
      final classified = PathologyDirectoryService.classifySpecialty(query);
      final dynamicGuide = PathologyDirectoryService.generateDynamicGuide(query, classified);
      temp[classified] = [dynamicGuide];
      _expandedSpecialties.add(classified);
    } else {
      // Auto-expand specialties with matches during search
      _expandedSpecialties.addAll(temp.keys);
    }

    setState(() {
      _filteredPathologies = temp;
    });
  }

  void _handleStartExam(PathologyGuide pathology, MedicalSpecialty specialty) {
    // 1. Set the active pathology in Riverpod state
    ref.read(selectedPathologyProvider.notifier).state = pathology;

    // 2. Dismiss the sheet
    Navigator.pop(context);

    // 3. Navigate to ObservationReportScreen
    context.push(
      AppRoutes.observationReport.replaceFirst(':specialty', specialty.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Aide au Diagnostic & Pathologies"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.1),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: "Rechercher une pathologie (ex. Asthme, AVC, FA...)",
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor.withOpacity(0.7),
                    ),
                    prefixIcon: Icon(
                      Iconsax.search_normal_1,
                      color: theme.primaryColor,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged("");
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredPathologies.isEmpty
                      ? _buildEmptyState(theme)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredPathologies.length,
                          itemBuilder: (context, index) {
                            final specialty = _filteredPathologies.keys.elementAt(index);
                            final pathologies = _filteredPathologies[specialty]!;
                            final isExpanded = _expandedSpecialties.contains(specialty);

                            return _buildSpecialtySection(
                              context,
                              theme,
                              isLight,
                              specialty,
                              pathologies,
                              isExpanded,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.search_status,
            size: 64,
            color: theme.hintColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "Aucune pathologie trouvée",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Essayez d'écrire un terme clinique ou un symptôme.",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtySection(
    BuildContext context,
    ThemeData theme,
    bool isLight,
    MedicalSpecialty specialty,
    List<PathologyGuide> pathologies,
    bool isExpanded,
  ) {
    // Resolve localized name
    final specConfig = SpecialtyConfigs.all.firstWhere(
      (c) => c.specialty == specialty,
      orElse: () => SpecialtyConfigs.general,
    );
    final specialtyTitle = specialty.localizedName(context);
    final iconColor = isLight ? theme.primaryColor : theme.primaryColorLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          key: PageStorageKey<MedicalSpecialty>(specialty),
          onExpansionChanged: (expanded) {
            setState(() {
              if (expanded) {
                _expandedSpecialties.add(specialty);
              } else {
                _expandedSpecialties.remove(specialty);
              }
            });
          },
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(specConfig.icon, size: 20, color: iconColor),
          ),
          title: Text(
            specialtyTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            "${pathologies.length} pathologie${pathologies.length > 1 ? 's' : ''}",
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.hintColor,
            ),
          ),
          children: pathologies.map((pathology) {
            final isDynamic = pathology.description?.contains("dynamique") ?? false;

            return Column(
              children: [
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          pathology.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isDynamic)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "IA Assist",
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    pathology.description ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  trailing: const Icon(
                    Iconsax.arrow_right_3,
                    size: 16,
                  ),
                  onTap: () {
                    PathologyDetailSheet.show(
                      context,
                      pathology,
                      onStartExam: () => _handleStartExam(pathology, specialty),
                    );
                  },
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
