import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meducyte_app/core/themes/app_colors.dart';

class ScrabbleQuestion {
  final String id;
  final String definition;
  final String word; // Must be uppercase
  final List<String> scrambledLetters;
  final List<SlotMultiplier> multipliers;

  const ScrabbleQuestion({
    required this.id,
    required this.definition,
    required this.word,
    required this.scrambledLetters,
    required this.multipliers,
  });
}

enum MultiplierType { none, doubleLetter, tripleLetter, doubleWord, tripleWord }

class SlotMultiplier {
  final int index;
  final MultiplierType type;

  const SlotMultiplier(this.index, this.type);

  String get label {
    switch (type) {
      case MultiplierType.doubleLetter:
        return "LD";
      case MultiplierType.tripleLetter:
        return "LT";
      case MultiplierType.doubleWord:
        return "MD";
      case MultiplierType.tripleWord:
        return "MT";
      default:
        return "";
    }
  }

  Color get color {
    switch (type) {
      case MultiplierType.doubleLetter:
        return const Color(0xFF60A5FA); // Blue
      case MultiplierType.tripleLetter:
        return const Color(0xFF1D4ED8); // Dark Blue
      case MultiplierType.doubleWord:
        return const Color(0xFFF472B6); // Pink
      case MultiplierType.tripleWord:
        return const Color(0xFFDC2626); // Red
      default:
        return Colors.transparent;
    }
  }
}

// Scrabble questions with custom multiplier grids for realism
const List<ScrabbleQuestion> scrabbleQuestions = [
  ScrabbleQuestion(
    id: 's1',
    definition: "Hormone hypoglycémiante sécrétée par les cellules bêta des îlots de Langerhans du pancréas.",
    word: "INSULINE",
    scrambledLetters: ["I", "N", "S", "U", "L", "I", "N", "E", "O", "P"],
    multipliers: [
      SlotMultiplier(1, MultiplierType.doubleLetter),
      SlotMultiplier(4, MultiplierType.tripleLetter),
      SlotMultiplier(7, MultiplierType.doubleWord),
    ],
  ),
  ScrabbleQuestion(
    id: 's2',
    definition: "Cellule excitable constituant l'unité fonctionnelle et structurelle de base du système nerveux.",
    word: "NEURONE",
    scrambledLetters: ["N", "E", "U", "R", "O", "N", "E", "T", "L", "A"],
    multipliers: [
      SlotMultiplier(0, MultiplierType.doubleWord),
      SlotMultiplier(3, MultiplierType.doubleLetter),
      SlotMultiplier(6, MultiplierType.tripleLetter),
    ],
  ),
  ScrabbleQuestion(
    id: 's3',
    definition: "Phase de contraction active des ventricules du cœur permettant l'éjection épurée du sang dans l'organisme.",
    word: "SYSTOLE",
    scrambledLetters: ["S", "Y", "S", "T", "O", "L", "E", "M", "I", "D"],
    multipliers: [
      SlotMultiplier(1, MultiplierType.tripleLetter),
      SlotMultiplier(5, MultiplierType.doubleLetter),
      SlotMultiplier(6, MultiplierType.tripleWord),
    ],
  ),
  ScrabbleQuestion(
    id: 's4',
    definition: "Substance inactive administrée en recherche clinique pour évaluer l'effet de contrôle thérapeutique.",
    word: "PLACEBO",
    scrambledLetters: ["P", "L", "A", "C", "E", "B", "O", "X", "U", "S"],
    multipliers: [
      SlotMultiplier(2, MultiplierType.doubleLetter),
      SlotMultiplier(4, MultiplierType.doubleWord),
      SlotMultiplier(6, MultiplierType.tripleLetter),
    ],
  ),
  ScrabbleQuestion(
    id: 's5',
    definition: "Coloration jaune des téguments due à une rétention sanguine et tissulaire de bilirubine.",
    word: "ICTERE",
    scrambledLetters: ["I", "C", "T", "E", "R", "E", "V", "B", "Z", "F"],
    multipliers: [
      SlotMultiplier(0, MultiplierType.tripleLetter),
      SlotMultiplier(3, MultiplierType.doubleLetter),
      SlotMultiplier(5, MultiplierType.tripleWord),
    ],
  ),
];

