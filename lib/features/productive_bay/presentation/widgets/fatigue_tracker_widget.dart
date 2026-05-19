import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/analytics_models.dart';

//Simulated Provider for Fatigue Status
final fatigueStatusProvider = Provider<FatigueStatus>((ref) {
  //Logic would normally analyze completed sessions today
  return const FatigueStatus(
    level: FatigueLevel.optimal,
    recommendation: "Concentration optimale",
    recommendationKey: "optimalConcentrationMsg",
    cognitiveLoad: 0.42,
  );
});

class FatigueTrackerWidget extends ConsumerWidget {
  const FatigueTrackerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(fatigueStatusProvider);
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
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildGauge(context, status.cognitiveLoad, status.level),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLevelLabel(context, status.level),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getLevelColor(status.level),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status.recommendationKey != null
                          ? _getLocalizedRecommendation(
                              context,
                              status.recommendationKey!,
                            )
                          : status.recommendation,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInsightRow(context, isDark),
        ],
      ),
    );
  }

  Widget _buildGauge(BuildContext context, double value, FatigueLevel level) {
    final color = _getLevelColor(level);
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 6,
              backgroundColor: color.withOpacity(0.1),
              color: color,
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getLevelIcon(level), color: color, size: 20),
              Text(
                "${(value * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSmallStat(context.l10n.loadLabel, "42%", Iconsax.speedometer),
          _buildSmallStat(
            context.l10n.capacityLabel,
            "Low Risk",
            Iconsax.shield_tick,
          ),
          _buildSmallStat(context.l10n.breakDueLabel, "1h 12m", Iconsax.coffee),
        ],
      ),
    );
  }

  Widget _buildSmallStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey)),
      ],
    );
  }

  Color _getLevelColor(FatigueLevel level) {
    switch (level) {
      case FatigueLevel.peak:
        return Colors.blue;
      case FatigueLevel.optimal:
        return Colors.green;
      case FatigueLevel.tired:
        return Colors.orange;
      case FatigueLevel.exhausted:
        return Colors.red;
    }
  }

  String _getLevelLabel(BuildContext context, FatigueLevel level) {
    switch (level) {
      case FatigueLevel.peak:
        return context.l10n.focusPeak;
      case FatigueLevel.optimal:
        return context.l10n.focusStable;
      case FatigueLevel.tired:
        return context.l10n.lightFatigue;
      case FatigueLevel.exhausted:
        return context.l10n.burnoutRisk;
    }
  }

  IconData _getLevelIcon(FatigueLevel level) {
    switch (level) {
      case FatigueLevel.peak:
        return Iconsax.flash;
      case FatigueLevel.optimal:
        return Iconsax.activity;
      case FatigueLevel.tired:
        return Iconsax.coffee;
      case FatigueLevel.exhausted:
        return Iconsax.danger;
    }
  }

  String _getLocalizedRecommendation(BuildContext context, String key) {
    if (key == 'optimalConcentrationMsg') {
      return context.l10n.optimalConcentrationMsg;
    }
    return key;
  }
}
