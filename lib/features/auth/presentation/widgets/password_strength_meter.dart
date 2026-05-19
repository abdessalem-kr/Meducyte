import 'package:meducyte_app/export.dart';

class PasswordStrengthMeter extends StatelessWidget {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasNumber;
  final bool hasSpecialChar;

  const PasswordStrengthMeter({
    super.key,
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasNumber,
    required this.hasSpecialChar,
  });

  @override
  Widget build(BuildContext context) {
    int score = 0;
    if (hasMinLength) score++;
    if (hasUppercase) score++;
    if (hasNumber) score++;
    if (hasSpecialChar) score++;

    Color color;
    String label;
    double progress;

    if (score == 0) {
      color = Colors.grey.shade300;
      label = context.l10n.authStrengthNone;
      progress = 0.05;
    } else if (score == 1) {
      color = Colors.red;
      label = context.l10n.authStrengthWeak;
      progress = 0.25;
    } else if (score == 2) {
      color = Colors.orange;
      label = context.l10n.authStrengthFair;
      progress = 0.5;
    } else if (score == 3) {
      color = Colors.blue;
      label = context.l10n.authStrengthGood;
      progress = 0.75;
    } else {
      color = Colors.green;
      label = context.l10n.authStrengthStrong;
      progress = 1.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.authStrengthLabel(label),
              style: TextStyle(
                fontSize: 11,
                color: score == 0 ? Colors.grey : color,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "${(progress * 100).toInt()}%",
              style: TextStyle(
                fontSize: 11,
                color: score == 0 ? Colors.grey : color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
