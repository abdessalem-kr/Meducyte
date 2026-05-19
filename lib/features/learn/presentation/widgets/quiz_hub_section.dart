import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';

class QuizHubSection extends ConsumerWidget {
  final int? selectedYear;
  const QuizHubSection({super.key, this.selectedYear});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(userStatsProvider);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildSectionHeader(context, l10n.quizTraining, isDark),
              const SizedBox(height: 16),
              _buildWideCard(
                context: context,
                title: l10n.practice,
                subtitle: l10n.reviseSubtitle,
                icon: Iconsax.book_1,
                color: AppColors.primary,
                onTap: () => context.push(
                  AppRoutes.quizTraining,
                  extra: {
                    'isPractice': true,
                    'isExplore': false,
                    'initialYear': selectedYear,
                  },
                ), //Practice mode
              ),
              const SizedBox(height: 16),
              _buildWideCard(
                context: context,
                title: l10n.simulation,
                subtitle: l10n.simulateSubtitle,
                icon: Iconsax.teacher,
                color: AppColors.secondaryLight,
                onTap: () => context.push(
                  AppRoutes.quizTraining,
                  extra: {
                    'isPractice': false,
                    'isExplore': false,
                    'initialYear': selectedYear,
                  },
                ), //Exam Simulation mode
              ),
              const SizedBox(height: 32),
              _buildSectionHeader(context, l10n.studyTools, isDark),
              const SizedBox(height: 32),
              _buildToolsGrid(context, l10n, isDark, primaryColor),
              const SizedBox(height: 32),
              _buildSectionHeader(context, l10n.performanceStats, isDark),
              const SizedBox(height: 16),
              _buildStatsRow(l10n, quizTheme, isDark, statsAsync),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildToolsGrid(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    Color primaryColor,
  ) {
    final tools = [
      _ToolItem(
        title: l10n.spacedRepetition,
        icon: Iconsax.repeat,
        color: AppColors.primary,
        route: AppRoutes.spacedRepetition,
      ),
      _ToolItem(
        title: l10n.savedQuizzes,
        icon: Iconsax.bookmark,
        color: const Color(0xFF6366F1), //Indigo
        route: AppRoutes.savedQuizzes,
      ),
      _ToolItem(
        title: l10n.flashcards,
        icon: Iconsax.card,
        color: const Color(0xFFEC4899), //Pink
        route: AppRoutes.flashcards,
      ),
      _ToolItem(
        title: l10n.notes,
        icon: Iconsax.note_text,
        color: const Color(0xFFF59E0B), //Amber
        route: AppRoutes.quizNotes,
      ),
      _ToolItem(
        title: l10n.medicalInsight,
        icon: Iconsax.lamp_on,
        color: const Color(0xFF10B981), //Emerald
        route: AppRoutes.chatbot,
      ),
      _ToolItem(
        title: l10n.navSimulation,
        icon: Iconsax.medal_star,
        color: const Color(0xFF8B5CF6), //Violet
        route: AppRoutes.simulation,
      ),
    ];

    return GridView(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: tools.map((t) => _buildToolCard(context, t, isDark)).toList(),
    );
  }

  Widget _buildToolCard(BuildContext context, _ToolItem tool, bool isDark) {
    return InkWell(
      onTap: () => context.push(tool.route),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: tool.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(tool.icon, color: tool.color, size: 24),
            ),
            const Spacer(),
            Text(
              tool.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                height: 1.2,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildWideCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(
    AppLocalizations l10n,
    QuizThemeExtension quizTheme,
    bool isDark,
    AsyncValue<UserStats> statsAsync,
  ) {
    return statsAsync.when(
      data: (stats) => Row(
        children: [
          _buildStatItem(
            l10n.accuracyLabel,
            "${(stats.overallAccuracy * 100).toStringAsFixed(0)}%",
            quizTheme.correctTextColor,
            quizTheme,
            isDark,
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            l10n.streakLabel,
            l10n.daysLabel(stats.studyStreak),
            AppColors.primary,
            quizTheme,
            isDark,
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => Row(
        children: [
          _buildStatItem(
            l10n.accuracyLabel,
            "--%",
            quizTheme.correctTextColor,
            quizTheme,
            isDark,
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            l10n.streakLabel,
            l10n.daysLabel(0),
            AppColors.primary,
            quizTheme,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    QuizThemeExtension quizTheme,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: quizTheme.statCardBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: quizTheme.secondaryTextColor.withOpacity(0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: quizTheme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolItem {
  const _ToolItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
  final String title;
  final IconData icon;
  final Color color;
  final String route;
}
