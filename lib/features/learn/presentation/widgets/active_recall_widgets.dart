import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/core/themes/quiz_theme_extension.dart';

class ActiveRecallBottomSheet extends ConsumerStatefulWidget {
  final LearnLesson lesson;
  final LearnParagraph? paragraph;

  const ActiveRecallBottomSheet({
    super.key,
    required this.lesson,
    this.paragraph,
  });

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
  int _correctCount = 0;
  final FocusNode _focusNode = FocusNode();

  LearnParagraph? _selectedParagraph;
  int _currentParagraphIndex = -1; // -1 means single paragraph mode

  @override
  void initState() {
    super.initState();
    if (widget.paragraph != null) {
      _selectedParagraph = widget.paragraph;
      _currentParagraphIndex = -1;
    } else {
      _currentParagraphIndex = 0;
      final paragraphs = widget.lesson.paragraphs ?? [];
      if (paragraphs.isNotEmpty) {
        _selectedParagraph = paragraphs[0];
      }
    }
    Future.microtask(() => _generateQuestions());
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _nextParagraph() {
    if (widget.lesson.paragraphs != null &&
        _currentParagraphIndex < widget.lesson.paragraphs!.length - 1) {
      setState(() {
        _currentParagraphIndex++;
        _selectedParagraph = widget.lesson.paragraphs![_currentParagraphIndex];
        _clozeItems = [];
        _currentIndex = 0;
        _isAnswerRevealed = false;
        _isCorrect = null;
        _correctCount = 0;
        _inputController.clear();
        _isLoading = true;
      });
      _generateQuestions();
    }
  }

  Future<void> _generateQuestions() async {
    try {
      final language = Localizations.localeOf(context).languageCode;
      final String contextText;
      if (_selectedParagraph != null) {
        contextText = "[SECTION]\n${_selectedParagraph!.content}";
      } else {
        contextText = "";
      }

      final response = await ref
          .read(noteAiRepositoryProvider)
          .getAiResponse(
            action: 'generate_cloze_recall',
            contextText: contextText,
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
        Future.microtask(() => _focusNode.requestFocus());
      }
    } catch (e) {
      if (mounted) {
        AppSnackBars.error(context, e);
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
    final language = Localizations.localeOf(context).languageCode;
    final isFr = language == 'fr';

    final showBackButton = _currentParagraphIndex > 0;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (showBackButton) ...[
            IconButton(
              onPressed: () {
                setState(() {
                  _currentParagraphIndex--;
                  _selectedParagraph = widget.lesson.paragraphs![_currentParagraphIndex];
                  _clozeItems = [];
                  _currentIndex = 0;
                  _isAnswerRevealed = false;
                  _isCorrect = null;
                  _correctCount = 0;
                  _inputController.clear();
                  _isLoading = true;
                });
                _generateQuestions();
              },
              icon: Icon(Iconsax.arrow_left_2, color: quizTheme.secondaryTextColor),
            ),
            const SizedBox(width: 8),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Iconsax.refresh, color: primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
          ],
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
                  _currentParagraphIndex >= 0 && widget.lesson.paragraphs != null
                      ? (isFr
                          ? "Section ${_currentParagraphIndex + 1} sur ${widget.lesson.paragraphs!.length}"
                          : "Section ${_currentParagraphIndex + 1} of ${widget.lesson.paragraphs!.length}")
                      : (_selectedParagraph?.title ?? widget.lesson.title),
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
    final language = Localizations.localeOf(context).languageCode;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  backgroundColor: primaryColor.withOpacity(0.1),
                ),
              ),
              Icon(
                Iconsax.teacher,
                color: primaryColor,
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            _t('loading_title', language),
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _t('loading_subtitle', language),
            style: GoogleFonts.inter(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionState(QuizThemeExtension quizTheme, Color primaryColor) {
    final language = Localizations.localeOf(context).languageCode;
    if (_clozeItems.isEmpty) {
      final isFr = language == 'fr';
      final hasNextParagraph = widget.paragraph == null &&
          widget.lesson.paragraphs != null &&
          _currentParagraphIndex < widget.lesson.paragraphs!.length - 1;

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.danger, color: Colors.orange, size: 48),
              const SizedBox(height: 16),
              Text(
                isFr ? "Aucune question générée" : "No questions generated",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: quizTheme.primaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isFr
                    ? "L'IA n'a pas pu générer d'exercices pour ce paragraphe."
                    : "The AI was not able to generate exercises for this paragraph.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: quizTheme.secondaryTextColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });
                  _generateQuestions();
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(isFr ? "Réessayer" : "Retry"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (hasNextParagraph) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    _nextParagraph();
                  },
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: Text(isFr ? "Paragraphe suivant" : "Next Paragraph"),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final item = _clozeItems[_currentIndex];
    final parts = item.sentence.split('[blank]');

    return GestureDetector(
      onTap: () {
        if (!_isAnswerRevealed) {
          _focusNode.requestFocus();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SingleChildScrollView(
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
              _t('exercise_progress', language)
                  .replaceAll('{x}', '${_currentIndex + 1}')
                  .replaceAll('{y}', '${_clozeItems.length}'),
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
                          alignment: PlaceholderAlignment.middle,
                          child: Container(
                            width: (item.answer.length * 12.0 + 40.0).clamp(90.0, 240.0),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: TextField(
                              controller: _inputController,
                              focusNode: _focusNode,
                              enabled: !_isAnswerRevealed,
                              textAlign: TextAlign.center,
                              onSubmitted: (_) => _checkAnswer(),
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _isCorrect == null
                                    ? primaryColor
                                    : (_isCorrect! ? Colors.green : Colors.red),
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 10,
                                ),
                                hintText: "...",
                                hintStyle: TextStyle(
                                  color: quizTheme.secondaryTextColor.withOpacity(0.4),
                                ),
                                filled: true,
                                fillColor: _isCorrect == null
                                    ? primaryColor.withOpacity(0.05)
                                    : (_isCorrect!
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: _isCorrect == null
                                        ? primaryColor.withOpacity(0.3)
                                        : (_isCorrect! ? Colors.green : Colors.red),
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: _isCorrect == null
                                        ? primaryColor
                                        : (_isCorrect! ? Colors.green : Colors.red),
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: _isCorrect == null
                                        ? primaryColor.withOpacity(0.3)
                                        : (_isCorrect! ? Colors.green : Colors.red),
                                    width: 1.5,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: _isCorrect == null
                                        ? primaryColor.withOpacity(0.2)
                                        : (_isCorrect! ? Colors.green : Colors.red),
                                    width: 1.5,
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
                                ? _t('correct', language)
                                : _t('incorrect_answer', language).replaceAll('{val}', item.answer),
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
                  child: Text(
                    _t('check_answer', language),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              Column(
                children: [
                  if (_isCorrect == false) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isCorrect = true;
                            _correctCount++;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(
                          _t('i_was_correct', language),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
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
                            ? _t('next_exercise', language)
                            : _t('finish_session', language),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _cleanString(String str) {
    return str
        .toLowerCase()
        .replaceAll(RegExp(r"[.,\/#!$%\^&\*;:{}=\-_`~()?]"), "")
        .trim();
  }

  int _levenshteinDistance(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.generate(t.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = _min3(v1[j] + 1, v0[j + 1] + 1, v0[j] + cost);
      }
      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v0[t.length];
  }

  int _min3(int a, int b, int c) {
    int m = a < b ? a : b;
    return m < c ? m : c;
  }

  void _checkAnswer() {
    if (_isAnswerRevealed) return;
    final item = _clozeItems[_currentIndex];
    final userInput = _cleanString(_inputController.text);
    final correctAnswer = _cleanString(item.answer);

    bool isCorrect = userInput == correctAnswer;

    // Plural/singular normalization
    if (!isCorrect) {
      String uNormalized = userInput;
      String cNormalized = correctAnswer;
      if (uNormalized.endsWith('s')) {
        if (uNormalized.endsWith('es')) {
          uNormalized = uNormalized.substring(0, uNormalized.length - 2);
        } else {
          uNormalized = uNormalized.substring(0, uNormalized.length - 1);
        }
      }
      if (cNormalized.endsWith('s')) {
        if (cNormalized.endsWith('es')) {
          cNormalized = cNormalized.substring(0, cNormalized.length - 2);
        } else {
          cNormalized = cNormalized.substring(0, cNormalized.length - 1);
        }
      }
      if (uNormalized == cNormalized && uNormalized.isNotEmpty) {
        isCorrect = true;
      }
    }

    // Levenshtein distance check
    if (!isCorrect && userInput.isNotEmpty && correctAnswer.isNotEmpty) {
      final distance = _levenshteinDistance(userInput, correctAnswer);
      final len = correctAnswer.length;
      if (len >= 8 && distance <= 2) {
        isCorrect = true;
      } else if (len >= 5 && distance <= 1) {
        isCorrect = true;
      }
    }

    if (isCorrect) {
      _correctCount++;
    }

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
      Future.microtask(() => _focusNode.requestFocus());
    } else {
      _showCompletion();
    }
  }

  void _showCompletion() {
    final language = Localizations.localeOf(context).languageCode;
    final double percentage = _clozeItems.isNotEmpty
        ? (_correctCount / _clozeItems.length) * 100
        : 0;

    final hasNextParagraph = _currentParagraphIndex >= 0 &&
        widget.lesson.paragraphs != null &&
        _currentParagraphIndex < widget.lesson.paragraphs!.length - 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 10,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    backgroundColor: Colors.green.withOpacity(0.1),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${percentage.round()}%",
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      language == 'fr' ? "correct" : "correct",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              _t('session_complete', language),
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _t('score_summary', language)
                  .replaceAll('{x}', '$_correctCount')
                  .replaceAll('{y}', '${_clozeItems.length}'),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            if (hasNextParagraph) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Pop completion sheet
                    _nextParagraph();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    language == 'fr' ? "Section suivante" : "Next Section",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context); // Pop completion sheet
                    Navigator.pop(context); // Close Active Recall entirely
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    language == 'fr' ? "Quitter l'étude" : "Exit Study",
                    style: GoogleFonts.inter(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Pop bottom sheet
                    Navigator.pop(context); // Pop ActiveRecallBottomSheet
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _t('done', language),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _t(String key, String language) {
    final isFr = language == 'fr';
    switch (key) {
      case 'loading_title':
        return isFr ? "Analyse de la leçon..." : "Analyzing Lesson...";
      case 'loading_subtitle':
        return isFr
            ? "Génération des questions d'auto-évaluation..."
            : "Generating active recall blanks with AI";
      case 'exercise_progress':
        return isFr ? "Exercice {x} sur {y}" : "Exercise {x} of {y}";
      case 'check_answer':
        return isFr ? "Vérifier la réponse" : "Check Answer";
      case 'i_was_correct':
        return isFr ? "J'avais raison" : "I was correct";
      case 'next_exercise':
        return isFr ? "Exercice suivant" : "Next Exercise";
      case 'finish_session':
        return isFr ? "Terminer la session" : "Finish Session";
      case 'correct':
        return isFr ? "Correct !" : "Correct!";
      case 'incorrect_answer':
        return isFr ? "Réponse : {val}" : "Answer: {val}";
      case 'session_complete':
        return isFr ? "Session terminée !" : "Session Complete!";
      case 'score_summary':
        return isFr
            ? "Vous avez réussi {x} exercices sur {y}."
            : "You got {x} out of {y} exercises correct.";
      case 'done':
        return isFr ? "Terminé" : "Done";
      case 'no_items':
        return isFr ? "Aucun exercice généré." : "No items generated.";
      default:
        return "";
    }
  }
}
