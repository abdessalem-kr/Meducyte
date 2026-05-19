import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';

class Sq3rStudyBottomSheet extends ConsumerStatefulWidget {
  final LearnLesson lesson;
  final VoidCallback onStartReading;
  final int initialStep;
  final List<String> initialQuestions;
  final Map<int, String> initialAnswers;
  final Map<int, String> initialModelAnswers;
  final Function(
    int step,
    List<String> questions,
    Map<int, String> answers,
    Map<int, String> modelAnswers,
  )
  onStateChanged;

  const Sq3rStudyBottomSheet({
    super.key,
    required this.lesson,
    required this.onStartReading,
    required this.onStateChanged,
    this.initialStep = 0,
    this.initialQuestions = const [],
    this.initialAnswers = const {},
    this.initialModelAnswers = const {},
  });

  @override
  ConsumerState<Sq3rStudyBottomSheet> createState() =>
      _Sq3rStudyBottomSheetState();
}

class _Sq3rStudyBottomSheetState extends ConsumerState<Sq3rStudyBottomSheet> {
  late int _currentStep; //0:Survey,1:Question,2:Read,3:Recite,4:Review
  late final List<String> _questions;
  late final Map<int, String> _answers;
  late final Map<int, String> _modelAnswers;
  bool _isGeneratingQuestions = false;
  bool _isGeneratingAnswers = false;
  final TextEditingController _manualQuestionController =
      TextEditingController();
  final Map<int, bool> _expandedSections = {};

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    _questions = List.from(widget.initialQuestions);
    _answers = Map.from(widget.initialAnswers);
    _modelAnswers = Map.from(widget.initialModelAnswers);
  }

  @override
  void dispose() {
    _manualQuestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: quizTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildStepIndicator(primaryColor, quizTheme),
          _buildHeader(quizTheme, primaryColor),
          Expanded(child: _buildCurrentStep(quizTheme, primaryColor)),
          _buildBottomActions(primaryColor),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(Color primaryColor, QuizThemeExtension quizTheme) {
    final stepLabels = ["Survey", "Question", "Read", "Recite", "Review"];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Column(
        children: [
          Row(
            children: List.generate(5, (index) {
              final isActive = index <= _currentStep;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(right: index == 4 ? 0 : 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? primaryColor
                        : primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final isActive = index == _currentStep;
              return Expanded(
                child: Text(
                  stepLabels[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive
                        ? primaryColor
                        : quizTheme.secondaryTextColor.withOpacity(0.5),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(QuizThemeExtension quizTheme, Color primaryColor) {
    final stepIcons = [
      Iconsax.search_status,
      Iconsax.message_question,
      Iconsax.book_1,
      Iconsax.edit,
      Iconsax.tick_circle,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stepIcons[_currentStep], color: primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            widget.lesson.title,
            style: GoogleFonts.inter(
              color: quizTheme.secondaryTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: quizTheme.secondaryTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(QuizThemeExtension quizTheme, Color primaryColor) {
    switch (_currentStep) {
      case 0:
        return _buildSurveyStep(quizTheme, primaryColor);
      case 1:
        return _buildQuestionStep(quizTheme, primaryColor);
      case 2:
        return _buildReadStep(quizTheme);
      case 3:
        return _buildReciteStep(quizTheme, primaryColor);
      case 4:
        return _buildReviewStep(quizTheme, primaryColor);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSurveyStep(QuizThemeExtension quizTheme, Color primaryColor) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            "Scan the headings and subheadings to get an overview of the content.",
            style: TextStyle(color: quizTheme.secondaryTextColor, fontSize: 13),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: widget.lesson.paragraphs?.length ?? 0,
            itemBuilder: (context, index) {
              final p = widget.lesson.paragraphs![index];
              final isExpanded = _expandedSections[index] ?? false;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: quizTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isExpanded
                        ? primaryColor.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                ),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    onExpansionChanged: (val) =>
                        setState(() => _expandedSections[index] = val),
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: Text(
                        "${index + 1}",
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      p.title ?? "Section${index + 1}",
                      style: GoogleFonts.inter(
                        color: quizTheme.primaryTextColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          p.content,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: quizTheme.secondaryTextColor,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionStep(QuizThemeExtension quizTheme, Color primaryColor) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                "Turn headings into questions to focus your reading.",
                textAlign: TextAlign.center,
                style: TextStyle(color: quizTheme.secondaryTextColor),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _manualQuestionController,
                decoration: InputDecoration(
                  hintText: "Type your own question...",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add_circle, color: primaryColor),
                    onPressed: () {
                      if (_manualQuestionController.text.isNotEmpty) {
                        setState(() {
                          _questions.add(_manualQuestionController.text);
                          _manualQuestionController.clear();
                          widget.onStateChanged(
                            _currentStep,
                            _questions,
                            _answers,
                            _modelAnswers,
                          );
                        });
                      }
                    },
                  ),
                  filled: true,
                  fillColor: quizTheme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (val) {
                  if (val.isNotEmpty) {
                    setState(() {
                      _questions.add(val);
                      _manualQuestionController.clear();
                      widget.onStateChanged(
                        _currentStep,
                        _questions,
                        _answers,
                        _modelAnswers,
                      );
                    });
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _isGeneratingQuestions
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _questions.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _questions.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 24),
                        child: Center(
                          child: TextButton.icon(
                            onPressed: _generateAiQuestions,
                            icon: Icon(Iconsax.magic_star, size: 18),
                            label: Text("Generate more with AI"),
                          ),
                        ),
                      );
                    }
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _questions[index],
                              style: TextStyle(
                                color: quizTheme.primaryTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red.withOpacity(0.7),
                              size: 20,
                            ),
                            onPressed: () => setState(() {
                              _questions.removeAt(index);
                              widget.onStateChanged(
                                _currentStep,
                                _questions,
                                _answers,
                                _modelAnswers,
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildReadStep(QuizThemeExtension quizTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.book_1, size: 80, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Text(
              "Active Reading Phase",
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Read the lesson and highlight the answers to your questions.This is the core of the SQ3R method.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReciteStep(QuizThemeExtension quizTheme, Color primaryColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Iconsax.message_question, color: primaryColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _questions[index],
                      style: GoogleFonts.inter(
                        color: quizTheme.primaryTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                maxLines: null,
                onChanged: (val) {
                  _answers[index] = val;
                  widget.onStateChanged(
                    _currentStep,
                    _questions,
                    _answers,
                    _modelAnswers,
                  );
                },
                controller: TextEditingController(text: _answers[index] ?? ""),
                decoration: InputDecoration(
                  hintText: "Try to answer without looking...",
                  filled: true,
                  fillColor: quizTheme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: quizTheme.secondaryTextColor.withOpacity(0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: quizTheme.secondaryTextColor.withOpacity(0.1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewStep(QuizThemeExtension quizTheme, Color primaryColor) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(Iconsax.tick_circle, color: Colors.green, size: 48),
              const SizedBox(height: 12),
              const Text(
                "Review Your Session",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "Great job mastering this content!",
                style: TextStyle(color: quizTheme.secondaryTextColor),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: quizTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: quizTheme.secondaryTextColor.withOpacity(0.05),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.message_question,
                          color: primaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _questions[index],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildComparisonItem(
                      label: "YOUR RECALL",
                      content: _answers[index] ?? "No answer recorded.",
                      color: quizTheme.primaryTextColor,
                      isDimmed: _answers[index]?.isEmpty ?? true,
                    ),
                    const SizedBox(height: 12),
                    _buildComparisonItem(
                      label: "LESSON FOCUS",
                      content: _modelAnswers[index] ?? "Generating answer...",
                      color: primaryColor,
                      isItalic: true,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonItem({
    required String label,
    required String content,
    required Color color,
    bool isDimmed = false,
    bool isItalic = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.grey.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            color: isDimmed ? Colors.grey : color,
            height: 1.5,
            fontSize: 14,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            _currentStep == 0
                ? "Start Questioning"
                : (_currentStep == 2
                      ? "Start Reading"
                      : (_currentStep == 4 ? "Finish Session" : "Next Phase")),
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 2) {
      _currentStep++; //Move to Recite step for when they return
      widget.onStateChanged(_currentStep, _questions, _answers, _modelAnswers);
      widget.onStartReading();
      Navigator.pop(context);
    } else if (_currentStep < 4) {
      if (_currentStep == 3) {
        _generateModelAnswers();
      }
      if (_currentStep == 1 && _questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please add at least one question to focus on."),
          ),
        );
        return;
      }
      setState(() => _currentStep++);
      widget.onStateChanged(_currentStep, _questions, _answers, _modelAnswers);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _generateModelAnswers() async {
    if (_isGeneratingAnswers) return;
    setState(() => _isGeneratingAnswers = true);

    try {
      final language = Localizations.localeOf(context).languageCode;
      final contextText =
          widget.lesson.paragraphs?.map((p) => p.content).join("\n") ?? "";

      for (int i = 0; i < _questions.length; i++) {
        if (_modelAnswers.containsKey(i)) continue;

        final answer = await ref
            .read(noteAiRepositoryProvider)
            .getAiResponse(
              action: 'generate_answer',
              contextText: contextText,
              language: language,
              currentNote: _questions[i],
            );

        if (mounted) {
          setState(() {
            _modelAnswers[i] = answer;
            widget.onStateChanged(
              _currentStep,
              _questions,
              _answers,
              _modelAnswers,
            );
          });
        }
      }
    } catch (e) {
      debugPrint("Error generating model answers: $e");
    } finally {
      if (mounted) {
        setState(() => _isGeneratingAnswers = false);
      }
    }
  }

  Future<void> _generateAiQuestions() async {
    setState(() => _isGeneratingQuestions = true);
    try {
      final language = Localizations.localeOf(context).languageCode;
      final titles =
          widget.lesson.paragraphs
              ?.map((p) => p.title ?? "")
              .where((t) => t.isNotEmpty)
              .join(", ") ??
          "";

      final response = await ref
          .read(noteAiRepositoryProvider)
          .getAiResponse(
            action: 'generate_recall_session',
            contextText:
                "Generate questions based on these section headings: $titles",
            language: language,
          );

      final questions = response
          .split('\n')
          .map((e) => e.replaceAll(RegExp(r'^[-*0-9.]+\s*'), '').trim())
          .where((e) => e.isNotEmpty)
          .toList();

      setState(() {
        _questions.addAll(questions);
        _isGeneratingQuestions = false;
        widget.onStateChanged(
          _currentStep,
          _questions,
          _answers,
          _modelAnswers,
        );
      });
    } catch (e) {
      setState(() => _isGeneratingQuestions = false);
    }
  }
}
