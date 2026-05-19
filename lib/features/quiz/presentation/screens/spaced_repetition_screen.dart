import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/shared/widgets/subscription_gate.dart';

class SpacedRepetitionScreen extends ConsumerStatefulWidget {
  const SpacedRepetitionScreen({super.key});

  @override
  ConsumerState<SpacedRepetitionScreen> createState() =>
      _SpacedRepetitionScreenState();
}

class _SpacedRepetitionScreenState
    extends ConsumerState<SpacedRepetitionScreen> {
  @override
  void initState() {
    super.initState();
    //Trigger sync on open
    Future.microtask(
      () => ref.read(srsRepositoryProvider).syncAllWithBackend(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(srsStatsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SubscriptionGate(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.spacedRepetition),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => _showResetDialog(context, l10n),
              icon: const Icon(Icons.refresh, color: Colors.grey),
            ),
          ],
        ),
        body: statsAsync.when(
          data: (stats) => RefreshIndicator(
            onRefresh: () =>
                ref.read(srsRepositoryProvider).syncAllWithBackend(),
            child: _buildContent(context, stats, isDark, theme, l10n),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Map<String, int> stats,
    bool isDark,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final dueCount = stats['due'] ?? 0;
    final total = stats['total'] ?? 0;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildDueCard(context, dueCount, isDark, theme, l10n),
              const SizedBox(height: 32),
              _buildStatsGrid(stats, isDark, theme, l10n),
              const SizedBox(height: 48),
              if (dueCount > 0)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      debugPrint(
                        'DEBUG:SpacedRepetitionScreen-START REVIEW pressed',
                      );
                      context.push(AppRoutes.srsSession);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(l10n.startReviewCount(dueCount)),
                  ),
                )
              else if (total > 0)
                _buildAllCaughtUp(theme, isDark, l10n)
              else
                _buildEmptyState(theme, isDark, l10n),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildDueCard(
    BuildContext context,
    int count,
    bool isDark,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            l10n.dueToday,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    Map<String, int> stats,
    bool isDark,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: [
        _buildStatItem(
          l10n.learningLabel,
          stats['learning'] ?? 0,
          Colors.orange,
        ),
        _buildStatItem(
          l10n.masteredLabel,
          stats['mastered'] ?? 0,
          Colors.green,
        ),
        _buildStatItem(l10n.totalLabel, stats['total'] ?? 0, AppColors.primary),
      ],
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildAllCaughtUp(
    ThemeData theme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        Icon(
          Iconsax.tick_circle5,
          size: 64,
          color: Colors.green.withOpacity(0.2),
        ),
        const SizedBox(height: 16),
        Text(l10n.allCaughtUp, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          l10n.checkBackTomorrow,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        Icon(Iconsax.ranking5, size: 64, color: Colors.blue.withOpacity(0.2)),
        const SizedBox(height: 16),
        Text(l10n.srsEmptyTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          l10n.srsEmptySubtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Future<void> _showResetDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetProgressTitle),
        content: Text(l10n.resetProgressSubtitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.srsReset,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(srsRepositoryProvider).resetSrs();
      if (context.mounted) {
        AppSnackBars.success(context, l10n.srsResetSuccess);
      }
    }
  }
}
