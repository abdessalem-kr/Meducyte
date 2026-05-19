import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/productive_bay/presentation/widgets/fatigue_tracker_widget.dart';
import 'package:meducyte_app/features/productive_bay/presentation/widgets/study_dashboard_widget.dart';
import 'package:meducyte_app/features/productive_bay/presentation/widgets/daily_goals_widget.dart';
import 'package:meducyte_app/features/productive_bay/presentation/widgets/study_recap_widget.dart';
import 'package:meducyte_app/features/productive_bay/presentation/widgets/mastery_heatmap_widget.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("Performance&Fatigue"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FatigueTrackerWidget(),
            const SizedBox(height: 32),

            _buildSectionHeader(
              context,
              "Maîtrise Clinique par Sujet",
              Iconsax.medal_star,
            ),
            const SizedBox(height: 16),
            const MasteryHeatmapWidget(),

            const SizedBox(height: 32),
            _buildSectionHeader(
              context,
              "Tableau de Bord Efficacité",
              Iconsax.chart_21,
            ),
            const SizedBox(height: 16),
            const StudyDashboardWidget(),
            const SizedBox(height: 32),
            _buildSectionHeader(
              context,
              "Objectifs de Productivité",
              Iconsax.flag,
            ),
            const SizedBox(height: 16),
            const DailyGoalsWidget(),
            const SizedBox(height: 32),
            _buildSectionHeader(context, "Journalisation&Récap", Iconsax.edit),
            const SizedBox(height: 16),
            const StudyRecapWidget(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
