import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/simulation/domain/models/simulation_models.dart';
import 'package:meducyte_app/features/simulation/presentation/widgets/investigation_modal.dart';
import 'package:meducyte_app/features/simulation/presentation/widgets/last_finding.dart';

class ExamTab extends ConsumerWidget {
  final SimSession session;
  const ExamTab({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final maneuvers = [
      l10n.simAuscultation,
      l10n.simPalpation,
      l10n.simPercussion,
      l10n.simNeurologicalExam,
      l10n.simPupillaryReflex,
      l10n.simJVP,
    ];

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.simPerformExamination, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: maneuvers.length,
              itemBuilder: (context, index) {
                final maneuver = maneuvers[index];
                return ElevatedButton(
                  onPressed: () {
                    showInvestigationModal(context, ref, maneuver, 'exam');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.cardColor,
                    foregroundColor: theme.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.primaryColor.withOpacity(0.1)),
                    ),
                  ),
                  child: Text(maneuver, style: const TextStyle(fontSize: 11)),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          LastFinding(session: session),
        ],
      ),
    );
  }
}
