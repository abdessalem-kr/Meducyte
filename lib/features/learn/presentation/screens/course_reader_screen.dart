import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/shared/providers/tts_provider.dart';
import 'package:meducyte_app/features/learn/presentation/utils/lesson_pdf_generator.dart';
import 'package:meducyte_app/features/learn/presentation/providers/lesson_interaction_provider.dart';
import 'package:meducyte_app/features/learn/presentation/widgets/lesson_comment_bottom_sheet.dart';
import 'package:meducyte_app/features/learn/presentation/widgets/lesson_report_bottom_sheet.dart';
import 'package:uuid/uuid.dart';
import 'package:meducyte_app/shared/widgets/highlightable_text.dart';
import 'package:meducyte_app/shared/widgets/reading_settings_bottom_sheet.dart';
import 'package:meducyte_app/features/quiz/presentation/widgets/note_editor_widgets.dart';
import 'package:meducyte_app/features/learn/presentation/widgets/active_recall_widgets.dart';
import 'package:meducyte_app/features/learn/presentation/widgets/sq3r_study_widgets.dart';
import 'package:meducyte_app/shared/services/access_gating_service.dart';

class CourseReaderScreen extends ConsumerStatefulWidget {
  final String courseId; //This is the lesson ID
  final String? initialCommentId;

  const CourseReaderScreen({
    super.key,
    required this.courseId,
    this.initialCommentId,
  });

  @override
  ConsumerState<CourseReaderScreen> createState() => _CourseReaderScreenState();
}

