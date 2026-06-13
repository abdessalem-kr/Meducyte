import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

enum PathologySpotType { ecg, xray, derm }

class PathologySpotCase {
  final String id;
  final PathologySpotType type;
  final String typeLabel;
  final String patientProfile;
  final String instruction;
  final List<String> options;
  final int correctIndex;
  final String keyFeature;
  final String explanation;

  const PathologySpotCase({
    required this.id,
    required this.type,
    required this.typeLabel,
    required this.patientProfile,
    required this.instruction,
    required this.options,
    required this.correctIndex,
    required this.keyFeature,
    required this.explanation,
  });
}

class EcgHeroScreen extends ConsumerStatefulWidget {
  const EcgHeroScreen({super.key});

  @override
  ConsumerState<EcgHeroScreen> createState() => _EcgHeroScreenState();
}

class _EcgHeroScreenState extends ConsumerState<EcgHeroScreen>
    with SingleTickerProviderStateMixin {
  final List<PathologySpotCase> _cases = const [
    PathologySpotCase(
      id: "p1",
      type: PathologySpotType.ecg,
      typeLabel: "ÉLECTROCARDIOGRAMME (DII)",
      patientProfile: "Homme, 62 ans, douleur constrictive rétrosternale.",
      instruction: "Localisez le segment de tracé anormal en le touchant.",
      options: [
        "Infarctus du Myocarde Antérieur (Sus-décalage ST)",
        "Bloc de Branche Gauche",
        "Flutter Auriculaire",
        "Péricardite Aiguë"
      ],
      correctIndex: 0,
      keyFeature: "Sus-décalage ST de 3mm (onde de Pardee).",
      explanation: "L'élévation du segment ST indique une lésion sous-épicardique aiguë en rapport avec une occlusion coronaire complète.",
    ),
    PathologySpotCase(
      id: "p2",
      type: PathologySpotType.xray,
      typeLabel: "RADIOGRAPHIE DU THORAX (AP)",
      patientProfile: "Femme, 24 ans, dyspnée aiguë après traumatisme.",
      instruction: "Touchez la zone pulmonaire montrant l'absence de trame vasculaire.",
      options: [
        "Pneumopathie Lobaire Droite",
        "Pneumothorax Gauche complet",
        "Cardiomégalie décompensée",
        "Épanchement pleural droit"
      ],
      correctIndex: 1,
      keyFeature: "Hyperclarté sans aucune trame vasculaire à gauche.",
      explanation: "Le pneumothorax se traduit par une poche d'air refoulant le poumon vers le hile, visible par une absence totale de vaisseaux en périphérie.",
    ),
    PathologySpotCase(
      id: "p3",
      type: PathologySpotType.derm,
      typeLabel: "EXAMEN DERMATOSCOPIQUE",
      patientProfile: "Homme, 48 ans, lésion pigmentée asymétrique d'apparition récente.",
      instruction: "Identifiez la lésion suspecte en la touchant.",
      options: [
        "Carcinome Basocellulaire nodulaire",
        "Mélanome malin à extension superficielle (SSM)",
        "Kératose Séborrhéique bénigne",
        "Nævus jonctionnel stable"
      ],
      correctIndex: 1,
      keyFeature: "Asymétrie, bords irréguliers, polychromie et diamètre > 6mm.",
      explanation: "Le mélanome malin répond aux critères cliniques ABCD (Asymétrie, Bords, Couleur, Diamètre) et requiert une exérèse chirurgicale urgente.",
    ),
  ];

  int _currentIndex = 0;
  int? _selectedIndex;
  bool _showResult = false;
  bool _abnormalityTapped = false;
  Offset? _tapPosition;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onMonitorTap(TapUpDetails details, BoxConstraints constraints, PathologySpotCase currentCase) {
    if (_abnormalityTapped) return;

    final double x = details.localPosition.dx;
    final double y = details.localPosition.dy;
    final double width = constraints.maxWidth;
    final double height = constraints.maxHeight;

    bool isCorrectSpot = false;

    if (currentCase.type == PathologySpotType.ecg) {
      // STEMI ST elevation: Peaks at [0.12, 0.32, 0.52, 0.72, 0.92] * width.
      // ST zone is slightly after peak.
      final List<double> peaks = [0.12, 0.32, 0.52, 0.72, 0.92].map((r) => r * width).toList();
      for (final peak in peaks) {
        final double distanceToStZone = x - (peak + 18);
        if (distanceToStZone.abs() < 24) {
          isCorrectSpot = true;
          break;
        }
      }
    } else if (currentCase.type == PathologySpotType.xray) {
      // Pneumothorax Gauche is located on the anatomical left lung (right side of the screen).
      // Target area: right side of monitor, middle/upper section.
      final double targetMinX = width * 0.55;
      final double targetMaxX = width * 0.85;
      final double targetMinY = height * 0.25;
      final double targetMaxY = height * 0.75;

      if (x >= targetMinX && x <= targetMaxX && y >= targetMinY && y <= targetMaxY) {
        isCorrectSpot = true;
      }
    } else if (currentCase.type == PathologySpotType.derm) {
      // Melanoma mole is drawn at the center of the screen with a random dispersion
      final double centerX = width / 2;
      final double centerY = height / 2;
      final double dx = x - centerX;
      final double dy = y - centerY;
      final double distance = math.sqrt(dx * dx + dy * dy);

      if (distance < 50) {
        isCorrectSpot = true;
      }
    }

    if (isCorrectSpot) {
      setState(() {
        _abnormalityTapped = true;
        _tapPosition = details.localPosition;
        HapticFeedback.lightImpact();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("ANOMALIE LOCALISÉE ! Sélectionnez maintenant la pathologie correspondante."),
          backgroundColor: Colors.green.shade800,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ce n'est pas la zone anormale. Examinez attentivement l'image."),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _next() {
    setState(() {
      _currentIndex++;
      _selectedIndex = null;
      _showResult = false;
      _abnormalityTapped = false;
      _tapPosition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_currentIndex >= _cases.length) {
      return _buildFinalSuccess(theme);
    }

    final currentCase = _cases[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          "PATHOLOGY SPOTTER",
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
          // Case Patient demographics bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.personalcard, color: Colors.blueAccent, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentCase.typeLabel,
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        currentCase.patientProfile,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Imaging Monitor Display Area
          Expanded(
            flex: 4,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapUp: (details) => _onMonitorTap(details, constraints, currentCase),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B132B),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _abnormalityTapped
                            ? Colors.green.withOpacity(0.8)
                            : Colors.white.withOpacity(0.12),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Custom Painter according to case type
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _getPainterForCase(currentCase),
                          ),
                        ),

                        // Animated Sweep line for ECG only
                        if (currentCase.type == PathologySpotType.ecg)
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: EcgWavePainter(
                                    progress: _animationController.value,
                                  ),
                                );
                              },
                            ),
                          ),

                        // Abnormality tap position circle
                        if (_abnormalityTapped && _tapPosition != null)
                          Positioned(
                            left: _tapPosition!.dx - 20,
                            top: _tapPosition!.dy - 20,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.redAccent, width: 2.5),
                                color: Colors.redAccent.withOpacity(0.25),
                              ),
                              child: const Center(
                                child: Icon(Icons.priority_high, color: Colors.redAccent, size: 16),
                              ),
                            ),
                          ),

                        // Status Overlay HUD
                        Positioned(
                          bottom: 12,
                          left: 20,
                          right: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                currentCase.instruction,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _abnormalityTapped ? "CIBLE TOUCHÉE" : "ATTENTE CIBLE",
                                style: TextStyle(
                                  color: _abnormalityTapped ? Colors.green : Colors.amber,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Controls Area
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "IDENTIFICATION DE LA PATHOLOGIE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentCase.options.length,
                      itemBuilder: (context, index) {
                        final option = currentCase.options[index];
                        final isSelected = _selectedIndex == index;
                        final isCorrect = index == currentCase.correctIndex;

                        Color borderColor = Colors.white.withOpacity(0.08);
                        Color textColor = Colors.white70;
                        Color? bgColor;

                        if (_showResult) {
                          if (isCorrect) {
                            borderColor = Colors.green;
                            textColor = Colors.green;
                            bgColor = Colors.green.withOpacity(0.08);
                          } else if (isSelected) {
                            borderColor = Colors.red;
                            textColor = Colors.red;
                            bgColor = Colors.red.withOpacity(0.08);
                          }
                        } else if (isSelected) {
                          borderColor = Colors.blueAccent;
                          textColor = Colors.blueAccent;
                          bgColor = Colors.blueAccent.withOpacity(0.08);
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            onTap: (!_abnormalityTapped || _showResult)
                                ? null
                                : () => setState(() => _selectedIndex = index),
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: bgColor ?? Colors.white.withOpacity(0.02),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: borderColor,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    String.fromCharCode(65 + index),
                                    style: TextStyle(
                                      color: isSelected ? Colors.blueAccent : Colors.grey,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        color: _abnormalityTapped ? textColor : Colors.white30,
                                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  if (_showResult && isCorrect)
                                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                  if (_showResult && isSelected && !isCorrect)
                                    const Icon(Icons.cancel, color: Colors.red, size: 20),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_showResult) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.05),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "CRITÈRE DE SPOTTING: ${currentCase.keyFeature}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  ElevatedButton(
                    onPressed: (_selectedIndex == null || !_abnormalityTapped)
                        ? null
                        : (_showResult
                              ? _next
                              : () => setState(() => _showResult = true)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _showResult ? "IMAGE SUIVANTE" : "CONFIRMER L'ANALYSE",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
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

  CustomPainter _getPainterForCase(PathologySpotCase item) {
    switch (item.type) {
      case PathologySpotType.ecg:
        return GridPainter();
      case PathologySpotType.xray:
        return ChestXrayPainter();
      case PathologySpotType.derm:
        return DermLesionPainter();
    }
  }

  Widget _buildFinalSuccess(ThemeData theme) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.eye, color: Colors.blueAccent, size: 100),
              const SizedBox(height: 24),
              const Text(
                "PATHOLOGUE HORS-PAIR",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Vous maîtrisez la détection visuelle d'anomalies sur tous les supports cliniques.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "TERMINER LA SESSION",
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

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.06)
      ..strokeWidth = 0.5;

    final thickPaint = Paint()
      ..color = Colors.green.withOpacity(0.12)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 10) {
      final isMajor = (i.toInt() % 50 == 0);
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), isMajor ? thickPaint : paint);
    }
    for (double i = 0; i < size.height; i += 10) {
      final isMajor = (i.toInt() % 50 == 0);
      canvas.drawLine(Offset(0, i), Offset(size.width, i), isMajor ? thickPaint : paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChestXrayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Fill background with a dark gray radiograph look
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF1E293B),
    );

    final double cx = size.width / 2;
    final double cy = size.height / 2;

    // Draw central heart silhouette (opaque white/gray glow)
    final heartPath = Path()
      ..moveTo(cx - 20, cy - 60)
      ..quadraticBezierTo(cx - 50, cy - 30, cx - 60, cy + 20)
      ..quadraticBezierTo(cx - 20, cy + 50, cx + 10, cy + 50)
      ..quadraticBezierTo(cx + 40, cy + 30, cx + 30, cy - 30)
      ..close();
    canvas.drawPath(
      heartPath,
      Paint()
        ..color = Colors.white.withOpacity(0.22)
        ..style = PaintingStyle.fill,
    );

    // Diaphragm arches
    final diaphragmPath = Path()
      ..moveTo(0, size.height - 20)
      ..quadraticBezierTo(cx - 80, cy + 60, cx - 20, cy + 50)
      ..quadraticBezierTo(cx + 80, cy + 60, size.width, size.height - 20)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      diaphragmPath,
      Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..style = PaintingStyle.fill,
    );

    // Normal Right Lung vascular markings (left side of screen)
    final vascularPaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final lungX = cx - 90;
    // Draw bronchial tree branches on left of screen
    canvas.drawLine(Offset(lungX, cy - 40), Offset(lungX - 40, cy - 70), vascularPaint);
    canvas.drawLine(Offset(lungX, cy - 40), Offset(lungX - 50, cy - 10), vascularPaint);
    canvas.drawLine(Offset(lungX - 40, cy - 70), Offset(lungX - 70, cy - 80), vascularPaint);
    canvas.drawLine(Offset(lungX - 50, cy - 10), Offset(lungX - 85, cy + 10), vascularPaint);

    // Abnormal Left Lung (right side of screen) - completely clear, no vascular markings!
    // Collapsed lung border (visceral pleural line)
    final pleuraPath = Path()
      ..moveTo(cx + 25, cy - 50)
      ..quadraticBezierTo(cx + 40, cy - 10, cx + 45, cy + 45);
    canvas.drawPath(
      pleuraPath,
      Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DermLesionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Skin colored background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFBCFE8).withOpacity(0.4), // Rose gold skin tone
    );

    final double cx = size.width / 2;
    final double cy = size.height / 2;

    // Irregular asymmetric melanoma mole
    final molePath = Path()
      ..moveTo(cx - 30, cy - 25)
      ..quadraticBezierTo(cx - 45, cy - 5, cx - 35, cy + 20)
      ..quadraticBezierTo(cx - 10, cy + 35, cx + 25, cy + 25)
      ..quadraticBezierTo(cx + 40, cy - 10, cx + 20, cy - 30)
      ..quadraticBezierTo(cx - 10, cy - 40, cx - 30, cy - 25)
      ..close();

    // Fill with irregular dark colors
    canvas.drawPath(
      molePath,
      Paint()
        ..color = const Color(0xFF1E1B4B) // Very dark blue/black
        ..style = PaintingStyle.fill,
    );

    // Irregular colored borders (variegation)
    final redZonePath = Path()
      ..moveTo(cx + 10, cy - 25)
      ..quadraticBezierTo(cx + 35, cy - 15, cx + 25, cy + 10)
      ..quadraticBezierTo(cx + 5, cy, cx + 10, cy - 25);
    canvas.drawPath(
      redZonePath,
      Paint()
        ..color = const Color(0xFF7F1D1D) // Dark red border tint
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EcgWavePainter extends CustomPainter {
  final double progress;

  EcgWavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double midY = size.height / 2;
    final double sweepX = progress * size.width;

    final List<double> beats = [0.12, 0.32, 0.52, 0.72, 0.92].map((r) => r * size.width).toList();

    for (double x = 1; x < size.width; x += 1.0) {
      final double yPrev = _getWaveYAt(x - 1, size.width, beats);
      final double yCurr = _getWaveYAt(x, size.width, beats);

      final double currentYPrev = midY + yPrev;
      final double currentYCurr = midY + yCurr;

      double dist = sweepX - x;
      if (dist < 0) {
        dist += size.width;
      }

      final double alphaRatio = (1.0 - (dist / size.width)).clamp(0.0, 1.0);

      if (dist > size.width - 12) {
        continue;
      }

      final pointColor = Colors.green.withOpacity(
        0.85 * math.pow(alphaRatio, 2.5),
      );

      canvas.drawLine(
        Offset(x - 1, currentYPrev),
        Offset(x, currentYCurr),
        Paint()
          ..color = pointColor
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }
  }

  double _getWaveYAt(double x, double totalWidth, List<double> beats) {
    double y = 0;
    double closestBeatDist = double.infinity;
    double activeDx = 0;
    for (final beatX in beats) {
      final dx = x - beatX;
      if (dx.abs() < closestBeatDist) {
        closestBeatDist = dx.abs();
        activeDx = dx;
      }
    }

    if (closestBeatDist < 40) {
      final dx = activeDx;
      if (dx >= -30 && dx < -15) {
        y = -4 * math.sin((dx + 30) / 15 * math.pi);
      } else if (dx >= -6 && dx < -2) {
        y = 4 * ((dx + 6) / 4);
      } else if (dx >= -2 && dx < 0) {
        y = 4 + (-35 - 4) * ((dx + 2) / 2);
      } else if (dx >= 0 && dx < 2) {
        y = -35 + (8 - (-35)) * (dx / 2);
      } else if (dx >= 2 && dx < 5) {
        y = 8 + (-12 - 8) * ((dx - 2) / 3);
      } else if (dx >= 5 && dx < 12) {
        y = -12;
      } else if (dx >= 12 && dx < 32) {
        // Elevated ST segment (STEMI)
        y = -12 - 14 * math.sin((dx - 12) / 20 * math.pi);
      }
    }

    y += 0.4 * math.sin(x * 0.9);
    return y;
  }

  @override
  bool shouldRepaint(covariant EcgWavePainter oldDelegate) => true;
}
