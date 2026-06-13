import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/features/observation/data/models/specialty_config.dart';
import 'package:meducyte_app/features/observation/data/models/specialty_localization.dart';
import 'package:meducyte_app/l10n/arb/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:meducyte_app/core/routes/routes.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meducyte_app/features/observation/data/services/pathology_directory_service.dart';

enum SpecialtyCategory {
  all,
  general,
  medical,
  surgical,
  motherChildPsy,
  sensory,
  preventiveOther,
}

extension SpecialtyCategoryExtension on SpecialtyCategory {
  String get displayName {
    switch (this) {
      case SpecialtyCategory.all:
        return "Tous";
      case SpecialtyCategory.general:
        return "Urgences & Général";
      case SpecialtyCategory.medical:
        return "Spé. Médicales";
      case SpecialtyCategory.surgical:
        return "Spé. Chirurgicales";
      case SpecialtyCategory.motherChildPsy:
        return "Pédiatrie & Psy";
      case SpecialtyCategory.sensory:
        return "Tête & Cou";
      case SpecialtyCategory.preventiveOther:
        return "Prévention & Autres";
    }
  }

  IconData get icon {
    switch (this) {
      case SpecialtyCategory.all:
        return Iconsax.category;
      case SpecialtyCategory.general:
        return Iconsax.flash;
      case SpecialtyCategory.medical:
        return Iconsax.health;
      case SpecialtyCategory.surgical:
        return Iconsax.scissor;
      case SpecialtyCategory.motherChildPsy:
        return Iconsax.people;
      case SpecialtyCategory.sensory:
        return Iconsax.eye;
      case SpecialtyCategory.preventiveOther:
        return Iconsax.activity;
    }
  }
}

class SpecialtySelectionScreen extends ConsumerStatefulWidget {
  const SpecialtySelectionScreen({super.key});

  @override
  ConsumerState<SpecialtySelectionScreen> createState() => _SpecialtySelectionScreenState();
}

