import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

class DrugDuelQuestion {
  final String cardTitle;
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const DrugDuelQuestion({
    required this.cardTitle,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class PharmaMatchScreen extends ConsumerStatefulWidget {
  const PharmaMatchScreen({super.key});

  @override
  ConsumerState<PharmaMatchScreen> createState() => _PharmaMatchScreenState();
}

class _PharmaMatchScreenState extends ConsumerState<PharmaMatchScreen> {
  final List<DrugDuelQuestion> _pool = const [
    DrugDuelQuestion(
      cardTitle: "FUROSÉMIDE (Anse)",
      questionText: "Quel est le mécanisme d'action principal du Furosémide ?",
      options: [
        "Inhibiteur du co-transporteur Na+/K+/2Cl- de l'anse de Henle",
        "Inhibiteur du co-transporteur Na+/Cl- du tubule contourné distal",
        "Antagoniste sélectif des récepteurs de l'aldostérone",
        "Bloqueur des canaux sodiques épithéliaux (ENaC)"
      ],
      correctIndex: 0,
      explanation: "Le furosémide est un diurétique de l'anse bloquant le cotransporteur Na-K-2Cl, entraînant une élimination massive de sodium et de potassium.",
    ),
    DrugDuelQuestion(
      cardTitle: "EFFET INDÉSIRABLE : TOUX SÈCHE",
      questionText: "Quel traitement anti-hypertenseur provoque typiquement une toux sèche via l'accumulation de bradykinine ?",
      options: [
        "Amlodipine (Inhibiteur calcique)",
        "Ramipril (Inhibiteur de l'ECA)",
        "Valsartan (Antagoniste des récepteurs AT1)",
        "Spironolactone (Épargneur de potassium)"
      ],
      correctIndex: 1,
      explanation: "Les IEC bloquent l'enzyme de conversion de l'angiotensine, responsable aussi de la dégradation de la bradykinine.",
    ),
    DrugDuelQuestion(
      cardTitle: "MÉCANISME : INHIBITEUR HMG-CoA",
      questionText: "À quelle classe thérapeutique appartiennent les molécules qui inhibent l'enzyme HMG-CoA réductase ?",
      options: [
        "Fibrates",
        "Inhibiteurs de PCSK9",
        "Statines (ex. Atorvastatine)",
        "Biguanides"
      ],
      correctIndex: 2,
      explanation: "Les statines réduisent la synthèse de cholestérol intracellulaire en inhibant la HMG-CoA réductase.",
    ),
    DrugDuelQuestion(
      cardTitle: "METFORMINE (Événement Grave)",
      questionText: "Quel est l'effet indésirable métabolique le plus redoutable (bien que rare) associé à la Metformine ?",
      options: [
        "Acidose lactique",
        "Hypoglycémie sévère",
        "Pancréatite aiguë",
        "Hypercalcémie"
      ],
      correctIndex: 0,
      explanation: "La metformine favorise la glycolyse anaérobie, d'où le risque d'acidose lactique en cas d'insuffisance rénale.",
    ),
    DrugDuelQuestion(
      cardTitle: "AMLODIPINE (Symptomatologie)",
      questionText: "Quel effet indésirable dose-dépendant est classique lors d'un traitement par Amlodipine ?",
      options: [
        "Oedème des membres inférieurs",
        "Hyperkaliémie sévère",
        "Toux sèche nocturne",
        "Hyperuricémie et crise de goutte"
      ],
      correctIndex: 0,
      explanation: "La vasodilatation artériolaire précapillaire induite par l'amlodipine favorise le passage de liquide dans l'interstitium.",
    ),
  ];

  int _currentIndex = 0;
  int? _selectedIndex;
  bool _showExplanation = false;
  int _score = 0;
  int _streak = 0;

  // Timed Sprint: 30 seconds total for the sprint
  int _secondsRemaining = 30;
  Timer? _gameTimer;
  bool _isGameOver = false;

  // Weak Pile
  final List<DrugDuelQuestion> _weakPile = [];
  bool _isReviewingWeakPile = false;

  @override
  void initState() {
    super.initState();
    _startSprintTimer();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _startSprintTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _gameTimer?.cancel();
        setState(() {
          _isGameOver = true;
          if (_weakPile.isNotEmpty) {
            _isReviewingWeakPile = true;
          }
        });
      }
    });
  }

  void _answer(int selectedIndex, DrugDuelQuestion question) {
    if (_showExplanation) return;
    final isCorrect = selectedIndex == question.correctIndex;

    setState(() {
      _selectedIndex = selectedIndex;
      _showExplanation = true;

      if (isCorrect) {
        _streak++;
        _score += 10 + (_streak >= 3 ? 5 : 0);
        HapticFeedback.lightImpact();
      } else {
        _streak = 0;
        if (!_isReviewingWeakPile && !_weakPile.contains(question)) {
          _weakPile.add(question);
        }
        HapticFeedback.mediumImpact();
      }
    });
  }

  void _next(List<DrugDuelQuestion> activeList) {
    setState(() {
      _selectedIndex = null;
      _showExplanation = false;
      _currentIndex++;

      if (_currentIndex >= activeList.length) {
        if (!_isReviewingWeakPile && _weakPile.isNotEmpty) {
          _isReviewingWeakPile = true;
          _currentIndex = 0;
        } else {
          _isGameOver = true;
          _gameTimer?.cancel();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeList = _isReviewingWeakPile ? _weakPile : _pool;

    if (_isGameOver && !_isReviewingWeakPile) {
      return _buildFinalSuccess(theme, isDark);
    }

    if (activeList.isEmpty || _currentIndex >= activeList.length) {
      return _buildFinalSuccess(theme, isDark);
    }

    final currentQuestion = activeList[_currentIndex];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isReviewingWeakPile ? "PILE FAIBLE (RÉVISION)" : "DRUG DUEL",
          style: const TextStyle(
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
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Score: $_score",
                  style: const TextStyle(
                    color: Colors.green,
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
              // Timer indicator (only if not in review mode)
              if (!_isReviewingWeakPile) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "TEMPS SPRINT RESTANT",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "$_secondsRemaining s",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: _secondsRemaining <= 10 ? Colors.redAccent : Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _secondsRemaining / 30,
                    minHeight: 8,
                    backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _secondsRemaining <= 10 ? Colors.redAccent : Colors.green,
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Iconsax.info_circle, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Vous révisez les cartes qui ont posé problème lors du sprint.",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Streak bonus badge
              if (_streak >= 2)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Text(
                      "SÉRIE DE $_streak ! +5 pts bonus",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Flashcard Box
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withOpacity(0.15),
                      Colors.green.withOpacity(0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        currentQuestion.cardTitle.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentQuestion.questionText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Multiple choices
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: currentQuestion.options.length,
                  itemBuilder: (context, idx) {
                    final isSelected = _selectedIndex == idx;
                    final isCorrect = idx == currentQuestion.correctIndex;

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
                        onTap: () => _answer(idx, currentQuestion),
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
                            currentQuestion.options[idx],
                            style: TextStyle(
                              fontSize: 13,
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

              // Educational explanation card
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
                        "DÉCRYPTAGE CLINIQUE :",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        currentQuestion.explanation,
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
                  onPressed: () => _next(activeList),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "CARTE SUIVANTE",
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
              const Icon(Iconsax.award, color: Colors.green, size: 100),
              const SizedBox(height: 24),
              const Text(
                "DUEL COMPLÉTÉ !",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Text(
                "Vous avez terminé le sprint pharmacologique.\nScore final : $_score points",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.black,
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
