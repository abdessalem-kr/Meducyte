import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/simulation/domain/models/simulation_models.dart';

class LastFinding extends StatelessWidget {
  final SimSession session;
  const LastFinding({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final lastClinicalMsg = session.messages.lastWhere(
      (m) => m.text.startsWith("[EXAM]") || m.text.startsWith("[LAB]"),
      orElse: () => const SimMessage(id: "", text: "", isFromUser: false, timestamp: null),
    );

    if (lastClinicalMsg.text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.simLatestFinding, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(lastClinicalMsg.text, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
