import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';

class FlashcardStudyScreen extends ConsumerStatefulWidget {
  final List<Question> initialQuestions;
  final String title;

  const FlashcardStudyScreen({
    super.key,
    required this.initialQuestions,
    required this.title,
  });

  @override
  ConsumerState<FlashcardStudyScreen> createState() =>
      _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends ConsumerState<FlashcardStudyScreen> {
  late List<Question> _questions;
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isFinished = false;
  int _timerSeconds = 0;
  final Map<SrsPerformance, String> _predictedIntervals = {};

  @override
  void initState() {
    super.initState();
    _questions = List.from(widget.initialQuestions);
    _startTimer();
    _loadPredictedIntervals();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || _isFinished) return false;
      setState(() => _timerSeconds++);
      return true;
    });
  }

  Future<void> _loadPredictedIntervals() async {
    if (_questions.isEmpty || _currentIndex >= _questions.length) return;

    final questionId = _questions[_currentIndex].id;
    final intervals = await ref
        .read(srsRepositoryProvider)
        .getPredictedIntervals(questionId);

    if (mounted) {
      setState(() {
        _predictedIntervals.clear();
        _predictedIntervals.addAll(intervals);
      });
    }
  }

  Future<void> _submitGrade(SrsPerformance performance) async {
    final question = _questions[_currentIndex];

    //Record review in SRS
    try {
      await ref
          .read(srsRepositoryProvider)
          .recordReview(question.id, performance);
    } catch (_) {
      //Error is handled Silently or via Sentry in production
    }

    if (!mounted) return;

    setState(() {
      if (performance == SrsPerformance.again) {
        //Add to end of deck if forgotten
        _questions.add(question);
      }

      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
        _isFlipped = false;
        _loadPredictedIntervals();
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

    if (_isFinished) {
      return _buildCompletionScreen(quizTheme);
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(child: Text(l10n.noCardsToStudy)),
      );
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: quizTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            QuizTopBar(
              onClose: () => context.pop(),
              timerText: _formatTime(_timerSeconds),
              isStarred: question.isSaved,
              isInSrs: true,
              onStarTap: () => _toggleStar(),
              onFlagTap: () => _showReportDialog(),
              onChatTap: () => _showComments(),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _currentIndex / _questions.length,
                      backgroundColor: quizTheme.secondaryTextColor.withOpacity(
                        0.1,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_currentIndex + 1}/${_questions.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: quizTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: FlashcardWidget(
                  question: question,
                  isFlipped: _isFlipped,
                  onFlip: () => setState(() => _isFlipped = !_isFlipped),
                ),
              ),
            ),

            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _isFlipped
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: _buildFlipHint(l10n, quizTheme),
              secondChild: _buildGradingSection(l10n, quizTheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlipHint(AppLocalizations l10n, QuizThemeExtension quizTheme) {
    return Container(
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      child: Center(
        child: Column(
          children: [
            Icon(
              Iconsax.eye,
              color: quizTheme.secondaryTextColor.withOpacity(0.3),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.showAnswerToGrade,
              style: TextStyle(
                color: quizTheme.secondaryTextColor.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradingSection(
    AppLocalizations l10n,
    QuizThemeExtension quizTheme,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
              color: quizTheme.secondaryTextColor.withOpacity(0.5),
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
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
    final interval = _predictedIntervals[perf] ?? '--';

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: () => _submitGrade(perf),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  interval,
                  style: TextStyle(
                    color: color.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionScreen(QuizThemeExtension quizTheme) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: quizTheme.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.medal_star,
                  size: 80,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.studyComplete,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: quizTheme.primaryTextColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.studySummary(
                  widget.initialQuestions.length,
                  _formatTime(_timerSeconds),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: quizTheme.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.backToHome,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleStar() async {
    final question = _questions[_currentIndex];
    try {
      final success = await ref
          .read(quizRepositoryProvider)
          .toggleSaveQuestion(question.id);

      if (success && mounted) {
        setState(() {
          //Update the local question object
          _questions[_currentIndex] = question.copyWith(
            isSaved: !question.isSaved,
          );
        });
        AppSnackBars.success(
          context,
          question.isSaved ? 'Question removed' : 'Question saved',
        );
      }
    } catch (e) {
      if (mounted) AppSnackBars.error(context, 'Error toggling save');
    }
  }

  void _showReportDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.reportQuestion),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Incorrect information'),
              onTap: () => _submitReport('Incorrect info'),
            ),
            ListTile(
              title: const Text('Typo or formatting'),
              onTap: () => _submitReport('Typo'),
            ),
            ListTile(
              title: const Text('Other'),
              onTap: () => _submitReport('Other'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport(String reason) async {
    final question = _questions[_currentIndex];
    Navigator.pop(context);
    try {
      await ref
          .read(quizRepositoryProvider)
          .reportQuestion(question.id, reason, null);
      if (mounted) AppSnackBars.success(context, 'Report submitted');
    } catch (e) {
      if (mounted) AppSnackBars.error(context, 'Error submitting report');
    }
  }

  void _showComments() {
    //For now,just show a message
    AppSnackBars.info(context, 'Comments coming soon');
  }
}