class MedicalScrabbleScreen extends StatefulWidget {
  const MedicalScrabbleScreen({super.key});

  @override
  State<MedicalScrabbleScreen> createState() => _MedicalScrabbleScreenState();
}

class _MedicalScrabbleScreenState extends State<MedicalScrabbleScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final List<int> _selectedIndices = [];
  bool _showError = false;
  bool _showSuccess = false;
  int _score = 0;
  int _hintsUsed = 0;

  // Real-time Timer variables
  Timer? _timer;
  int _timeLeft = 45; // 45 seconds per puzzle
  static const int _maxTime = 45;

  // Animation controller for general transitions
  late AnimationController _shakeController;
  List<String> _currentScrambled = [];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _startTimer();
    _loadQuestionData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _loadQuestionData() {
    if (_currentIndex < scrabbleQuestions.length) {
      setState(() {
        _currentScrambled = List.from(scrabbleQuestions[_currentIndex].scrambledLetters);
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = _maxTime;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
        _onTimeOut();
      }
    });
  }

  void _onTimeOut() {
    HapticFeedback.vibrate();
    setState(() {
      _showError = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Iconsax.clock, color: Colors.white),
            SizedBox(width: 8),
            Text("TEMPS ÉCOULÉ ! Une pénalité de score a été appliquée."),
          ],
        ),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    setState(() {
      _score = math.max(0, _score - 5);
      _startTimer(); // Restart timer for the same question
    });
  }

  int _getScrabblePoints(String char) {
    final c = char.toUpperCase();
    if ('AEILNORSTU'.contains(c)) return 1;
    if ('DGM'.contains(c)) return 2;
    if ('BCP'.contains(c)) return 3;
    if ('FHV'.contains(c)) return 4;
    if ('JQ'.contains(c)) return 8;
    if ('KWXYZ'.contains(c)) return 10;
    return 1;
  }

  void _onLetterTap(int index) {
    if (_showSuccess) return;

    HapticFeedback.selectionClick();
    setState(() {
      _showError = false;
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        final currentQuestion = scrabbleQuestions[_currentIndex];
        if (_selectedIndices.length < currentQuestion.word.length) {
          _selectedIndices.add(index);
        }
      }
    });
  }

  void _shuffleRack() {
    HapticFeedback.mediumImpact();
    setState(() {
      // Shuffle the list of scrambled letters
      _currentScrambled.shuffle();
      // Since we shuffled, we must clear selections to avoid index misalignments
      _selectedIndices.clear();
      _showError = false;
    });
  }

  void _clearSelection() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedIndices.clear();
      _showError = false;
    });
  }

  void _useHint() {
    final currentQuestion = scrabbleQuestions[_currentIndex];
    final targetWord = currentQuestion.word;

    // Find the next correct letter that is not filled
    for (int i = 0; i < targetWord.length; i++) {
      final targetLetter = targetWord[i];

      if (i < _selectedIndices.length) {
        final currentLetter = _currentScrambled[_selectedIndices[i]];
        if (currentLetter == targetLetter) {
          continue;
        }
      }

      int foundIndex = -1;
      for (int k = 0; k < _currentScrambled.length; k++) {
        if (_currentScrambled[k] == targetLetter &&
            !_selectedIndices.sublist(0, math.min(i, _selectedIndices.length)).contains(k)) {
          foundIndex = k;
          break;
        }
      }

      if (foundIndex != -1) {
        HapticFeedback.mediumImpact();
        setState(() {
          if (i < _selectedIndices.length) {
            _selectedIndices[i] = foundIndex;
          } else {
            _selectedIndices.add(foundIndex);
          }
          _hintsUsed++;
        });
        return;
      }
    }
  }

  void _validateWord() {
    final currentQuestion = scrabbleQuestions[_currentIndex];
    final targetWord = currentQuestion.word;

    final userWord = _selectedIndices
        .map((idx) => _currentScrambled[idx])
        .join();

    if (userWord == targetWord) {
      _timer?.cancel();
      HapticFeedback.heavyImpact();

      // Calculation of detailed Scrabble points with board multipliers
      int wordPoints = 0;
      int wordMultiplier = 1;

      for (int i = 0; i < targetWord.length; i++) {
        final letter = targetWord[i];
        int letterScore = _getScrabblePoints(letter);

        // Find if this slot has a letter multiplier
        final slotMult = currentQuestion.multipliers.firstWhere(
          (m) => m.index == i,
          orElse: () => const SlotMultiplier(-1, MultiplierType.none),
        );

        if (slotMult.type == MultiplierType.doubleLetter) {
          letterScore *= 2;
        } else if (slotMult.type == MultiplierType.tripleLetter) {
          letterScore *= 3;
        } else if (slotMult.type == MultiplierType.doubleWord) {
          wordMultiplier *= 2;
        } else if (slotMult.type == MultiplierType.tripleWord) {
          wordMultiplier *= 3;
        }

        wordPoints += letterScore;
      }

      int totalEarned = (wordPoints * wordMultiplier) - (_hintsUsed * 2);
      
      // Speed bonus
      if (_timeLeft > 25) {
        totalEarned += 5; // Fast response bonus
      }

      setState(() {
        _showSuccess = true;
        _showError = false;
        _score += math.max(2, totalEarned);
      });
    } else {
      HapticFeedback.vibrate();
      _shakeController.forward(from: 0.0);
      setState(() {
        _showError = true;
      });
    }
  }

  void _nextQuestion() {
    setState(() {
      _currentIndex++;
      _selectedIndices.clear();
      _showSuccess = false;
      _showError = false;
      _hintsUsed = 0;
    });
    _loadQuestionData();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_currentIndex >= scrabbleQuestions.length) {
      return _buildScoreScreen(theme, isDark);
    }

    final currentQuestion = scrabbleQuestions[_currentIndex];
    final targetWordLength = currentQuestion.word.length;
    final totalRemainingTiles = (scrabbleQuestions.length - _currentIndex) * 8;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "SCRABBLE CLINIQUE",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2.0,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.box, size: 14, color: isDark ? Colors.white60 : Colors.black54),
                  const SizedBox(width: 4),
                  Text(
                    "Sac: $totalRemainingTiles",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HUD Dashboard
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Puzzles ${_currentIndex + 1}/${scrabbleQuestions.length}",
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Iconsax.clock,
                        color: _timeLeft < 15 ? Colors.red : AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${_timeLeft}s",
                        style: TextStyle(
                          color: _timeLeft < 15 ? Colors.red : (isDark ? Colors.white : Colors.black),
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Iconsax.award, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "Score: $_score pts",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_currentIndex) / scrabbleQuestions.length,
                  minHeight: 6,
                  backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 20),

              // Definition/Card Box
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Iconsax.document_text, color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "DEFINITION CLINIQUE",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.primary : Colors.blueGrey,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentQuestion.definition,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey.shade200 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Game multiplier grid / rules notice
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMultiplierBadge(MultiplierType.doubleLetter),
                      const SizedBox(width: 8),
                      _buildMultiplierBadge(MultiplierType.tripleLetter),
                      const SizedBox(width: 8),
                      _buildMultiplierBadge(MultiplierType.doubleWord),
                      const SizedBox(width: 8),
                      _buildMultiplierBadge(MultiplierType.tripleWord),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Word slots (the board)
              Center(
                child: AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    final double offset = math.sin(_shakeController.value * math.pi * 4) * 8 * (1.0 - _shakeController.value);
                    return Transform.translate(
                      offset: Offset(offset, 0),
                      child: child,
                    );
                  },
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: List.generate(targetWordLength, (i) {
                      final isPlaced = i < _selectedIndices.length;
                      final char = isPlaced ? _currentScrambled[_selectedIndices[i]] : "";
                      final point = isPlaced ? _getScrabblePoints(char) : 0;

                      // Check multiplier for this index
                      final slotMult = currentQuestion.multipliers.firstWhere(
                        (m) => m.index == i,
                        orElse: () => const SlotMultiplier(-1, MultiplierType.none),
                      );

                      Color boxBg = theme.cardColor;
                      Color borderColor = isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade300;

                      if (_showSuccess) {
                        boxBg = Colors.green.withOpacity(isDark ? 0.15 : 0.08);
                        borderColor = Colors.green;
                      } else if (_showError) {
                        boxBg = Colors.red.withOpacity(isDark ? 0.15 : 0.08);
                        borderColor = Colors.red;
                      } else if (isPlaced) {
                        boxBg = isDark ? const Color(0xFF3B2A1E) : const Color(0xFFFDF4E3);
                        borderColor = const Color(0xFFD97706);
                      } else if (slotMult.type != MultiplierType.none) {
                        boxBg = slotMult.color.withOpacity(0.12);
                        borderColor = slotMult.color.withOpacity(0.4);
                      }

                      return Container(
                        width: 40,
                        height: 46,
                        decoration: BoxDecoration(
                          color: boxBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor, width: 2),
                          boxShadow: isPlaced && !_showSuccess && !_showError
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Stack(
                          children: [
                            // Multiplier label in background if empty
                            if (!isPlaced && slotMult.type != MultiplierType.none)
                              Center(
                                child: Text(
                                  slotMult.label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: slotMult.color.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            if (isPlaced)
                              Center(
                                child: Text(
                                  char,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: _showSuccess
                                        ? Colors.green
                                        : (_showError ? Colors.red : (isDark ? Colors.amber.shade200 : Colors.brown.shade900)),
                                  ),
                                ),
                              ),
                            if (isPlaced)
                              Positioned(
                                bottom: 2,
                                right: 3,
                                child: Text(
                                  "$point",
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.amber.shade300 : Colors.brown.shade800,
                                  ),
                                ),
                              ),
                            // Small colored indicator to show placed letter is on multiplier
                            if (isPlaced && slotMult.type != MultiplierType.none)
                              Positioned(
                                top: 2,
                                left: 2,
                                child: Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: slotMult.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const Spacer(),

              // Letter rack bezel wrapper
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161C2A) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "RACK DE LETTRES",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                          ),
                        ),
                        GestureDetector(
                          onTap: _shuffleRack,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Iconsax.refresh, size: 12, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                "MÉLANGER",
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: List.generate(_currentScrambled.length, (index) {
                        final letter = _currentScrambled[index];
                        final isSelected = _selectedIndices.contains(index);
                        final point = _getScrabblePoints(letter);

                        return GestureDetector(
                          onTap: () => _onLetterTap(index),
                          child: Opacity(
                            opacity: isSelected ? 0.22 : 1.0,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 42,
                              height: 46,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2E1C13) : const Color(0xFFEAD8C9),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: isSelected
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
                                          blurRadius: 4,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                border: Border.all(
                                  color: isDark ? Colors.amber.shade900 : Colors.amber.shade700.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Text(
                                      letter,
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.amber.shade200 : Colors.brown.shade900,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 3,
                                    right: 4,
                                    child: Text(
                                      "$point",
                                      style: TextStyle(
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.amber.shade200.withOpacity(0.7) : Colors.brown.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Game Controls / Buttons
              if (_showSuccess)
                ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "MOT CORRECT - CONTINUER",
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clearSelection,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: theme.cardColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: isDark ? Colors.white12 : Colors.grey.shade300,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "EFFACER",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey.shade700,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _useHint,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.amber.withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.amber),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.flash, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text(
                              "INDICE",
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _selectedIndices.length == targetWordLength ? _validateWord : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "VALIDER",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMultiplierBadge(MultiplierType type) {
    String text = "";
    Color color = Colors.transparent;
    switch (type) {
      case MultiplierType.doubleLetter:
        text = "LD (x2)";
        color = const Color(0xFF60A5FA);
        break;
      case MultiplierType.tripleLetter:
        text = "LT (x3)";
        color = const Color(0xFF1D4ED8);
        break;
      case MultiplierType.doubleWord:
        text = "MD (x2)";
        color = const Color(0xFFF472B6);
        break;
      case MultiplierType.tripleWord:
        text = "MT (x3)";
        color = const Color(0xFFDC2626);
        break;
      default:
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _buildScoreScreen(ThemeData theme, bool isDark) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.cup, color: Colors.amber, size: 100),
              const SizedBox(height: 24),
              const Text(
                "PARTIE TERMINÉE",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Text(
                "Félicitations ! Vous avez complété tous les mots médicaux.",
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                ),
                child: Text(
                  "Score Final: $_score points",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 64),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "RETOUR AUX JEUX",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
