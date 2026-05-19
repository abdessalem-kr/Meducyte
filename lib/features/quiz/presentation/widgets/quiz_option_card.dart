import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';
import 'package:meducyte_app/shared/widgets/highlightable_text.dart';

enum OptionState { idle, selected, correct, incorrect, missed }

class QuizOptionCard extends StatelessWidget {
  final String label; //A,B,C,D,E
  final String text;
  final OptionState state;
  final List<HighlightModel> highlights;
  final Function(HighlightModel)? onHighlightTap;
  final Function(String selectedText)? onHighlight;
  final Function(String selectedText)? onNote;
  final VoidCallback onTap;
  final double? fontSize;

  const QuizOptionCard({
    super.key,
    required this.label,
    required this.text,
    required this.state,
    this.highlights = const [],
    this.onHighlightTap,
    this.onHighlight,
    this.onNote,
    required this.onTap,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final primaryColor = Theme.of(context).primaryColor;

    Color borderColor = Colors.transparent;
    Color bgColor = quizTheme.cardColor;
    Color labelBgColor = primaryColor;

    if (state == OptionState.selected) {
      borderColor = primaryColor;
      bgColor = quizTheme.cardSelectedColor;
    } else if (state == OptionState.correct) {
      borderColor = quizTheme.correctBorderColor;
      bgColor = quizTheme.correctBorderColor.withOpacity(0.1);
      labelBgColor = quizTheme.correctBorderColor;
    } else if (state == OptionState.incorrect) {
      borderColor = quizTheme.incorrectBorderColor;
      bgColor = quizTheme.incorrectBorderColor.withOpacity(0.1);
      labelBgColor = quizTheme.incorrectBorderColor;
    } else if (state == OptionState.missed) {
      //Missed correct answer:orange or distinct dashed border
      borderColor = Colors.orange;
      bgColor = Colors.orange.withOpacity(0.1);
      labelBgColor = Colors.orange;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: labelBgColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white, //Labels always white on primary
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: HighlightableText(
                text: text,
                highlights: highlights,
                onHighlightTap: onHighlightTap,
                onHighlight: onHighlight,
                onNote: onNote,
                onTap: onTap,
                style: TextStyle(
                  color: quizTheme.primaryTextColor,
                  fontSize: fontSize ?? 16,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