class _CourseReaderScreenState extends ConsumerState<CourseReaderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isMenuOpen = false;
  bool _isSq3rMode = false;
  int _sq3rStep = 0;
  List<String> _sq3rQuestions = [];
  Map<int, String> _sq3rAnswers = {};
  Map<int, String> _sq3rModelAnswers = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    //Auto-open comments if initialCommentId is provided
    if (widget.initialCommentId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //Delay slightly to ensure lesson is loaded(or at least the screen is ready)
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            final lessonAsync = ref.read(
              lessonDetailsProvider(widget.courseId),
            );
            lessonAsync.whenData((lesson) {
              _onChatTap(context, lesson);
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Iconsax.crown, color: Colors.amber),
            SizedBox(width: 12),
            Text("Premium Feature"),
          ],
        ),
        content: const Text(
          "Upgrade to a higher tier to unlock high-level AI tools and full module access.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Test Features"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "View Plans",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lessonAsync = ref.watch(lessonDetailsProvider(widget.courseId));
    final gating = ref.watch(accessGatingServiceProvider);
    final isSubscriber = gating.hasActiveSubscription;
    final interactionState = ref.watch(
      interactionProvider((id: widget.courseId, type: InteractionType.lesson)),
    );
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(appSettingsProvider);

    double courseFontScale = 1.0;
    if (settings.courseFontSize == 'Small' ||
        settings.courseFontSize == 'Petit') {
      courseFontScale = 0.85;
    } else if (settings.courseFontSize == 'Large' ||
        settings.courseFontSize == 'Grand') {
      courseFontScale = 1.25;
    }

    return lessonAsync.when(
      data: (lesson) {
        if (!isSubscriber && !gating.canAccessModule(lesson)) {
          return const SubscriptionScreen();
        }

        return Scaffold(
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : AppColors.backgroundLight,
          appBar: _buildAppBar(context, ref, lesson, primaryColor, isDark),
          body: Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 20,
                ),
                itemCount: (lesson.paragraphs?.length ?? 0) + 1,
                cacheExtent: 1000,
                itemBuilder: (context, index) {
                  if (index == (lesson.paragraphs?.length ?? 0)) {
                    return _buildCompletionSection(
                      context,
                      ref,
                      lesson,
                      primaryColor,
                      isDark,
                      l10n,
                    );
                  }
                  final paragraph = lesson.paragraphs![index];
                  final ttsStatus = ref.watch(ttsProvider);
                  final isReading = ttsStatus.currentParagraphIndex == index;

                  return _buildParagraph(
                    context,
                    ref,
                    paragraph,
                    primaryColor,
                    isDark,
                    interactionState,
                    isReading: isReading,
                    allParagraphs: lesson.paragraphs ?? [],
                    fontScale: courseFontScale,
                  );
                },
              ),
              if (_isSq3rMode)
                _buildSq3rOverlay(context, lesson, primaryColor, isDark, l10n),
            ],
          ),
          floatingActionButton: _buildStudyToolsFAB(
            context,
            lesson,
            primaryColor,
            isDark,
            l10n,
          ),
          bottomNavigationBar: _buildVoiceController(
            context,
            ref,
            lesson,
            primaryColor,
            isDark,
            l10n,
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('$err'))),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    LearnLesson lesson,
    Color primaryColor,
    bool isDark,
  ) {
    return AppBar(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Iconsax.arrow_left,
          color: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
        ),
        onPressed: () => context.pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  lesson.title,
                  style: GoogleFonts.inter(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (lesson.module != null &&
                  !ref
                      .watch(accessGatingServiceProvider)
                      .canAccessModule(lesson.module!))
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(Iconsax.lock, color: Colors.amber[700], size: 16),
                ),
            ],
          ),
          if (lesson.paragraphs != null)
            Text(
              "${lesson.paragraphs!.length}sections",
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontSize: 12,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Iconsax.text_italic,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          onPressed: () => _showFontSizeSettings(context, ref),
        ),
        IconButton(
          icon: Icon(
            Iconsax.messages_3,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          onPressed: () => _onChatTap(context, lesson),
        ),
        IconButton(
          icon: Icon(
            Iconsax.flag,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          onPressed: () => _onFlagTap(context, lesson),
        ),
        IconButton(
          icon: Icon(
            Iconsax.note_2,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          onPressed: () => _onNoteTap(context, lesson),
        ),
        IconButton(
          icon: Icon(
            Iconsax.printer,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          onPressed: () {
            LessonPdfGenerator.printLesson(lesson);
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _onChatTap(BuildContext context, LearnLesson lesson) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InteractionCommentBottomSheet(
        id: lesson.id,
        type: InteractionType.lesson,
        lesson: lesson,
        initialTabIndex: 0,
        initialCommentId: widget.initialCommentId,
      ),
    );
  }

  void _onFlagTap(BuildContext context, LearnLesson lesson) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InteractionReportBottomSheet(
        id: lesson.id,
        type: InteractionType.lesson,
      ),
    );
  }

  void _onNoteTap(BuildContext context, LearnLesson lesson) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => InteractionCommentBottomSheet(
        id: lesson.id,
        type: InteractionType.lesson,
        lesson: lesson,
        initialTabIndex: 1,
      ),
    );
  }

  void _showFontSizeSettings(BuildContext context, WidgetRef ref) {
    final settings = ref.read(appSettingsProvider);
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ReadingSettingsBottomSheet(
        title: l10n.courseFontSizeTitle,
        currentSize: settings.courseFontSize,
        onSizeChanged: (newSize) {
          ref.read(appSettingsProvider.notifier).setCourseFontSize(newSize);
        },
      ),
    );
  }

  Widget _buildParagraph(
    BuildContext context,
    WidgetRef ref,
    LearnParagraph paragraph,
    Color primaryColor,
    bool isDark,
    InteractionState interactionState, {
    bool isReading = false,
    List<LearnParagraph> allParagraphs = const [],
    double fontScale = 1.0,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final ttsStatus = ref.watch(ttsProvider);

    final activeHighlights =
        interactionState.optimisticHighlights[paragraph.id] ??
        paragraph.highlights;
    final optimisticNoteText = interactionState.optimisticNotes[paragraph.id];
    ParagraphNote? activeNote = paragraph.myNote;
    if (optimisticNoteText != null) {
      if (optimisticNoteText.isEmpty) {
        activeNote = null;
      } else {
        activeNote = ParagraphNote(id: 'opt', text: optimisticNoteText);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isReading
              ? primaryColor.withOpacity(0.5)
              : (isDark ? Colors.white12 : Colors.black12),
          width: isReading ? 2 : 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  paragraph.title ?? "Paragraph${paragraph.order + 1}",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isReading
                        ? primaryColor
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                  ),
                ),
              ),
            ],
          ),
          subtitle: ttsStatus.state == TtsState.playing && isReading
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.readingInProgress,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : null,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  (isReading
                          ? primaryColor
                          : (isDark ? Colors.white : Colors.black))
                      .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Iconsax.document_text,
              color: isReading
                  ? primaryColor
                  : (isDark ? Colors.white70 : Colors.black54),
              size: 20,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isReading)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                ),
              _buildParagraphMenu(
                context,
                ref,
                paragraph,
                primaryColor,
                allParagraphs,
                isDark,
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isReading
                          ? primaryColor.withOpacity(0.05)
                          : (isDark
                                ? Colors.white.withOpacity(0.02)
                                : Colors.black.withOpacity(0.01)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: HighlightableText(
                      text: paragraph.content,
                      style: GoogleFonts.inter(
                        fontSize: 16 * fontScale,
                        height: 1.6,
                        color: isDark
                            ? AppColors.textPrimaryDark.withOpacity(0.9)
                            : AppColors.textPrimaryLight.withOpacity(0.9),
                        decoration: isReading ? TextDecoration.underline : null,
                        decorationColor: primaryColor.withOpacity(0.4),
                        decorationThickness: 2,
                      ),
                      highlights: activeHighlights,
                      onHighlightTap: (h) => _showHighlightActions(
                        context,
                        ref,
                        paragraph,
                        activeHighlights,
                        h,
                      ),
                      onHighlight: (text) => _showColorPicker(
                        context,
                        paragraph,
                        activeHighlights,
                        selectedText: text,
                      ),
                      onNote: (text) => _showNoteEditor(
                        context,
                        ref,
                        paragraph,
                        activeHighlights,
                        selectedText: text,
                      ),
                    ),
                  ),
                  if (activeNote != null) ...[
                    const SizedBox(height: 16),
                    _buildNoteCard(context, ref, paragraph, activeNote, isDark),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParagraphMenu(
    BuildContext context,
    WidgetRef ref,
    LearnParagraph paragraph,
    Color primaryColor,
    List<LearnParagraph> allParagraphs,
    bool isDark,
  ) {
    return PopupMenuButton<String>(
      icon: Icon(
        Iconsax.more,
        color: isDark ? Colors.white70 : Colors.black54,
        size: 20,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      offset: const Offset(0, 40),
      onSelected: (value) {
        switch (value) {
          case 'play':
            ref
                .read(ttsProvider.notifier)
                .startReading(
                  allParagraphs.map((p) => p.content).toList(),
                  startAt: allParagraphs.indexOf(paragraph),
                );
            break;
          case 'explain':
          case 'summarize':
          case 'mnemonic':
            if (ref.read(accessGatingServiceProvider).canUseAi()) {
              _showNoteEditor(context, ref, paragraph, [], autoAction: value);
            } else {
              _showUpgradeDialog(context);
            }
            break;
          case 'note':
            _showNoteEditor(context, ref, paragraph, []);
            break;
          case 'delete_note':
            if (paragraph.myNote != null) {
              ref
                  .read(
                    interactionProvider((
                      id: widget.courseId,
                      type: InteractionType.lesson,
                    )).notifier,
                  )
                  .deleteParagraphNote(paragraph.id);
            }
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'play',
          child: Row(
            children: [
              Icon(Iconsax.play_circle, color: primaryColor, size: 20),
              const SizedBox(width: 12),
              Text(
                "Listen",
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: 'note',
          child: Row(
            children: [
              const Icon(Iconsax.edit, color: Colors.amber, size: 20),
              const SizedBox(width: 12),
              Text(
                "Add Note",
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: 'explain',
          child: Row(
            children: [
              const Icon(Iconsax.magic_star, color: Colors.purple, size: 20),
              const SizedBox(width: 12),
              Text(
                "AI Explain",
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'summarize',
          child: Row(
            children: [
              const Icon(Iconsax.document_text, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              Text(
                "AI Summarize",
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'mnemonic',
          child: Row(
            children: [
              const Icon(Iconsax.lamp_on, color: Colors.orange, size: 20),
              const SizedBox(width: 12),
              Text(
                "AI Mnemonic",
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        if (paragraph.myNote != null) ...[
          const PopupMenuDivider(height: 1),
          PopupMenuItem(
            value: 'delete_note',
            child: Row(
              children: [
                const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  "Delete Note",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStudyToolsFAB(
    BuildContext context,
    LearnLesson lesson,
    Color primaryColor,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        //1.SQ3R Technique
        _buildFabMenuItem(
          icon: Iconsax.teacher,
          label: l10n.sq3rTechnique,
          onTap: () {
            _toggleMenu();
            _showSq3rStudy(context, lesson);
          },
          index: 3,
        ),
        const SizedBox(height: 12),
        //2.Active Recall
        _buildFabMenuItem(
          icon: Iconsax.refresh,
          label: l10n.activeRecall,
          onTap: () {
            _toggleMenu();
            _showActiveRecall(context, lesson);
          },
          index: 2,
        ),
        const SizedBox(height: 12),
        //3.Quick Training
        _buildFabMenuItem(
          icon: Iconsax.flash,
          label: l10n.quickTraining,
          onTap: () {
            _toggleMenu();
            final filters = QuizFilters(
              lessonIds: [lesson.id],
              isPractice: true,
            );
            context.push('/quiz/session/new', extra: filters);
          },
          index: 1,
        ),
        const SizedBox(height: 16),
        //Main Toggle Button
        FloatingActionButton.extended(
          onPressed: _toggleMenu,
          backgroundColor: primaryColor,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: AnimatedRotation(
            turns: _isMenuOpen ? 0.125 : 0, //45 degrees
            duration: const Duration(milliseconds: 250),
            child: Icon(_isMenuOpen ? Iconsax.add : Iconsax.book_1),
          ),
          label: Text(
            _isMenuOpen ? l10n.close : l10n.studyTools,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFabMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required int index,
  }) {
    return ScaleTransition(
      scale: _expandAnimation,
      child: FadeTransition(
        opacity: _expandAnimation,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            FloatingActionButton.small(
              heroTag: 'fab_$index',
              onPressed: onTap,
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  void _showSq3rStudy(BuildContext context, LearnLesson lesson) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Sq3rStudyBottomSheet(
        lesson: lesson,
        initialStep: _sq3rStep,
        initialQuestions: _sq3rQuestions,
        initialAnswers: _sq3rAnswers,
        initialModelAnswers: _sq3rModelAnswers,
        onStateChanged: (step, questions, answers, modelAnswers) {
          setState(() {
            _sq3rStep = step;
            _sq3rQuestions = questions;
            _sq3rAnswers = answers;
            _sq3rModelAnswers = modelAnswers;
          });
        },
        onStartReading: () {
          setState(() {
            _isSq3rMode = true;
          });
        },
      ),
    );
  }

  void _showActiveRecall(BuildContext context, LearnLesson lesson) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ActiveRecallBottomSheet(lesson: lesson),
    );
  }

  Widget _buildSq3rOverlay(
    BuildContext context,
    LearnLesson lesson,
    Color primaryColor,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Positioned(
      bottom: 100, //Above voice controller
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Iconsax.book_1, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "SQ3R Reading Mode",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isSq3rMode = false;
                });
                _showSq3rStudy(context, lesson);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Return to SQ3R"),
            ),
            IconButton(
              onPressed: () => setState(() => _isSq3rMode = false),
              icon: const Icon(Icons.close, color: Colors.white70, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceController(
    BuildContext context,
    WidgetRef ref,
    LearnLesson lesson,
    Color primaryColor,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final ttsStatus = ref.watch(ttsProvider);
    if (ttsStatus.state == TtsState.stopped) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () => ref.read(ttsProvider.notifier).stop(),
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          IconButton(
            onPressed: () => ref
                .read(ttsProvider.notifier)
                .seekRelative(const Duration(seconds: -10)),
            icon: Icon(
              Icons.replay_10,
              color: isDark ? Colors.white70 : Colors.black54,
              size: 28,
            ),
          ),
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                if (ttsStatus.state == TtsState.playing) {
                  ref.read(ttsProvider.notifier).pause();
                } else {
                  ref.read(ttsProvider.notifier).resume();
                }
              },
              icon: Icon(
                ttsStatus.state == TtsState.playing
                    ? Iconsax.pause
                    : Iconsax.play,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          IconButton(
            onPressed: () => ref
                .read(ttsProvider.notifier)
                .seekRelative(const Duration(seconds: 10)),
            icon: Icon(
              Icons.forward_10,
              color: isDark ? Colors.white70 : Colors.black54,
              size: 28,
            ),
          ),
          IconButton(
            onPressed: () => ref.read(ttsProvider.notifier).next(),
            icon: Icon(
              Iconsax.next,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
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

  void _showColorPicker(
    BuildContext context,
    LearnParagraph paragraph,
    List<HighlightModel> currentHighlights, {
    required String selectedText,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Highlight Color",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: _highlightColors.map((color) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final queryText = selectedText.trim();
                      final startIndex = paragraph.content.indexOf(queryText);
                      if (startIndex == -1) return; // Prevent crashes if text changed

                      final highlight = HighlightModel(
                        id: const Uuid().v4(),
                        text: queryText,
                        color: color,
                        start: startIndex,
                        end: startIndex + queryText.length,
                      );
                      ref
                          .read(
                            interactionProvider((
                              id: widget.courseId,
                              type: InteractionType.lesson,
                            )).notifier,
                          )
                          .addHighlight(
                            paragraph.id,
                            currentHighlights,
                            highlight,
                          );
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 28,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showHighlightActions(
    BuildContext context,
    WidgetRef ref,
    LearnParagraph paragraph,
    List<HighlightModel> currentHighlights,
    HighlightModel highlight,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                "Highlight Options",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
              child: Row(
                children: _highlightColors.map((color) {
                  final isSelected = highlight.color.value == color.value;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(
                              interactionProvider((
                                id: widget.courseId,
                                type: InteractionType.lesson,
                              )).notifier,
                            )
                            .updateHighlightColor(
                              paragraph.id,
                              currentHighlights,
                              highlight.id,
                              color,
                            );
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        height: 28,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                          border: isSelected
                              ? Border.all(color: Colors.black54, width: 2)
                              : null,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Iconsax.edit, color: AppColors.primary),
              title: const Text("Edit Note"),
              onTap: () {
                Navigator.pop(ctx);
                _showNoteEditor(
                  context,
                  ref,
                  paragraph,
                  currentHighlights,
                  highlight: highlight,
                );
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Iconsax.trash, color: Colors.red),
              title: const Text("Delete Highlight"),
              onTap: () {
                ref
                    .read(
                      interactionProvider((
                        id: widget.courseId,
                        type: InteractionType.lesson,
                      )).notifier,
                    )
                    .deleteHighlight(
                      paragraph.id,
                      currentHighlights,
                      highlight.id,
                    );
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteEditor(
    BuildContext context,
    WidgetRef ref,
    LearnParagraph paragraph,
    List<HighlightModel> currentHighlights, {
    HighlightModel? highlight,
    String? selectedText,
    String? autoAction,
  }) {
    final interactionNotifier = ref.read(
      interactionProvider((
        id: widget.courseId,
        type: InteractionType.lesson,
      )).notifier,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NoteEditorBottomSheet(
        initialValue: highlight?.note ?? paragraph.myNote?.text ?? "",
        onSave: (newNote) {
          if (highlight != null) {
            interactionNotifier.updateHighlightNote(
              paragraph.id,
              currentHighlights,
              highlight.id,
              newNote,
            );
          } else {
            interactionNotifier.saveParagraphNote(paragraph.id, newNote);
          }
        },
        onDelete: () {
          if (highlight != null) {
            interactionNotifier.updateHighlightNote(
              paragraph.id,
              currentHighlights,
              highlight.id,
              "",
            );
          } else {
            interactionNotifier.deleteParagraphNote(paragraph.id);
          }
        },
        contextText: highlight?.text ?? selectedText,
        autoAction: autoAction,
      ),
    );
  }

  Widget _buildNoteCard(
    BuildContext context,
    WidgetRef ref,
    LearnParagraph paragraph,
    ParagraphNote note,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(isDark ? 0.05 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.note, size: 16, color: Colors.amber),
              const SizedBox(width: 8),
              const Text(
                "My Note",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.amber,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showNoteEditor(context, ref, paragraph, []),
                icon: const Icon(Iconsax.edit_2, size: 16, color: Colors.amber),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  ref
                      .read(
                        interactionProvider((
                          id: widget.courseId,
                          type: InteractionType.lesson,
                        )).notifier,
                      )
                      .deleteParagraphNote(paragraph.id);
                },
                icon: const Icon(
                  Iconsax.trash,
                  size: 16,
                  color: Colors.redAccent,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (note.text != null && note.text!.isNotEmpty)
            QuillSimpleViewer(
              content: note.text!,
              textColor: isDark ? Colors.white : Colors.black,
            )
          else
            const Text(
              "Empty note.Tap to edit.",
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildCompletionSection(
    BuildContext context,
    WidgetRef ref,
    LearnLesson lesson,
    Color primaryColor,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: lesson.isStudied
            ? Colors.green.withOpacity(0.1)
            : primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: lesson.isStudied
              ? Colors.green.withOpacity(0.3)
              : primaryColor.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            lesson.isStudied ? Iconsax.verify : Iconsax.book_1,
            size: 64,
            color: lesson.isStudied ? Colors.green : primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            lesson.isStudied ? l10n.lessonCompleted : l10n.finishLesson,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.isStudied ? l10n.lessonCompletedSub : l10n.finishLessonSub,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final params = (
                  id: widget.courseId,
                  type: InteractionType.lesson,
                );
                ref
                    .read(interactionProvider(params).notifier)
                    .toggleLessonStudied();
              },
              icon: Icon(
                lesson.isStudied ? Icons.refresh : Icons.check_circle_outline,
                color: Colors.white,
              ),
              label: Text(
                lesson.isStudied ? l10n.markAsUnstudied : l10n.markAsStudied,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: lesson.isStudied ? Colors.green : primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
