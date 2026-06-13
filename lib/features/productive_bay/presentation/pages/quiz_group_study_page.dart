import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';
import 'package:meducyte_app/features/quiz/presentation/widgets/quiz_option_card.dart';
import 'package:meducyte_app/features/productive_bay/data/providers/study_group_provider.dart';
import 'package:meducyte_app/features/productive_bay/presentation/widgets/quiz_selection_sheet.dart';
import 'package:meducyte_app/shared/widgets/highlightable_text.dart';
import 'package:meducyte_app/features/auth/presentation/widgets/notion_avatar_renderer.dart';
import 'package:collection/collection.dart';
import 'dart:async';
import 'package:skeletonizer/skeletonizer.dart';

class QuizGroupStudyPage extends ConsumerStatefulWidget {
  final String groupId;
  final StudyGroupQuizSession? initialSession;

  const QuizGroupStudyPage({
    super.key,
    required this.groupId,
    this.initialSession,
  });

  @override
  ConsumerState<QuizGroupStudyPage> createState() => _QuizGroupStudyPageState();
}

class _QuizGroupStudyPageState extends ConsumerState<QuizGroupStudyPage> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _answered = false;
  final Set<int> _selectedIndices = {};
  bool _isReady = false;
  bool _isFinished = false;
  int _countdown = 3;
  Timer? _countdownTimer;
  bool _countdownStarted = false;
  int _questionTimerValue = 15;
  Timer? _questionTimer;

  final Map<String, List<HighlightModel>> _highlights = {};
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(activeStudyGroupQuizProvider(widget.groupId)).value ?? widget.initialSession;
      if (session != null) {
        ref.read(studyGroupRepositoryProvider).joinQuizSession(widget.groupId, session.id).catchError((_) {});
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _questionTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  void _startCountdown(String sessionId) {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        if (mounted) setState(() => _countdown--);
      } else {
        if (mounted) {
          final session =
              ref
                  .read(activeStudyGroupQuizProvider(widget.groupId))
                  .asData
                  ?.value ??
              widget.initialSession;
          setState(() {
            _isReady = true;
            _countdown = 0;
          });
          _startQuestionTimer(sessionId, session?.secondsPerQuestion ?? 0);
        }
        timer.cancel();
      }
    });
  }

  void _startQuestionTimer(String sessionId, int seconds) {
    _questionTimer?.cancel();
    if (seconds <= 0) {
      if (mounted) setState(() => _questionTimerValue = 0);
      return;
    }

    //Reset timer to configured value
    if (mounted) setState(() => _questionTimerValue = seconds);

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_questionTimerValue > 0) {
        if (mounted) setState(() => _questionTimerValue--);
      } else {
        timer.cancel();
        final session =
            ref
                .read(activeStudyGroupQuizProvider(widget.groupId))
                .asData
                ?.value ??
            widget.initialSession;
        if (session != null && !_answered && mounted) {
          final currentQuestion = session.questions[_currentQuestionIndex];
          _onOptionSelected(-1, currentQuestion, sessionId);
        }
      }
    });
  }

  void _onOptionSelected(
    int index,
    StudyGroupQuizQuestion question,
    String sessionId,
  ) {
    if (_answered) return;

    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _validateMultipleChoice(
    StudyGroupQuizQuestion question,
    String sessionId,
  ) {
    if (_answered) return;
    _questionTimer?.cancel();
    setState(() {
      _answered = true;
      _checkAndSubmitScore(question, sessionId);
    });
  }

  void _checkAndSubmitScore(StudyGroupQuizQuestion question, String sessionId) {
    final isCorrect =
        _selectedIndices.length == question.correctIndices.length &&
        _selectedIndices.every((i) => question.correctIndices.contains(i));

    if (isCorrect) {
      _score += 500;
      final repo = ref.read(studyGroupRepositoryProvider);
      final myName = ref.read(authControllerProvider).value?.name ?? "Me";
      repo.submitScore(sessionId, myName, _score);
    }
  }

  void _nextQuestion(String sessionId) {
    if (mounted) {
      final session =
          ref
              .read(activeStudyGroupQuizProvider(widget.groupId))
              .asData
              ?.value ??
          widget.initialSession;
      if (session != null) {
        if (_currentQuestionIndex < session.questions.length - 1) {
          setState(() {
            _currentQuestionIndex++;
            _answered = false;
            _selectedIndices.clear();
            _highlights.clear();
          });
          _startQuestionTimer(sessionId, session.secondsPerQuestion);
        } else {
          setState(() => _isFinished = true);
        }
      }
    }
  }

  void _showChat(BuildContext context, String questionId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GroupDiscussionBottomSheet(groupId: widget.groupId),
    );
  }

  void _showQuestionInfo(
    BuildContext context,
    StudyGroupQuizQuestion q,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.questionInfo,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (q.sourceExam != null && q.sourceExam!.isNotEmpty)
              _buildInfoItem(l10n.source, q.sourceExam!),
            if (q.moduleName != null && q.moduleName!.isNotEmpty)
              _buildInfoItem(l10n.module, q.moduleName!),
            if (q.year != null) _buildInfoItem(l10n.year, q.year.toString()),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  void _showClinicalCase(
    BuildContext context,
    AppLocalizations l10n,
    String? caseText,
    String textId,
  ) {
    if (caseText == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Iconsax.document_text, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  l10n.clinicalCase,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: HighlightableText(
                  text: caseText,
                  highlights: _highlights['cc_$textId'] ?? [],
                  style: const TextStyle(fontSize: 16, height: 1.6),
                  onHighlight: (selectedText) =>
                      _addHighlight('cc_$textId', selectedText, caseText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addHighlight(String textId, String selectedText, String fullText) {
    final start = fullText.indexOf(selectedText);
    if (start == -1) return;

    final color = [
      const Color(0x66FFEB3B),
      const Color(0x6666BB6A),
      const Color(0x6642A5F5),
    ][(_highlights[textId]?.length ?? 0) % 3];

    setState(() {
      final current = _highlights[textId] ?? [];
      _highlights[textId] = [
        ...current,
        HighlightModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: selectedText,
          start: start,
          end: start + selectedText.length,
          color: color,
          createdAt: DateTime.now(),
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quizTheme = theme.extension<QuizThemeExtension>()!;
    final sessionAsync = ref.watch(
      activeStudyGroupQuizProvider(widget.groupId),
    );
    final groupAsync = ref.watch(studyGroupProvider(widget.groupId));
    final currentUser = ref.watch(authControllerProvider).asData?.value;

    return groupAsync.when(
      data: (group) {
        if (group == null) return const _GroupNotFoundScreen();
        return sessionAsync.when(
          data: (session) => _buildMainContent(
            quizTheme,
            session ?? widget.initialSession,
            group,
            currentUser,
          ),
          loading: () => Skeletonizer(
            enabled: true,
            child: _buildMainContent(
              quizTheme,
              widget.initialSession ??
                  StudyGroupQuizSession(
                    id: 'dummy',
                    studyGroupId: widget.groupId,
                    quizId: 'dummy',
                    title: 'Chargement...',
                    participantIds: const ['Me'],
                    participantScores: const {'Me': 0},
                    questions: [
                      StudyGroupQuizQuestion(
                        id: 'dummy',
                        text: 'Ceci est une question factice en cours de chargement.',
                        options: const ['Option A', 'Option B', 'Option C', 'Option D'],
                        correctIndices: const [0],
                        explanation: 'Explication factice.',
                      ),
                    ],
                    isActive: true,
                    startTime: DateTime.now(),
                  ),
              group,
              currentUser,
            ),
          ),
          error: (e, s) => Scaffold(body: Center(child: Text("Erreur: $e"))),
        );
      },
      loading: () => Scaffold(
        body: Skeletonizer(
          enabled: true,
          child: _buildMainContent(
            quizTheme,
            widget.initialSession ??
                StudyGroupQuizSession(
                  id: 'dummy',
                  studyGroupId: widget.groupId,
                  quizId: 'dummy',
                  title: 'Chargement...',
                  participantIds: const ['Me'],
                  participantScores: const {'Me': 0},
                  questions: [
                    StudyGroupQuizQuestion(
                      id: 'dummy',
                      text: 'Ceci est une question factice en cours de chargement.',
                      options: const ['Option A', 'Option B', 'Option C', 'Option D'],
                      correctIndices: const [0],
                      explanation: 'Explication factice.',
                    ),
                  ],
                  isActive: true,
                  startTime: DateTime.now(),
                ),
            StudyGroup(
              id: widget.groupId,
              title: 'Groupe d\'étude',
              description: 'Description...',
              membersCount: 0,
              totalPomodoros: 0,
              tags: const [],
              themeColor: Colors.blue,
              icon: Icons.group,
              type: StudyGroupType.qcmBattle,
            ),
            currentUser,
          ),
        ),
      ),
      error: (e, s) => Scaffold(body: Center(child: Text("Erreur: $e"))),
    );
  }

  Widget _buildMainContent(
    QuizThemeExtension quizTheme,
    StudyGroupQuizSession? displaySession,
    StudyGroup group,
    User? currentUser,
  ) {
    final isDiscussion = displaySession?.secondsPerQuestion == 0;

    if (displaySession == null) {
      final dummySession = StudyGroupQuizSession(
        id: 'dummy',
        studyGroupId: widget.groupId,
        quizId: 'dummy',
        title: 'Chargement...',
        participantIds: const ['Me'],
        participantScores: const {'Me': 0},
        questions: [
          StudyGroupQuizQuestion(
            id: 'dummy',
            text: 'Ceci est une question factice en cours de chargement.',
            options: const ['Option A', 'Option B', 'Option C', 'Option D'],
            correctIndices: const [0],
            explanation: 'Explication factice.',
          ),
        ],
        isActive: true,
        startTime: DateTime.now(),
      );
      return Skeletonizer(
        enabled: true,
        child: _buildMainContent(
          quizTheme,
          dummySession,
          group,
          currentUser,
        ),
      );
    }
    final leaderboard = displaySession.participantScores.entries.map((e) {
      final isMe = currentUser != null && e.key == currentUser.name;
      return <String, dynamic>{
        "name": isMe ? context.l10n.you : e.key,
        "score": e.value,
      };
    }).toList();
    leaderboard.sort(
      (a, b) => (b["score"] as int).compareTo(a["score"] as int),
    );

    if (!_isReady) {
      if (!_countdownStarted) {
        _countdownStarted = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startCountdown(displaySession.id);
        });
      }
      return _buildWaitingRoom(quizTheme, displaySession);
    }

    if (_isFinished) {
      return _buildVictoryScreen(quizTheme, leaderboard);
    }

    final questions = displaySession.questions;
    final currentQuestion = questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: quizTheme.backgroundColor,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              group.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: quizTheme.primaryTextColor,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDiscussion ? AppColors.primary : Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isDiscussion ? "Session d'Étude" : context.l10n.liveBattle,
                  style: TextStyle(
                    fontSize: 10,
                    color: (isDiscussion ? AppColors.primary : Colors.green)
                        .withOpacity(0.8),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Iconsax.close_square, color: quizTheme.primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (group.isAdmin)
            IconButton(
              icon: Icon(Iconsax.setting_5, color: quizTheme.primaryTextColor),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => QuizSelectionSheet(
                    group: group,
                    editingSession: displaySession,
                  ),
                );
              },
            ),
          IconButton(
            icon: Icon(Iconsax.info_circle, color: quizTheme.primaryTextColor),
            onPressed: () => _showQuestionInfo(
              context,
              displaySession.questions[_currentQuestionIndex],
              context.l10n,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildParticipantList(quizTheme, leaderboard, isDiscussion),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressIndicator(
                    quizTheme,
                    questions.length,
                    isDiscussion,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (currentQuestion.clinicalCase != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildActionChip(
                            icon: Iconsax.document_text,
                            label: context.l10n.clinicalCase,
                            onTap: () => _showClinicalCase(
                              context,
                              context.l10n,
                              currentQuestion.clinicalCase,
                              currentQuestion.id,
                            ),
                            color: AppColors.primary,
                          ),
                        ),
                      _buildActionChip(
                        icon: Iconsax.messages_3,
                        label: "Discussion",
                        onTap: () => _showChat(context, currentQuestion.id),
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildQuestionCard(quizTheme, currentQuestion),
                  const SizedBox(height: 32),
                  ...List.generate(
                    currentQuestion.options.length,
                    (index) => _buildOptionCard(
                      index,
                      quizTheme,
                      currentQuestion,
                      displaySession.id,
                    ),
                  ),
                  if (!_answered && _selectedIndices.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => _validateMultipleChoice(
                            currentQuestion,
                            displaySession.id,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Valider mes réponses",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_answered) ...[
                    _buildExplanationCard(quizTheme, currentQuestion),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _nextQuestion(displaySession.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentQuestionIndex < questions.length - 1
                              ? "Question suivante"
                              : "Terminer le duel",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (displaySession.secondsPerQuestion == 0) ...[
                    _buildLiveInteractionHeader(quizTheme),
                    const SizedBox(height: 8),
                    _buildLiveInteraction(quizTheme, widget.groupId),
                  ],
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveInteractionHeader(QuizThemeExtension quizTheme) {
    return Row(
      children: [
        const Icon(Iconsax.messages_3, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          "Discussion en direct",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: quizTheme.primaryTextColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantList(
    QuizThemeExtension quizTheme,
    List<Map<String, dynamic>> leaderboard,
    bool isDiscussion,
  ) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: quizTheme.statCardBackgroundColor.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: quizTheme.secondaryTextColor.withOpacity(0.05),
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: leaderboard.length,
        itemBuilder: (context, index) {
          final user = leaderboard[index];
          final isMe = user["name"] == context.l10n.you;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : quizTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isMe
                    ? AppColors.primary
                    : quizTheme.secondaryTextColor.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                if (!isDiscussion) ...[
                  Text(
                    "#${index + 1}",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isMe ? Colors.white : AppColors.primary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  user["name"],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isMe ? Colors.white : quizTheme.primaryTextColor,
                    fontSize: 12,
                  ),
                ),
                if (!isDiscussion) ...[
                  const SizedBox(width: 8),
                  Text(
                    "${user["score"]}",
                    style: TextStyle(
                      color: isMe
                          ? Colors.white.withOpacity(0.9)
                          : quizTheme.secondaryTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator(
    QuizThemeExtension quizTheme,
    int total,
    bool isDiscussion,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.questionOf(_currentQuestionIndex + 1, total),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.1,
                color: quizTheme.secondaryTextColor,
              ),
            ),
            if (!isDiscussion)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    if (_questionTimerValue > 0) ...[
                      Text(
                        "$_questionTimerValue",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: _questionTimerValue < 5
                              ? Colors.red
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      context.l10n.yourScore(_score),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / total,
            backgroundColor: quizTheme.secondaryTextColor.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(
    QuizThemeExtension quizTheme,
    StudyGroupQuizQuestion question,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: quizTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: quizTheme.secondaryTextColor.withOpacity(0.05),
        ),
      ),
      child: HighlightableText(
        text: question.text,
        highlights: _highlights[question.id] ?? [],
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: quizTheme.primaryTextColor,
          height: 1.5,
        ),
        onHighlight: (text) => _addHighlight(question.id, text, question.text),
      ),
    );
  }

  Widget _buildOptionCard(
    int index,
    QuizThemeExtension quizTheme,
    StudyGroupQuizQuestion question,
    String sessionId,
  ) {
    final option = question.options[index];
    final isCorrect = question.correctIndices.contains(index);
    final isSelected = _selectedIndices.contains(index);

    OptionState state = OptionState.idle;
    if (_answered) {
      if (isCorrect && isSelected) {
        state = OptionState.correct;
      } else if (isCorrect && !isSelected) {
        state = OptionState.missed;
      } else if (!isCorrect && isSelected) {
        state = OptionState.incorrect;
      }
    } else if (isSelected) {
      state = OptionState.selected;
    }

    return QuizOptionCard(
      label: String.fromCharCode(65 + index),
      text: option,
      state: state,
      highlights: _highlights['prop_${question.id}_$index'] ?? [],
      onHighlight: (text) =>
          _addHighlight('prop_${question.id}_$index', text, option),
      onTap: () => _onOptionSelected(index, question, sessionId),
    );
  }

  Widget _buildLiveInteraction(QuizThemeExtension quizTheme, String groupId) {
    final messagesAsync = ref.watch(studyGroupMessagesProvider(groupId));
    final groupAsync = ref.watch(studyGroupProvider(groupId));
    final group = groupAsync.value;
    final isAdmin = group?.isAdmin ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Text(
                        context.l10n.beFirstToEncourage,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: quizTheme.secondaryTextColor.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final recentMessages = messages.reversed.take(10).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: recentMessages.length,
                  itemBuilder: (context, index) {
                    final m = recentMessages[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? AppColors.dividerDark
                              : AppColors.dividerLight,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(
                            builder: (context) {
                              final group = ref.watch(studyGroupProvider(widget.groupId)).value;
                              final senderUser = group?.members.firstWhereOrNull((u) => u.id.toString() == m.senderId);
                              final avatarKey = senderUser?.avatarKey ?? 'avatar_1';
                              return NotionAvatarRenderer(avatarKey: avatarKey, size: 28);
                            },
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      m.senderName.toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 11,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    if (m.isEdited) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        "(${context.l10n.edited})",
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.grey.withOpacity(0.7),
                                          fontStyle: FontStyle.italic,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  m.text,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                    color: quizTheme.primaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.more_vert,
                                  size: 18,
                                  color: Colors.grey.withOpacity(0.7),
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditMessageDialog(context, m);
                                  } else if (value == 'delete') {
                                    _confirmDeleteMessage(context, m);
                                  } else if (value == 'report') {
                                    _showReportMessageDialog(context, m);
                                  }
                                },
                                itemBuilder: (context) => [
                                  if (m.isMine)
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Iconsax.edit,
                                            size: 18,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(context.l10n.edit),
                                        ],
                                      ),
                                    ),
                                  if (m.isMine || isAdmin)
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Iconsax.trash,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(context.l10n.delete),
                                        ],
                                      ),
                                    ),
                                  if (!m.isMine)
                                    PopupMenuItem(
                                      value: 'report',
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Iconsax.danger,
                                            size: 18,
                                            color: Colors.orange,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(context.l10n.reportError),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                _timeAgo(m.timestamp),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text("Erreur: $e")),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(
                    color: quizTheme.primaryTextColor,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: context.l10n.sendEncouragement,
                    hintStyle: TextStyle(
                      color: quizTheme.secondaryTextColor.withOpacity(0.6),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.03),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () async {
                  if (_messageController.text.trim().isEmpty) return;
                  final text = _messageController.text.trim();
                  _messageController.clear();

                  final repo = ref.read(studyGroupRepositoryProvider);
                  await repo.sendMessage(
                    groupId,
                    StudyGroupMessage(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      senderId: "me",
                      senderName: context.l10n.you,
                      text: text,
                      timestamp: DateTime.now(),
                    ),
                  );
                  ref.invalidate(studyGroupMessagesProvider(groupId));
                },
                icon: const Icon(Iconsax.send_1, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationCard(
    QuizThemeExtension quizTheme,
    StudyGroupQuizQuestion question,
  ) {
    final isCorrect =
        _selectedIndices.length == question.correctIndices.length &&
        _selectedIndices.every((i) => question.correctIndices.contains(i));
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: quizTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCorrect
              ? Colors.green.withOpacity(0.2)
              : Colors.red.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Iconsax.tick_circle : Iconsax.close_circle,
                color: isCorrect ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                isCorrect ? context.l10n.excellent : context.l10n.oopsNotQuite,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: isCorrect ? Colors.green : Colors.red,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question.explanation,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: quizTheme.primaryTextColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingRoom(
    QuizThemeExtension quizTheme,
    StudyGroupQuizSession session,
  ) {
    return Scaffold(
      backgroundColor: quizTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                "$_countdown",
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              context.l10n.battleAboutToStart,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: quizTheme.primaryTextColor,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.getReadyTenQuestions,
              style: TextStyle(
                color: quizTheme.secondaryTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: quizTheme.statCardBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Iconsax.user_tag,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    context.l10n.participantsReady(
                      session.participantScores.length,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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

  Widget _buildVictoryScreen(
    QuizThemeExtension quizTheme,
    List<Map<String, dynamic>> leaderboard,
  ) {
    return Scaffold(
      backgroundColor: quizTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Iconsax.cup, color: Colors.amber, size: 80),
              const SizedBox(height: 24),
              Text(
                context.l10n.battleFinished,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: quizTheme.primaryTextColor,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView.builder(
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    final user = leaderboard[index];
                    final isFirst = index == 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isFirst
                            ? AppColors.primary.withOpacity(0.1)
                            : quizTheme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isFirst
                              ? AppColors.primary
                              : quizTheme.secondaryTextColor.withOpacity(0.05),
                          width: isFirst ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: isFirst
                                ? AppColors.primary
                                : Colors.grey,
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              user["name"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            "${user["score"]}XP",
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    context.l10n.backToGroup,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final local = dateTime.toLocal();
    final diff = DateTime.now().difference(local);

    if (diff.inSeconds < 60) return "Maintenant";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m";
    if (diff.inHours < 24) return "${diff.inHours}h";
    if (diff.inDays < 7) return "${diff.inDays}j";
    return "${local.day}/${local.month}";
  }

  void _showEditMessageDialog(BuildContext context, StudyGroupMessage message) {
    final controller = TextEditingController(text: message.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.edit),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: context.l10n.editNote,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              try {
                await ref
                    .read(studyGroupRepositoryProvider)
                    .editMessage(message.id, controller.text.trim());
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(studyGroupMessagesProvider(widget.groupId));
              } catch (e) {
                if (context.mounted) {
                  AppSnackBars.error(context, e);
                }
              }
            },
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteMessage(
    BuildContext context,
    StudyGroupMessage message,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.confirmDelete),
        content: Text(context.l10n.deleteCommentConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(studyGroupRepositoryProvider).deleteMessage(message.id);
        ref.invalidate(studyGroupMessagesProvider(widget.groupId));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Message supprimé'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackBars.error(context, e);
        }
      }
    }
  }

  void _showReportMessageDialog(
    BuildContext context,
    StudyGroupMessage message,
  ) {
    final reasons = [
      context.l10n.reasonInaccurate,
      context.l10n.reasonUnclear,
      context.l10n.reasonOther,
    ];
    String selectedReason = reasons.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.reportError),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: reasons
                .map(
                  (r) => RadioListTile<String>(
                    title: Text(r),
                    value: r,
                    groupValue: selectedReason,
                    onChanged: (val) => setState(() => selectedReason = val!),
                  ),
                )
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await ref
                      .read(studyGroupRepositoryProvider)
                      .reportMessage(message.id, selectedReason);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.reportSent)),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    AppSnackBars.error(context, e);
                  }
                }
              },
              child: Text(context.l10n.sendReport),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupNotFoundScreen extends StatefulWidget {
  const _GroupNotFoundScreen();

  @override
  State<_GroupNotFoundScreen> createState() => _GroupNotFoundScreenState();
}

class _GroupNotFoundScreenState extends State<_GroupNotFoundScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text(
                'Groupe non trouvé',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.of(context).maybePop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _GroupDiscussionBottomSheet extends ConsumerStatefulWidget {
  final String groupId;
  const _GroupDiscussionBottomSheet({required this.groupId});

  @override
  ConsumerState<_GroupDiscussionBottomSheet> createState() =>
      _GroupDiscussionBottomSheetState();
}

class _GroupDiscussionBottomSheetState
    extends ConsumerState<_GroupDiscussionBottomSheet> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _timeAgo(DateTime dateTime) {
    final local = dateTime.toLocal();
    final diff = DateTime.now().difference(local);

    if (diff.inSeconds < 60) return "Maintenant";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m";
    if (diff.inHours < 24) return "${diff.inHours}h";
    if (diff.inDays < 7) return "${diff.inDays}j";
    return "${local.day}/${local.month}";
  }

  void _showEditMessageDialog(BuildContext context, StudyGroupMessage message) {
    final controller = TextEditingController(text: message.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.edit),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: context.l10n.editNote,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              try {
                await ref
                    .read(studyGroupRepositoryProvider)
                    .editMessage(message.id, controller.text.trim());
                if (context.mounted) Navigator.pop(context);
                ref.invalidate(studyGroupMessagesProvider(widget.groupId));
              } catch (e) {
                if (context.mounted) {
                  AppSnackBars.error(context, e);
                }
              }
            },
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteMessage(
    BuildContext context,
    StudyGroupMessage message,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.confirmDelete),
        content: Text(context.l10n.deleteCommentConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(studyGroupRepositoryProvider).deleteMessage(message.id);
        ref.invalidate(studyGroupMessagesProvider(widget.groupId));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Message supprimé'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackBars.error(context, e);
        }
      }
    }
  }

  void _showReportMessageDialog(
    BuildContext context,
    StudyGroupMessage message,
  ) {
    final reasons = [
      context.l10n.reasonInaccurate,
      context.l10n.reasonUnclear,
      context.l10n.reasonOther,
    ];
    String selectedReason = reasons.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.reportError),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: reasons
                .map(
                  (r) => RadioListTile<String>(
                    title: Text(r),
                    value: r,
                    groupValue: selectedReason,
                    onChanged: (val) => setState(() => selectedReason = val!),
                  ),
                )
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await ref
                      .read(studyGroupRepositoryProvider)
                      .reportMessage(message.id, selectedReason);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.reportSent)),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    AppSnackBars.error(context, e);
                  }
                }
              },
              child: Text(context.l10n.sendReport),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final messagesAsync = ref.watch(studyGroupMessagesProvider(widget.groupId));
    final groupAsync = ref.watch(studyGroupProvider(widget.groupId));
    final group = groupAsync.value;
    final isAdmin = group?.isAdmin ?? false;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: quizTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: quizTheme.secondaryTextColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Discussion du Groupe",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: quizTheme.primaryTextColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Iconsax.close_circle,
                    color: quizTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Text(
                        context.l10n.beFirstToEncourage,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: quizTheme.secondaryTextColor.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? AppColors.dividerDark
                              : AppColors.dividerLight,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(
                            builder: (context) {
                              final group = ref.watch(studyGroupProvider(widget.groupId)).value;
                              final senderUser = group?.members.firstWhereOrNull((u) => u.id.toString() == m.senderId);
                              final avatarKey = senderUser?.avatarKey ?? 'avatar_1';
                              return NotionAvatarRenderer(avatarKey: avatarKey, size: 28);
                            },
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      m.senderName.toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 11,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    if (m.isEdited) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        "(${context.l10n.edited})",
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.grey.withOpacity(0.7),
                                          fontStyle: FontStyle.italic,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  m.text,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                    color: quizTheme.primaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.more_vert,
                                  size: 18,
                                  color: Colors.grey.withOpacity(0.7),
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditMessageDialog(context, m);
                                  } else if (value == 'delete') {
                                    _confirmDeleteMessage(context, m);
                                  } else if (value == 'report') {
                                    _showReportMessageDialog(context, m);
                                  }
                                },
                                itemBuilder: (context) => [
                                  if (m.isMine)
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Iconsax.edit,
                                            size: 18,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(context.l10n.edit),
                                        ],
                                      ),
                                    ),
                                  if (m.isMine || isAdmin)
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Iconsax.trash,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(context.l10n.delete),
                                        ],
                                      ),
                                    ),
                                  if (!m.isMine)
                                    PopupMenuItem(
                                      value: 'report',
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Iconsax.danger,
                                            size: 18,
                                            color: Colors.orange,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(context.l10n.reportError),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                _timeAgo(m.timestamp),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text("Erreur: $e")),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(
                      color: quizTheme.primaryTextColor,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: context.l10n.sendEncouragement,
                      hintStyle: TextStyle(
                        color: quizTheme.secondaryTextColor.withOpacity(0.6),
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.03),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () async {
                    if (_messageController.text.trim().isEmpty) return;
                    final text = _messageController.text.trim();
                    _messageController.clear();

                    final repo = ref.read(studyGroupRepositoryProvider);
                    await repo.sendMessage(
                      widget.groupId,
                      StudyGroupMessage(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        senderId: "me",
                        senderName: context.l10n.you,
                        text: text,
                        timestamp: DateTime.now(),
                      ),
                    );
                    ref.invalidate(studyGroupMessagesProvider(widget.groupId));
                  },
                  icon: const Icon(Iconsax.send_1, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
