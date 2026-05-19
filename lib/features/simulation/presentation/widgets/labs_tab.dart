import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/simulation/domain/models/simulation_models.dart';
import 'package:meducyte_app/features/simulation/presentation/widgets/investigation_modal.dart';
import 'package:meducyte_app/features/simulation/presentation/widgets/last_finding.dart';

class LabsTab extends ConsumerStatefulWidget {
  final SimSession session;
  const LabsTab({super.key, required this.session});

  @override
  ConsumerState<LabsTab> createState() => _LabsTabState();
}

class _LabsTabState extends ConsumerState<LabsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategoryKey = "all";

  List<Map<String, String>> _getLocalizedInvestigations(AppLocalizations l10n) {
    return [
      {"name": l10n.labBloodGlucose, "category": l10n.labBiochemistry, "catKey": "Biochemistry"},
      {"name": l10n.labUreaElectrolytes, "category": l10n.labBiochemistry, "catKey": "Biochemistry"},
      {"name": l10n.labLiverFunction, "category": l10n.labBiochemistry, "catKey": "Biochemistry"},
      {"name": l10n.labCrp, "category": l10n.labBiochemistry, "catKey": "Biochemistry"},
      {"name": l10n.labHba1c, "category": l10n.labBiochemistry, "catKey": "Biochemistry"},
      {"name": l10n.labLipidProfile, "category": l10n.labBiochemistry, "catKey": "Biochemistry"},
      {"name": l10n.labFbc, "category": l10n.labHematology, "catKey": "Hematology"},
      {"name": l10n.labCoagulation, "category": l10n.labHematology, "catKey": "Hematology"},
      {"name": l10n.labDdimer, "category": l10n.labHematology, "catKey": "Hematology"},
      {"name": l10n.labBloodFilm, "category": l10n.labHematology, "catKey": "Hematology"},
      {"name": l10n.labTroponin, "category": l10n.labCardiac, "catKey": "Cardiac"},
      {"name": l10n.labNtProBnp, "category": l10n.labCardiac, "catKey": "Cardiac"},
      {"name": l10n.labEcg, "category": l10n.labCardiac, "catKey": "Cardiac"},
      {"name": l10n.labEcho, "category": l10n.labCardiac, "catKey": "Cardiac"},
      {"name": l10n.labCardiacEnzymes, "category": l10n.labCardiac, "catKey": "Cardiac"},
      {"name": l10n.labCxr, "category": l10n.labRadiology, "catKey": "Radiology"},
      {"name": l10n.labAxr, "category": l10n.labRadiology, "catKey": "Radiology"},
      {"name": l10n.labCtBrain, "category": l10n.labRadiology, "catKey": "Radiology"},
      {"name": l10n.labCtpa, "category": l10n.labRadiology, "catKey": "Radiology"},
      {"name": l10n.labAbdoUs, "category": l10n.labRadiology, "catKey": "Radiology"},
      {"name": l10n.labMriBrain, "category": l10n.labRadiology, "catKey": "Radiology"},
      {"name": l10n.labBloodCultures, "category": l10n.labMicrobiology, "catKey": "Microbiology"},
      {"name": l10n.labUrineCulture, "category": l10n.labMicrobiology, "catKey": "Microbiology"},
      {"name": l10n.labSputumCulture, "category": l10n.labMicrobiology, "catKey": "Microbiology"},
      {"name": l10n.labPcr, "category": l10n.labMicrobiology, "catKey": "Microbiology"},
      {"name": l10n.labUrinalysis, "category": l10n.labOthers, "catKey": "Others"},
      {"name": l10n.labAbg, "category": l10n.labOthers, "catKey": "Others"},
      {"name": l10n.labPeakFlow, "category": l10n.labOthers, "catKey": "Others"},
    ];
  }

  List<Map<String, String>> _getLocalizedCategories(AppLocalizations l10n) {
    return [
      {"name": l10n.all, "key": "all"},
      {"name": l10n.labBiochemistry, "key": "Biochemistry"},
      {"name": l10n.labHematology, "key": "Hematology"},
      {"name": l10n.labCardiac, "key": "Cardiac"},
      {"name": l10n.labRadiology, "key": "Radiology"},
      {"name": l10n.labMicrobiology, "key": "Microbiology"},
      {"name": l10n.labOthers, "key": "Others"},
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final investigations = _getLocalizedInvestigations(l10n);
    final categories = _getLocalizedCategories(l10n);

    final filtered = investigations.where((i) {
      final matchSearch = i['name']!.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCat = _selectedCategoryKey == "all" || i['catKey'] == _selectedCategoryKey;
      return matchSearch && matchCat;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.simSearchInvestigations,
              prefixIcon: const Icon(Iconsax.search_normal, size: 20),
              filled: true, fillColor: theme.cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final sel = _selectedCategoryKey == cat['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat['name']!, style: TextStyle(fontSize: 10, color: sel ? Colors.white : theme.hintColor)),
                    selected: sel,
                    onSelected: (s) { if (s) setState(() => _selectedCategoryKey = cat['key']!); },
                    selectedColor: AppColors.primary,
                    backgroundColor: theme.cardColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.8,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final inv = filtered[index];
                return ElevatedButton(
                  onPressed: () => showInvestigationModal(context, ref, inv['name']!, 'lab'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.cardColor, foregroundColor: AppColors.primary, elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.primary.withOpacity(0.1))),
                  ),
                  child: Text(inv['name']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2),
                );
              },
            ),
          ),
          LastFinding(session: widget.session),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
