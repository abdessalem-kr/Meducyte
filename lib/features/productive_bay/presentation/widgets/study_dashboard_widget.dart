import 'package:meducyte_app/export.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StudyDashboardWidget extends ConsumerWidget {
  const StudyDashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(studyStatsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return stats.when(
      data: (data) => Container(
        width: double.infinity,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  context,
                  "${data.currentStreak} ${context.l10n.days.substring(0, 1)}",
                  context.l10n.studyStreak,
                  Iconsax.flash,
                  Colors.orange,
                ),
                Container(width: 1, height: 40, color: theme.dividerColor),
                _buildStatItem(
                  context,
                  "${data.completedPomodorosToday}/${data.totalPomodorosGoal}",
                  context.l10n.pomodoroToday,
                  Iconsax.timer_1,
                  theme.primaryColor,
                ),
                Container(width: 1, height: 40, color: theme.dividerColor),
                _buildStatItem(
                  context,
                  "${data.totalHours}h",
                  context.l10n.totalHours,
                  Iconsax.clock,
                  Colors.blue,
                ),
              ],
            ),
            if (data.moduleScores.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                context.l10n.moduleEfficiency,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              ...data.moduleScores.entries.map(
                (e) => _buildModuleScore(context, e.key, e.value),
              ),
            ],
          ],
        ),
      ),
      loading: () => Skeletonizer(
        enabled: true,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    context,
                    "5 J",
                    context.l10n.studyStreak,
                    Iconsax.flash,
                    Colors.orange,
                  ),
                  Container(width: 1, height: 40, color: theme.dividerColor),
                  _buildStatItem(
                    context,
                    "4/8",
                    context.l10n.pomodoroToday,
                    Iconsax.timer_1,
                    theme.primaryColor,
                  ),
                  Container(width: 1, height: 40, color: theme.dividerColor),
                  _buildStatItem(
                    context,
                    "12h",
                    context.l10n.totalHours,
                    Iconsax.clock,
                    Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.moduleEfficiency,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              _buildModuleScore(context, "Module d'anatomie de test", 0.75),
            ],
          ),
        ),
      ),
      error: (err, stack) =>
          Center(child: Text('${context.l10n.errorLabel}: $err')),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildModuleScore(BuildContext context, String module, double score) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color scoreColor = score < 0.5
        ? Colors.red
        : (score < 0.8 ? Colors.orange : Colors.green);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  module,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${(score * 100).toInt()}%",
                style: TextStyle(
                  color: scoreColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
