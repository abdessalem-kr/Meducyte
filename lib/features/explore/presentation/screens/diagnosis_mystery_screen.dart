import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meducyte_app/core/themes/app_colors.dart';
import 'package:meducyte_app/features/explore/domain/models/game_models.dart';
import 'package:meducyte_app/features/explore/data/providers/game_content_provider.dart';

class DiagnosisMysteryScreen extends ConsumerStatefulWidget {
  const DiagnosisMysteryScreen({super.key});

  @override
  ConsumerState<DiagnosisMysteryScreen> createState() =>
      _DiagnosisMysteryScreenState();
}

class _DiagnosisMysteryScreenState extends ConsumerState<DiagnosisMysteryScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _totalScore = 0;
  int _clueBudget = 100;

  // Track revealed clue indexes per category
  final Set<int> _revealedHistory = {};
  final Set<int> _revealedLabs = {};
  final Set<int> _revealedImaging = {};

  int? _selectedDiagnosisIdx;
  bool _showResult = false;
  bool _isCorrect = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _resetForNextCase() {
    setState(() {
      _clueBudget = 100;
      _revealedHistory.clear();
      _revealedLabs.clear();
      _revealedImaging.clear();
      _selectedDiagnosisIdx = null;
      _showResult = false;
      _isCorrect = false;
      _tabController.index = 0;
    });
  }

  void _revealClue(String category, int index, int cost) {
    if (_showResult) return;

    bool alreadyRevealed = false;
    setState(() {
      if (category == 'history') {
        alreadyRevealed = !_revealedHistory.add(index);
      } else if (category == 'labs') {
        alreadyRevealed = !_revealedLabs.add(index);
      } else if (category == 'imaging') {
        alreadyRevealed = !_revealedImaging.add(index);
      }

      if (!alreadyRevealed) {
        _clueBudget = (_clueBudget - cost).clamp(0, 100);
        HapticFeedback.lightImpact();
      }
    });
  }

  void _submitDiagnosis(CaseDetectiveCase currentCase) {
    if (_selectedDiagnosisIdx == null || _showResult) return;

    final selectedOption = currentCase.differentials[_selectedDiagnosisIdx!];
    final correct = selectedOption == currentCase.correctDiagnosis;

    setState(() {
      _showResult = true;
      _isCorrect = correct;

      if (correct) {
        _totalScore += _clueBudget;
        HapticFeedback.heavyImpact();
      } else {
        _clueBudget = (_clueBudget - 15).clamp(0, 100);
        HapticFeedback.mediumImpact();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<CaseDetectiveCase> cases = ref.watch(caseDetectiveCasesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_currentIndex >= cases.length) {
      return _buildFinalSuccess(theme, isDark);
    }

    final currentCase = cases[_currentIndex];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "CASE DETECTIVE",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Score: $_totalScore pts",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Budget Meter Header
            _buildBudgetMeter(theme, isDark),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Patient Folder Header Card
                    _buildPatientFolder(currentCase, theme, isDark),
                    const SizedBox(height: 20),

                    // Clues & Investigation Drawer
                    Text(
                      "DOSSIER D'INVESTIGATION (Cliquer pour commander)",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildInvestigationTabs(currentCase, theme, isDark),
                    const SizedBox(height: 24),

                    // Diagnostic Form
                    _buildDiagnosticSelector(currentCase, theme, isDark),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetMeter(ThemeData theme, bool isDark) {
    Color budgetColor = Colors.green;
    if (_clueBudget < 35) {
      budgetColor = Colors.redAccent;
    } else if (_clueBudget < 65) {
      budgetColor = Colors.amber;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Iconsax.flash, color: budgetColor, size: 18),
                  const SizedBox(width: 6),
                  const Text(
                    "BUDGET D'INDICES",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Text(
                "$_clueBudget / 100",
                style: TextStyle(
                  color: budgetColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _clueBudget / 100,
              minHeight: 10,
              backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(budgetColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientFolder(
      CaseDetectiveCase currentCase, ThemeData theme, bool isDark) {
    Color difficultyColor = Colors.green;
    if (currentCase.difficulty == 'Intermédiaire') {
      difficultyColor = Colors.amber;
    } else if (currentCase.difficulty == 'Avancé') {
      difficultyColor = Colors.redAccent;
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Folder Tab Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white12 : Colors.grey.shade200,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.folder_open, size: 18, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      "CAS CLINIQUE N° ${currentCase.id.toUpperCase()}",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: difficultyColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    currentCase.difficulty.toUpperCase(),
                    style: TextStyle(
                      color: difficultyColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Demographics & Vitals
                Row(
                  children: [
                    const Icon(Iconsax.user, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      currentCase.patientDemographics,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.01) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Iconsax.activity, size: 16, color: Colors.redAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          currentCase.vitals,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Chief Complaint
                Text(
                  "MOTIF DE CONSULTATION",
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.primary : Colors.blueGrey.shade600,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  currentCase.chiefComplaint,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestigationTabs(
      CaseDetectiveCase currentCase, ThemeData theme, bool isDark) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? Colors.white38 : Colors.grey.shade500,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3.0,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: "Anamnèse"),
            Tab(text: "Laboratoire"),
            Tab(text: "Imagerie"),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildClueCategoryList(currentCase.historyOptions, 'history', isDark),
              _buildClueCategoryList(currentCase.labOptions, 'labs', isDark),
              _buildClueCategoryList(currentCase.imagingOptions, 'imaging', isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClueCategoryList(
      List<ClueOption> options, String category, bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: options.length,
      itemBuilder: (context, idx) {
        final option = options[idx];
        final bool isRevealed = (category == 'history' && _revealedHistory.contains(idx)) ||
            (category == 'labs' && _revealedLabs.contains(idx)) ||
            (category == 'imaging' && _revealedImaging.contains(idx));

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRevealed
                  ? AppColors.primary.withOpacity(0.3)
                  : (isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade200),
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: () => _revealClue(category, idx, option.cost),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          option.label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isRevealed
                                ? AppColors.primary
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                      if (!isRevealed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "-${option.cost} pts",
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                            ),
                          ),
                        )
                      else
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                    ],
                  ),
                  if (isRevealed) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.01) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        option.result,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiagnosticSelector(
      CaseDetectiveCase currentCase, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "FORMULER LE DIAGNOSTIC :",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(currentCase.differentials.length, (idx) {
          final option = currentCase.differentials[idx];
          final isSelected = _selectedDiagnosisIdx == idx;
          final isCorrectOption = option == currentCase.correctDiagnosis;

          Color itemBg = isDark ? const Color(0xFF1E293B) : Colors.white;
          Color borderColor = isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade200;
          Color textColor = isDark ? Colors.white70 : Colors.black87;

          if (_showResult) {
            if (isCorrectOption) {
              itemBg = Colors.green.withOpacity(isDark ? 0.08 : 0.04);
              borderColor = Colors.green;
              textColor = Colors.green;
            } else if (isSelected) {
              itemBg = Colors.red.withOpacity(isDark ? 0.08 : 0.04);
              borderColor = Colors.red;
              textColor = Colors.red;
            }
          } else if (isSelected) {
            itemBg = AppColors.primary.withOpacity(0.08);
            borderColor = AppColors.primary;
            textColor = AppColors.primary;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: itemBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: InkWell(
              onTap: _showResult ? null : () => setState(() => _selectedDiagnosisIdx = idx),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Text(
                      String.fromCharCode(65 + idx),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: isSelected ? textColor : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    if (_showResult && isCorrectOption)
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    if (_showResult && isSelected && !isCorrectOption)
                      const Icon(Icons.cancel, color: Colors.red, size: 20),
                  ],
                ),
              ),
            ),
          );
        }),

        if (_showResult) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isCorrect
                  ? Colors.green.withOpacity(0.08)
                  : Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isCorrect ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      _isCorrect ? Iconsax.verify : Iconsax.info_circle,
                      color: _isCorrect ? Colors.green : Colors.redAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isCorrect ? "EXCELLENT DETECTIVE !" : "DIAGNOSTIC ERRONÉ",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: _isCorrect ? Colors.green : Colors.redAccent,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _isCorrect
                      ? currentCase.teachingPoints
                      : "Pénalité de diagnostic raté appliquée (-15 pts budget). Relisez le dossier d'investigation et tentez une autre réponse.",
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _selectedDiagnosisIdx == null
              ? null
              : (_showResult
                  ? (_isCorrect
                      ? () {
                          setState(() {
                            _currentIndex++;
                            _resetForNextCase();
                          });
                        }
                      : () {
                          setState(() {
                            _showResult = false;
                            _selectedDiagnosisIdx = null;
                          });
                        })
                  : () => _submitDiagnosis(currentCase)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _showResult && !_isCorrect
                ? Colors.redAccent
                : AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            _showResult
                ? (_isCorrect ? "PROCHAIN DOSSIER" : "RESSAYER LE DIAGNOSTIC")
                : "SOUMETTRE LE DIAGNOSTIC",
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
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
              const Icon(Iconsax.medal_star, color: Colors.amber, size: 100),
              const SizedBox(height: 24),
              const Text(
                "L'EXPERT DES CAS !",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Text(
                "Félicitations, vous avez résolu tous les cas cliniques.\nVotre score total est de : $_totalScore points !",
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
