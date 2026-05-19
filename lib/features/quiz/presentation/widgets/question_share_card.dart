import 'package:meducyte_app/export.dart';
import '../../domain/models/share_theme.dart';

class QuestionShareCard extends StatelessWidget {
  final Question question;
  final String? category;
  final bool showAnswers;
  final ShareTheme theme;

  const QuestionShareCard({
    super.key,
    required this.question,
    this.category,
    this.showAnswers = true,
    this.theme = ShareTheme.classic,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = theme == ShareTheme.dark;
    final isMedical = theme == ShareTheme.medical;

    final cardBg = isDark
        ? const Color(0xFF1E1E1E)
        : (isMedical ? const Color(0xFFF0F7FF) : Colors.white);
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      width: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Header
          Row(
            children: [
              Image.asset('assets/images/logo.png', width: 32, height: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MEDUCYTE',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    if (category != null || question.sourceExam != null)
                      Text(
                        '${category ?? ""} ${category != null && question.sourceExam != null ? "•" : ""} ${question.sourceExam ?? ""}'
                            .trim()
                            .toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          //Question Text
          Text(
            question.text,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          //Options
          ...List.generate(question.propositions.length, (index) {
            final prop = question.propositions[index];
            final isCorrect = prop.isCorrect && showAnswers;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isCorrect
                    ? Colors.green.withOpacity(isDark ? 0.2 : 0.05)
                    : (isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey[50]),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCorrect
                      ? Colors.green.withOpacity(0.4)
                      : (isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey[200]!),
                  width: isCorrect ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isCorrect ? Colors.green : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCorrect ? Colors.green : Colors.grey[300]!,
                      ),
                    ),
                    child: isCorrect
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            String.fromCharCode(65 + index),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      prop.text,
                      style: TextStyle(
                        color: isCorrect
                            ? (isDark ? Colors.green[300] : Colors.green[800])
                            : (isDark ? Colors.white70 : Colors.grey[800]),
                        fontSize: 14,
                        fontWeight: isCorrect
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),
          //Footer/Call to action
          Center(
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Challenge yourself on Meducyte',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Available on iOS&Android',
                  style: TextStyle(
                    color: primaryColor.withOpacity(0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
