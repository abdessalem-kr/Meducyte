import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meducyte_app/features/explore/domain/models/game_models.dart';
import 'package:meducyte_app/features/explore/data/providers/game_content_provider.dart';

class LabMasterScreen extends ConsumerStatefulWidget {
  const LabMasterScreen({super.key});

  @override
  ConsumerState<LabMasterScreen> createState() => _LabMasterScreenState();
}

class _LabMasterScreenState extends ConsumerState<LabMasterScreen> {
  int _currentCaseIndex = 0;
  int _revealedStepsCount = 1; // Always start with the first step revealed
  List<String> _shuffledOptions = [];
  String? _lastErrorText;
  bool _showCaseSuccess = false;

  @override
  void initState() {
    super.initState();
    _initCurrentCase();
  }

  void _initCurrentCase() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cases = ref.read(physiologyFlowCasesProvider);
      if (_currentCaseIndex >= cases.length) return;

      final currentCase = cases[_currentCaseIndex];
      // Shuffle all steps except the first one
      final optionsToShuffle = currentCase.correctSteps.sublist(1);
      setState(() {
        _shuffledOptions = List<String>.from(optionsToShuffle)..shuffle();
        _revealedStepsCount = 1;
        _lastErrorText = null;
        _showCaseSuccess = false;
      });
    });
  }

  void _onOptionTap(String selectedOption, PhysiologyFlowCase currentCase) {
    if (_showCaseSuccess) return;

    final nextCorrectStep = currentCase.correctSteps[_revealedStepsCount];
    if (selectedOption == nextCorrectStep) {
      setState(() {
        _revealedStepsCount++;
        _shuffledOptions.remove(selectedOption);
        _lastErrorText = null;
        HapticFeedback.lightImpact();

        if (_revealedStepsCount == currentCase.correctSteps.length) {
          _showCaseSuccess = true;
          HapticFeedback.heavyImpact();
        }
      });
    } else {
      // Find the index of the wrong selected option to find its correct context/explanation
      int wrongIdx = currentCase.correctSteps.indexOf(selectedOption);
      setState(() {
        _lastErrorText = wrongIdx != -1
            ? "Faux. ${currentCase.explanations[wrongIdx]}"
            : "Ce lien n'est pas correct physiologiquement.";
        HapticFeedback.mediumImpact();
      });
    }
  }

  void _nextCase() {
    setState(() {
      _currentCaseIndex++;
      _initCurrentCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<PhysiologyFlowCase> cases = ref.watch(physiologyFlowCasesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_currentCaseIndex >= cases.length) {
      return _buildFinalSuccess(theme, isDark);
    }

    final currentCase = cases[_currentCaseIndex];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B132B) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          "PHYSIOLOGY FLOW",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Case Info Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C2541) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.diagram, color: Colors.cyan, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        currentCase.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentCase.description,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Vertical Interactive Flow Graph
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentCase.correctSteps.length,
                      itemBuilder: (context, idx) {
                        final isRevealed = idx < _revealedStepsCount;
                        final stepText = isRevealed ? currentCase.correctSteps[idx] : "Option manquante";
                        final explanation = isRevealed ? currentCase.explanations[idx] : null;

                        return Column(
                          children: [
                            // Node Container
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isRevealed
                                    ? (isDark ? const Color(0xFF1C2541) : Colors.white)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isRevealed
                                      ? Colors.cyan.withOpacity(0.4)
                                      : (isDark ? Colors.white10 : Colors.grey.shade300),
                                  width: isRevealed ? 2 : 1.5,
                                ),
                                boxShadow: isRevealed
                                    ? [
                                        BoxShadow(
                                          color: Colors.cyan.withOpacity(0.05),
                                          blurRadius: 10,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                children: [
                                  // Circle Index
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: isRevealed ? Colors.cyan : Colors.transparent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isRevealed ? Colors.cyan : (isDark ? Colors.white30 : Colors.grey.shade400),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${idx + 1}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: isRevealed ? Colors.black : (isDark ? Colors.white54 : Colors.grey.shade600),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          stepText,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.5,
                                            color: isRevealed
                                                ? (isDark ? Colors.white : Colors.black87)
                                                : (isDark ? Colors.white24 : Colors.grey.shade400),
                                            fontStyle: isRevealed ? FontStyle.normal : FontStyle.italic,
                                          ),
                                        ),
                                        if (explanation != null) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            explanation,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                              height: 1.35,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Connective line between nodes
                            if (idx < currentCase.correctSteps.length - 1)
                              Container(
                                width: 2,
                                height: 24,
                                color: idx + 1 < _revealedStepsCount
                                    ? Colors.cyan
                                    : (isDark ? Colors.white10 : Colors.grey.shade300),
                              ),
                          ],
                        );
                      },
                    ),

                    if (_showCaseSuccess) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Iconsax.verify, color: Colors.green),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Cascade Complète ! La logique physiopathologique est validée.",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _nextCase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "CASCADE SUIVANTE",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Error Message HUD
            if (_lastErrorText != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                ),
                child: Text(
                  _lastErrorText!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // Draggable/Selectable Step Options Drawer
            if (!_showCaseSuccess)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C2541) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "SÉLECTIONNEZ LE LIEN PHYSIOLOGIQUE SUIVANT :",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _shuffledOptions.map((opt) {
                        return InkWell(
                          onTap: () => _onOptionTap(opt, currentCase),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0B132B) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? Colors.white12 : Colors.grey.shade200,
                              ),
                            ),
                            child: Text(
                              opt,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalSuccess(ThemeData theme, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B132B) : const Color(0xFFF1F5F9),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.diagram, color: Colors.cyan, size: 100),
              const SizedBox(height: 24),
              const Text(
                "EXPERT EN PHYSIOLOGIE !",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              const Text(
                "Vous avez reconstitué toutes les cascades physiopathologiques avec brio.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13.5, height: 1.4),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
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
