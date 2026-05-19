import 'package:meducyte_app/export.dart';

class FlashcardPulseWidget extends ConsumerWidget {
  const FlashcardPulseWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pulse = ref.watch(studyPulseProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildStat(
                context,
                pulse.cardsDueToday.toString(),
                "Cartesàrevoir",
                Iconsax.cards,
                Colors.orange,
              ),
              const Spacer(),
              _buildStat(
                context,
                "${pulse.currentReviewStreak}j",
                "Série SRS",
                Iconsax.flash,
                Colors.amber,
              ),
              const Spacer(),
              _buildMasteryRing(context, pulse.masteryLevel),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                //Future:Navigate to flashcard review
              },
              icon: const Icon(Iconsax.play, size: 20),
              label: const Text("Démarrer la Révision Rapide"),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMasteryRing(BuildContext context, double mastery) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: mastery,
                strokeWidth: 4,
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
              Center(
                child: Text(
                  "${(mastery * 100).toInt()}%",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Maîtrise",
          style: TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }
}
