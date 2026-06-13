import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meducyte_app/core/database/app_database.dart';
import 'package:meducyte_app/features/observation/data/repositories/observation_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:meducyte_app/core/routes/routes.dart';
import 'package:meducyte_app/features/observation/data/models/specialty_config.dart';
import 'package:meducyte_app/features/observation/data/models/specialty_localization.dart';
import 'package:meducyte_app/features/observation/presentation/widgets/section_card.dart';
import 'package:meducyte_app/features/observation/presentation/screens/specialty_selection_screen.dart';
import 'package:meducyte_app/l10n/arb/app_localizations.dart';
import 'package:intl/intl.dart';

class ObservationHistoryScreen extends ConsumerStatefulWidget {
  const ObservationHistoryScreen({super.key});

  @override
  ConsumerState<ObservationHistoryScreen> createState() =>
      _ObservationHistoryScreenState();
}

class _ObservationHistoryScreenState
    extends ConsumerState<ObservationHistoryScreen> {
  String _searchQuery = '';
  SpecialtyCategory _selectedCategory = SpecialtyCategory.all;

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

  int _getCategoryCount(
      List<DbSavedObservation> reports, SpecialtyCategory category) {
    if (category == SpecialtyCategory.all) return reports.length;
    return reports.where((r) {
      final config = SpecialtyConfigs.all.firstWhere(
        (c) => c.specialty.name == r.specialty,
        orElse: () => SpecialtyConfigs.all.first,
      );
      return _getSpecialtyCategory(config.specialty) == category;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repository = ref.watch(observationRepositoryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.observationHistory),
      ),
      body: FutureBuilder<List<DbSavedObservation>>(
        future: repository.getAllReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allReports = snapshot.data ?? [];

          final filteredReports = allReports.where((r) {
            final query = _searchQuery.toLowerCase();
            final matchesSearch =
                r.patientName.toLowerCase().contains(query) ||
                r.specialty.toLowerCase().contains(query);

            final config = SpecialtyConfigs.all.firstWhere(
              (c) => c.specialty.name == r.specialty,
              orElse: () => SpecialtyConfigs.all.first,
            );
            final category = _getSpecialtyCategory(config.specialty);
            final matchesCategory =
                _selectedCategory == SpecialtyCategory.all ||
                    category == _selectedCategory;

            return matchesSearch && matchesCategory;
          }).toList();

          // Group reports by specialty name
          final Map<String, List<DbSavedObservation>> reportsBySpecialty = {};
          for (final report in filteredReports) {
            reportsBySpecialty
                .putIfAbsent(report.specialty, () => [])
                .add(report);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Search & Filters Section Card
              SectionCard(
                title: l10n.filters,
                icon: Iconsax.setting_4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: l10n.searchPatients,
                        prefixIcon: const Icon(Iconsax.search_normal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                    const SizedBox(height: 12),
                    // Category scrolling chips
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: SpecialtyCategory.values.length,
                        itemBuilder: (context, index) {
                          final cat = SpecialtyCategory.values[index];
                          final isSelected = _selectedCategory == cat;
                          final count = _getCategoryCount(allReports, cat);

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: FilterChip(
                              selected: isSelected,
                              showCheckmark: false,
                              avatar: Icon(
                                cat.icon,
                                size: 14,
                                color: isSelected
                                    ? Colors.white
                                    : (isLight
                                        ? theme.primaryColor.withOpacity(0.8)
                                        : theme.primaryColorLight),
                              ),
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    cat.displayName,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : theme.textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white.withOpacity(0.2)
                                          : (isLight
                                              ? theme.primaryColor.withOpacity(0.08)
                                              : theme.primaryColor.withOpacity(0.15)),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "$count",
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : theme.primaryColor,
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
                  ],
                ),
              ),

              if (filteredReports.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      l10n.noSavedReports,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              else
                ...reportsBySpecialty.entries.map((entry) {
                  final specialtyName = entry.key;
                  final reportsList = entry.value;

                  final config = SpecialtyConfigs.all.firstWhere(
                    (c) => c.specialty.name == specialtyName,
                    orElse: () => SpecialtyConfigs.all.first,
                  );

                  return SectionCard(
                    title: config.specialty.localizedName(context),
                    icon: config.icon,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = 0; i < reportsList.length; i++) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              color: isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : theme.primaryColor.withOpacity(0.08),
                            ),
                          _HistoryItemTile(
                            report: reportsList[i],
                            onTap: () => _loadReport(reportsList[i]),
                            onDelete: () =>
                                _confirmDelete(context, reportsList[i].id),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, int id) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteReportConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(observationRepositoryProvider).deleteReport(id);
      setState(() {});
    }
  }

  void _loadReport(DbSavedObservation report) async {
    await ref.read(observationRepositoryProvider).loadReport(report);
    if (mounted) {
      //Find the specialty config to navigate to the correct report screen
      final config = SpecialtyConfigs.all.firstWhere(
        (c) => c.specialty.name == report.specialty,
        orElse: () => SpecialtyConfigs.all.first, //Fallback
      );

      context.pushReplacement(
        AppRoutes.observationReport.replaceFirst(
          ':specialty',
          config.specialty.name,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report "${report.patientName}" loaded')),
      );
    }
  }
}

class _HistoryItemTile extends StatelessWidget {
  final DbSavedObservation report;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryItemTile({
    required this.report,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleText =
        report.patientName.isEmpty ? 'Patient Inconnu' : report.patientName;
    final dateStr = DateFormat.yMMMd().add_Hm().format(report.date);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Icon(
              Iconsax.document_text,
              size: 22,
              color: theme.primaryColor.withOpacity(0.7),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Iconsax.trash,
                color: theme.colorScheme.error.withOpacity(0.8),
                size: 20,
              ),
              onPressed: onDelete,
            ),
            Icon(
              Iconsax.arrow_right_3,
              size: 16,
              color: isDark ? Colors.white30 : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}
