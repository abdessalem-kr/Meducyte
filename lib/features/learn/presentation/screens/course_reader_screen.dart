import 'package:meducyte_app/export.dart';
import 'dart:async';
import 'dart:math';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:meducyte_app/shared/providers/tts_provider.dart';
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
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:meducyte_app/features/learn/presentation/widgets/pdf_print_settings_sheet.dart';

enum ReaderMode { read, watch }

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

  final Map<int, ExpansionTileController> _tileControllers = {};
  final Map<int, GlobalKey> _itemKeys = {};
  late ScrollController _scrollController;
  double _readingProgress = 0.0;
  double _lastMaxScroll = 0.0;
  bool _globallyExpanded = false;

  bool _zenMode = false;
  bool _sepiaMode = false;
  bool _isAutoScrolling = false;
  double _autoScrollSpeed = 1.0;
  Timer? _autoScrollTimer;
  int? _scrollingActiveParagraphIndex;
  int _scrollingActiveWordIndex = -1;
  int _ticksCount = 0;
  bool _showVideoPlayer = false;
  bool _isMiniPlayer = false;
  ReaderMode _activeMode = ReaderMode.read;

  void _toggleAutoScroll() {
    setState(() {
      _isAutoScrolling = !_isAutoScrolling;
      if (_isAutoScrolling) {
        _startAutoScrolling();
      } else {
        _autoScrollTimer?.cancel();
      }
    });
  }

  void _startAutoScrolling() {
    _autoScrollTimer?.cancel();

    const int tickMs = 30;

    if (_scrollingActiveParagraphIndex == null) {
      _scrollingActiveParagraphIndex = 0;
      _scrollingActiveWordIndex = 0;
    }
    _ticksCount = 0;

    // Immediately expand the active paragraph
    final initialIndex = _scrollingActiveParagraphIndex ?? 0;
    _tileControllers[initialIndex]?.expand();

    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: tickMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // 1. Smoothly scroll the page
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentOffset = _scrollController.offset;
        // Scroll delta per 30ms tick (adjust speed multiplier for smooth continuous scroll)
        final scrollDelta = _autoScrollSpeed * 0.8;

        if (currentOffset < maxScroll) {
          _scrollController.jumpTo(currentOffset + scrollDelta);
        } else {
          // Reached the bottom of the page
          setState(() {
            _isAutoScrolling = false;
            _scrollingActiveParagraphIndex = null;
            _scrollingActiveWordIndex = -1;
          });
          timer.cancel();
          return;
        }
      }

      // 2. Advance the active word index at the configured WPM speed
      int ticksPerWord = 8; // 240ms at 1.0x (8 * 30ms)
      if (_autoScrollSpeed == 1.5) {
        ticksPerWord = 5; // 150ms at 1.5x (5 * 30ms)
      } else if (_autoScrollSpeed == 2.0) {
        ticksPerWord = 3; // 90ms at 2.0x (3 * 30ms)
      }

      _ticksCount++;
      if (_ticksCount >= ticksPerWord) {
        _ticksCount = 0;

        final lesson = ref.read(lessonDetailsProvider(widget.courseId)).valueOrNull;
        if (lesson == null) return;

        final paragraphs = lesson.paragraphs ?? [];
        if (paragraphs.isEmpty) {
          timer.cancel();
          return;
        }

        final activeIndex = _scrollingActiveParagraphIndex ?? 0;
        if (activeIndex >= paragraphs.length) {
          setState(() {
            _isAutoScrolling = false;
            _scrollingActiveParagraphIndex = null;
            _scrollingActiveWordIndex = -1;
          });
          timer.cancel();
          return;
        }

        final activeParagraph = paragraphs[activeIndex];
        final segments = parseParagraphContent(activeParagraph.content);
        int totalWords = 0;
        for (final seg in segments) {
          if (seg is TextSegment) {
            totalWords += RegExp(r'\S+').allMatches(seg.text).length;
          } else if (seg is MarkdownBlockSegment) {
            totalWords += RegExp(r'\S+').allMatches(seg.markdown).length;
          }
        }

        setState(() {
          _scrollingActiveWordIndex++;
          if (_scrollingActiveWordIndex >= totalWords) {
            _scrollingActiveParagraphIndex = activeIndex + 1;
            _scrollingActiveWordIndex = 0;

            if (_scrollingActiveParagraphIndex! < paragraphs.length) {
              final nextController = _tileControllers[_scrollingActiveParagraphIndex!];
              nextController?.expand();
            }
          }
        });

        if (_scrollingActiveWordIndex == 0) {
          final activeKey = _itemKeys[_scrollingActiveParagraphIndex ?? 0];
          if (activeKey != null) {
            final activeContext = activeKey.currentContext;
            if (activeContext != null) {
              Scrollable.ensureVisible(
                activeContext,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          }
        }
      }
    });
  }

  List<TextSpan> _buildWordHighlightSpans(
    String text,
    int activeWordIndexOffset,
    int activeWordIndex,
    TextStyle defaultStyle,
    Color highlightColor,
  ) {
    final RegExp regExp = RegExp(r'(\s+)|(\S+)');
    final matches = regExp.allMatches(text).toList();

    final List<TextSpan> spans = [];
    int wordCount = 0;

    for (final match in matches) {
      final value = match.group(0) ?? '';
      final isWhitespace = match.group(1) != null;

      if (isWhitespace) {
        spans.add(TextSpan(text: value, style: defaultStyle));
      } else {
        final currentWordIndex = activeWordIndexOffset + wordCount;
        final isHighlighted = currentWordIndex == activeWordIndex;

        spans.add(
          TextSpan(
            text: value,
            style: defaultStyle.copyWith(
              backgroundColor: isHighlighted ? highlightColor : null,
              fontWeight: isHighlighted
                  ? FontWeight.bold
                  : defaultStyle.fontWeight,
            ),
          ),
        );
        wordCount++;
      }
    }

    return spans;
  }

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
    _scrollController = ScrollController();
    _scrollController.addListener(_updateProgress);

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

  void _updateProgress() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;
    final currentScroll = _scrollController.offset;
    final newProgress = (currentScroll / maxScroll).clamp(0.0, 1.0);

    if (_showVideoPlayer && _activeMode == ReaderMode.read) {
      final shouldMini = currentScroll > 240;
      if (shouldMini != _isMiniPlayer) {
        setState(() {
          _isMiniPlayer = shouldMini;
        });
      }
    }

    setState(() {
      if (maxScroll > _lastMaxScroll && newProgress < _readingProgress) {
        // Prevent layout expansion from pulling progress backwards
      } else {
        _readingProgress = newProgress;
      }
      _lastMaxScroll = maxScroll;
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.removeListener(_updateProgress);
    _scrollController.dispose();
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

  void _toggleExpandAll() {
    setState(() {
      _globallyExpanded = !_globallyExpanded;
    });
    for (final controller in _tileControllers.values) {
      if (_globallyExpanded) {
        controller.expand();
      } else {
        controller.collapse();
      }
    }
  }

  void _showUpgradeDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Iconsax.crown, color: Colors.amber),
            const SizedBox(width: 12),
            Text(l10n.premiumFeature),
          ],
        ),
        content: Text(
          l10n.upgradeToUnlockAi,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.testFeatures),
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
            child: Text(
              l10n.viewPlans,
              style: const TextStyle(color: Colors.white),
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

    ref.listen<TtsStatus>(ttsProvider, (previous, next) {
      if (next.state == TtsState.playing &&
          next.currentParagraphIndex != null) {
        final index = next.currentParagraphIndex!;

        // 1. Automatically expand the active paragraph
        final controller = _tileControllers[index];
        if (controller != null && !controller.isExpanded) {
          controller.expand();
        }

        // 2. Smoothly scroll to the active paragraph
        final key = _itemKeys[index];
        if (key != null) {
          Future.delayed(const Duration(milliseconds: 100), () {
            final context = key.currentContext;
            if (context != null && context.mounted) {
              Scrollable.ensureVisible(
                context,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          });
        }
      }
    });

    double courseFontScale = 1.0;
    final double? parsedScale = double.tryParse(settings.courseFontSize);
    if (parsedScale != null) {
      courseFontScale = parsedScale;
    } else if (settings.courseFontSize == 'Small' ||
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
          backgroundColor: _sepiaMode
              ? const Color(0xFFFBF0D9)
              : (isDark ? AppColors.backgroundDark : AppColors.backgroundLight),
          appBar: _buildAppBar(context, ref, lesson, primaryColor, isDark),
          body: Stack(
            children: [
              Column(
                children: [
                  if (_readingProgress > 0)
                    LinearProgressIndicator(
                      value: _readingProgress,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      minHeight: 3,
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.book_1,
                                size: 16,
                                color: _activeMode == ReaderMode.read ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              ),
                              const SizedBox(width: 6),
                              const Text('Read Lesson'),
                            ],
                          ),
                          selected: _activeMode == ReaderMode.read,
                          selectedColor: primaryColor,
                          backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                          labelStyle: TextStyle(
                            color: _activeMode == ReaderMode.read ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _activeMode = ReaderMode.read;
                                if (_showVideoPlayer) {
                                  _isMiniPlayer = true;
                                }
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.video_play,
                                size: 16,
                                color: _activeMode == ReaderMode.watch ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              ),
                              const SizedBox(width: 6),
                              const Text('Watch Video'),
                            ],
                          ),
                          selected: _activeMode == ReaderMode.watch,
                          selectedColor: primaryColor,
                          backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                          labelStyle: TextStyle(
                            color: _activeMode == ReaderMode.watch ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _activeMode = ReaderMode.watch;
                                _showVideoPlayer = true;
                                _isMiniPlayer = false;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  if (_activeMode == ReaderMode.watch)
                    Expanded(
                      child: LessonVideoPlayer(
                        lesson: lesson,
                        isWatchMode: true,
                        onClose: () {
                          setState(() {
                            _activeMode = ReaderMode.read;
                            _showVideoPlayer = false;
                          });
                        },
                        onParagraphSelected: (activeIndex) {
                          _tileControllers[activeIndex]?.expand();
                          final key = _itemKeys[activeIndex];
                          if (key != null) {
                            final context = key.currentContext;
                            if (context != null) {
                              Scrollable.ensureVisible(
                                context,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            }
                          }
                        },
                      ),
                    )
                  else ...[
                    if (_showVideoPlayer && !_isMiniPlayer)
                      LessonVideoPlayer(
                        lesson: lesson,
                        onClose: () {
                          setState(() {
                            _showVideoPlayer = false;
                          });
                        },
                        onParagraphSelected: (activeIndex) {
                          _tileControllers[activeIndex]?.expand();
                          final key = _itemKeys[activeIndex];
                          if (key != null) {
                            final context = key.currentContext;
                            if (context != null) {
                              Scrollable.ensureVisible(
                                context,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            }
                          }
                        },
                      )
                    else if (_showVideoPlayer && _isMiniPlayer)
                      const SizedBox(height: 12),
                    if (!_showVideoPlayer)
                      _buildVideoBanner(context, primaryColor, isDark, l10n),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
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
                          final isReading =
                              ttsStatus.currentParagraphIndex == index;

                          final controller = _tileControllers.putIfAbsent(
                            index,
                            () => ExpansionTileController(),
                          );
                          final key = _itemKeys.putIfAbsent(
                            index,
                            () => GlobalKey(),
                          );

                          return Container(
                            key: key,
                            child: _buildParagraph(
                              context,
                              ref,
                              lesson,
                              paragraph,
                              primaryColor,
                              isDark,
                              interactionState,
                              isReading: isReading,
                              allParagraphs: lesson.paragraphs ?? [],
                              fontScale: courseFontScale,
                              controller: controller,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
              if (_isSq3rMode)
                _buildSq3rOverlay(context, lesson, primaryColor, isDark, l10n),
              if (_showVideoPlayer && _isMiniPlayer)
                Positioned(
                  bottom: 90,
                  right: 16,
                  child: LessonVideoPlayer(
                    lesson: lesson,
                    isMini: true,
                    onClose: () {
                      setState(() {
                        _showVideoPlayer = false;
                      });
                    },
                  ),
                ),
            ],
          ),
          floatingActionButton: _zenMode
              ? null
              : _buildStudyToolsFAB(
                  context,
                  lesson,
                  primaryColor,
                  isDark,
                  l10n,
                ),
          bottomNavigationBar: _zenMode
              ? null
              : _buildVoiceController(
                  context,
                  ref,
                  lesson,
                  primaryColor,
                  isDark,
                  l10n,
                ),
        );
      },
      loading: () => Skeletonizer(
        enabled: true,
        child: Scaffold(
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: isDark
                ? AppColors.backgroundDark
                : AppColors.backgroundLight,
            elevation: 0,
            leading: const Icon(Iconsax.arrow_left_2),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.dummyLoadingLessonTitle),
                Text(l10n.sectionsCount('6')),
              ],
            ),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ListTile(
                  title: Text(l10n.dummyLoadingParagraphTitle((index + 1).toString())),
                  subtitle: Text(
                    l10n.dummyLoadingParagraphContent,
                  ),
                ),
              );
            },
          ),
        ),
      ),
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
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Iconsax.arrow_left_2,
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
              l10n.sectionsCount(lesson.paragraphs!.length.toString()),
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
            _activeMode == ReaderMode.watch ? Iconsax.video_play : Iconsax.video,
            color: _activeMode == ReaderMode.watch
                ? primaryColor
                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          ),
          onPressed: () {
            setState(() {
              if (_activeMode == ReaderMode.read) {
                _activeMode = ReaderMode.watch;
                _showVideoPlayer = true;
              } else {
                _activeMode = ReaderMode.read;
                _showVideoPlayer = false;
              }
              _isMiniPlayer = false;
            });
          },
        ),
        IconButton(
          icon: Icon(
            _globallyExpanded ? Icons.unfold_less : Icons.unfold_more,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          onPressed: _toggleExpandAll,
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
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          onSelected: (value) {
            switch (value) {
              case 'zen':
                setState(() => _zenMode = !_zenMode);
                break;
              case 'sepia':
                setState(() => _sepiaMode = !_sepiaMode);
                break;
              case 'autoscroll':
                _toggleAutoScroll();
                break;
              case 'speed':
                setState(() {
                  if (_autoScrollSpeed == 1.0) {
                    _autoScrollSpeed = 1.5;
                  } else if (_autoScrollSpeed == 1.5) {
                    _autoScrollSpeed = 2.0;
                  } else {
                    _autoScrollSpeed = 1.0;
                  }
                  if (_isAutoScrolling) {
                    _startAutoScrolling();
                  }
                });
                break;
              case 'font':
                _showFontSizeSettings(context, ref);
                break;
              case 'notes':
                _onNoteTap(context, lesson);
                break;
              case 'print':
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => PdfPrintSettingsSheet(lesson: lesson),
                );
                break;
              case 'flag':
                _onFlagTap(context, lesson);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'zen',
              child: Row(
                children: [
                  Icon(
                    _zenMode ? Icons.visibility : Icons.visibility_off,
                    size: 18,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  const SizedBox(width: 12),
                  Text(_zenMode ? l10n.zenModeDisable : l10n.zenModeEnable),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'sepia',
              child: Row(
                children: [
                  Icon(
                    Icons.menu_book,
                    size: 18,
                    color: _sepiaMode
                        ? Colors.amber
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                  const SizedBox(width: 12),
                  Text(_sepiaMode ? l10n.sepiaThemeDisable : l10n.sepiaThemeEnable),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'autoscroll',
              child: Row(
                children: [
                  Icon(
                    _isAutoScrolling ? Icons.pause_circle : Icons.play_circle,
                    size: 18,
                    color: _isAutoScrolling
                        ? primaryColor
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isAutoScrolling
                        ? l10n.autoScrollPause
                        : l10n.autoScrollStart,
                  ),
                ],
              ),
            ),
            if (_isAutoScrolling)
              PopupMenuItem(
                value: 'speed',
                child: Row(
                  children: [
                    Icon(
                      Icons.speed,
                      size: 18,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.scrollSpeedLabel(_autoScrollSpeed.toString())),
                  ],
                ),
              ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'font',
              child: Row(
                children: [
                  Icon(
                    Iconsax.text_italic,
                    size: 18,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.adjustTextSize),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'notes',
              child: Row(
                children: [
                  Icon(
                    Iconsax.note_2,
                    size: 18,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.notes),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'print',
              child: Row(
                children: [
                  Icon(
                    Iconsax.printer,
                    size: 18,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.printPdfExport),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'flag',
              child: Row(
                children: [
                  const Icon(Iconsax.flag, size: 18, color: Colors.redAccent),
                  const SizedBox(width: 12),
                  Text(
                    l10n.reportContent,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
              ),
            ),
          ],
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
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Consumer(
        builder: (context, ref, _) {
          final settings = ref.watch(appSettingsProvider);
          return ReadingSettingsBottomSheet(
            title: l10n.courseFontSizeTitle,
            currentSize: settings.courseFontSize,
            onSizeChanged: (newSize) {
              ref.read(appSettingsProvider.notifier).setCourseFontSize(newSize);
            },
            currentFontFamily: settings.courseFontFamily,
            onFontFamilyChanged: (newFont) {
              ref.read(appSettingsProvider.notifier).setCourseFontFamily(newFont);
            },
          );
        },
      ),
    );
  }

  TextStyle _getReaderTextStyle({
    required String fontFamily,
    required double fontSize,
    required double height,
    required Color color,
    TextDecoration? decoration,
    Color? decorationColor,
    double? decorationThickness,
  }) {
    if (fontFamily.toLowerCase() == 'opendyslexic') {
      return TextStyle(
        fontFamily: 'OpenDyslexic',
        fontSize: fontSize,
        height: height,
        color: color,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationThickness: decorationThickness,
      );
    }
    try {
      return GoogleFonts.getFont(
        fontFamily,
        fontSize: fontSize,
        height: height,
        color: color,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationThickness: decorationThickness,
      );
    } catch (e) {
      return GoogleFonts.inter(
        fontSize: fontSize,
        height: height,
        color: color,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationThickness: decorationThickness,
      );
    }
  }

  Widget _buildParagraph(
    BuildContext context,
    WidgetRef ref,
    LearnLesson lesson,
    LearnParagraph paragraph,
    Color primaryColor,
    bool isDark,
    InteractionState interactionState, {
    bool isReading = false,
    List<LearnParagraph> allParagraphs = const [],
    double fontScale = 1.0,
    required ExpansionTileController controller,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final ttsStatus = ref.watch(ttsProvider);
    final settings = ref.watch(appSettingsProvider);

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

    final cardBgColor = _sepiaMode
        ? const Color(0xFFFEF9EF)
        : (isDark ? AppColors.cardDark : AppColors.cardLight);

    final paragraphIndex = allParagraphs.indexOf(paragraph);
    final isScrollingActiveParagraph =
        _isAutoScrolling && _scrollingActiveParagraphIndex == paragraphIndex;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cardBgColor,
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
              : (_sepiaMode
                    ? const Color(0xFFE8DFCD)
                    : (isDark ? Colors.white12 : Colors.black12)),
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
          controller: controller,
          initiallyExpanded:
              isReading || _globallyExpanded || isScrollingActiveParagraph,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: paragraph.title != null && paragraph.title!.isNotEmpty
              ? Text(
                  paragraph.title!,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isReading
                        ? primaryColor
                        : (_sepiaMode
                              ? const Color(0xFF5B4636)
                              : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight)),
                  ),
                )
              : Text(
                  l10n.sectionLabel((paragraphIndex + 1).toString()),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isReading
                        ? primaryColor
                        : (_sepiaMode
                              ? const Color(0xFF5B4636)
                              : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight)),
                  ),
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
          leading: _zenMode
              ? null
              : Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isReading
                        ? primaryColor
                        : (isDark
                              ? primaryColor.withOpacity(0.12)
                              : primaryColor.withOpacity(0.08)),
                    borderRadius: BorderRadius.circular(12),
                    border: isReading
                        ? null
                        : Border.all(
                            color: primaryColor.withOpacity(0.25),
                            width: 1,
                          ),
                  ),
                  child: Center(
                    child: Text(
                      '${paragraphIndex + 1}'.padLeft(2, '0'),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isReading
                            ? Colors.white
                            : primaryColor.withOpacity(0.9),
                      ),
                    ),
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
              if (!_zenMode)
                _buildParagraphMenu(
                  context,
                  ref,
                  lesson,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: parseParagraphContent(paragraph.content).map((
                      segment,
                    ) {
                      if (segment is TextSegment) {
                        final segmentHighlights = activeHighlights
                            .where(
                              (h) =>
                                  h.start >= segment.startOffset &&
                                  h.end <=
                                      segment.startOffset + segment.text.length,
                            )
                            .map(
                              (h) => HighlightModel(
                                id: h.id,
                                text: h.text,
                                color: h.color,
                                start: h.start - segment.startOffset,
                                end: h.end - segment.startOffset,
                                note: h.note,
                              ),
                            )
                            .toList();
                        int activeWordIndexOffset = 0;
                        final allSegments = parseParagraphContent(
                          paragraph.content,
                        );
                        for (final s in allSegments) {
                          if (s == segment) break;
                          if (s is TextSegment) {
                            activeWordIndexOffset += RegExp(
                              r'\S+',
                            ).allMatches(s.text).length;
                          } else if (s is MarkdownBlockSegment) {
                            activeWordIndexOffset += RegExp(
                              r'\S+',
                            ).allMatches(s.markdown).length;
                          }
                        }

                        final defaultTextStyle = _getReaderTextStyle(
                          fontFamily: settings.courseFontFamily,
                          fontSize: 16 * fontScale,
                          height: 1.6,
                          color: _sepiaMode
                              ? const Color(0xFF5B4636)
                              : (isDark
                                    ? AppColors.textPrimaryDark.withOpacity(0.9)
                                    : AppColors.textPrimaryLight.withOpacity(
                                        0.9,
                                      )),
                          decoration: isReading
                              ? TextDecoration.underline
                              : null,
                          decorationColor: primaryColor.withOpacity(0.4),
                          decorationThickness: 2,
                        );

                        return AnimatedContainer(
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
                          child: isScrollingActiveParagraph
                              ? Text.rich(
                                  TextSpan(
                                    style: defaultTextStyle,
                                    children: _buildWordHighlightSpans(
                                      segment.text,
                                      activeWordIndexOffset,
                                      _scrollingActiveWordIndex,
                                      defaultTextStyle,
                                      primaryColor.withOpacity(0.3),
                                    ),
                                  ),
                                )
                              : HighlightableText(
                                  text: segment.text,
                                  style: defaultTextStyle,
                                  highlights: segmentHighlights,
                                  onHighlightTap: (h) {
                                    final originalHighlight = activeHighlights
                                        .firstWhere(
                                          (element) => element.id == h.id,
                                        );
                                    _showHighlightActions(
                                      context,
                                      ref,
                                      paragraph,
                                      activeHighlights,
                                      originalHighlight,
                                    );
                                  },
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
                        );
                      } else if (segment is MarkdownBlockSegment) {
                        final mdTextColor = _sepiaMode
                            ? const Color(0xFF5B4636)
                            : (isDark
                                  ? AppColors.textPrimaryDark.withOpacity(0.9)
                                  : AppColors.textPrimaryLight.withOpacity(0.9));
                        final mdSecondaryColor = _sepiaMode
                            ? const Color(0xFF8C6B4A)
                            : (isDark ? Colors.white54 : Colors.black45);
                        final primaryColor2 = Theme.of(context).primaryColor;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: MarkdownBody(
                            data: segment.markdown,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                fontSize: 16 * fontScale,
                                color: mdTextColor,
                                height: 1.6,
                              ),
                              // Headings
                              h1: TextStyle(
                                fontSize: 22 * fontScale,
                                fontWeight: FontWeight.bold,
                                color: primaryColor2,
                                height: 1.4,
                              ),
                              h1Padding: const EdgeInsets.only(top: 12, bottom: 4),
                              h2: TextStyle(
                                fontSize: 19 * fontScale,
                                fontWeight: FontWeight.bold,
                                color: mdTextColor,
                                height: 1.4,
                              ),
                              h2Padding: const EdgeInsets.only(top: 10, bottom: 4),
                              h3: TextStyle(
                                fontSize: 17 * fontScale,
                                fontWeight: FontWeight.bold,
                                color: mdTextColor,
                                height: 1.4,
                              ),
                              h3Padding: const EdgeInsets.only(top: 8, bottom: 2),
                              h4: TextStyle(
                                fontSize: 15 * fontScale,
                                fontWeight: FontWeight.bold,
                                color: mdTextColor,
                              ),
                              h5: TextStyle(
                                fontSize: 14 * fontScale,
                                fontWeight: FontWeight.w600,
                                color: mdTextColor,
                              ),
                              h6: TextStyle(
                                fontSize: 13 * fontScale,
                                fontWeight: FontWeight.w600,
                                color: mdSecondaryColor,
                              ),
                              // Lists
                              listBullet: TextStyle(
                                fontSize: 16 * fontScale,
                                color: primaryColor2,
                              ),
                              listIndent: 20,
                              listBulletPadding: const EdgeInsets.only(right: 8),
                              // Inline styles
                              strong: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: mdTextColor,
                                fontSize: 16 * fontScale,
                              ),
                              em: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: mdTextColor,
                                fontSize: 16 * fontScale,
                              ),
                              // Blockquote
                              blockquote: TextStyle(
                                fontSize: 15 * fontScale,
                                color: mdSecondaryColor,
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                              ),
                              blockquoteDecoration: BoxDecoration(
                                color: primaryColor2.withOpacity(0.06),
                                border: Border(
                                  left: BorderSide(
                                    color: primaryColor2.withOpacity(0.5),
                                    width: 4,
                                  ),
                                ),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              blockquotePadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              // Code
                              code: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14 * fontScale,
                                color: isDark ? Colors.greenAccent[400] : const Color(0xFF1A7F4A),
                                backgroundColor: isDark
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.black.withOpacity(0.05),
                              ),
                              codeblockDecoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.black.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDark ? Colors.white12 : Colors.black12,
                                ),
                              ),
                              codeblockPadding: const EdgeInsets.all(14),
                              // Horizontal rule
                              horizontalRuleDecoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    width: 1.5,
                                    color: isDark ? Colors.white24 : Colors.black26,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      } else if (segment is TableSegment) {
                        final tableTextColor = _sepiaMode
                            ? const Color(0xFF5B4636)
                            : (isDark ? Colors.white70 : Colors.black87);
                        final tableHeaderColor = _sepiaMode
                            ? const Color(0xFF5B4636)
                            : (isDark ? Colors.white : Colors.black);
                        final tableBorderColor = isDark
                            ? Colors.white.withOpacity(0.15)
                            : Colors.black.withOpacity(0.1);

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: tableBorderColor),
                            color: isDark
                                ? Colors.white.withOpacity(0.02)
                                : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  isDark ? 0.15 : 0.04,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Table header label
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  color: primaryColor.withOpacity(
                                    isDark ? 0.15 : 0.07,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.table_chart_outlined,
                                        size: 14,
                                        color: primaryColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        l10n.tableLabel,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: primaryColor,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  height: 1,
                                  color: tableBorderColor,
                                ),
                                // Horizontally scrollable table body
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: MarkdownBody(
                                      data: segment.markdownTable,
                                      styleSheet:
                                          MarkdownStyleSheet.fromTheme(
                                            Theme.of(context),
                                          ).copyWith(
                                            tableBorder: TableBorder.all(
                                              color: tableBorderColor,
                                              width: 1,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            tableBody: TextStyle(
                                              fontSize: 13.5 * fontScale,
                                              color: tableTextColor,
                                              height: 1.4,
                                            ),
                                            tableHead: TextStyle(
                                              fontSize: 13.5 * fontScale,
                                              fontWeight: FontWeight.bold,
                                              color: tableHeaderColor,
                                            ),
                                            tableHeadAlign:
                                                TextAlign.center,
                                            tableCellsPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 10,
                                            ),
                                            tableColumnWidth:
                                                const IntrinsicColumnWidth(),
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (segment is ImageSegment) {
                        return GestureDetector(
                          onTap: () => showDialog(
                            context: context,
                            builder: (ctx) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.all(12),
                              child: Stack(
                                children: [
                                  InteractiveViewer(
                                    minScale: 0.5,
                                    maxScale: 5.0,
                                    child: CachedNetworkImage(
                                      imageUrl: segment.imageUrl,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => Navigator.pop(ctx),
                                      child: Container(
                                        margin: const EdgeInsets.all(8),
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.08),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    isDark ? 0.2 : 0.06,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  // Image with aspect-ratio placeholder
                                  AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: CachedNetworkImage(
                                      imageUrl: segment.imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          Container(
                                        color: isDark
                                            ? Colors.white.withOpacity(0.05)
                                            : Colors.black.withOpacity(0.04),
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: primaryColor
                                                    .withOpacity(0.5),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                l10n.loadingImage,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isDark
                                                      ? Colors.white38
                                                      : Colors.black38,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: isDark
                                            ? Colors.white.withOpacity(0.04)
                                            : Colors.black.withOpacity(0.03),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.broken_image_outlined,
                                              size: 36,
                                              color: isDark
                                                  ? Colors.white24
                                                  : Colors.black26,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              l10n.imageUnavailable,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark
                                                    ? Colors.white38
                                                    : Colors.black38,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Tap hint + caption footer
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    color: isDark
                                        ? Colors.white.withOpacity(0.04)
                                        : Colors.black.withOpacity(0.03),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.photo_outlined,
                                          size: 14,
                                          color: isDark
                                              ? Colors.white38
                                              : Colors.black38,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            segment.altText.isNotEmpty
                                                ? segment.altText
                                                : l10n.tapToZoom,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontStyle: segment
                                                      .altText.isNotEmpty
                                                  ? FontStyle.italic
                                                  : FontStyle.normal,
                                              color: isDark
                                                  ? Colors.white54
                                                  : Colors.black54,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.zoom_out_map_rounded,
                                          size: 14,
                                          color: isDark
                                              ? Colors.white.withOpacity(0.3)
                                              : Colors.black.withOpacity(0.3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }).toList(),
                  ),
                  if (activeNote != null) ...[
                    const SizedBox(height: 16),
                    _buildNoteCard(context, ref, paragraph, activeNote, isDark, activeHighlights),
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
    LearnLesson lesson,
    LearnParagraph paragraph,
    Color primaryColor,
    List<LearnParagraph> allParagraphs,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final interactionState = ref.read(interactionProvider((
      id: widget.courseId,
      type: InteractionType.lesson,
    )));
    final activeHighlights = interactionState.optimisticHighlights[paragraph.id] ?? paragraph.highlights;
    final optimisticNoteText = interactionState.optimisticNotes[paragraph.id];
    final hasNote = (optimisticNoteText != null && optimisticNoteText.isNotEmpty) ||
        (optimisticNoteText == null && paragraph.myNote != null);

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
              _showNoteEditor(context, ref, paragraph, activeHighlights, autoAction: value);
            } else {
              _showUpgradeDialog(context);
            }
            break;
          case 'note':
            _showNoteEditor(context, ref, paragraph, activeHighlights);
            break;
           case 'active_recall':
            _showActiveRecall(context, lesson, paragraph: paragraph);
            break;
          case 'delete_note':
            if (hasNote) {
              ref
                  .read(
                    interactionProvider((
                      id: widget.courseId,
                      type: InteractionType.lesson,
                    )).notifier,
                  )
                  .deleteParagraphNote(paragraph.id, paragraph.myNote?.id);
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
                l10n.listen,
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
                hasNote ? l10n.editNote : l10n.addNote,
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
                l10n.aiExplain,
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
                l10n.aiSummarize,
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
                l10n.aiMnemonic,
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: 'active_recall',
          child: Row(
            children: [
              Icon(Iconsax.refresh, color: primaryColor, size: 20),
              const SizedBox(width: 12),
              Text(
                l10n.activeRecall,
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        if (hasNote) ...[
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
                  l10n.deleteNote,
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

  void _showActiveRecall(
    BuildContext context,
    LearnLesson lesson, {
    LearnParagraph? paragraph,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ActiveRecallBottomSheet(
        lesson: lesson,
        paragraph: paragraph,
      ),
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
            Expanded(
              child: Text(
                l10n.sq3rReadingModeTitle,
                style: const TextStyle(
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
              child: Text(l10n.returnToSq3r),
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
    final l10n = AppLocalizations.of(context)!;
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
            Text(
              l10n.highlightColorTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: _highlightColors.map((color) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final queryText = selectedText.trim();
                      final startIndex = paragraph.content.indexOf(queryText);
                      if (startIndex == -1) {
                        return; // Prevent crashes if text changed
                      }

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
    final l10n = AppLocalizations.of(context)!;
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                l10n.highlightOptionsTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              title: Text(l10n.editNote),
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
              title: Text(l10n.deleteHighlight),
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
    final optimisticNoteText = ref.read(
      interactionProvider((
        id: widget.courseId,
        type: InteractionType.lesson,
      )),
    ).optimisticNotes[paragraph.id];

    final initialNoteVal = highlight?.note ??
        optimisticNoteText ??
        paragraph.myNote?.text ??
        "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NoteEditorBottomSheet(
        initialValue: initialNoteVal,
        onSave: (newNote) {
          if (highlight != null) {
            interactionNotifier.updateHighlightNote(
              paragraph.id,
              currentHighlights,
              highlight.id,
              newNote,
            );
          } else if (selectedText != null && selectedText.isNotEmpty) {
            final queryText = selectedText.trim();
            final startIndex = paragraph.content.indexOf(queryText);
            if (startIndex != -1) {
              final defaultColor = _highlightColors.first;
              final newHighlight = HighlightModel(
                id: const Uuid().v4(),
                text: queryText,
                color: defaultColor,
                start: startIndex,
                end: startIndex + queryText.length,
                note: newNote,
              );
              interactionNotifier.addHighlight(
                paragraph.id,
                currentHighlights,
                newHighlight,
              );
            }
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
            interactionNotifier.deleteParagraphNote(paragraph.id, paragraph.myNote?.id);
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
    List<HighlightModel> currentHighlights,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(isDark ? 0.04 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber.withOpacity(isDark ? 0.15 : 0.25),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Colors.amber[600]!, width: 5),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   Icon(Iconsax.note_1, size: 18, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  Text(
                    l10n.studyNote,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.amber[700],
                    ),
                  ),
                  const Spacer(),
                  // Edit Button
                  GestureDetector(
                    onTap: () => _showNoteEditor(context, ref, paragraph, currentHighlights),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.edit_2,
                        size: 14,
                        color: Colors.amber[800],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Delete Button
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(
                            interactionProvider((
                              id: widget.courseId,
                              type: InteractionType.lesson,
                            )).notifier,
                          )
                          .deleteParagraphNote(paragraph.id, paragraph.myNote?.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.trash,
                        size: 14,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (note.text != null && note.text!.isNotEmpty)
                QuillSimpleViewer(
                  content: note.text!,
                  textColor: isDark ? Colors.white70 : Colors.black87,
                )
              else
                Text(
                  l10n.emptyNoteHint,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
            ],
          ),
        ),
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

  Widget _buildVideoBanner(
    BuildContext context,
    Color primaryColor,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Iconsax.video_play, color: primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Interactive Video Lecture Available",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  "Watch a dynamic lecture explaining this lesson.",
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _activeMode = ReaderMode.watch;
                _showVideoPlayer = true;
                _isMiniPlayer = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Watch Now",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

abstract class ParagraphSegment {
  final int startOffset;
  ParagraphSegment(this.startOffset);
}

class TextSegment extends ParagraphSegment {
  final String text;
  TextSegment(this.text, int startOffset) : super(startOffset);
}

class MarkdownBlockSegment extends ParagraphSegment {
  final String markdown;
  MarkdownBlockSegment(this.markdown, int startOffset) : super(startOffset);
}

class TableSegment extends ParagraphSegment {
  final String markdownTable;
  TableSegment(this.markdownTable, int startOffset) : super(startOffset);
}

class ImageSegment extends ParagraphSegment {
  final String altText;
  final String imageUrl;
  ImageSegment({
    required this.altText,
    required this.imageUrl,
    required int startOffset,
  }) : super(startOffset);
}

/// Returns true when a line should be rendered as a markdown block element
/// (heading, bullet list, numbered list, blockquote, HR, code fence).
bool _isMarkdownBlockLine(String trimmed) {
  if (trimmed.isEmpty) return false;
  // Headings: # / ## / ###
  if (RegExp(r'^#{1,6}\s').hasMatch(trimmed)) return true;
  // Unordered list: -, *, +
  if (RegExp(r'^[-*+]\s').hasMatch(trimmed)) return true;
  // Ordered list: 1. 2. etc.
  if (RegExp(r'^\d+\.\s').hasMatch(trimmed)) return true;
  // Blockquote
  if (trimmed.startsWith('> ')) return true;
  // Horizontal rule
  if (RegExp(r'^[-*_]{3,}$').hasMatch(trimmed)) return true;
  // Code fence
  if (trimmed.startsWith('```') || trimmed.startsWith('~~~')) return true;
  return false;
}

List<ParagraphSegment> parseParagraphContent(String content) {
  final List<ParagraphSegment> segments = [];
  final lines = content.split('\n');

  int currentPos = 0;

  // Buffers for the three kinds of line-groups
  List<String> textBuffer = [];
  int textStartOffset = 0;

  List<String> tableBuffer = [];
  int tableStartOffset = 0;

  List<String> mdBlockBuffer = [];
  int mdBlockStartOffset = 0;
  bool inCodeFence = false; // tracks ``` blocks

  void flushText() {
    if (textBuffer.isNotEmpty) {
      final text = textBuffer.join('\n');
      if (text.trim().isNotEmpty) {
        segments.add(TextSegment(text, textStartOffset));
      }
      textBuffer.clear();
    }
  }

  void flushTable() {
    if (tableBuffer.isNotEmpty) {
      final table = tableBuffer.join('\n');
      segments.add(TableSegment(table, tableStartOffset));
      tableBuffer.clear();
    }
  }

  void flushMdBlock() {
    if (mdBlockBuffer.isNotEmpty) {
      final md = mdBlockBuffer.join('\n');
      segments.add(MarkdownBlockSegment(md, mdBlockStartOffset));
      mdBlockBuffer.clear();
      inCodeFence = false;
    }
  }

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmed = line.trim();

    // ── Image: ![alt](url) ──────────────────────────────────────────────────
    final imageRegex = RegExp(r'^!\[(.*?)\]\((.*?)\)$');
    final imageMatch = imageRegex.firstMatch(trimmed);

    if (imageMatch != null) {
      flushMdBlock();
      flushTable();
      flushText();
      segments.add(
        ImageSegment(
          altText: imageMatch.group(1) ?? '',
          imageUrl: imageMatch.group(2) ?? '',
          startOffset: currentPos,
        ),
      );
    } else {
      // ── Table row: starts and ends with | ─────────────────────────────────
      final isTableRow =
          trimmed.startsWith('|') &&
          trimmed.endsWith('|') &&
          trimmed.contains('|');

      if (isTableRow) {
        flushMdBlock();
        flushText();
        if (tableBuffer.isEmpty) tableStartOffset = currentPos;
        tableBuffer.add(line);
      } else {
        flushTable();

        // Track code-fence toggle so the whole block stays together
        if (trimmed.startsWith('```') || trimmed.startsWith('~~~')) {
          inCodeFence = !inCodeFence;
        }

        // ── Markdown block element (or we're inside a code fence) ──────────
        if (inCodeFence || _isMarkdownBlockLine(trimmed)) {
          flushText();
          if (mdBlockBuffer.isEmpty) mdBlockStartOffset = currentPos;
          mdBlockBuffer.add(line);
        } else if (trimmed.isEmpty && mdBlockBuffer.isNotEmpty) {
          // A blank line that continues/terminates a markdown block
          mdBlockBuffer.add(line);
        } else {
          // Plain prose – flush any accumulated md block first
          flushMdBlock();
          if (textBuffer.isEmpty) textStartOffset = currentPos;
          textBuffer.add(line);
        }
      }
    }

    currentPos += line.length + 1; // +1 for the '\n' character
  }

  flushTable();
  flushMdBlock();
  flushText();

  return segments;
}

// ─── Interactive Video Player & Visualizer Widgets ──────────────────────────

// ─── Interactive Video Player & Visualizer Widgets ──────────────────────────

class LessonVideoPlayer extends StatefulWidget {
  final LearnLesson lesson;
  final bool isMini;
  final bool isWatchMode;
  final VoidCallback onClose;
  final Function(int)? onParagraphSelected;

  const LessonVideoPlayer({
    super.key,
    required this.lesson,
    this.isMini = false,
    this.isWatchMode = false,
    required this.onClose,
    this.onParagraphSelected,
  });

  @override
  State<LessonVideoPlayer> createState() => _LessonVideoPlayerState();
}

class _LessonVideoPlayerState extends State<LessonVideoPlayer>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late TabController _tabController;
  Timer? _playbackTimer;
  bool _isPlaying = false;
  int _currentTimeSeconds = 0;
  double _playbackSpeed = 1.0;
  bool _showSubtitles = true;
  bool _isMuted = false;
  late int _totalDuration;

  // Personal notes state
  final List<Map<String, dynamic>> _userNotes = [];
  final TextEditingController _noteInputController = TextEditingController();

  // Chat Q&A state
  final List<Map<String, String>> _chatMessages = [];
  final TextEditingController _chatInputController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  bool _isAiTyping = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _tabController = TabController(length: 4, vsync: this);

    final paragraphCount = widget.lesson.paragraphs?.length ?? 0;
    _totalDuration = paragraphCount > 0 ? paragraphCount * 45 : 180;

    // Initialize mock notes
    _userNotes.addAll([
      {
        'time': 10,
        'text': 'Key introduction and background on ${widget.lesson.title}.',
      },
      {
        'time': 35,
        'text': 'Pay attention to diagnostic criteria mentioned here.',
      }
    ]);

    // Initialize AI chat greeting
    _chatMessages.add({
      'sender': 'ai',
      'text': 'Hello! I am Dr. Marc, your AI tutor. Ask me any questions about the video lecture or clinical material!',
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _tabController.dispose();
    _playbackTimer?.cancel();
    _noteInputController.dispose();
    _chatInputController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startPlaybackTimer();
      } else {
        _playbackTimer?.cancel();
      }
    });
  }

  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    final intervalMs = (1000 / _playbackSpeed).round();
    _playbackTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_currentTimeSeconds < _totalDuration) {
          _currentTimeSeconds++;
          
          // Trigger paragraph highlight as video plays
          final paragraphCount = widget.lesson.paragraphs?.length ?? 0;
          if (paragraphCount > 0) {
            final activeIndex = (_currentTimeSeconds / 45).floor().clamp(0, paragraphCount - 1);
            widget.onParagraphSelected?.call(activeIndex);
          }
        } else {
          _isPlaying = false;
          _currentTimeSeconds = 0;
          _playbackTimer?.cancel();
        }
      });
    });
  }

  void _changeSpeed() {
    setState(() {
      if (_playbackSpeed == 1.0) {
        _playbackSpeed = 1.5;
      } else if (_playbackSpeed == 1.5) {
        _playbackSpeed = 2.0;
      } else {
        _playbackSpeed = 1.0;
      }
      if (_isPlaying) {
        _startPlaybackTimer();
      }
    });
  }

  String _formatDuration(int totalSecs) {
    final minutes = (totalSecs / 60).floor().toString().padLeft(2, '0');
    final seconds = (totalSecs % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _sendChatMessage() {
    final text = _chatInputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatMessages.add({
        'sender': 'user',
        'text': text,
      });
      _chatInputController.clear();
      _isAiTyping = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    Timer(const Duration(seconds: 1), () {
      if (!mounted) return;

      String aiReply = "Regarding your question about this lecture: ";
      final query = text.toLowerCase();
      bool found = false;
      
      final paragraphs = widget.lesson.paragraphs ?? [];
      for (int i = 0; i < paragraphs.length; i++) {
        final p = paragraphs[i];
        final title = p.title?.toLowerCase() ?? '';
        final content = p.content.toLowerCase();
        
        if ((title.isNotEmpty && query.contains(title)) || 
            (content.contains(query) && query.length > 3)) {
          final cleanContent = p.content.replaceAll(RegExp(r'[#*|_\-\[\]\(\)]'), '').trim();
          final displayContent = cleanContent.length > 200 ? '${cleanContent.substring(0, 197)}...' : cleanContent;
          final time = i * 45;
          aiReply += "As explained at ${_formatDuration(time)} during the slide '${p.title ?? 'Section ${i + 1}'}': \"$displayContent\"";
          found = true;
          break;
        }
      }

      if (!found && paragraphs.isNotEmpty) {
        final cleanContent = paragraphs.first.content.replaceAll(RegExp(r'[#*|_\-\[\]\(\)]'), '').trim();
        final displayContent = cleanContent.length > 150 ? '${cleanContent.substring(0, 147)}...' : cleanContent;
        aiReply += "At the start of the lecture (00:00), we discuss: \"$displayContent\"";
      }

      setState(() {
        _chatMessages.add({
          'sender': 'ai',
          'text': aiReply,
        });
        _isAiTyping = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_chatScrollController.hasClients) {
          _chatScrollController.animateTo(
            _chatScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  Widget _buildChaptersTab(
    List<LearnParagraph> paragraphs,
    Color tabTextColor,
    Color tabSecondaryTextColor,
    Color borderDividerColor,
    Color primaryColor,
    bool isDark,
  ) {
    if (paragraphs.isEmpty) {
      return Center(
        child: Text(
          'No chapters available.',
          style: TextStyle(color: tabSecondaryTextColor, fontSize: 11),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: paragraphs.length,
      itemBuilder: (context, index) {
        final p = paragraphs[index];
        final title = p.title ?? "Section ${index + 1}";
        final startSec = index * 45;
        final isCurrent = _currentTimeSeconds >= startSec && _currentTimeSeconds < (index + 1) * 45;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _currentTimeSeconds = startSec;
                if (_isPlaying) _startPlaybackTimer();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderDividerColor)),
              ),
              child: Row(
                children: [
                  Icon(
                    isCurrent ? Iconsax.play_circle : Iconsax.verify,
                    color: isCurrent ? primaryColor : (isDark ? Colors.white38 : Colors.black38),
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isCurrent ? primaryColor : tabTextColor,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    _formatDuration(startSec),
                    style: TextStyle(color: tabSecondaryTextColor, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTranscriptTab(
    List<LearnParagraph> paragraphs,
    Color tabTextColor,
    Color tabSecondaryTextColor,
    Color primaryColor,
    bool isDark,
  ) {
    if (paragraphs.isEmpty) {
      return Center(
        child: Text(
          'No transcript transcriptions available.',
          style: TextStyle(color: tabSecondaryTextColor, fontSize: 11),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: paragraphs.length,
      itemBuilder: (context, index) {
        final p = paragraphs[index];
        String text = p.content.replaceAll(RegExp(r'[#*|_\-\[\]\(\)]'), '').trim();
        if (text.length > 140) {
          text = '${text.substring(0, 137)}...';
        }
        final startSec = index * 45;
        final isCurrent = _currentTimeSeconds >= startSec && _currentTimeSeconds < (index + 1) * 45;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _currentTimeSeconds = startSec;
                if (_isPlaying) _startPlaybackTimer();
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: isCurrent ? (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '[${_formatDuration(startSec)}]',
                    style: TextStyle(
                      color: isCurrent ? primaryColor : (isDark ? Colors.cyan : Colors.teal),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: isCurrent ? tabTextColor : tabSecondaryTextColor,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotesTab(
    Color tabTextColor,
    Color tabSecondaryTextColor,
    Color borderDividerColor,
    Color primaryColor,
    bool isDark,
  ) {
    return Column(
      children: [
        Expanded(
          child: _userNotes.isEmpty
              ? Center(
                  child: Text(
                    'No video notes yet. Type below to save a timestamped note!',
                    style: TextStyle(color: tabSecondaryTextColor, fontSize: 11),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _userNotes.length,
                  itemBuilder: (context, index) {
                    final note = _userNotes[index];
                    final noteTime = note['time'] as int;
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: borderDividerColor)),
                      ),
                      child: ListTile(
                        dense: true,
                         leading: IconButton(
                          icon: Icon(Iconsax.play_circle, color: primaryColor, size: 20),
                          onPressed: () {
                            setState(() {
                              _currentTimeSeconds = noteTime;
                              if (_isPlaying) _startPlaybackTimer();
                            });
                          },
                        ),
                        title: Text(
                          note['text'] as String,
                          style: TextStyle(color: tabTextColor, fontSize: 11),
                        ),
                        subtitle: Text(
                          'Timestamp: ${_formatDuration(noteTime)}',
                          style: TextStyle(color: tabSecondaryTextColor, fontSize: 9),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Iconsax.trash, color: Colors.redAccent, size: 16),
                          onPressed: () {
                            setState(() {
                              _userNotes.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03),
            border: Border(top: BorderSide(color: borderDividerColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteInputController,
                  style: TextStyle(color: tabTextColor, fontSize: 11),
                  decoration: InputDecoration(
                    hintText: 'Add note at ${_formatDuration(_currentTimeSeconds)}...',
                    hintStyle: TextStyle(color: tabSecondaryTextColor.withOpacity(0.6), fontSize: 11),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (_) => _saveNote(),
                ),
              ),
              IconButton(
                icon: Icon(Iconsax.note_1, color: primaryColor, size: 20),
                onPressed: _saveNote,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _saveNote() {
    final text = _noteInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _userNotes.add({
          'time': _currentTimeSeconds,
          'text': text,
        });
        _noteInputController.clear();
      });
    }
  }

  Widget _buildChatTab(
    Color tabTextColor,
    Color tabSecondaryTextColor,
    Color borderDividerColor,
    Color primaryColor,
    bool isDark,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _chatScrollController,
            padding: const EdgeInsets.all(8),
            itemCount: _chatMessages.length,
            itemBuilder: (context, index) {
              final msg = _chatMessages[index];
              final isAi = msg['sender'] == 'ai';
              return Align(
                alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 280),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isAi 
                        ? (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04))
                        : primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isAi 
                          ? (isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.1))
                          : primaryColor.withOpacity(0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAi ? 'Dr. Marc (AI Tutor)' : 'You',
                        style: TextStyle(
                          color: isAi ? (isDark ? Colors.cyanAccent : Colors.teal) : primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        msg['text'] ?? '',
                        style: TextStyle(color: tabTextColor, fontSize: 11, height: 1.3),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_isAiTyping)
          Padding(
            padding: const EdgeInsets.all(6),
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: primaryColor),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03),
            border: Border(top: BorderSide(color: borderDividerColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatInputController,
                  style: TextStyle(color: tabTextColor, fontSize: 11),
                  decoration: InputDecoration(
                    hintText: 'Ask a question about this lecture...',
                    hintStyle: TextStyle(color: tabSecondaryTextColor.withOpacity(0.6), fontSize: 11),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (_) => _sendChatMessage(),
                ),
              ),
              IconButton(
                icon: Icon(Iconsax.send_1, color: primaryColor, size: 16),
                onPressed: _sendChatMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final tabBgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final tabTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final tabSecondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderDividerColor = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08);

    final paragraphs = widget.lesson.paragraphs ?? [];
    final paragraphCount = paragraphs.length;

    // Determine current active slide / subtitle
    String slideTitle = widget.lesson.title;
    String subtitleText = "Welcome to the video lecture. Tap play to start learning.";

    if (paragraphCount > 0 && _currentTimeSeconds > 0) {
      final activeIndex = (_currentTimeSeconds / 45).floor().clamp(0, paragraphCount - 1);
      final activeParagraph = paragraphs[activeIndex];
      slideTitle = activeParagraph.title ?? "Section ${activeIndex + 1}";
      subtitleText = activeParagraph.content;
      // Clean content markup for clean subtitle rendering
      subtitleText = subtitleText.replaceAll(RegExp(r'[#*|_\-\[\]\(\)]'), '').trim();
      if (subtitleText.length > 120) {
        subtitleText = '${subtitleText.substring(0, 117)}...';
      }
    }

    if (widget.isMini) {
      return Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(16),
        color: Colors.black,
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: 170,
          height: 110,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[900]!, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: EcgWavePainter(
                        _isPlaying ? _waveController.value : 0.0,
                        Colors.cyanAccent.withOpacity(0.15),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Text(
                  slideTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Center(
                child: IconButton(
                  icon: Icon(
                    _isPlaying ? Iconsax.pause_circle : Iconsax.play_circle,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: _togglePlay,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Iconsax.close_circle, color: Colors.white70, size: 16),
                  onPressed: widget.onClose,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  color: Colors.grey[800],
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _totalDuration > 0 ? (_currentTimeSeconds / _totalDuration).clamp(0.0, 1.0) : 0.0,
                    child: Container(color: Colors.cyanAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: widget.isWatchMode ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: widget.isWatchMode ? BorderRadius.zero : BorderRadius.circular(16),
        color: tabBgColor,
        boxShadow: widget.isWatchMode ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: widget.isWatchMode ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A237E), Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: EcgWavePainter(
                          _isPlaying ? _waveController.value : 0.0,
                          Colors.cyanAccent.withOpacity(0.12),
                        ),
                      );
                    },
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.cyanAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "VIDEO LESSON • DR. MARC",
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slideTitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: const Icon(Iconsax.user, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 8),
                            SpeakingVisualizer(isPlaying: _isPlaying),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showSubtitles)
                  Positioned(
                    bottom: 48,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Text(
                        subtitleText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Iconsax.pause : Iconsax.play,
                        color: Colors.white,
                      ),
                      onPressed: _togglePlay,
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                          activeTrackColor: Colors.cyanAccent,
                          inactiveTrackColor: Colors.white.withOpacity(0.2),
                          thumbColor: Colors.cyanAccent,
                        ),
                        child: Slider(
                          value: _totalDuration > 0 ? _currentTimeSeconds.toDouble() : 0.0,
                          min: 0.0,
                          max: _totalDuration.toDouble(),
                          onChanged: (val) {
                            setState(() {
                              _currentTimeSeconds = val.round();
                              if (_isPlaying) {
                                _startPlaybackTimer();
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    Text(
                      '${_formatDuration(_currentTimeSeconds)} / ${_formatDuration(_totalDuration)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _changeSpeed,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_playbackSpeed}x',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isMuted ? Iconsax.volume_mute : Iconsax.volume_high,
                        color: Colors.white70,
                        size: 16,
                      ),
                      onPressed: () {
                        setState(() {
                          _isMuted = !_isMuted;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Iconsax.message_text,
                        color: _showSubtitles ? Colors.cyanAccent : Colors.white70,
                        size: 16,
                      ),
                      onPressed: () {
                        setState(() {
                          _showSubtitles = !_showSubtitles;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
      Container(
        decoration: BoxDecoration(
          color: tabBgColor,
          border: Border(bottom: BorderSide(color: borderDividerColor)),
        ),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: tabSecondaryTextColor,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          tabs: const [
            Tab(text: 'Chapters'),
            Tab(text: 'Transcript'),
            Tab(text: 'Notes'),
            Tab(text: 'AI Tutor'),
          ],
        ),
      ),
      if (widget.isWatchMode)
        Expanded(
          child: Container(
            color: tabBgColor,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChaptersTab(paragraphs, tabTextColor, tabSecondaryTextColor, borderDividerColor, primaryColor, isDark),
                _buildTranscriptTab(paragraphs, tabTextColor, tabSecondaryTextColor, primaryColor, isDark),
                _buildNotesTab(tabTextColor, tabSecondaryTextColor, borderDividerColor, primaryColor, isDark),
                _buildChatTab(tabTextColor, tabSecondaryTextColor, borderDividerColor, primaryColor, isDark),
              ],
            ),
          ),
        )
      else
        Container(
          height: 240,
          color: tabBgColor,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildChaptersTab(paragraphs, tabTextColor, tabSecondaryTextColor, borderDividerColor, primaryColor, isDark),
              _buildTranscriptTab(paragraphs, tabTextColor, tabSecondaryTextColor, primaryColor, isDark),
              _buildNotesTab(tabTextColor, tabSecondaryTextColor, borderDividerColor, primaryColor, isDark),
              _buildChatTab(tabTextColor, tabSecondaryTextColor, borderDividerColor, primaryColor, isDark),
            ],
          ),
        ),
    ],
  ),
);
  }
}

class SpeakingVisualizer extends StatefulWidget {
  final bool isPlaying;
  const SpeakingVisualizer({super.key, required this.isPlaying});

  @override
  State<SpeakingVisualizer> createState() => _SpeakingVisualizerState();
}

class _SpeakingVisualizerState extends State<SpeakingVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _heights = List.generate(8, (_) => 5.0);
  final _random = Random();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);

    if (widget.isPlaying) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (mounted && widget.isPlaying) {
        setState(() {
          for (int i = 0; i < _heights.length; i++) {
            _heights[i] = 4.0 + _random.nextDouble() * 24.0;
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(SpeakingVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _startTimer();
      } else {
        _timer?.cancel();
        setState(() {
          _heights.fillRange(0, _heights.length, 5.0);
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(_heights.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          width: 3,
          height: _heights[index],
          decoration: BoxDecoration(
            color: Colors.cyanAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

class EcgWavePainter extends CustomPainter {
  final double animationVal;
  final Color color;
  EcgWavePainter(this.animationVal, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double width = size.width;
    final double height = size.height;
    final double midY = height / 2;

    path.moveTo(0, midY);

    for (double x = 0; x < width; x++) {
      final double normalizedX = x / width;
      double y = midY;

      final double phase = (normalizedX - animationVal) % 1.0;
      if (phase > 0.4 && phase < 0.6) {
        final double t = (phase - 0.4) / 0.2;
        if (t < 0.2) {
          y -= (t / 0.2) * 10;
        } else if (t < 0.3) {
          y += ((t - 0.2) / 0.1) * 5;
        } else if (t < 0.45) {
          y -= ((t - 0.3) / 0.15) * 45;
        } else if (t < 0.6) {
          y += ((t - 0.45) / 0.15) * 60;
        } else if (t < 0.75) {
          y -= ((t - 0.6) / 0.15) * 15;
        } else {
          y -= ((t - 0.75) / 0.25) * 15;
        }
      }

      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant EcgWavePainter oldDelegate) {
    return oldDelegate.animationVal != animationVal;
  }
}
