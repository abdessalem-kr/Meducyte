import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';
import 'package:meducyte_app/shared/widgets/highlightable_text.dart';
import 'dart:math' as math;

class FlashcardWidget extends StatefulWidget {
  final Question question;
  final bool isFlipped;
  final VoidCallback onFlip;

  const FlashcardWidget({
    super.key,
    required this.question,
    required this.isFlipped,
    required this.onFlip,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    if (widget.isFlipped) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;

    return GestureDetector(
      onTap: widget.onFlip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: angle <= math.pi / 2
                ? _buildFront(context, l10n, quizTheme)
                : Transform(
                    transform: Matrix4.identity()..rotateY(math.pi),
                    alignment: Alignment.center,
                    child: _buildBack(context, l10n, quizTheme),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFront(
    BuildContext context,
    AppLocalizations l10n,
    QuizThemeExtension quizTheme,
  ) {
    return Container(
      key: const ValueKey('front'),
      decoration: _cardDecoration(quizTheme),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.flash_1,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.questionLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: quizTheme.secondaryTextColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: HighlightableText(
                text: widget.question.text,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: quizTheme.primaryTextColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.refresh_2,
                size: 16,
                color: quizTheme.secondaryTextColor.withOpacity(0.5),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.tapToFlip,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: quizTheme.secondaryTextColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBack(
    BuildContext context,
    AppLocalizations l10n,
    QuizThemeExtension quizTheme,
  ) {
    final correctPropositions = widget.question.propositions
        .where((p) => p.isCorrect)
        .toList();

    return Container(
      key: const ValueKey('back'),
      decoration: _cardDecoration(quizTheme),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.tick_circle,
              color: AppColors.success,
              size: 40,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.correctAnswerLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: quizTheme.secondaryTextColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...correctPropositions.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        p.text,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  if (widget.question.clinicalCase != null) ...[
                    const Divider(height: 48),
                    Text(
                      l10n.clinicalContext,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: quizTheme.secondaryTextColor.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.question.clinicalCase!.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: quizTheme.secondaryTextColor,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.nowGradeYourRecall,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: quizTheme.secondaryTextColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(QuizThemeExtension quizTheme) {
    return BoxDecoration(
      color: quizTheme.cardColor,
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: quizTheme.secondaryTextColor.withOpacity(0.08)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
