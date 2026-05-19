import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/mastery_provider.dart';

class MasteryHeatmapWidget extends ConsumerWidget {
  const MasteryHeatmapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masteryMap = ref.watch(masteryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
          ),
          itemCount: masteryMap.length,
          itemBuilder: (context, index) {
            final data = masteryMap.values.elementAt(index);
            return _buildMasteryCard(context, data, isDark);
          },
        ),
      ],
    );
  }

  Widget _buildMasteryCard(
    BuildContext context,
    MasteryData data,
    bool isDark,
  ) {
    final color = _getMasteryColor(data.masteryScore);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data.subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${(data.masteryScore * 100).toInt()}%",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          if (data.lastDifficultConcept != null)
            Text(
              "Défi: ${data.lastDifficultConcept}",
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 8),
          _buildMiniHeatmap(data.history, color),
        ],
      ),
    );
  }

  Widget _buildMiniHeatmap(List<int> history, Color color) {
    return Row(
      children: List.generate(8, (index) {
        final score = index < history.length ? history[index] : 0;
        return Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: score == 0
                ? Colors.grey.withOpacity(0.1)
                : color.withOpacity(score / 5),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Color _getMasteryColor(double score) {
    if (score < 0.5) return Colors.red;
    if (score < 0.75) return Colors.orange;
    return Colors.green;
  }
}
