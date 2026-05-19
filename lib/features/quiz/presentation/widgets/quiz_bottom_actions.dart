import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';

class QuizBottomActions extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onPrimary;
  final String primaryLabel;
  final bool isPrimaryEnabled;

  const QuizBottomActions({
    super.key,
    required this.onPrevious,
    required this.onPrimary,
    required this.primaryLabel,
    this.isPrimaryEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(
        children: [
          //Previous Button(Secondary)
          if (onPrevious != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildSecondaryButton(context, quizTheme, isDark),
            ),

          //Primary Button(Verify/Next/Finish)
          Expanded(child: _buildPrimaryButton(context, primaryColor, isDark)),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton(
    BuildContext context,
    QuizThemeExtension quizTheme,
    bool isDark,
  ) {
    return InkWell(
      onTap: onPrevious,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Icon(
          Iconsax.arrow_left_2,
          color: isDark ? Colors.white : Colors.black87,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context,
    Color primaryColor,
    bool isDark,
  ) {
    final bool isDisabled = !isPrimaryEnabled || onPrimary == null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: isDisabled
            ? null
            : LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor
                      .withBlue(primaryColor.blue + 30)
                      .withGreen(primaryColor.green + 10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isDisabled ? (isDark ? Colors.white12 : Colors.black12) : null,
        boxShadow: isDisabled
            ? []
            : [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPrimary,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              primaryLabel,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDisabled
                    ? (isDark ? Colors.white24 : Colors.black26)
                    : Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _getIconForLabel(primaryLabel),
              size: 20,
              color: isDisabled
                  ? (isDark ? Colors.white24 : Colors.black26)
                  : Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('verify') || lower.contains('vérifier')) {
      return Iconsax.tick_circle;
    } else if (lower.contains('finish') || lower.contains('terminer')) {
      return Iconsax.flag;
    }
    return Iconsax.arrow_right_3;
  }
}
