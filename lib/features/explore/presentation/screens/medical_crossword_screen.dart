import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/explore/domain/models/game_models.dart';
import 'package:meducyte_app/features/explore/data/providers/game_content_provider.dart';

class MedicalCrosswordScreen extends ConsumerStatefulWidget {
  const MedicalCrosswordScreen({super.key});

  @override
  ConsumerState<MedicalCrosswordScreen> createState() =>
      _MedicalCrosswordScreenState();
}

class _MedicalCrosswordScreenState
    extends ConsumerState<MedicalCrosswordScreen> {
  final Map<int, Map<int, String>> _userInput = {};
  int _focusedRow = 0;
  int _focusedCol = 0;
  bool _isHorizontal = true;

  @override
  Widget build(BuildContext context) {
    final CrosswordGame game = ref.watch(crosswordProvider);
    final theme = Theme.of(context);

    int maxRow = 0;
    int maxCol = 0;
    for (var w in game.words) {
      if (w.isHorizontal) {
        maxRow = maxRow > w.row ? maxRow : w.row;
        maxCol = maxCol > (w.col + w.word.length - 1)
            ? maxCol
            : (w.col + w.word.length - 1);
      } else {
        maxRow = maxRow > (w.row + w.word.length - 1)
            ? maxRow
            : (w.row + w.word.length - 1);
        maxCol = maxCol > w.col ? maxCol : w.col;
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          game.title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
        ),
        actions: [
          IconButton(
            onPressed: _checkAnswers,
            icon: const Icon(Iconsax.tick_circle, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.05),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  "DÉCHIFFREZ LES TERMES MÉDICAUX",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              //Grid Area
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: maxCol + 1,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                    ),
                    itemCount: (maxRow + 1) * (maxCol + 1),
                    itemBuilder: (context, index) {
                      final r = index ~/ (maxCol + 1);
                      final c = index % (maxCol + 1);

                      final isPlayable = _isPlayable(r, c, game.words);
                      if (!isPlayable) return Container();

                      final isFocused = _focusedRow == r && _focusedCol == c;
                      final isCurrentWord = _isInCurrentWord(r, c, game.words);
                      final char = _userInput[r]?[c] ?? "";

                      return GestureDetector(
                        onTap: () => setState(() {
                          if (isFocused) _isHorizontal = !_isHorizontal;
                          _focusedRow = r;
                          _focusedCol = c;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isFocused
                                ? AppColors.primary
                                : (isCurrentWord
                                      ? AppColors.primary.withOpacity(0.08)
                                      : theme.cardColor),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isFocused
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                            border: Border.all(
                              color: isFocused
                                  ? AppColors.primary
                                  : Colors.grey.withOpacity(0.15),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              char,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: isFocused
                                    ? Colors.white
                                    : theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              //Clue Bar
              _buildCurrentClue(game.words, theme),
              const SizedBox(height: 24),
              //Modern Keyboard
              Container(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 40,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildKeyboardRow("AZERTYUIOP"),
                    const SizedBox(height: 10),
                    _buildKeyboardRow("QSDFGHJKLM"),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSpecialKey("⌫", () => _handleInput("⌫")),
                        const SizedBox(width: 8),
                        ..."WXCVBN".split("").map((l) => _buildKey(l)),
                        const SizedBox(width: 8),
                        _buildSpecialKey(
                          "↵",
                          _checkAnswers,
                          color: AppColors.primary,
                        ),
                      ],
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

  bool _isPlayable(int r, int c, List<CrosswordWord> words) {
    for (var w in words) {
      if (_isInWord(w, r, c)) return true;
    }
    return false;
  }

  bool _isInCurrentWord(int r, int c, List<CrosswordWord> words) {
    final currentWord = _getCurrentWord(words);
    return _isInWord(currentWord, r, c);
  }

  CrosswordWord _getCurrentWord(List<CrosswordWord> words) {
    return words.firstWhere(
      (w) =>
          w.isHorizontal == _isHorizontal &&
          _isInWord(w, _focusedRow, _focusedCol),
      orElse: () =>
          words.firstWhere((w) => _isInWord(w, _focusedRow, _focusedCol)),
    );
  }

  Widget _buildKeyboardRow(String letters) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: letters
          .split("")
          .map(
            (l) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildKey(l),
            ),
          )
          .toList(),
    );
  }

  Widget _buildKey(String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _handleInput(label),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(String label, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color ?? Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: color != null ? Colors.white : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentClue(List<CrosswordWord> words, ThemeData theme) {
    final w = _getCurrentWord(words);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Text(
                w.isHorizontal ? "H" : "V",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                w.clue,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isInWord(CrosswordWord w, int r, int c) {
    if (w.isHorizontal) {
      return w.row == r && c >= w.col && c < w.col + w.word.length;
    } else {
      return w.col == c && r >= w.row && r < w.row + w.word.length;
    }
  }

  void _handleInput(String char) {
    setState(() {
      if (char == "⌫") {
        if (_userInput[_focusedRow] != null) {
          _userInput[_focusedRow]!.remove(_focusedCol);
        }
        return;
      }

      _userInput.putIfAbsent(_focusedRow, () => {})[_focusedCol] = char;

      final currentWord = _getCurrentWord(ref.read(crosswordProvider).words);

      if (_isHorizontal) {
        if (_focusedCol < currentWord.col + currentWord.word.length - 1) {
          _focusedCol++;
        }
      } else {
        if (_focusedRow < currentWord.row + currentWord.word.length - 1) {
          _focusedRow++;
        }
      }
    });
  }

  void _checkAnswers() {
    final game = ref.read(crosswordProvider);
    bool allCorrect = true;
    for (var w in game.words) {
      for (int i = 0; i < w.word.length; i++) {
        final r = w.isHorizontal ? w.row : w.row + i;
        final c = w.isHorizontal ? w.col + i : w.col;
        final input = _userInput[r]?[c] ?? "";
        if (input != w.word[i]) {
          allCorrect = false;
          break;
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          allCorrect
              ? "FÉLICITATIONS!Tout est correct."
              : "Il y a quelques erreurs...",
        ),
        backgroundColor: allCorrect ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
