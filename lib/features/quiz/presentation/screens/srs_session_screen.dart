import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';
import 'package:meducyte_app/features/quiz/presentation/widgets/quiz_progress_bar.dart';
import 'package:meducyte_app/features/quiz/presentation/widgets/quiz_option_card.dart';
import 'package:meducyte_app/features/quiz/presentation/widgets/quiz_bottom_actions.dart';
import 'package:meducyte_app/shared/widgets/highlightable_text.dart';
import 'package:meducyte_app/features/quiz/presentation/widgets/quiz_report_bottom_sheet.dart';
import 'package:meducyte_app/features/quiz/presentation/widgets/quiz_comment_bottom_sheet.dart';
import 'package:meducyte_app/features/quiz/presentation/widgets/note_editor_widgets.dart';
import 'package:meducyte_app/features/quiz/presentation/widgets/quiz_save_bottom_sheet.dart';
import 'package:uuid/uuid.dart';

class SrsSessionScreen extends ConsumerStatefulWidget {
  const SrsSessionScreen({super.key});

  @override
  ConsumerState<SrsSessionScreen> createState() => _SrsSessionScreenState();
}

class _SrsSessionScreenState extends ConsumerState<SrsSessionScreen> {
  int _currentIndex = 0;
  bool _showAnswer = false;
  List<Question>? _questions;
  bool _isLoading = true;
  Set<int> _selectedPropIds = {};
  bool _isFinished = false;
  int _timerSeconds = 0;
  final Map<SrsPerformance, int> _sessionStats = {
    SrsPerformance.again: 0,
    SrsPerformance.hard: 0,
    SrsPerformance.good: 0,
    SrsPerformance.easy: 0,
  };
  Map<SrsPerformance, String>? _predictedIntervals;
  final Map<String, List<HighlightModel>> _highlights = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || _isFinished) return false;
      setState(() => _timerSeconds++);
      return true;
    });
  }
  Future<void> _loadQuestions() async {
    final srsRepo = ref.read(srsRepositoryProvider);
    final quizRepo = ref.read(quizRepositoryProvider);
    final user = ref.read(authControllerProvider).value;
    final is1to6YearUser = user != null && user.year >= 1 && user.year <= 6;

    final dueReviews = await srsRepo.getDueReviews();
    final ids = dueReviews.map((r) => r.questionId).toList();

    if (ids.isNotEmpty) {
      debugPrint('DEBUG:SrsSessionScreen-Fetching${ids.length}questions: $ids');
      final fetched = await quizRepo.getQuestionsByIds(ids);
      _questions = is1to6YearUser
          ? fetched.where((q) => q.year == user.year).toList()
          : fetched;
      debugPrint('DEBUG:SrsSessionScreen-Loaded${_questions?.length}questions');
    } else {
      _questions = [];
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (_questions != null && _questions!.isNotEmpty) {
        _loadPredictedIntervals();
      }
    }
  }

  Future<void> _loadPredictedIntervals() async {
    if (_questions == null || _currentIndex >= _questions!.length) return;
    final questionId = _questions![_currentIndex].id;
    final intervals = await ref
        .read(srsRepositoryProvider)
        .getPredictedIntervals(questionId);
    if (mounted) {
      setState(() => _predictedIntervals = intervals);
    }
  }

  void _validateAnswer() {
    final question = _questions![_currentIndex];
    ref
        .read(quizRepositoryProvider)
        .submitQuizAnswerLocal(
          question,
          _selectedPropIds,
          QuizCorrectionMode.allOrNothing,
        );

    setState(() {
      _showAnswer = true;
    });
    _loadPredictedIntervals();
  }

  Future<void> _submitGrade(SrsPerformance performance) async {
    final question = _questions![_currentIndex];

    try {
      await ref
          .read(srsRepositoryProvider)
          .recordReview(question.id, performance);
    } catch (e) {
      debugPrint('DEBUG:SrsSession _submitGrade error: $e');
      //Continue even if there's an error-don't block the session
    }

    if (!mounted) return;

    setState(() {
      _sessionStats[performance] = (_sessionStats[performance] ?? 0) + 1;

      if (performance == SrsPerformance.again) {
        _questions!.add(question);
      }

      if (_currentIndex < _questions!.length - 1) {
        _currentIndex++;
        _showAnswer = false;
        _selectedPropIds = {};
        _predictedIntervals = null;
      } else {
        _isFinished = true;
      }
    });
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isFinished) {
      return _buildSummary(context);
    }

    if (_questions == null || _questions!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.spacedRepetition)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                l10n.errorLoadingQuestions,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.noQuestionsFound,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text(l10n.backToHome.toUpperCase()),
              ),
            ],
          ),
        ),
      );
    }

    final question = _questions![_currentIndex];
    final isInSrs =
        ref.watch(questionInSrsProvider(question.id)).value ?? false;

    return Scaffold(
      backgroundColor: quizTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ───TOP BAR(same as QuizSessionScreen) ───
            QuizTopBar(
              onClose: () => context.pop(),
              timerText: _formatTime(_timerSeconds),
              isStarred: question.isSaved,
              isInSrs: isInSrs,
              onChatTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => QuizCommentBottomSheet(
                    questionId: question.id.toString(),
                    questionContext: question.text,
                  ),
                );
              },
              onStarTap: () {
                if (question.isSaved) {
                  _handleUnstarSrs(question);
                } else {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) =>
                        QuizSaveBottomSheet(questionId: question.id),
                  ).then((saved) {
                    if (saved == true && mounted) {
                      setState(() {
                        _questions![_currentIndex] = question.copyWith(
                          isSaved: true,
                        );
                      });
                    }
                  });
                }
              },
              onStarLongPress: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) =>
                      QuizSaveBottomSheet(questionId: question.id),
                ).then((saved) {
                  if (saved == true && mounted) {
                    setState(() {
                      _questions![_currentIndex] = question.copyWith(
                        isSaved: true,
                      );
                    });
                  }
                });
              },
              onFlagTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) =>
                      QuizReportBottomSheet(questionId: question.id.toString()),
                );
              },
            ),

            // ───PROGRESS BAR(same as QuizSessionScreen) ───
            QuizProgressBar(
              current: _currentIndex,
              total: _questions!.length,
              onInfoTap: () => _showInfoBottomSheet(context, question),
              onQuestionTap: () => _showQuestionSelector(
                context,
                _questions!.length,
                _currentIndex,
              ),
            ),

            const SizedBox(height: 24),

            // ───QUESTION+OPTIONS(same as QuizSessionScreen) ───
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //Question text card
                    RepaintBoundary(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: quizTheme.cardColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: quizTheme.secondaryTextColor.withOpacity(
                                0.1,
                              ),
                            ),
                          ),
                          child: HighlightableText(
                            text: question.text,
                            highlights:
                                _highlights['${question.id}_question'] ?? [],
                            onHighlightTap: (h) => _showNoteDialog(
                              context,
                              '${question.id}_question',
                              highlight: h,
                            ),
                            onHighlight: (text) => _showHighlightColors(
                              context,
                              '${question.id}_question',
                              selectedText: text,
                            ),
                            onNote: (text) => _showNoteDialog(
                              context,
                              '${question.id}_question',
                              selectedText: text,
                            ),
                            style: TextStyle(
                              color: quizTheme.primaryTextColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    //Feedback tag
                    if (_showAnswer)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildFeedbackTag(context, question, quizTheme),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    //Option cards
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: question.propositions.length,
                      itemBuilder: (context, index) {
                        final prop = question.propositions[index];
                        final isSelected = _selectedPropIds.contains(prop.id);
                        final isCorrect = prop.isCorrect;

                        return QuizOptionCard(
                          label: String.fromCharCode(65 + index),
                          text: prop.text,
                          state: _showAnswer
                              ? (isCorrect
                                    ? (isSelected
                                          ? OptionState.correct
                                          : OptionState.missed)
                                    : (isSelected
                                          ? OptionState.incorrect
                                          : OptionState.idle))
                              : (isSelected
                                    ? OptionState.selected
                                    : OptionState.idle),
                          highlights:
                              _highlights['${question.id}_option_$index'] ?? [],
                          onHighlightTap: (h) => _showNoteDialog(
                            context,
                            '${question.id}_option_$index',
                            highlight: h,
                          ),
                          onHighlight: (text) => _showHighlightColors(
                            context,
                            '${question.id}_option_$index',
                            selectedText: text,
                          ),
                          onNote: (text) => _showNoteDialog(
                            context,
                            '${question.id}_option_$index',
                            selectedText: text,
                          ),
                          onTap: _showAnswer
                              ? () {}
                              : () {
                                  setState(() {
                                    if (_selectedPropIds.contains(prop.id)) {
                                      _selectedPropIds.remove(prop.id);
                                    } else {
                                      _selectedPropIds.add(prop.id);
                                    }
                                  });
                                },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ───BOTTOM SECTION───
            if (!_showAnswer)
              QuizBottomActions(
                onPrevious: _currentIndex > 0
                    ? () {
                        setState(() {
                          _currentIndex--;
                          _showAnswer = false;
                          _selectedPropIds = {};
                          _predictedIntervals = null;
                        });
                      }
                    : null,
                onPrimary: _validateAnswer,
                primaryLabel: AppLocalizations.of(context)!.verify,
                isPrimaryEnabled: _selectedPropIds.isNotEmpty,
              )
            else
              _buildGradingSection(quizTheme, l10n),
          ],
        ),
      ),
    );
  }

  // ───SRS-SPECIFIC:GRADING SECTION───
  Widget _buildGradingSection(
    QuizThemeExtension quizTheme,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: quizTheme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.howWellDidYouRecall,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: quizTheme.secondaryTextColor,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildGradeButton(
                l10n.performanceAgain,
                Colors.red,
                SrsPerformance.again,
              ),
              _buildGradeButton(
                l10n.performanceHard,
                Colors.orange,
                SrsPerformance.hard,
              ),
              _buildGradeButton(
                l10n.performanceGood,
                Colors.green,
                SrsPerformance.good,
              ),
              _buildGradeButton(
                l10n.performanceEasy,
                Colors.blue,
                SrsPerformance.easy,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGradeButton(String label, Color color, SrsPerformance perf) {
    final interval = _predictedIntervals?[perf] ?? '';

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: () => _submitGrade(perf),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (interval.isNotEmpty)
                  Text(
                    interval,
                    style: TextStyle(
                      color: color.withOpacity(0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───FEEDBACK TAG───
  Widget _buildFeedbackTag(
    BuildContext context,
    Question question,
    QuizThemeExtension quizTheme,
  ) {
    final correctIds = question.propositions
        .where((p) => p.isCorrect)
        .map((p) => p.id)
        .toSet();
    final isCorrect =
        _selectedPropIds.containsAll(correctIds) &&
        correctIds.containsAll(_selectedPropIds);
    final l10n = AppLocalizations.of(context)!;

    final Color color = isCorrect
        ? quizTheme.correctTextColor
        : Theme.of(context).colorScheme.error;

    return Text(
      isCorrect ? l10n.correct : l10n.incorrect,
      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
    );
  }

  // ───SUMMARY SCREEN───
  Widget _buildSummary(BuildContext context) {
    final theme = Theme.of(context);
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: quizTheme.backgroundColor,
      appBar: AppBar(
        title: Text(l10n.sessionComplete),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 64,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.greatJob,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: quizTheme.primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.completionTime(_formatTime(_timerSeconds)),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: quizTheme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 48),
            _buildSummaryRow(
              l10n.performanceEasy,
              _sessionStats[SrsPerformance.easy]!,
              Colors.blue,
            ),
            _buildSummaryRow(
              l10n.performanceGood,
              _sessionStats[SrsPerformance.good]!,
              Colors.green,
            ),
            _buildSummaryRow(
              l10n.performanceHard,
              _sessionStats[SrsPerformance.hard]!,
              Colors.orange,
            ),
            _buildSummaryRow(
              l10n.performanceAgain,
              _sessionStats[SrsPerformance.again]!,
              Colors.red,
            ),
            const Spacer(),
            QuizBottomActions(
              onPrevious: null,
              onPrimary: () => context.pop(),
              primaryLabel: l10n.finish.toUpperCase(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, int count, Color color) {
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: quizTheme.primaryTextColor,
                ),
              ),
            ],
          ),
          Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ───INFO BOTTOM SHEET(same as QuizSessionScreen) ───
  void _showInfoBottomSheet(BuildContext context, Question question) {
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: quizTheme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: quizTheme.secondaryTextColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Icon(
                  Iconsax.info_circle,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.questionInfo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow(l10n.source, question.sourceExam ?? '-', quizTheme),
            _buildInfoRow(
              l10n.year,
              question.year?.toString() ?? '-',
              quizTheme,
            ),
            _buildInfoRow(
              l10n.specialty,
              question.moduleName ?? '-',
              quizTheme,
            ),
            _buildInfoRow(l10n.lesson, question.lessonTitle ?? '-', quizTheme),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    QuizThemeExtension quizTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: quizTheme.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: quizTheme.primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ───QUESTION SELECTOR(same as QuizSessionScreen) ───
  void _showQuestionSelector(BuildContext context, int total, int current) {
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).primaryColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: quizTheme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: quizTheme.secondaryTextColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Icon(Iconsax.grid_5, color: primaryColor),
                const SizedBox(width: 12),
                Text(
                  l10n.jumpToQuestion,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Flexible(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: total,
                itemBuilder: (context, index) {
                  final isCurrent = index == current;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _currentIndex = index;
                        _showAnswer = false;
                        _selectedPropIds = {};
                        _predictedIntervals = null;
                      });
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCurrent ? primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isCurrent
                              ? primaryColor
                              : quizTheme.secondaryTextColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isCurrent
                              ? Colors.white
                              : quizTheme.secondaryTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ───HIGHLIGHT COLORS───
  void _showHighlightColors(
    BuildContext context,
    String textId, {
    required String selectedText,
  }) {
    if (selectedText.isEmpty) return;

    final question = _questions![_currentIndex];
    String targetText = textId.endsWith('_question') ? question.text : '';
    if (textId.contains('_option_')) {
      int idx = int.parse(textId.split('_').last);
      targetText = question.propositions[idx].text;
    }

    final start = targetText.indexOf(selectedText);
    if (start == -1) return;

    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.chooseColor,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: quizTheme.highlightColors
                  .map(
                    (color) => _buildColorOption(
                      context,
                      textId,
                      selectedText,
                      start,
                      color,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(
    BuildContext context,
    String textId,
    String selectedText,
    int start,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          _highlights[textId] = [
            ...(_highlights[textId] ?? []),
            HighlightModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              start: start,
              end: start + selectedText.length,
              color: color,
              text: selectedText,
            ),
          ];
        });
        Navigator.pop(context);
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  // ───NOTE DIALOG───
  void _showNoteDialog(
    BuildContext context,
    String textId, {
    HighlightModel? highlight,
    String? selectedText,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NoteEditorBottomSheet(
        initialValue: highlight?.note ?? '',
        contextText: highlight?.text ?? selectedText,
        onDelete: highlight != null
            ? () {
                setState(() {
                  _highlights[textId]?.removeWhere((h) => h.id == highlight.id);
                });
                ref
                    .read(quizSessionProvider.notifier)
                    .removeHighlight(
                      _questions![_currentIndex].id,
                      textId,
                      highlight.id,
                    );
              }
            : null,
        onSave: (newNote) {
          if (highlight != null) {
            setState(() {
              final list = _highlights[textId] ?? [];
              final idx = list.indexWhere((h) => h.id == highlight.id);
              if (idx != -1) {
                list[idx] = highlight.copyWith(note: newNote);
              }
            });
            ref
                .read(quizSessionProvider.notifier)
                .updateHighlightNote(
                  _questions![_currentIndex].id,
                  textId,
                  highlight.id,
                  newNote,
                );
          } else if (selectedText != null) {
            final question = _questions![_currentIndex];
            String targetText = textId.endsWith('_question')
                ? question.text
                : '';
            if (textId.contains('_option_')) {
              int idx = int.parse(textId.split('_').last);
              targetText = question.propositions[idx].text;
            }
            final start = targetText.indexOf(selectedText);
            if (start != -1) {
              final newHighlight = HighlightModel(
                id: const Uuid().v4(),
                text: selectedText,
                start: start,
                end: start + selectedText.length,
                color:
                    Theme.of(
                      context,
                    ).extension<QuizThemeExtension>()?.highlightColors.first ??
                    Colors.yellow.withOpacity(0.5),
                note: newNote,
              );
              setState(() {
                if (!_highlights.containsKey(textId)) {
                  _highlights[textId] = [];
                }
                _highlights[textId]!.add(newHighlight);
              });
              ref
                  .read(quizSessionProvider.notifier)
                  .addHighlight(
                    question.id,
                    textId,
                    selectedText,
                    start,
                    start + selectedText.length,
                    newHighlight.color,
                    note: newNote,
                  );
            }
          }
        },
      ),
    );
  }

  Future<void> _handleUnstarSrs(Question question) async {
    try {
      await ref.read(quizRepositoryProvider).toggleSaveQuestion(question.id);
      //Invalidate both lists
      ref.invalidate(mySavedQuestionsProvider);

      if (mounted) {
        setState(() {
          _questions![_currentIndex] = question.copyWith(isSaved: false);
        });
        AppSnackBars.success(context, 'Removed from Saved');
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        context.pop();
        AppSnackBars.error(context, l10n.errorLoadingQuestionsShort);
      }
    }
  }
}
