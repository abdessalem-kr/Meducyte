import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/explore/domain/models/game_models.dart';
import 'package:meducyte_app/features/explore/data/providers/game_content_provider.dart';

class DiagnosisMysteryScreen extends ConsumerStatefulWidget {
  const DiagnosisMysteryScreen({super.key});

  @override
  ConsumerState<DiagnosisMysteryScreen> createState() =>
      _DiagnosisMysteryScreenState();
}

class _DiagnosisMysteryScreenState
    extends ConsumerState<DiagnosisMysteryScreen> {
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _showResult = false;

  @override
  Widget build(BuildContext context) {
    final List<DiagnosisCase> cases = ref.watch(diagnosisCasesProvider);
    final theme = Theme.of(context);

    if (_currentIndex >= cases.length) {
      return _buildFinalSuccess(theme);
    }

    final currentCase = cases[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "DIAGNOSIS ARCHIVE",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          //Background"Paper"Texture effect
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.network(
                "https://www.transparenttextures.com/patterns/natural-paper.png",
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //Folder-like Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.amber.shade200,
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Iconsax.folder_open,
                                  color: Colors.amber,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "DOSSIER N° ${currentCase.id.toUpperCase()}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32),
                            const Text(
                              "PROFIL PATIENT",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.blueGrey,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentCase.patientProfile,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "MOTIF DE CONSULTATION",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.blueGrey,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentCase.symptoms,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                        // "Confidential"stamp
                        Positioned(
                          right: -10,
                          top: 40,
                          child: Transform.rotate(
                            angle: -0.2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.2),
                                  width: 3,
                                ),
                              ),
                              child: Text(
                                "CONFIDENTIEL",
                                style: TextStyle(
                                  color: Colors.red.withOpacity(0.2),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  //Findings Table
                  const Text(
                    "OBSERVATIONS CLINIQUES",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: currentCase.findings
                        .map(
                          (f) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 14,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  f,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "VOTRE DIAGNOSTIC:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(currentCase.options.length, (index) {
                    final option = currentCase.options[index];
                    final isSelected = _selectedIndex == index;
                    final isCorrect = index == currentCase.correctIndex;

                    Color cardColor = Colors.white;
                    Color borderColor = Colors.grey.shade200;
                    if (_showResult) {
                      if (isCorrect) {
                        cardColor = Colors.green.shade50;
                        borderColor = Colors.green;
                      } else if (isSelected) {
                        cardColor = Colors.red.shade50;
                        borderColor = Colors.red;
                      }
                    } else if (isSelected) {
                      cardColor = Colors.blue.shade50;
                      borderColor = Colors.blue;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: _showResult
                            ? null
                            : () => setState(() => _selectedIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: Row(
                            children: [
                              Text(
                                String.fromCharCode(65 + index),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: isSelected ? Colors.blue : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                  option,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (_showResult && isCorrect)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                              if (_showResult && isSelected && !isCorrect)
                                const Icon(Icons.cancel, color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  if (_showResult) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade900,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white70,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "EXPLICATION",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentCase.explanation,
                            style: const TextStyle(
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _selectedIndex == null
                        ? null
                        : (_showResult
                              ? _nextCase
                              : () => setState(() => _showResult = true)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _showResult
                          ? "PROCHAIN DOSSIER"
                          : "VALIDER LE DIAGNOSTIC",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextCase() {
    setState(() {
      _currentIndex++;
      _selectedIndex = null;
      _showResult = false;
    });
  }

  Widget _buildFinalSuccess(ThemeData theme) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.medal_star, color: Colors.amber, size: 100),
            const SizedBox(height: 24),
            const Text(
              "L'Expert est là !",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            const Text(
              "Vous avez résolu tous les cas cliniques.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Retour au Hub"),
            ),
          ],
        ),
      ),
    );
  }
}
