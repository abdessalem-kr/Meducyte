import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';

class QuizResultScreen extends ConsumerWidget {
  final QuizSession? session;
  final List<Question> questions;
  final bool isPractice;

  const QuizResultScreen({
    super.key,
    this.session,
    required this.questions,
    this.isPractice = true,
  });

  String _formatDuration(int seconds) {
    if (seconds < 0) seconds = 0;
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizSessionProvider);
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).primaryColor;

    // Calculate scores from real results
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
        // Calculate All or Nothing
        bool isCorrectAllOrNothing =
            selectedIds.length == correctPropIds.length &&
            selectedIds.containsAll(correctPropIds);
        if (isCorrectAllOrNothing) correctAllOrNothing++;

        // Calculate Partial
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
        incorrect++; // Unanswered
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

    // Time Spent & Average Pace Calculation
    int timeSpentSeconds = 0;
    if (session != null) {
      final int? timeLimit = session!.filters['timeLimit'];
      if (quizState.isCountdown && timeLimit != null) {
        timeSpentSeconds = (timeLimit * 60) - quizState.timeSeconds;
      } else {
        timeSpentSeconds = quizState.timeSeconds;
      }
    } else {
      timeSpentSeconds = quizState.timeSeconds;
    }
    if (timeSpentSeconds < 0) timeSpentSeconds = 0;

    final averagePaceSeconds = total > 0 ? (timeSpentSeconds / total).round() : 0;

    // Focus Areas grouping (Incorrect questions by Module/Lesson)
    final incorrectQuestions = questions.where((q) {
      final result = quizState.results[q.id];
      return result == null || !result.isCorrect;
    }).toList();

    final Map<String, List<String>> weakPoints = {};
    for (var q in incorrectQuestions) {
      final module = q.moduleName ?? 'Général';
      final lesson = q.lessonTitle ?? 'Questions diverses';
      if (!weakPoints.containsKey(module)) {
        weakPoints[module] = [];
      }
      if (!weakPoints[module]!.contains(lesson)) {
        weakPoints[module]!.add(lesson);
      }
    }

    // Performance Feedback based on accuracy
    String performanceBadge = l10n.performanceNeedsWork;
    Color badgeColor = Theme.of(context).colorScheme.error;
    String feedbackMessage = l10n.feedbackNeedsWork;

    if (accuracy >= 90) {
      performanceBadge = l10n.performanceExcellent;
      badgeColor = const Color(0xFF10B981); // Emerald
      feedbackMessage = l10n.feedbackExcellent;
    } else if (accuracy >= 75) {
      performanceBadge = l10n.performanceVeryGood;
      badgeColor = const Color(0xFF6366F1); // Indigo
      feedbackMessage = l10n.feedbackVeryGood;
    } else if (accuracy >= 50) {
      performanceBadge = l10n.performanceAverage;
      badgeColor = const Color(0xFFF59E0B); // Amber
      feedbackMessage = l10n.feedbackAverage;
    }

    return Scaffold(
      backgroundColor: quizTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: badgeColor.withOpacity(0.2)),
                    ),
                    child: Text(
                      performanceBadge,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Main Score Card
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
                            const Color(0xFF10B981),
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
                      label: feedbackMessage,
                    ),

                  const SizedBox(height: 24),

                  // Time Spent & Average Pace stats panel
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: quizTheme.secondaryTextColor.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: quizTheme.secondaryTextColor.withOpacity(0.08),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Iconsax.timer_1, color: primaryColor, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.elapsedTime,
                                    style: TextStyle(
                                      color: quizTheme.secondaryTextColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatDuration(timeSpentSeconds),
                                style: TextStyle(
                                  color: quizTheme.primaryTextColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: quizTheme.secondaryTextColor.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: quizTheme.secondaryTextColor.withOpacity(0.08),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Iconsax.speedometer, color: primaryColor, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.averagePace,
                                    style: TextStyle(
                                      color: quizTheme.secondaryTextColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${averagePaceSeconds}s / q',
                                style: TextStyle(
                                  color: quizTheme.primaryTextColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Standard Statistics Items
                  Text(
                    l10n.statistics,
                    style: TextStyle(
                      color: quizTheme.primaryTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
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

                  const SizedBox(height: 32),

                  // Weak points & Focus areas recommendation
                  if (weakPoints.isNotEmpty) ...[
                    Text(
                      l10n.recommendedReview,
                      style: TextStyle(
                        color: quizTheme.primaryTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...weakPoints.entries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Iconsax.danger,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: TextStyle(
                                      color: quizTheme.primaryTextColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...entry.value.map((lesson) => Padding(
                              padding: const EdgeInsets.only(left: 28, bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "• ",
                                    style: TextStyle(
                                      color: quizTheme.secondaryTextColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      lesson,
                                      style: TextStyle(
                                        color: quizTheme.secondaryTextColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      );
                    }),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Iconsax.award,
                            color: Color(0xFF10B981),
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.perfectScore,
                                  style: TextStyle(
                                    color: quizTheme.primaryTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.perfectScoreSubtitle,
                                  style: TextStyle(
                                    color: quizTheme.secondaryTextColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  Text(
                    l10n.questionsDetailsList,
                    style: TextStyle(
                      color: quizTheme.primaryTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
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

            // Action Buttons Panel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Review Mistakes shortcut (only if there are incorrect answers)
                  if (incorrectQuestions.isNotEmpty) ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        final firstIncorrectIndex = questions.indexWhere((q) {
                          final result = quizState.results[q.id];
                          return result == null || !result.isCorrect;
                        });
                        if (firstIncorrectIndex != -1) {
                          final q = questions[firstIncorrectIndex];
                          ref.read(quizSessionProvider.notifier).reviewQuestion(
                                firstIncorrectIndex,
                                quizState.userAnswers[q.id] ?? {},
                              );
                        }
                      },
                      icon: const Icon(Iconsax.edit),
                      label: Text(
                        l10n.reviewMistakes,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B), // Amber
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  Row(
                    children: [
                      // Recommencer (Restart) Button
                      if (session != null) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              session!.userAnswers = {};
                              session!.isCompleted = false;
                              session!.currentQuestionIndex = 0;
                              ref.read(quizSessionProvider.notifier).initialize(session!);
                            },
                            icon: const Icon(Iconsax.refresh, size: 20),
                            label: Text(
                              l10n.restartQuiz,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: BorderSide(color: primaryColor, width: 1.5),
                              minimumSize: const Size(0, 50),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],

                      // Retour à l'accueil (Back to home) Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ref.read(navigationIndexProvider.notifier).state = 1; // Learn Tab
                            context.go(AppRoutes.home);
                          },
                          icon: const Icon(Iconsax.home, size: 20),
                          label: Text(
                            l10n.backToHome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 50),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
          colors: [color.withOpacity(0.85), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (!isSmall) ...[
            Text(
              accuracy >= 80 ? l10n.congratulations : l10n.keepImproving,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            label ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isSmall ? 14 : 14,
              fontWeight: isSmall ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          SizedBox(height: isSmall ? 12 : 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: isSmall ? 80 : 110,
                height: isSmall ? 80 : 110,
                child: CircularProgressIndicator(
                  value: accuracy / 100,
                  strokeWidth: isSmall ? 8 : 10,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$accuracy%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmall ? 20 : 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (!isSmall)
                    Text(
                      l10n.accuracy,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: color.withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          ref
              .read(quizSessionProvider.notifier)
              .reviewQuestion(index, userAnswerIds ?? {});
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: quizTheme.secondaryTextColor.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: quizTheme.secondaryTextColor.withOpacity(0.06),
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
                    fontSize: 14,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (mode == QuizCorrectionMode.partial && score != null)
                      Text(
                        "Score: ${score.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
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
