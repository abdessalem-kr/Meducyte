import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/explore/domain/models/game_models.dart';
import 'package:meducyte_app/features/explore/data/providers/game_content_provider.dart';

class EcgHeroScreen extends ConsumerStatefulWidget {
  const EcgHeroScreen({super.key});

  @override
  ConsumerState<EcgHeroScreen> createState() => _EcgHeroScreenState();
}

class _EcgHeroScreenState extends ConsumerState<EcgHeroScreen> {
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _showResult = false;

  @override
  Widget build(BuildContext context) {
    final List<EcgStrip> strips = ref.watch(ecgHeroProvider);
    final theme = Theme.of(context);

    if (_currentIndex >= strips.length) {
      return _buildFinalSuccess(theme);
    }

    final current = strips[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF020617), //Near black for monitor feel
      appBar: AppBar(
        title: const Text(
          "ECG MONITOR v2.0",
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: Column(
        children: [
          //Monitor Display Area
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.05),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  //Grid background
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: CustomPaint(painter: GridPainter()),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Iconsax.bezier,
                          color: Colors.green,
                          size: 60,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "RÉCEPTION DU SIGNAL...",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          current.id.toUpperCase(),
                          style: TextStyle(
                            color: Colors.green.withOpacity(0.5),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  //Animated sweep line(simulated)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.green.withOpacity(0),
                            Colors.green,
                            Colors.green.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          //Controls Area
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "ANALYSE DU RYTHME",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: ListView.builder(
                      itemCount: current.options.length,
                      itemBuilder: (context, index) {
                        final option = current.options[index];
                        final isSelected = _selectedIndex == index;
                        final isCorrect = index == current.correctIndex;

                        Color borderColor = Colors.white12;
                        Color textColor = Colors.white;
                        if (_showResult) {
                          if (isCorrect) {
                            borderColor = Colors.green;
                          } else if (isSelected) {
                            borderColor = Colors.red;
                          }
                        } else if (isSelected) {
                          borderColor = Colors.green;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: _showResult
                                ? null
                                : () => setState(() => _selectedIndex = index),
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.green.withOpacity(0.05)
                                    : Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: borderColor,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: isSelected
                                            ? FontWeight.w900
                                            : FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  if (_showResult && isCorrect)
                                    const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    ),
                                  if (_showResult && isSelected && !isCorrect)
                                    const Icon(Icons.close, color: Colors.red),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_showResult) ...[
                    const SizedBox(height: 16),
                    Text(
                      "SIGNES CLÉS: ${current.keyFeature}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _selectedIndex == null
                        ? null
                        : (_showResult
                              ? _next
                              : () => setState(() => _showResult = true)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _showResult ? "PROCHAIN RYTHME" : "CONFIRMER L'ANALYSE",
                      style: const TextStyle(fontWeight: FontWeight.w900),
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

  void _next() {
    setState(() {
      _currentIndex++;
      _selectedIndex = null;
      _showResult = false;
    });
  }

  Widget _buildFinalSuccess(ThemeData theme) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.heart_tick, color: Colors.green, size: 100),
            const SizedBox(height: 24),
            const Text(
              "RYTHMOLOGUE CERTIFIÉ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.black,
              ),
              child: const Text("FIN DE SESSION"),
            ),
          ],
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.2)
      ..strokeWidth = 0.5;

    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
