import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meducyte_app/core/database/app_database.dart';
import 'package:meducyte_app/features/observation/data/repositories/observation_repository.dart';
import 'package:meducyte_app/features/observation/presentation/screens/observation_report_screen.dart';
import 'package:meducyte_app/features/observation/data/models/specialty_config.dart';
import 'package:meducyte_app/features/observation/data/models/specialty_localization.dart';
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
  String? _selectedSpecialty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repository = ref.watch(observationRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.observationHistory),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
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
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: DropdownButtonFormField<String?>(
                  value: _selectedSpecialty,
                  decoration: InputDecoration(
                    hintText: 'Filter by Specialty',
                    prefixIcon: const Icon(Iconsax.filter),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Specialties'),
                    ),
                    ...SpecialtyConfigs.all.map(
                      (c) => DropdownMenuItem(
                        value: c.specialty.name,
                        child: Text(c.specialty.localizedName(context)),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedSpecialty = value),
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<DbSavedObservation>>(
        future: repository.getAllReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(l10n.noSavedReports));
          }

          final reports = snapshot.data!.where((r) {
            final query = _searchQuery.toLowerCase();
            final matchesSearch =
                r.patientName.toLowerCase().contains(query) ||
                r.specialty.toLowerCase().contains(query);
            final matchesSpecialty =
                _selectedSpecialty == null || r.specialty == _selectedSpecialty;
            return matchesSearch && matchesSpecialty;
          }).toList();

          if (reports.isEmpty) {
            return Center(child: Text(l10n.noSavedReports));
          }

          return ListView.builder(
            itemCount: reports.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    child: Icon(Iconsax.document_text),
                  ),
                  title: Text(
                    report.patientName.isEmpty
                        ? 'Unknown Patient'
                        : report.patientName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${report.specialty} • ${DateFormat.yMMMd().add_Hm().format(report.date)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Iconsax.trash,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => _confirmDelete(context, report.id),
                      ),
                      const Icon(Iconsax.arrow_right_3, size: 16),
                    ],
                  ),
                  onTap: () => _loadReport(report),
                ),
              );
            },
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

      //Replace current screen or pop if already on report screen?
      //Since history is now in selection screen,we should push to report screen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ObservationReportScreen(config: config),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report"${report.patientName}"loaded')),
      );
    }
  }
}
