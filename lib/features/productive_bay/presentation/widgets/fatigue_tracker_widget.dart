import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/analytics_models.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/fatigue_provider.dart';

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
          _buildInsightRow(context, status, isDark),
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

  Widget _buildInsightRow(BuildContext context, FatigueStatus status, bool isDark) {
    final isFr = Localizations.localeOf(context).languageCode == 'fr';
    String capacityLabel;
    if (status.capacity > 0.75) {
      capacityLabel = isFr ? "Risque faible" : "Low Risk";
    } else if (status.capacity > 0.4) {
      capacityLabel = isFr ? "Risque modéré" : "Medium Risk";
    } else {
      capacityLabel = isFr ? "Risque élevé" : "High Risk";
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSmallStat(
            context.l10n.loadLabel,
            "${(status.cognitiveLoad * 100).toInt()}%",
            Iconsax.speedometer,
          ),
          _buildSmallStat(
            context.l10n.capacityLabel,
            capacityLabel,
            Iconsax.shield_tick,
          ),
          _buildSmallStat(
            context.l10n.breakDueLabel,
            _formatDuration(status.breakDue, isFr),
            Iconsax.coffee,
          ),
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

  String _formatDuration(Duration duration, bool isFr) {
    if (duration == Duration.zero) {
      return isFr ? "Maintenant" : "Now";
    }
    final mins = duration.inMinutes;
    if (mins < 60) {
      return "${mins}m";
    }
    final hrs = mins ~/ 60;
    final remMins = mins % 60;
    if (remMins == 0) {
      return "${hrs}h";
    }
    return "${hrs}h ${remMins}m";
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
    switch (key) {
      case 'peakFocusMsg':
        return context.l10n.peakFocusMsg;
      case 'optimalConcentrationMsg':
        return context.l10n.optimalConcentrationMsg;
      case 'lightFatigueMsg':
        return context.l10n.lightFatigueMsg;
      case 'burnoutRiskMsg':
        return context.l10n.burnoutRiskMsg;
      default:
        return key;
    }
  }
}
