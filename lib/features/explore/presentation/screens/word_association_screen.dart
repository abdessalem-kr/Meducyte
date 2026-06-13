import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meducyte_app/core/themes/app_colors.dart';

class WordSearchLevel {
  final int id;
  final String title;
  final String category;
  final List<String> words;
  final Map<String, String> wordDefinitions;
  final List<List<String>> grid;
  final Map<String, List<GridPosition>> wordPositions;

  const WordSearchLevel({
    required this.id,
    required this.title,
    required this.category,
    required this.words,
    required this.wordDefinitions,
    required this.grid,
    required this.wordPositions,
  });
}

class GridPosition {
  final int row;
  final int col;

  const GridPosition(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPosition && runtimeType == other.runtimeType && row == other.row && col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}

// Fixed level data for guaranteed clinical puzzles
final List<WordSearchLevel> levels = [
  WordSearchLevel(
    id: 1,
    title: "Les Organes",
    category: "Anatomie",
    words: ["POUMON", "COEUR", "FOIE", "REIN", "ESTOMAC"],
    wordDefinitions: {
      "POUMON": "Organe principal de la respiration assurant les échanges gazeux.",
      "COEUR": "Muscle creux qui propulse le sang à travers le système circulatoire.",
      "FOIE": "Glande endocrine et exocrine assurant la détoxification sanguine.",
      "REIN": "Organe de filtration du sang et de production de l'urine.",
      "ESTOMAC": "Poche digestive assurant le brassage des aliments ingérés.",
    },
    grid: [
      ['P', 'O', 'U', 'M', 'O', 'N', 'A', 'S'],
      ['T', 'C', 'R', 'F', 'O', 'I', 'E', 'H'],
      ['A', 'E', 'S', 'T', 'O', 'M', 'A', 'C'],
      ['G', 'O', 'K', 'J', 'U', 'W', 'P', 'R'],
      ['L', 'U', 'N', 'D', 'G', 'Z', 'F', 'K'],
      ['B', 'R', 'E', 'I', 'N', 'L', 'V', 'Y'],
      ['Z', 'M', 'T', 'R', 'Y', 'U', 'I', 'O'],
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'],
    ],
    wordPositions: {
      "POUMON": [
        GridPosition(0, 0), GridPosition(0, 1), GridPosition(0, 2),
        GridPosition(0, 3), GridPosition(0, 4), GridPosition(0, 5),
      ],
      "COEUR": [
        GridPosition(1, 1), GridPosition(2, 1), GridPosition(3, 1),
        GridPosition(4, 1), GridPosition(5, 1),
      ],
      "FOIE": [
        GridPosition(1, 3), GridPosition(1, 4), GridPosition(1, 5), GridPosition(1, 6),
      ],
      "REIN": [
        GridPosition(5, 1), GridPosition(5, 2), GridPosition(5, 3), GridPosition(5, 4),
      ],
      "ESTOMAC": [
        GridPosition(2, 1), GridPosition(2, 2), GridPosition(2, 3),
        GridPosition(2, 4), GridPosition(2, 5), GridPosition(2, 6), GridPosition(2, 7),
      ],
    },
  ),
  WordSearchLevel(
    id: 2,
    title: "Pathologies",
    category: "Clinique",
    words: ["CANCER", "DIABETE", "ASTHME", "GRIPPE", "ANEMIE"],
    wordDefinitions: {
      "CANCER": "Prolifération cellulaire anarchique et incontrôlée formant une tumeur.",
      "DIABETE": "Trouble métabolique caractérisé par une hyperglycémie chronique.",
      "ASTHME": "Maladie inflammatoire chronique des voies aériennes avec bronchospasme.",
      "GRIPPE": "Infection virale respiratoire aiguë et hautement contagieuse.",
      "ANEMIE": "Baisse du taux d'hémoglobine dans le sang limitant le transport d'oxygène.",
    },
    grid: [
      ['C', 'A', 'N', 'C', 'E', 'R', 'K', 'L'],
      ['T', 'N', 'F', 'H', 'D', 'S', 'Q', 'P'],
      ['Y', 'E', 'A', 'S', 'T', 'H', 'M', 'E'],
      ['V', 'M', 'O', 'P', 'L', 'Z', 'W', 'P'],
      ['D', 'I', 'A', 'B', 'E', 'T', 'E', 'P'],
      ['X', 'E', 'C', 'R', 'N', 'B', 'V', 'I'],
      ['Z', 'W', 'K', 'L', 'U', 'J', 'O', 'R'],
      ['S', 'P', 'M', 'F', 'H', 'Q', 'X', 'G'],
    ],
    wordPositions: {
      "CANCER": [
        GridPosition(0, 0), GridPosition(0, 1), GridPosition(0, 2),
        GridPosition(0, 3), GridPosition(0, 4), GridPosition(0, 5),
      ],
      "ANEMIE": [
        GridPosition(0, 1), GridPosition(1, 1), GridPosition(2, 1),
        GridPosition(3, 1), GridPosition(4, 1), GridPosition(5, 1),
      ],
      "ASTHME": [
        GridPosition(2, 2), GridPosition(2, 3), GridPosition(2, 4),
        GridPosition(2, 5), GridPosition(2, 6), GridPosition(2, 7),
      ],
      "DIABETE": [
        GridPosition(4, 0), GridPosition(4, 1), GridPosition(4, 2),
        GridPosition(4, 3), GridPosition(4, 4), GridPosition(4, 5), GridPosition(4, 6),
      ],
      "GRIPPE": [
        GridPosition(7, 7), GridPosition(6, 7), GridPosition(5, 7),
        GridPosition(4, 7), GridPosition(3, 7), GridPosition(2, 7),
      ],
    },
  ),
  WordSearchLevel(
    id: 3,
    title: "Biologie",
    category: "Laboratoire",
    words: ["CELLULE", "VIRUS", "SANG", "ADN", "PROTEINE"],
    wordDefinitions: {
      "CELLULE": "Unité structurelle et fonctionnelle de base de tout être vivant.",
      "VIRUS": "Agent infectieux microscopique nécessitant une cellule hôte pour se répliquer.",
      "SANG": "Fluide biologique circulant transportant oxygène et nutriments.",
      "ADN": "Support de l'information génétique en double hélice.",
      "PROTEINE": "Macromolécule essentielle formée d'acides aminés.",
    },
    grid: [
      ['C', 'E', 'L', 'L', 'U', 'L', 'E', 'T'],
      ['M', 'P', 'B', 'Z', 'Q', 'V', 'L', 'Y'],
      ['P', 'R', 'O', 'T', 'E', 'I', 'N', 'E'],
      ['V', 'I', 'R', 'U', 'S', 'H', 'K', 'W'],
      ['F', 'A', 'D', 'N', 'J', 'M', 'O', 'X'],
      ['K', 'S', 'T', 'W', 'Z', 'R', 'B', 'L'],
      ['S', 'A', 'N', 'G', 'P', 'E', 'C', 'H'],
      ['R', 'X', 'Y', 'D', 'F', 'G', 'H', 'Q'],
    ],
    wordPositions: {
      "CELLULE": [
        GridPosition(0, 0), GridPosition(0, 1), GridPosition(0, 2),
        GridPosition(0, 3), GridPosition(0, 4), GridPosition(0, 5), GridPosition(0, 6),
      ],
      "PROTEINE": [
        GridPosition(2, 0), GridPosition(2, 1), GridPosition(2, 2), GridPosition(2, 3),
        GridPosition(2, 4), GridPosition(2, 5), GridPosition(2, 6), GridPosition(2, 7),
      ],
      "VIRUS": [
        GridPosition(3, 0), GridPosition(3, 1), GridPosition(3, 2), GridPosition(3, 3), GridPosition(3, 4),
      ],
      "ADN": [
        GridPosition(4, 1), GridPosition(4, 2), GridPosition(4, 3),
      ],
      "SANG": [
        GridPosition(6, 0), GridPosition(6, 1), GridPosition(6, 2), GridPosition(6, 3),
      ],
    },
  ),
];

class WordAssociationScreen extends StatefulWidget {
  const WordAssociationScreen({super.key});

