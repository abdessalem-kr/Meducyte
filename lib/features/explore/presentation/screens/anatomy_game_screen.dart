import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meducyte_app/core/themes/app_colors.dart';

class TerminologyBlitzItem {
  final String term;
  final String deconstruction;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const TerminologyBlitzItem({
    required this.term,
    required this.deconstruction,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class AnatomyGameScreen extends ConsumerStatefulWidget {
  const AnatomyGameScreen({super.key});

  @override
  ConsumerState<AnatomyGameScreen> createState() => _AnatomyGameScreenState();
}

class _AnatomyGameScreenState extends ConsumerState<AnatomyGameScreen> {
  final List<TerminologyBlitzItem> _items = const [
    TerminologyBlitzItem(
      term: "Hépatomégalie",
      deconstruction: "Hépato (Foie) | Mégalie (Augmentation / Grand)",
      options: [
        "Augmentation anormale du volume du foie",
        "Ablation chirurgicale de la vésicule biliaire",
        "Inflammation des voies biliaires",
        "Accumulation de graisse dans le pancréas"
      ],
      correctIndex: 0,
      explanation: "Hépatomégalie désigne un foie hypertrophié, détectable à la palpation clinique.",
    ),
    TerminologyBlitzItem(
      term: "Cholécystectomie",
      deconstruction: "Cholécyst (Vésicule biliaire) | Ectomie (Ablation)",
      options: [
        "Incision chirurgicale de l'estomac",
        "Ablation chirurgicale de la vésicule biliaire",
        "Suture de l'intestin grêle",
        "Visualisation endoscopique du côlon"
      ],
      correctIndex: 1,
      explanation: "La cholécystectomie est l'ablation de la vésicule, souvent indiquée en cas de lithiase symptomatique.",
    ),
    TerminologyBlitzItem(
      term: "Néphrolithiase",
      deconstruction: "Néphro (Rein) | Lithiase (Calcul / Pierre)",
      options: [
        "Infection bactérienne de la vessie",
        "Présence de calculs dans les reins ou voies urinaires",
        "Dilatation anormale des uretères",
        "Kyste bénigne du cortex rénal"
      ],
      correctIndex: 1,
      explanation: "La néphrolithiase est la formation de calculs urinaires pouvant provoquer des coliques néphrétiques.",
    ),
    TerminologyBlitzItem(
      term: "Splénomégalie",
      deconstruction: "Spléno (Rate) | Mégalie (Augmentation / Grand)",
      options: [
        "Augmentation anormale du volume de la rate",
        "Inflammation aiguë de l'estomac",
        "Diminution de la sécrétion biliaire",
        "Rupture traumatique du diaphragme"
      ],
      correctIndex: 0,
      explanation: "La splénomégalie est une hypertrophie de la rate, fréquemment associée à l'hypertension portale.",
    ),
    TerminologyBlitzItem(
      term: "Hystérosalpingographie",
      deconstruction: "Hystéro (Utérus) | Salpingo (Trompe de Fallope) | Graphie (Radiographie)",
      options: [
        "Enregistrement de l'activité utérine lors du travail",
        "Échographie pelvienne en trois dimensions",
        "Radiographie de l'utérus et des trompes de Fallope",
        "Examen endoscopique de la cavité utérine"
      ],
      correctIndex: 2,
      explanation: "Cet examen utilise un produit de contraste pour étudier la perméabilité tubaire en cas d'infertilité.",
    ),
  ];

  int _currentIndex = 0;
  int? _selectedIndex;
  bool _showExplanation = false;
  int _score = 0;
  int _streak = 0;
  double _timerProgress = 1.0;
  Timer? _countdownTimer;
  int _secondsLeft = 5;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _secondsLeft = 5;
    _timerProgress = 1.0;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _secondsLeft = 5 - (timer.tick ~/ 10);
        _timerProgress = (50 - timer.tick) / 50;

        if (timer.tick >= 50) {
          _countdownTimer?.cancel();
          _onTimeOut();
        }
      });
    });
  }

  void _onTimeOut() {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedIndex = -1; // Indicate time out / no selection
      _streak = 0;
      _showExplanation = true;
    });
  }

  void _selectOption(int index) {
    if (_showExplanation) return;
    _countdownTimer?.cancel();

    final item = _items[_currentIndex];
    final bool correct = index == item.correctIndex;

    setState(() {
      _selectedIndex = index;
      _showExplanation = true;
      if (correct) {
        _streak++;
        // Multiplier bonus for high streak
        final int multiplier = (_streak >= 3) ? 2 : 1;
        _score += 10 * multiplier;
        HapticFeedback.lightImpact();
      } else {
        _streak = 0;
        HapticFeedback.mediumImpact();
      }
    });
  }

  void _next() {
    setState(() {
      _currentIndex++;
      _selectedIndex = null;
      _showExplanation = false;
      if (_currentIndex < _items.length) {
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_currentIndex >= _items.length) {
      return _buildFinalSuccess(theme, isDark);
    }

    final currentItem = _items[_currentIndex];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "TERMINOLOGY BLITZ",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Score: $_score",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timer Progress Bar
              if (!_showExplanation) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "TEMPS RESTANT",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      "$_secondsLeft s",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: _secondsLeft <= 2 ? Colors.redAccent : AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _timerProgress,
                    minHeight: 8,
                    backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _secondsLeft <= 2 ? Colors.redAccent : AppColors.primary,
                    ),
                  ),
                ),
              ] else
                const SizedBox(height: 22),

              const SizedBox(height: 20),

              // Streak Indicator
              if (_streak >= 2)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Iconsax.flash, color: Colors.amber, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          "SÉRIE DE $_streak ! (Score x2)",
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Term Flashcard Card
              Container(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.12),
                      AppColors.primary.withOpacity(0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text(
                      "DÉCOUVREZ LE SENS DE :",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentItem.term,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Options
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: currentItem.options.length,
                  itemBuilder: (context, idx) {
                    final isSelected = _selectedIndex == idx;
                    final isCorrect = idx == currentItem.correctIndex;

                    Color itemBg = isDark ? const Color(0xFF1E293B) : Colors.white;
                    Color borderColor = isDark ? Colors.white10 : Colors.grey.shade200;
                    Color textColor = isDark ? Colors.white70 : Colors.black87;

                    if (_showExplanation) {
                      if (isCorrect) {
                        itemBg = Colors.green.withOpacity(0.1);
                        borderColor = Colors.green;
                        textColor = Colors.green;
                      } else if (isSelected) {
                        itemBg = Colors.red.withOpacity(0.1);
                        borderColor = Colors.red;
                        textColor = Colors.red;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _selectOption(idx),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: itemBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: Text(
                            currentItem.options[idx],
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Deconstruction & Explanation box
              if (_showExplanation) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "DÉCONSTRUCTION ÉTYMOLOGIQUE :",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        currentItem.deconstruction,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        currentItem.explanation,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "TERME SUIVANT",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinalSuccess(ThemeData theme, bool isDark) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.flash_1, color: Colors.amber, size: 100),
              const SizedBox(height: 24),
              const Text(
                "BLITZ TERMINÉ !",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Text(
                "Vous maîtrisez l'étymologie et les racines médicales.\nScore final : $_score points",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.primary : const Color(0xFF1E293B),
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
