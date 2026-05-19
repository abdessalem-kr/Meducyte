import 'package:meducyte_app/export.dart';
import '../../domain/models/share_theme.dart';

class QuizShareCard extends StatelessWidget {
  final int accuracy;
  final int correct;
  final int incorrect;
  final int total;
  final String? quizTitle;
  final ShareTheme theme;

  const QuizShareCard({
    super.key,
    required this.accuracy,
    required this.correct,
    required this.incorrect,
    required this.total,
    this.quizTitle,
    this.theme = ShareTheme.indigo,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).primaryColor;

    final isDark = theme == ShareTheme.dark;
    final isMedical = theme == ShareTheme.medical;

    //Custom gradients per theme
    final List<Color> gradientColors = isDark
        ? [const Color(0xFF1A1A1A), const Color(0xFF2D2D2D)]
        : (isMedical
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
              : [primaryColor.withBlue(150), primaryColor]);

    return Container(
      width: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //Header/Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 40, height: 40),
              const SizedBox(width: 12),
              const Text(
                'MEDUCYTE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),

          //Score Circle
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: accuracy / 100,
                  strokeWidth: 16,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$accuracy%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    l10n.accuracy.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 48),

          //Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                l10n.correctAnswers,
                correct,
                Colors.white,
                Iconsax.tick_circle,
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.2),
              ),
              _buildStatItem(
                l10n.incorrectAnswers,
                incorrect,
                Colors.white.withOpacity(0.8),
                Iconsax.close_circle,
              ),
            ],
          ),
          const SizedBox(height: 48),

          //Footer Text
          Text(
            quizTitle ?? l10n.quizResult,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Becoming the best doctor',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