  @override
  State<WordAssociationScreen> createState() => _WordAssociationScreenState();
}

class _WordAssociationScreenState extends State<WordAssociationScreen> {
  int _currentLevelIdx = 0;
  GridPosition? _startPosition;
  GridPosition? _endPosition;

  final Set<GridPosition> _currentlySelected = {};
  final Set<GridPosition> _permanentlyFoundCells = {};
  final Set<String> _foundWords = {};

  int _score = 0;
  GridPosition? _highlightedHintCell;
  Timer? _hintTimer;

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  void _onCellTap(int row, int col) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_startPosition == null) {
        _startPosition = GridPosition(row, col);
        _currentlySelected.add(_startPosition!);
      } else if (_endPosition == null) {
        _endPosition = GridPosition(row, col);
        _calculateLineSelection();
        _checkSelection();
      } else {
        // Reset and start fresh
        _startPosition = GridPosition(row, col);
        _endPosition = null;
        _currentlySelected.clear();
        _currentlySelected.add(_startPosition!);
      }
    });
  }

  void _calculateLineSelection() {
    if (_startPosition == null || _endPosition == null) return;

    _currentlySelected.clear();
    final r1 = _startPosition!.row;
    final c1 = _startPosition!.col;
    final r2 = _endPosition!.row;
    final c2 = _endPosition!.col;

    if (r1 == r2) {
      // Horizontal
      final start = math.min(c1, c2);
      final end = math.max(c1, c2);
      for (int c = start; c <= end; c++) {
        _currentlySelected.add(GridPosition(r1, c));
      }
    } else if (c1 == c2) {
      // Vertical
      final start = math.min(r1, r2);
      final end = math.max(r1, r2);
      for (int r = start; r <= end; r++) {
        _currentlySelected.add(GridPosition(r, c1));
      }
    } else if ((r1 - r2).abs() == (c1 - c2).abs()) {
      // Diagonal
      final steps = (r1 - r2).abs();
      final dr = (r2 - r1) ~/ steps;
      final dc = (c2 - c1) ~/ steps;
      for (int i = 0; i <= steps; i++) {
        _currentlySelected.add(GridPosition(r1 + i * dr, c1 + i * dc));
      }
    }
  }

  void _checkSelection() {
    final level = levels[_currentLevelIdx];
    
    // Check if the selected positions match any hidden word
    bool matches = false;
    String matchedWordKey = "";

    for (final word in level.words) {
      if (_foundWords.contains(word)) continue;

      final positions = level.wordPositions[word];
      if (positions != null && positions.length == _currentlySelected.length) {
        // Check exact coordinate matches (order independent or forward/reverse check)
        final bool isMatch = positions.every((pos) => _currentlySelected.contains(pos));
        if (isMatch) {
          matches = true;
          matchedWordKey = word;
          break;
        }
      }
    }

    if (matches) {
      HapticFeedback.heavyImpact();
      setState(() {
        _foundWords.add(matchedWordKey);
        _permanentlyFoundCells.addAll(_currentlySelected);
        _score += 15;
        _startPosition = null;
        _endPosition = null;
        _currentlySelected.clear();
      });

      // Show temporary celebratory snackbar
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("MOT TROUVÉ : $matchedWordKey (+15 points)"),
          backgroundColor: Colors.green.shade800,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      HapticFeedback.vibrate();
      // Reset after 400ms to show the error state
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() {
            _startPosition = null;
            _endPosition = null;
            _currentlySelected.clear();
          });
        }
      });
    }
  }

  void _useHint() {
    final level = levels[_currentLevelIdx];
    // Find first word not yet found
    for (final word in level.words) {
      if (!_foundWords.contains(word)) {
        final positions = level.wordPositions[word];
        if (positions != null && positions.isNotEmpty) {
          HapticFeedback.mediumImpact();
          setState(() {
            _highlightedHintCell = positions.first;
            _score = math.max(0, _score - 5);
          });
          _hintTimer?.cancel();
          _hintTimer = Timer(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _highlightedHintCell = null;
              });
            }
          });
          break;
        }
      }
    }
  }

  void _resetLevel() {
    HapticFeedback.mediumImpact();
    setState(() {
      _startPosition = null;
      _endPosition = null;
      _currentlySelected.clear();
      _permanentlyFoundCells.clear();
      _foundWords.clear();
      _highlightedHintCell = null;
    });
  }

  void _selectLevel(int idx) {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentLevelIdx = idx;
      _resetLevel();
    });
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Iconsax.info_circle, color: AppColors.primary),
            SizedBox(width: 8),
            Text("Comment Jouer ?"),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("1. Trouvez les mots de la liste cachés dans la grille."),
            SizedBox(height: 8),
            Text("2. Tapez sur la première lettre du mot, puis sur la dernière lettre du mot."),
            SizedBox(height: 8),
            Text("3. Les mots peuvent être placés horizontalement, verticalement ou diagonalement."),
            SizedBox(height: 8),
            Text("4. Utilisez le bouton INDICE pour révéler la première lettre d'un mot (-5 pts)."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Compris", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final level = levels[_currentLevelIdx];
    final allFound = _foundWords.length == level.words.length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "MOTS MÊLÉS CLINIQUE",
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
          IconButton(
            icon: const Icon(Iconsax.message_question),
            onPressed: _showInstructions,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Level Selector Hub
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(levels.length, (index) {
                  final lvl = levels[index];
                  final isCurrent = index == _currentLevelIdx;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(
                          lvl.title,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isCurrent ? Colors.white : (isDark ? Colors.white60 : Colors.black87),
                          ),
                        ),
                        selected: isCurrent,
                        onSelected: (_) => _selectLevel(index),
                        selectedColor: AppColors.primary,
                        backgroundColor: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // HUD Dashboard
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Catégorie: ${level.category.toUpperCase()}",
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
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
              const SizedBox(height: 16),

              // Grid Board Container
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: 64,
                    itemBuilder: (context, index) {
                      final r = index ~/ 8;
                      final c = index % 8;
                      final pos = GridPosition(r, c);
                      final letter = level.grid[r][c];

                      final isPermanentlyFound = _permanentlyFoundCells.contains(pos);
                      final isCurrentlySelected = _currentlySelected.contains(pos);
                      final isStart = _startPosition == pos;
                      final isEnd = _endPosition == pos;
                      final isHint = _highlightedHintCell == pos;

                      Color cellBg = isDark ? Colors.white.withOpacity(0.02) : Colors.white;
                      Color borderColor = isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200;
                      Color textColor = isDark ? Colors.white70 : Colors.black87;

                      if (isPermanentlyFound) {
                        cellBg = AppColors.primary.withOpacity(0.18);
                        borderColor = AppColors.primary;
                        textColor = AppColors.primary;
                      } else if (isCurrentlySelected) {
                        cellBg = Colors.amber.withOpacity(0.25);
                        borderColor = Colors.amber;
                        textColor = Colors.amber.shade700;
                      } else if (isStart || isEnd) {
                        cellBg = Colors.amber.withOpacity(0.4);
                        borderColor = Colors.amber.shade700;
                        textColor = Colors.amber.shade900;
                      } else if (isHint) {
                        cellBg = Colors.purple.withOpacity(0.3);
                        borderColor = Colors.purple;
                        textColor = Colors.purple.shade700;
                      }

                      return GestureDetector(
                        onTap: () => _onCellTap(r, c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: cellBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              letter,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Spacer(),

              // Level completion HUD or standard buttons
              if (allFound)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.medal, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            "Niveau Complété !",
                            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.green, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_currentLevelIdx < levels.length - 1)
                        ElevatedButton(
                          onPressed: () => _selectLevel(_currentLevelIdx + 1),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Passer au niveau suivant", style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      else
                        const Text(
                          "Vous avez terminé tous les niveaux !",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                )
              else ...[
                // Definitions Trigger Button
                ElevatedButton(
                  onPressed: () => _showDefinitionsBottomSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                    foregroundColor: isDark ? Colors.white : Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark ? Colors.white12 : Colors.grey.shade300,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.document_text, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        "DÉFINITIONS CLINIQUES (${_foundWords.length}/${level.words.length})",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetLevel,
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
                          "REINITIALISER",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey.shade700,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _useHint,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.flash, size: 16),
                            SizedBox(width: 6),
                            Text(
                              "INDICE",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showDefinitionsBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final level = levels[_currentLevelIdx];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pull Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Title Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "DÉFINITIONS CLINIQUES",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${_foundWords.length} / ${level.words.length} Trouvés",
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Scrollable Definitions
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: level.words.length,
                      itemBuilder: (context, idx) {
                        final word = level.words[idx];
                        final isFound = _foundWords.contains(word);
                        final definition = level.wordDefinitions[word] ?? "";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isFound
                                ? Colors.green.withOpacity(isDark ? 0.08 : 0.04)
                                : (isDark ? Colors.white.withOpacity(0.02) : Colors.grey.shade50),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isFound
                                  ? Colors.green.withOpacity(0.3)
                                  : (isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                isFound ? Icons.check_circle : Iconsax.info_circle,
                                color: isFound ? Colors.green : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isFound) ...[
                                      Text(
                                        word,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.green,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                    Text(
                                      definition,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isFound
                                            ? (isDark ? Colors.grey.shade500 : Colors.grey.shade600)
                                            : (isDark ? Colors.white70 : Colors.black87),
                                        decoration: isFound ? TextDecoration.lineThrough : null,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