class _SpecialtySelectionScreenState extends ConsumerState<SpecialtySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  SpecialtyCategory _selectedCategory = SpecialtyCategory.all;
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  SpecialtyCategory _getSpecialtyCategory(MedicalSpecialty specialty) {
    switch (specialty) {
      case MedicalSpecialty.general:
      case MedicalSpecialty.anesthesiereanimation:
      case MedicalSpecialty.reanimationmedicale:
        return SpecialtyCategory.general;

      case MedicalSpecialty.cardiology:
      case MedicalSpecialty.neurology:
      case MedicalSpecialty.diabetologieendocrinologieetmaladiesmetaboliques:
      case MedicalSpecialty.hepatogastroenterologie:
      case MedicalSpecialty.nephrologie:
      case MedicalSpecialty.pneumophtisiologie:
      case MedicalSpecialty.rhumatologie:
      case MedicalSpecialty.dermatologieetvenereologie:
      case MedicalSpecialty.hematologie:
      case MedicalSpecialty.infectiologie:
      case MedicalSpecialty.medecineinterne:
      case MedicalSpecialty.oncologiemedicale:
        return SpecialtyCategory.medical;

      case MedicalSpecialty.chirurgiegenerale:
      case MedicalSpecialty.chirurgiecardiaque:
      case MedicalSpecialty.chirurgiemaxillofaciale:
      case MedicalSpecialty.chirurgieneurologique:
      case MedicalSpecialty.chirurgieorthopediqueettraumatologie:
      case MedicalSpecialty.chirurgiethoracique:
      case MedicalSpecialty.chirurgieurologique:
      case MedicalSpecialty.chirurgievasculaire:
      case MedicalSpecialty.chirurgieplastiquereconstructriceesthetiqueetdebrulologie:
        return SpecialtyCategory.surgical;

      case MedicalSpecialty.pediatrie:
      case MedicalSpecialty.anesthesiereanimationpediatrique:
      case MedicalSpecialty.chirurgiepediatrique:
      case MedicalSpecialty.gynecologieobstetrique:
      case MedicalSpecialty.psychiatrie:
      case MedicalSpecialty.pedopsychiatrie:
        return SpecialtyCategory.motherChildPsy;

      case MedicalSpecialty.ophtalmologie:
      case MedicalSpecialty.orl:
        return SpecialtyCategory.sensory;

      case MedicalSpecialty.epidemiologieetmedecinepreventive:
      case MedicalSpecialty.biophysiquemedicale:
      case MedicalSpecialty.medecinelegaledroitmedicaletethique:
      case MedicalSpecialty.medecinenucleaireetimageriemoleculaire:
      case MedicalSpecialty.medecinedutravail:
      case MedicalSpecialty.medecinephysiqueetreadaptation:
      case MedicalSpecialty.medecinedusport:
      case MedicalSpecialty.radiotherapieoncologie:
        return SpecialtyCategory.preventiveOther;
    }
  }

  List<SpecialtyFormConfig> _getFilteredConfigs(BuildContext context) {
    return SpecialtyConfigs.all.where((config) {
      final category = _getSpecialtyCategory(config.specialty);
      final categoryMatch = _selectedCategory == SpecialtyCategory.all || category == _selectedCategory;

      if (!categoryMatch) return false;

      if (_searchQuery.isNotEmpty) {
        final name = config.specialty.localizedName(context).toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }

      return true;
    }).toList();
  }

  int _getCategoryCount(SpecialtyCategory category) {
    if (category == SpecialtyCategory.all) return SpecialtyConfigs.all.length;
    return SpecialtyConfigs.all.where((config) => _getSpecialtyCategory(config.specialty) == category).length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final filtered = _getFilteredConfigs(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.observationReport),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.clock),
            onPressed: () {
              context.push(AppRoutes.observationHistory);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Description & Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.selectSpecialty,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Sélectionnez une spécialité pour lancer l'examen clinique type.",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),

            // Main Diagnosis Helper Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: InkWell(
                onTap: () {
                  context.push(AppRoutes.pathologyDirectory);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isLight
                          ? [theme.primaryColor.withOpacity(0.08), theme.primaryColor.withOpacity(0.03)]
                          : [theme.primaryColor.withOpacity(0.2), theme.primaryColor.withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.primaryColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Iconsax.radar,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Aide au Diagnostic & Pathologies",
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isLight ? theme.primaryColor : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Rechercher parmi des milliers de diagnostics guidés.",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Iconsax.arrow_right_3,
                        color: theme.primaryColor,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Search and Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.08),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Iconsax.search_normal, size: 18),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = "";
                              });
                            },
                          )
                        : null,
                    hintText: "Rechercher une spécialité...",
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor.withOpacity(0.6),
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),

            // Category scrolling chips
            SizedBox(
              height: 48,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                scrollDirection: Axis.horizontal,
                itemCount: SpecialtyCategory.values.length,
                itemBuilder: (context, index) {
                  final cat = SpecialtyCategory.values[index];
                  final isSelected = _selectedCategory == cat;
                  final count = _getCategoryCount(cat);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    // ActionChip
                    child: FilterChip(
                      selected: isSelected,
                      showCheckmark: false,
                      avatar: Icon(
                        cat.icon,
                        size: 14,
                        color: isSelected
                            ? Colors.white
                            : (isLight ? theme.primaryColor.withOpacity(0.8) : theme.primaryColorLight),
                      ),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            cat.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.2)
                                  : (isLight ? theme.primaryColor.withOpacity(0.08) : theme.primaryColor.withOpacity(0.15)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "$count",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : theme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: theme.cardColor,
                      selectedColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : theme.dividerColor.withOpacity(0.08),
                        ),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 4),

            // Specialties Grid
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState(theme)
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.15,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final config = filtered[index];
                        final cat = _getSpecialtyCategory(config.specialty);
                        final hasDetailedData = PathologyDirectoryService.specialtiesWithData.contains(config.specialty);

                        return _SpecialtyCard(
                          config: config,
                          category: cat,
                          hasDetailedData: hasDetailedData,
                          isLight: isLight,
                          onTap: () {
                            context.push(
                              AppRoutes.observationReport.replaceFirst(
                                ':specialty',
                                config.specialty.name,
                              ),
                            );
                          },
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
            Iconsax.info_circle,
            size: 48,
            color: theme.hintColor.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            "Aucune spécialité trouvée",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Vérifiez l'orthographe ou changez de filtre.",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialtyCard extends StatelessWidget {
  final SpecialtyFormConfig config;
  final SpecialtyCategory category;
  final bool hasDetailedData;
  final bool isLight;
  final VoidCallback onTap;

  const _SpecialtyCard({
    required this.config,
    required this.category,
    required this.hasDetailedData,
    required this.isLight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.primaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withOpacity(isLight ? 0.15 : 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background design decoration
            Positioned(
              right: -12,
              bottom: -12,
              child: Icon(
                config.icon,
                size: 64,
                color: accentColor.withOpacity(isLight ? 0.03 : 0.04),
              ),
            ),
            
            // Detailed Badge tag
            if (hasDetailedData)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline, size: 8, color: Color(0xFF10B981)),
                      SizedBox(width: 2),
                      Text(
                        "DÉTAILLÉ",
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(config.icon, size: 22, color: accentColor),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        config.specialty.localizedName(context),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
