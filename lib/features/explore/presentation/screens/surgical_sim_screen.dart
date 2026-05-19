import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/explore/domain/models/game_models.dart';
import 'package:meducyte_app/features/explore/data/providers/game_content_provider.dart';

class SurgicalSimScreen extends ConsumerStatefulWidget {
  const SurgicalSimScreen({super.key});

  @override
  ConsumerState<SurgicalSimScreen> createState() => _SurgicalSimScreenState();
}

class _SurgicalSimScreenState extends ConsumerState<SurgicalSimScreen> {
  int _currentStep = 0;
  bool _isFinished = false;

  @override
  Widget build(BuildContext context) {
    final List<SurgicalStep> steps = ref.watch(surgicalStepsProvider);
    final theme = Theme.of(context);

    if (_isFinished) {
      return _buildSuccessScreen(theme);
    }

    final step = steps[_currentStep];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), //Deep dark surgical room vibe
      appBar: AppBar(
        title: const Text(
          "OR-SUITE 4",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        children: [
          //Visual Simulation Area
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  //Procedural Overlay
                  Positioned(
                    top: 24,
                    left: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "STEP${_currentStep + 1}/${steps.length}",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Iconsax.mask_1,
                          color: Color(0xFF334155),
                          size: 100,
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            step.instruction.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // "OR"Ambient Light effect
                  Positioned(
                    right: 40,
                    top: 40,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          //Tool Selection Area
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(40),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "SÉLECTIONNEZ L'INSTRUMENT DE CHIRURGIE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildToolButton(
                          "Scalpel",
                          Icons.content_cut,
                          step.tool == "Scalpel",
                        ),
                        const SizedBox(height: 16),
                        _buildToolButton(
                          "Pince bipolaire",
                          Iconsax.flash,
                          step.tool == "Pince bipolaire",
                        ),
                        const SizedBox(height: 16),
                        _buildToolButton(
                          "Porte-aiguille",
                          Icons.architecture,
                          step.tool == "Porte-aiguille",
                        ),
                        const SizedBox(height: 16),
                        _buildToolButton(
                          "Écarteur",
                          Icons.keyboard_arrow_left,
                          step.tool == "Écarteur",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(String name, IconData icon, bool isCorrect) {
    return GestureDetector(
      onTap: () => _handleTool(isCorrect),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 20),
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTool(bool isCorrect) {
    if (isCorrect) {
      if (_currentStep < ref.read(surgicalStepsProvider).length - 1) {
        setState(() => _currentStep++);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("ORIENTATION RÉUSSIE"),
            backgroundColor: Colors.blue.shade900,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        setState(() => _isFinished = true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ERREUR DE PROTOCOLE"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSuccessScreen(ThemeData theme) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.star_1, color: Colors.blue, size: 100),
            const SizedBox(height: 24),
            const Text(
              "SURGEON CERTIFIED",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text("QUITTER LE BLOC"),
            ),
          ],
        ),
      ),
    );
  }
}
