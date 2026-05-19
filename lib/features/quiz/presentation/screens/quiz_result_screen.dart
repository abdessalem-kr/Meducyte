import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';
import '../widgets/quiz_export_bottom_sheet.dart';

class QuizResultScreen extends ConsumerWidget {
  final List<Question> questions;
  final bool isPractice;

  const QuizResultScreen({
    super.key,
    required this.questions,
    this.isPractice = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizSessionProvider);
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).primaryColor;

    //Calculate scores from real results
    int correctAllOrNothing = 0;
    int correct = 0;
    int incorrect = 0;
    double totalScore = 0.0;
    double totalPartialScore = 0.0;

    for (var q in questions) {
      final selectedIds = quizState.userAnswers[q.id] ?? {};
      final correctPropIds = q.propositions
          .where((p) => p.isCorrect)
          .map((p) => p.id)
          .toSet();

      if (correctPropIds.isNotEmpty) {
        //Calculate All or Nothing
        bool isCorrectAllOrNothing =
            selectedIds.length == correctPropIds.length &&
            selectedIds.containsAll(correctPropIds);
        if (isCorrectAllOrNothing) correctAllOrNothing++;

        //Calculate Partial
        final correctlySelected = selectedIds
            .where((id) => correctPropIds.contains(id))
            .length;
        double qPartialScore = correctlySelected / correctPropIds.length;
        totalPartialScore += qPartialScore;
      }

      final result = quizState.results[q.id];
      if (result != null) {
        totalScore += result.score;
        if (result.isCorrect) {
          correct++;
        } else {
          incorrect++;
        }
      } else {
        incorrect++; //Unanswered
      }
    }

    final total = questions.length;
    final accuracy = total > 0 ? (totalScore / total * 100).round() : 0;
    final accuracyAllOrNothing = total > 0
        ? (correctAllOrNothing / total * 100).round()
        : 0;
    final accuracyPartial = total > 0
        ? (totalPartialScore / total * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: quizTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    l10n.quizResult,
                    style: TextStyle(
                      color: quizTheme.primaryTextColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => QuizExportBottomSheet(
                          accuracy: accuracy,
                          correct: correct,
                          incorrect: incorrect,
                          total: total,
                          quizTitle: l10n.quizResult,
                        ),
                      );
                    },
                    icon: Icon(Iconsax.share, color: primaryColor),
                    style: IconButton.styleFrom(
                      backgroundColor: primaryColor.withOpacity(0.1),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  if (!isPractice)
                    Row(
                      children: [
                        Expanded(
                          child: _buildScoreCard(
                            context,
                            accuracyAllOrNothing,
                            l10n,
                            quizTheme,
                            primaryColor,
                            label: l10n.allOrNothingScore,
                            isSmall: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildScoreCard(
                            context,
                            accuracyPartial,
                            l10n,
                            quizTheme,
                            const Color(0xFF10B981), //Emerald
                            label: l10n.partialPointsScore,
                            isSmall: true,
                          ),
                        ),
                      ],
                    )
                  else
                    _buildScoreCard(
                      context,
                      accuracy,
                      l10n,
                      quizTheme,
                      primaryColor,
                    ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.statistics,
                    style: TextStyle(
                      color: quizTheme.primaryTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatItem(
                        l10n.correctAnswers,
                        correct,
                        quizTheme.correctTextColor,
                        Iconsax.tick_circle,
                      ),
                      const SizedBox(width: 12),
                      _buildStatItem(
                        l10n.incorrectAnswers,
                        incorrect,
                        Theme.of(context).colorScheme.error,
                        Iconsax.close_circle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Détails des questions',
                    style: TextStyle(
                      color: quizTheme.primaryTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(questions.length, (index) {
                    final q = questions[index];
                    final result = quizState.results[q.id];
                    final status = result?.isCorrect == true
                        ? 'correct'
                        : 'incorrect';

                    return _buildQuestionSummaryItem(
                      context,
                      ref,
                      index,
                      q.text,
                      status,
                      quizTheme,
                      userAnswerIds: quizState.userAnswers[q.id],
                      score: result?.score,
                      mode: quizState.correctionMode,
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => QuizExportBottomSheet(
                      accuracy: accuracy,
                      correct: correct,
                      incorrect: incorrect,
                      total: total,
                      quizTitle: l10n.quizResult,
                    ),
                  );
                },
                icon: const Icon(Iconsax.share),
                label: const Text(
                  'Share Results',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1), //Indigo
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  ref.read(navigationIndexProvider.notifier).state =
                      1; //Learn Tab
                  context.go(AppRoutes.home);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  l10n.backToHome,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(
    BuildContext context,
    int accuracy,
    AppLocalizations l10n,
    QuizThemeExtension quizTheme,
    Color color, {
    String? label,
    bool isSmall = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            label ??
                (accuracy >= 80 ? l10n.congratulations : l10n.keepImproving),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 14 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isSmall ? 12 : 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: isSmall ? 80 : 120,
                height: isSmall ? 80 : 120,
                child: CircularProgressIndicator(
                  value: accuracy / 100,
                  strokeWidth: isSmall ? 8 : 12,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$accuracy%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmall ? 20 : 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (!isSmall)
                    Text(
                      l10n.accuracy,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionSummaryItem(
    BuildContext context,
    WidgetRef ref,
    int index,
    String text,
    String status,
    QuizThemeExtension quizTheme, {
    Set<int>? userAnswerIds,
    double? score,
    QuizCorrectionMode? mode,
  }) {
    Color statusColor = status == 'correct'
        ? quizTheme.correctTextColor
        : Theme.of(context).colorScheme.error;
    IconData statusIcon = status == 'correct'
        ? Iconsax.tick_circle
        : Iconsax.close_circle;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          ref
              .read(quizSessionProvider.notifier)
              .reviewQuestion(index, userAnswerIds ?? {});
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: quizTheme.secondaryTextColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: quizTheme.secondaryTextColor.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: quizTheme.primaryTextColor,
                        fontSize: 15,
                      ),
                    ),
                    if (mode == QuizCorrectionMode.partial && score != null)
                      Text(
                        "Score: ${score.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(statusIcon, color: statusColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
