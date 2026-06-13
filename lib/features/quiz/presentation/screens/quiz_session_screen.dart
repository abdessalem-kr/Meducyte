import 'package:meducyte_app/export.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';
import 'package:meducyte_app/features/quiz/presentation/widgets/quiz_progress_bar.dart';
import 'package:meducyte_app/features/quiz/presentation/widgets/quiz_option_card.dart';
import 'package:meducyte_app/features/quiz/presentation/widgets/quiz_bottom_actions.dart';
import 'package:meducyte_app/features/quiz/presentation/widgets/quiz_comment_bottom_sheet.dart';
import 'package:meducyte_app/features/quiz/presentation/widgets/quiz_report_bottom_sheet.dart';
import 'package:meducyte_app/features/quiz/presentation/widgets/quiz_save_bottom_sheet.dart';
import 'package:meducyte_app/features/quiz/presentation/widgets/note_editor_widgets.dart';
import 'package:meducyte_app/features/quiz/presentation/screens/quiz_result_screen.dart';
import 'package:meducyte_app/shared/widgets/subscription_gate.dart';
import 'package:meducyte_app/shared/widgets/highlightable_text.dart';
import 'package:meducyte_app/shared/widgets/reading_settings_bottom_sheet.dart';
import '../widgets/quiz_export_bottom_sheet.dart';

class QuizSessionScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final QuizFilters filters;
  final String? initialQuestionId;
  final String? initialCommentId;

  const QuizSessionScreen({
    super.key,
    this.sessionId = 'new',
    required this.filters,
    this.initialQuestionId,
    this.initialCommentId,
  });

  @override
  ConsumerState<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends ConsumerState<QuizSessionScreen> {
  bool _isExiting = false;

  @override
  Widget build(BuildContext context) {
    final isCurrent = widget.sessionId == 'current';
    final savedSessionAsync = ref.watch(savedQuizSessionProvider);
    final fetchSessionAsync = ref.watch(quizSessionFetcherProvider(widget.filters));

    final sessionAsync = isCurrent ? savedSessionAsync : fetchSessionAsync;
    final quizState = ref.watch(quizSessionProvider);
    final quizNotifier = ref.read(quizSessionProvider.notifier);

    final isSubscriber =
        ref.watch(authControllerProvider).value?.isSubscriber ?? false;

    return sessionAsync.when(
      loading: () {
        final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
        return Skeletonizer(
          enabled: true,
          child: Scaffold(
            backgroundColor: quizTheme.backgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  QuizTopBar(
                    onClose: () => context.pop(),
                    timerText: "00:00",
                    isStarred: false,
                    onStarTap: () {},
                    onStarLongPress: () {},
                    onChatTap: () {},
                    onFlagTap: () {},
                    onShareTap: () {},
                    onFontSizeTap: () {},
                  ),
                  QuizProgressBar(
                    isTrial: false,
                    trialQuestionIndex: 0,
                    current: 0,
                    total: 10,
                    onInfoTap: () {},
                    onQuestionTap: () {},
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: quizTheme.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: quizTheme.secondaryTextColor
                                      .withOpacity(0.05),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.loadingQuestion,
                                style: TextStyle(
                                  fontSize: 18,
                                  height: 1.6,
                                  fontWeight: FontWeight.w500,
                                  color: quizTheme.primaryTextColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              return QuizOptionCard(
                                label: String.fromCharCode(65 + index),
                                text: AppLocalizations.of(context)!.dummyLoadingOption(index + 1),
                                state: OptionState.idle,
                                fontSize: 16,
                                highlights: const [],
                                onHighlight: (_) {},
                                onNote: (_) {},
                                onHighlightTap: (_) {},
                                onTap: () {},
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  QuizBottomActions(
                    onPrevious: null,
                    onPrimary: () {},
                    primaryLabel: AppLocalizations.of(context)!.verify,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (data) {
        final QuizSession? session = isCurrent
            ? (data as SavedQuizSession?)?.session
            : (data as QuizSession);

        if (session == null || session.questions.isEmpty) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            appBar: AppBar(title: const Text('Quiz')),
            body: Center(child: Text(l10n.noQuestionsFound)),
          );
        }

        final l10n = AppLocalizations.of(context)!;

        void handleExitConfirmation() async {
          final result = await _showExitConfirmationDialog(context);
          if (result == null) return;

          if (result == 'save') {
            await quizNotifier.saveSessionForLater(session);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.sessionSavedSuccess),
                  duration: const Duration(seconds: 2),
                ),
              );
              setState(() {
                _isExiting = true;
              });
              context.pop();
            }
          } else if (result == 'abandon') {
            await quizNotifier.abandonSession();
            if (context.mounted) {
              setState(() {
                _isExiting = true;
              });
              context.pop();
            }
          }
        }

        //Initialize quiz if not already done
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!quizState.isInitialized && !quizState.isFinished) {
            if (isCurrent && data is SavedQuizSession) {
              quizNotifier.initialize(
                data.session,
                timeSeconds: data.timeSeconds,
                showFeedback: data.showFeedback,
                selectedOptionIds: data.selectedOptionIds,
              );
            } else {
              quizNotifier.initialize(session);
            }
            quizNotifier.startTimer();

            //Jump to initial question if provided
            if (widget.initialQuestionId != null) {
              final targetId = int.tryParse(widget.initialQuestionId!);
              if (targetId != null) {
                final index = session.questions.indexWhere(
                  (q) => q.id == targetId,
                );
                if (index != -1) {
                  quizNotifier.jumpTo(index, session.questions);

                  //Show chat after a slight delay to allow jump animation/rebuild
                  if (widget.initialCommentId != null) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (context.mounted) {
                        _showChat(
                          context,
                          session.questions[index],
                          initialCommentId: widget.initialCommentId,
                        );
                      }
                    });
                  }
                }
              }
            }
          }
        });

        Widget mainContent;

        if (quizState.isFinished) {
          if (quizState.isExplore) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) context.pop();
            });
            mainContent = const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            mainContent = QuizResultScreen(
              session: session,
              questions: session.questions,
              isPractice: session.filters['isPractice'] ?? true,
            );
          }
        } else {
          final questions = session.questions;
          final q = questions[quizState.currentQuestionIndex < questions.length ? quizState.currentQuestionIndex : 0];
          final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
          final settings = ref.watch(appSettingsProvider);

          double quizFontScale = 1.0;
          if (settings.quizFontSize == 'Small' ||
              settings.quizFontSize == 'Petit') {
            quizFontScale = 0.85;
          } else if (settings.quizFontSize == 'Large' ||
              settings.quizFontSize == 'Grand') {
            quizFontScale = 1.25;
          }

          mainContent = Scaffold(
            backgroundColor: quizTheme.backgroundColor,
            body: SafeArea(
              child: SubscriptionGate(
                isEnabled: !isSubscriber && quizState.currentQuestionIndex >= 10,
                child: Column(
                  children: [
                    QuizTopBar(
                      onClose: handleExitConfirmation,
                      timerText: _formatTime(quizState.timeSeconds),
                      isStarred: quizState.isStarred,
                      onStarTap: () => quizNotifier.toggleSave(q.id),
                      onStarLongPress: () => _showSaveToFolder(context, q),
                      onChatTap: () => _showChat(context, q),
                      onFlagTap: () => _showReport(context, q),
                      onShareTap: () => _shareQuestion(context, q),
                      onFontSizeTap: () => _showFontSizeSettings(context, ref),
                    ),
                    QuizProgressBar(
                      isTrial: !isSubscriber,
                      trialQuestionIndex: quizState.currentQuestionIndex,
                      current: quizState.currentQuestionIndex,
                      total: questions.length,
                      onInfoTap: () => _showQuestionInfo(context, q, l10n),
                      onQuestionTap: () => _showQuestionNavigator(
                        context,
                        questions,
                        quizState,
                        quizNotifier,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          if (q.clinicalCase != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 24,
                                right: 24,
                                bottom: 12,
                              ),
                              child: GestureDetector(
                                onTap: () => _showClinicalCase(
                                  context,
                                  q.clinicalCase!,
                                  l10n,
                                  quizNotifier,
                                  quizState,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Iconsax.document_text,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.clinicalCase,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: quizTheme.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: quizTheme.secondaryTextColor
                                      .withOpacity(0.05),
                                ),
                              ),
                              child: HighlightableText(
                                text: q.text,
                                highlights:
                                    quizState.highlights[q.id.toString()] ?? [],
                                style: TextStyle(
                                  fontSize: 18 * quizFontScale,
                                  height: 1.6,
                                  fontWeight: FontWeight.w500,
                                  color: quizTheme.primaryTextColor,
                                ),
                                onHighlight: (selectedText) {
                                  _showColorPickerAndHighlight(
                                    context,
                                    q,
                                    selectedText,
                                    quizNotifier,
                                    fullText: q.text,
                                  );
                                },
                                onNote: (selectedText) {
                                  _showNoteEditor(
                                    context,
                                    q,
                                    selectedText,
                                    quizNotifier,
                                    fullText: q.text,
                                  );
                                },
                                onHighlightTap: (highlight) {
                                  _showHighlightActions(
                                    context,
                                    q,
                                    highlight,
                                    fullText: q.text,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (quizState.showFeedback) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                              child: _buildCorrectionStatus(q, quizState),
                            ),
                          ],
                          const SizedBox(height: 12),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: q.propositions.length,
                            itemBuilder: (context, index) {
                              final prop = q.propositions[index];
                              final isSelected = quizState.selectedOptionIds
                                  .contains(prop.id);
                              final isCorrect = prop.isCorrect;
                              final showResults = quizState.showFeedback;

                              OptionState state = OptionState.idle;
                              if (showResults) {
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
                                label: _getOptionLabel(index),
                                text: prop.text,
                                state: state,
                                fontSize: 16 * quizFontScale,
                                highlights:
                                    quizState.highlights['prop_${prop.id}'] ??
                                    [],
                                onHighlight: (selectedText) {
                                  _showColorPickerAndHighlight(
                                    context,
                                    q,
                                    selectedText,
                                    quizNotifier,
                                    propositionId: prop.id,
                                    fullText: prop.text,
                                  );
                                },
                                onNote: (selectedText) {
                                  _showNoteEditor(
                                    context,
                                    q,
                                    selectedText,
                                    quizNotifier,
                                    propositionId: prop.id,
                                    fullText: prop.text,
                                  );
                                },
                                onHighlightTap: (highlight) {
                                  _showHighlightActions(
                                    context,
                                    q,
                                    highlight,
                                    propositionId: prop.id,
                                    fullText: prop.text,
                                  );
                                },
                                onTap: () => quizNotifier.toggleOption(prop.id),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  QuizBottomActions(
                    onPrevious: quizState.currentQuestionIndex > 0
                        ? () => quizNotifier.previous(questions)
                        : null,
                    onPrimary: () {
                      if (!quizState.showFeedback) {
                        quizNotifier.submit(q);
                      } else if (quizState.currentQuestionIndex <
                          questions.length - 1) {
                        quizNotifier.next(questions);
                      } else {
                        quizNotifier.finishQuiz(session);
                      }
                    },
                    primaryLabel: !quizState.showFeedback
                        ? l10n.verify
                        : (quizState.currentQuestionIndex < questions.length - 1
                              ? l10n.nextQuestion
                              : l10n.finishQuiz),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return PopScope(
        canPop: _isExiting || quizState.isFinished,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) {
            ref.read(quizSessionProvider.notifier).resetQuiz();
            return;
          }
          handleExitConfirmation();
        },
        child: mainContent,
      );
    },
  );
}

  Future<String?> _showExitConfirmationDialog(BuildContext context) {
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final l10n = AppLocalizations.of(context)!;
    
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: quizTheme.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: quizTheme.secondaryTextColor.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.info_circle,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.quitQuizTitle,
                  style: TextStyle(
                    color: quizTheme.primaryTextColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.quitQuizBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: quizTheme.secondaryTextColor,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, 'save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.saveAndQuit,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, 'abandon'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.quitWithoutSaving,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, null),
                        style: TextButton.styleFrom(
                          foregroundColor: quizTheme.secondaryTextColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          l10n.cancel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final mins = (seconds / 60).floor();
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getOptionLabel(int index) {
    return String.fromCharCode(65 + index);
  }

  Widget _buildCorrectionStatus(Question q, QuizSessionState state) {
    final result = state.results[q.id];
    final isCorrect = result?.isCorrect ?? false;
    final score = result?.score ?? 0.0;

    final l10n = AppLocalizations.of(context)!;
    String statusText = isCorrect ? l10n.correct : l10n.incorrect;
    if (!isCorrect && score > 0) statusText = l10n.partiallyCorrect;

    final Color statusColor = isCorrect
        ? Colors.green
        : (score > 0 ? Colors.orange : Colors.red);

    final correctLabels = <String>[];
    for (int i = 0; i < q.propositions.length; i++) {
      if (q.propositions[i].isCorrect) {
        correctLabels.add(_getOptionLabel(i));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (correctLabels.isNotEmpty) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child: Text(
                  correctLabels.join(''),
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (_getCorrectionSummary(q, state).isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            _getCorrectionSummary(q, state),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  String _getCorrectionSummary(Question q, QuizSessionState state) {
    final result = state.results[q.id];
    if (result != null &&
        result.explanation != null &&
        result.explanation!.isNotEmpty) {
      return result.explanation!;
    }
    return '';
  }

  void _showFontSizeSettings(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Consumer(
        builder: (context, ref, _) {
          final settings = ref.watch(appSettingsProvider);
          return ReadingSettingsBottomSheet(
            title: l10n.quizFontSizeTitle,
            currentSize: settings.quizFontSize,
            onSizeChanged: (newSize) {
              ref.read(appSettingsProvider.notifier).setQuizFontSize(newSize);
            },
          );
        },
      ),
    );
  }

  void _showChat(BuildContext context, Question q, {String? initialCommentId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuizCommentBottomSheet(
        questionId: q.id.toString(),
        initialCommentId: initialCommentId,
      ),
    );
  }

  void _showQuestionInfo(
    BuildContext context,
    Question q,
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
            Text(
              l10n.questionInfo,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (q.sourceExam != null)
              _buildInfoItem(l10n.source, q.sourceExam!),
            if (q.lessonTitle != null)
              _buildInfoItem(l10n.lesson, q.lessonTitle!),
            if (q.moduleName != null)
              _buildInfoItem(l10n.module, q.moduleName!),
            if (q.year != null) _buildInfoItem(l10n.year, q.year.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showClinicalCase(
    BuildContext context,
    ClinicalCase clinicalCase,
    AppLocalizations l10n,
    QuizSessionNotifier quizNotifier,
    QuizSessionState quizState,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final currentQuizState = ref.watch(quizSessionProvider);
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
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
                      text: clinicalCase.text,
                      highlights:
                          currentQuizState
                              .highlights['cc_${clinicalCase.id}'] ??
                          [],
                      style: const TextStyle(fontSize: 16, height: 1.6),
                      onHighlight: (selectedText) {
                        _showColorPickerAndHighlight(
                          context,
                          null, //No Question needed for CC
                          selectedText,
                          quizNotifier,
                          clinicalCaseId: clinicalCase.id,
                          fullText: clinicalCase.text,
                        );
                      },
                      onNote: (selectedText) {
                        _showNoteEditor(
                          context,
                          null, //No Question needed for CC
                          selectedText,
                          quizNotifier,
                          clinicalCaseId: clinicalCase.id,
                          fullText: clinicalCase.text,
                        );
                      },
                      onHighlightTap: (highlight) {
                        _showHighlightActions(
                          context,
                          null, //No Question needed for CC
                          highlight,
                          clinicalCaseId: clinicalCase.id,
                          fullText: clinicalCase.text,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showReport(BuildContext context, Question q) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuizReportBottomSheet(questionId: q.id.toString()),
    );
  }

  void _showSaveToFolder(BuildContext context, Question q) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuizSaveBottomSheet(questionId: q.id),
    );
  }

  void _shareQuestion(BuildContext context, Question q) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          QuizExportBottomSheet(question: q, category: q.moduleName),
    );
  }

  void _showQuestionNavigator(
    BuildContext context,
    List<Question> questions,
    QuizSessionState quizState,
    QuizSessionNotifier quizNotifier,
  ) {
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final primaryColor = Theme.of(context).primaryColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: quizTheme.backgroundColor,
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
                  color: quizTheme.secondaryTextColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.questionNavigation,
              style: TextStyle(
                color: quizTheme.primaryTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final isCurrent = index == quizState.currentQuestionIndex;
                  final isAnswered = quizState.userAnswers.containsKey(
                    questions[index].id,
                  );
                  final result = quizState.results[questions[index].id];

                  Color bgColor;
                  Color textColor;
                  if (isCurrent) {
                    bgColor = primaryColor;
                    textColor = Colors.white;
                  } else if (result != null) {
                    bgColor = result.isCorrect
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2);
                    textColor = result.isCorrect ? Colors.green : Colors.red;
                  } else if (isAnswered) {
                    bgColor = primaryColor.withOpacity(0.15);
                    textColor = primaryColor;
                  } else {
                    bgColor = quizTheme.secondaryTextColor.withOpacity(0.08);
                    textColor = quizTheme.secondaryTextColor;
                  }

                  return InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      quizNotifier.jumpTo(index, questions);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: isCurrent
                            ? Border.all(color: primaryColor, width: 2)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static const List<Color> _highlightColors = [
    Color(0x66FFEB3B), //Yellow
    Color(0x6666BB6A), //Green
    Color(0x6642A5F5), //Blue
    Color(0x66EF5350), //Red
    Color(0x66AB47BC), //Purple
    Color(0x66FF7043), //Orange
    Color(0x6626C6DA), //Cyan
    Color(0x66EC407A), //Pink
  ];

  void _showColorPickerAndHighlight(
    BuildContext context,
    Question? q,
    String selectedText,
    QuizSessionNotifier quizNotifier, {
    int? propositionId,
    int? clinicalCaseId,
    String? fullText,
  }) {
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    String textId = '';
    if (propositionId != null) {
      textId = 'prop_$propositionId';
    } else if (clinicalCaseId != null) {
      textId = 'cc_$clinicalCaseId';
    } else if (q != null) {
      textId = q.id.toString();
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: quizTheme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.highlight,
              style: TextStyle(
                color: quizTheme.primaryTextColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _highlightColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    final sourceText = fullText ?? '';
                    final start = sourceText.indexOf(selectedText);
                    if (start != -1) {
                      quizNotifier.addHighlight(
                        q?.id ?? 0,
                        textId,
                        selectedText,
                        start,
                        start + selectedText.length,
                        color,
                        clinicalCaseId: clinicalCaseId,
                      );
                    }
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: quizTheme.secondaryTextColor.withOpacity(0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showNoteEditor(
    BuildContext context,
    Question? q,
    String selectedText,
    QuizSessionNotifier quizNotifier, {
    int? propositionId,
    int? clinicalCaseId,
    String? fullText,
  }) {
    String textId = '';
    if (propositionId != null) {
      textId = 'prop_$propositionId';
    } else if (clinicalCaseId != null) {
      textId = 'cc_$clinicalCaseId';
    } else if (q != null) {
      textId = q.id.toString();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NoteEditorBottomSheet(
        initialValue: '',
        title: AppLocalizations.of(context)!.addNote,
        contextText: selectedText,
        onSave: (content) {
          final sourceText = fullText ?? '';
          final start = sourceText.indexOf(selectedText);
          if (start != -1) {
            quizNotifier.addHighlight(
              q?.id ?? 0,
              textId,
              selectedText,
              start,
              start + selectedText.length,
              Colors.blue.withOpacity(0.3),
              note: content,
              clinicalCaseId: clinicalCaseId,
            );
          }
        },
      ),
    );
  }

  void _showHighlightActions(
    BuildContext context,
    Question? q,
    dynamic highlight, {
    int? propositionId,
    int? clinicalCaseId,
    String? fullText,
  }) {
    final quizNotifier = ref.read(quizSessionProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;

    String textId = '';
    if (propositionId != null) {
      textId = 'prop_$propositionId';
    } else if (clinicalCaseId != null) {
      textId = 'cc_$clinicalCaseId';
    } else if (q != null) {
      textId = q.id.toString();
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: quizTheme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //Show existing note preview
            if (highlight.note != null && highlight.note!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: quizTheme.secondaryTextColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Iconsax.note_text, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: QuillSimpleViewer(
                        content: highlight.note!,
                        textColor: quizTheme.primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            //Color change row
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: _highlightColors.map((color) {
                  final isSelected = highlight.color.value == color.value;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        //Remove old and add new with different color
                        quizNotifier.removeHighlight(
                          q?.id ?? 0,
                          textId,
                          highlight.id,
                          clinicalCaseId: clinicalCaseId,
                        );

                        final sourceText = fullText ?? '';
                        final start = sourceText.isNotEmpty
                            ? sourceText.indexOf(highlight.text)
                            : highlight.start;

                        if (start != -1) {
                          quizNotifier.addHighlight(
                            q?.id ?? 0,
                            textId,
                            highlight.text,
                            start,
                            start + (highlight.text as String).length,
                            color,
                            note: highlight.note,
                            clinicalCaseId: clinicalCaseId,
                          );
                        }
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        height: 28,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            //Edit note
            ListTile(
              leading: const Icon(Iconsax.edit, color: AppColors.primary),
              title: Text(l10n.editNote),
              onTap: () {
                Navigator.pop(ctx);
                _editHighlightNote(
                  context,
                  q,
                  highlight,
                  propositionId: propositionId,
                  clinicalCaseId: clinicalCaseId,
                  fullText: fullText,
                );
              },
            ),
            //Delete highlight
            ListTile(
              leading: const Icon(Iconsax.trash, color: Colors.red),
              title: Text(l10n.deleteHighlight),
              onTap: () {
                quizNotifier.removeHighlight(
                  q?.id ?? 0,
                  textId,
                  highlight.id,
                  clinicalCaseId: clinicalCaseId,
                );
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editHighlightNote(
    BuildContext context,
    Question? q,
    dynamic highlight, {
    int? propositionId,
    int? clinicalCaseId,
    String? fullText,
  }) {
    final quizNotifier = ref.read(quizSessionProvider.notifier);

    String textId = '';
    if (propositionId != null) {
      textId = 'prop_$propositionId';
    } else if (clinicalCaseId != null) {
      textId = 'cc_$clinicalCaseId';
    } else if (q != null) {
      textId = q.id.toString();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NoteEditorBottomSheet(
        initialValue: highlight.note ?? '',
        title: AppLocalizations.of(context)!.editNote,
        contextText: highlight.text,
        onSave: (content) {
          quizNotifier.updateHighlightNote(
            q?.id ?? 0,
            textId,
            highlight.id,
            content,
            clinicalCaseId: clinicalCaseId,
          );
        },
        onDelete: () {
          quizNotifier.removeHighlight(
            q?.id ?? 0,
            textId,
            highlight.id,
            clinicalCaseId: clinicalCaseId,
          );
        },
      ),
    );
  }
}
