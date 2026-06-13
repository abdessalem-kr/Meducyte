import 'package:meducyte_app/export.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:meducyte_app/features/productive_bay/presentation/widgets/fatigue_tracker_widget.dart';
import 'package:meducyte_app/features/productive_bay/presentation/widgets/mastery_heatmap_widget.dart';
import 'package:meducyte_app/features/productive_bay/presentation/widgets/study_dashboard_widget.dart';
import 'package:meducyte_app/features/productive_bay/presentation/widgets/daily_goals_widget.dart';
import 'package:meducyte_app/features/productive_bay/presentation/widgets/study_recap_widget.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(userStatsProvider);
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(l10n.statistics),
          centerTitle: true,
          bottom: TabBar(
            labelColor: theme.primaryColor,
            unselectedLabelColor: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
            indicatorColor: theme.primaryColor,
            tabs: const [
              Tab(
                icon: Icon(Iconsax.chart_21, size: 20),
                text: "Quiz & Performance",
              ),
              Tab(
                icon: Icon(Iconsax.coffee, size: 20),
                text: "Productivité & Fatigue",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Quiz & Performance
            statsAsync.when(
              data: (stats) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryHeader(context, stats, l10n),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, l10n.statsPerformanceTrend),
                    const SizedBox(height: 16),
                    _buildAccuracyChart(context, stats),
                    const SizedBox(height: 32),
                    _buildSectionTitle(context, l10n.statsSpecialtyAccuracy),
                    const SizedBox(height: 16),
                    _buildSpecialtyChart(context, stats),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
            
            // Tab 2: Productivité & Fatigue
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FatigueTrackerWidget(),
                  const SizedBox(height: 32),
                  _buildSectionTitle(context, "Maîtrise Clinique par Sujet"),
                  const SizedBox(height: 16),
                  const MasteryHeatmapWidget(),
                  const SizedBox(height: 32),
                  _buildSectionTitle(context, "Tableau de Bord Efficacité"),
                  const SizedBox(height: 16),
                  const StudyDashboardWidget(),
                  const SizedBox(height: 32),
                  _buildSectionTitle(context, "Objectifs de Productivité"),
                  const SizedBox(height: 16),
                  const DailyGoalsWidget(),
                  const SizedBox(height: 32),
                  _buildSectionTitle(context, "Journalisation & Récap"),
                  const SizedBox(height: 16),
                  const StudyRecapWidget(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSummaryHeader(BuildContext context, UserStats stats, AppLocalizations l10n) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          context,
          l10n.statsTotalAccuracy,
          '${(stats.overallAccuracy * 100).toStringAsFixed(0)}%',
          Iconsax.chart_2,
          AppColors.primary,
        ),
        _buildStatCard(
          context,
          l10n.statsQuizzesDone,
          '${stats.quizzesCompleted}',
          Iconsax.task,
          AppColors.accentLight,
        ),
        _buildStatCard(
          context,
          l10n.statsStreak,
          l10n.daysLabel(stats.studyStreak.toString()),
          Iconsax.flash,
          Colors.orange,
        ),
        _buildStatCard(
          context,
          l10n.statsQuestions,
          '${stats.questionsAnswered}',
          Iconsax.message_question,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyChart(BuildContext context, UserStats stats) {
    final theme = Theme.of(context);
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 ||
                      value.toInt() >= stats.performanceTrend.length) {
                    return const SizedBox();
                  }
                  final date = stats.performanceTrend[value.toInt()].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${date.day}/${date.month}',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                    ),
                  );
                },
                reservedSize: 22,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${(value * 100).toInt()}%',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                  );
                },
                reservedSize: 32,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: stats.performanceTrend.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.accuracy);
              }).toList(),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtyChart(BuildContext context, UserStats stats) {
    final theme = Theme.of(context);
    final sortedSpecialties = stats.specialtyAccuracy.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedSpecialties.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(entry.value * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: entry.value,
                  minHeight: 8,
                  backgroundColor: theme.dividerColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    entry.value >= 0.8
                        ? Colors.green
                        : (entry.value >= 0.6
                              ? AppColors.primary
                              : Colors.orange),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
