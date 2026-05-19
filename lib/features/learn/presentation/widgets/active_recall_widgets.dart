import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';

class ActiveRecallBottomSheet extends ConsumerStatefulWidget {
  final LearnLesson lesson;

  const ActiveRecallBottomSheet({super.key, required this.lesson});

  @override
  ConsumerState<ActiveRecallBottomSheet> createState() =>
      _ActiveRecallBottomSheetState();
}

class ClozeItem {
  final String sentence;
  final String answer;

  ClozeItem(this.sentence, this.answer);
}

class _ActiveRecallBottomSheetState
    extends ConsumerState<ActiveRecallBottomSheet> {
  bool _isLoading = true;
  List<ClozeItem> _clozeItems = [];
  int _currentIndex = 0;
  bool _isAnswerRevealed = false;
  final TextEditingController _inputController = TextEditingController();
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _generateQuestions());
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _generateQuestions() async {
    try {
      final language = Localizations.localeOf(context).languageCode;
      final response = await ref
          .read(noteAiRepositoryProvider)
          .getAiResponse(
            action: 'generate_cloze_recall',
            contextText:
                widget.lesson.paragraphs
                    ?.map((p) => "[SECTION]\n${p.content}")
                    .join("\n\n") ??
                "",
            language: language,
          );

      final items = response
          .split('\n')
          .map((line) {
            final parts = line.split('|');
            if (parts.length == 2) {
              return ClozeItem(parts[0].trim(), parts[1].trim());
            }
            return null;
          })
          .whereType<ClozeItem>()
          .toList();

      if (mounted) {
        setState(() {
          _clozeItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error generating content: $e")));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizTheme = Theme.of(context).extension<QuizThemeExtension>()!;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: quizTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(context, quizTheme, primaryColor),
          Expanded(
            child: _isLoading
                ? _buildLoadingState(primaryColor)
                : _buildSessionState(quizTheme, primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    QuizThemeExtension quizTheme,
    Color primaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Iconsax.refresh, color: primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Active Recall",
                  style: GoogleFonts.inter(
                    color: quizTheme.primaryTextColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.lesson.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: quizTheme.secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: quizTheme.secondaryTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            "Analyzing Lesson Content...",
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            "Generating active recall blanks",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionState(QuizThemeExtension quizTheme, Color primaryColor) {
    if (_clozeItems.isEmpty) {
      return const Center(child: Text("No items generated."));
    }

    final item = _clozeItems[_currentIndex];
    final parts = item.sentence.split('[blank]');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _clozeItems.length,
            backgroundColor: primaryColor.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Text(
            "Exercise${_currentIndex + 1}of${_clozeItems.length}",
            style: TextStyle(color: quizTheme.secondaryTextColor, fontSize: 13),
          ),
          const SizedBox(height: 48),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: quizTheme.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isCorrect == null
                    ? primaryColor.withOpacity(0.2)
                    : (_isCorrect! ? Colors.green : Colors.red),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      color: quizTheme.primaryTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(text: parts[0]),
                      WidgetSpan(
                        child: Container(
                          width: 120,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: TextField(
                            controller: _inputController,
                            enabled: !_isAnswerRevealed,
                            textAlign: TextAlign.center,
                            onSubmitted: (_) => _checkAnswer(),
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              hintText: "...",
                              hintStyle: TextStyle(
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (parts.length > 1) TextSpan(text: parts[1]),
                    ],
                  ),
                ),
                if (_isAnswerRevealed) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (_isCorrect ?? false)
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          (_isCorrect ?? false)
                              ? Icons.check_circle
                              : Icons.error,
                          color: (_isCorrect ?? false)
                              ? Colors.green
                              : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          (_isCorrect ?? false)
                              ? "Correct!"
                              : "Answer: ${item.answer}",
                          style: TextStyle(
                            color: (_isCorrect ?? false)
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 48),
          if (!_isAnswerRevealed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Check Answer",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _currentIndex < _clozeItems.length - 1
                      ? "Next Exercise"
                      : "Finish Session",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _checkAnswer() {
    if (_isAnswerRevealed) return;
    final item = _clozeItems[_currentIndex];
    final userInput = _inputController.text.trim().toLowerCase();
    final correctAnswer = item.answer.toLowerCase();

    //Basic exact matching
    final isCorrect = userInput == correctAnswer;

    setState(() {
      _isCorrect = isCorrect;
      _isAnswerRevealed = true;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _clozeItems.length - 1) {
      setState(() {
        _currentIndex++;
        _isAnswerRevealed = false;
        _isCorrect = null;
        _inputController.clear();
      });
    } else {
      _showCompletion();
    }
  }

  void _showCompletion() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 24),
            const Text(
              "Session Complete!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "You've covered all high-yield points for this lesson.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); //Pop bottom sheet
                  Navigator.pop(context); //Pop ActiveRecallBottomSheet
                },
                child: const Text("Finish"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
