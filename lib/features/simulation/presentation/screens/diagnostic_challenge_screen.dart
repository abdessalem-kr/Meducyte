import 'package:meducyte_app/export.dart';

class DiagnosticChallengeScreen extends StatefulWidget {
  const DiagnosticChallengeScreen({super.key});

  @override
  State<DiagnosticChallengeScreen> createState() => _DiagnosticChallengeScreenState();
}

class _DiagnosticChallengeScreenState extends State<DiagnosticChallengeScreen> {
  int _score = 0;
  int _caseIndex = 0;
  int _step = 0; // 0=history, 1=exam, 2=labs, 3=diagnosis
  String? _selectedDiagnosis;
  bool _submitted = false;
  final List<String> _cluesRevealed = [];

  final List<Map<String, dynamic>> _cases = [
    {
      "title": "Cas 01 – L'essoufflement progressif",
      "color": const Color(0xFF3B82F6),
      "history": {
        "age": "72 ans, homme",
        "motif": "Dyspnée d'effort progressive depuis 3 mois, orthopnée, œdèmes des membres inférieurs.",
        "atcd": "HTA depuis 20 ans, tabagisme 40 PA (sevré il y a 10 ans).",
        "traitements": "Amlodipine 5mg, Ramipril 10mg",
      },
      "exam": {
        "Conscience": "Orienté, score Glasgow 15",
        "Auscultation cardio": "Souffle holosystolique 3/6 apex, irradiant aisselle",
        "Auscultation pulmonaire": "Crépitants bilatéraux bases",
        "Extrémités": "Œdème cheville 2+, chaleur conservée",
        "PA": "155/95 mmHg · FC 92 bpm · SpO2 90%",
      },
      "labs": {
        "BNP": "820 pg/mL (N < 100)",
        "Troponine": "Négative",
        "NFS": "Hb 11.2 g/dL, GB normaux",
        "Créatinine": "110 µmol/L",
        "Radio thoracique": "Cardiomégalie + opacités interstitielles péri-hilaires",
      },
      "diagnoses": [
        {"text": "Insuffisance cardiaque gauche sur cardiopathie valvulaire (IM)", "correct": true},
        {"text": "Embolie pulmonaire récidivante", "correct": false},
        {"text": "BPCO sévère exacerbé", "correct": false},
        {"text": "Hypertension artérielle pulmonaire primitive", "correct": false},
      ],
      "explanation": "L'association dyspnée + orthopnée + BNP élevé + souffle d'insuffisance mitrale + crépitants bilatéraux + cardiomégalie est caractéristique d'une insuffisance cardiaque gauche sur cardiopathie valvulaire (insuffisance mitrale).",
    },
    {
      "title": "Cas 02 – La céphalée qui réveille",
      "color": const Color(0xFF8B5CF6),
      "history": {
        "age": "38 ans, femme",
        "motif": "Céphalée brutale 'en coup de tonnerre', la pire de sa vie, apparue pendant l'effort il y a 2 heures.",
        "atcd": "Migraines connues depuis l'adolescence, pas de traitement au long cours.",
        "traitements": "Paracétamol 1g pris sans effet",
      },
      "exam": {
        "Conscience": "Consciente, très algique, GCS 14",
        "Signes méningés": "Raideur de nuque présente, Kernig +",
        "Fond d'œil": "Hémorragie sous-hyaloïdienne",
        "Neurologique": "Pas de déficit focal",
        "PA": "160/100 mmHg · FC 88 bpm · T 37.5°C",
      },
      "labs": {
        "Scanner cérébral sans injection": "Hyperdensité spontanée des citernes de la base",
        "PL (si scanner normal)": "LCR xanthochromique, GR > 10 000/mm³",
        "Glycémie": "5.2 mmol/L",
        "TP/TCA": "Normaux",
      },
      "diagnoses": [
        {"text": "Hémorragie sous-arachnoïdienne (HSA) sur rupture d'anévrisme", "correct": true},
        {"text": "Migraine avec aura sévère (état de mal migraineux)", "correct": false},
        {"text": "Méningite bactérienne aiguë", "correct": false},
        {"text": "Thrombose veineuse cérébrale", "correct": false},
      ],
      "explanation": "La céphalée 'en coup de tonnerre' d'emblée maximale est l'HSA jusqu'à preuve du contraire. L'hyperdensité des citernes au scanner et le LCR xanthochromique signent le diagnostic. Urgence neuroradiologique absolue : angio-TDM cérébrale pour localiser l'anévrisme.",
    },
    {
      "title": "Cas 03 – La fatigue du jeune",
      "color": const Color(0xFF10B981),
      "history": {
        "age": "24 ans, homme",
        "motif": "Asthénie progressive depuis 2 mois, perte de poids 8 kg, sueurs nocturnes, fièvre vespérale.",
        "atcd": "Pas d'antécédents. Revient d'un séjour de 3 mois en Afrique subsaharienne il y a 1 mois.",
        "traitements": "Aucun",
      },
      "exam": {
        "État général": "Amaigri, pâle, asthénique",
        "Adénopathies": "Cervicales et axillaires bilatérales, indolores, fermes",
        "Rate": "Splénomégalie modérée (flèche splénique 15 cm)",
        "Poumons": "Pas de signe auscultatoire",
        "Peau": "Pas de lésion visible",
      },
      "labs": {
        "NFS": "Pancytopénie : Hb 8.5, GB 2800, Plaquettes 95 000",
        "VS/CRP": "VS 95 mm/h, CRP 48 mg/L",
        "LDH": "840 UI/L (N < 250)",
        "Frottis sanguin": "Absence de plasmodium",
        "Bilan hépatique": "Normal",
      },
      "diagnoses": [
        {"text": "Lymphome de Hodgkin (stade III-IV)", "correct": true},
        {"text": "Paludisme viscéral évolutif (Kala-Azar)", "correct": false},
        {"text": "VIH au stade SIDA", "correct": false},
        {"text": "Tuberculose disséminée", "correct": false},
      ],
      "explanation": "La triade 'fièvre + sueurs nocturnes + amaigrissement' (signes B) + adénopathies bilatérales indolores + splénomégalie + LDH élevé + pancytopénie est hautement évocatrice d'un Lymphome de Hodgkin. Le diagnostic sera confirmé par biopsie ganglionnaire (cellule de Reed-Sternberg).",
    },
  ];

  int get _maxScore => _cases.fold<int>(0, (sum, _) => sum + 30);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_caseIndex >= _cases.length) {
      return _buildFinalScreen(isDark);
    }

    final cas = _cases[_caseIndex];
    final color = cas['color'] as Color;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_2, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Diagnostic Challenge",
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("$_score pts", style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold, fontSize: 16)),
                Text("SCORE", style: TextStyle(color: Colors.grey[500], fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Step progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildStep(0, "Anamnèse", Iconsax.message, color),
                _buildStepConnector(0),
                _buildStep(1, "Examen", Iconsax.activity, color),
                _buildStepConnector(1),
                _buildStep(2, "Bilans", Iconsax.microscope, color),
                _buildStepConnector(2),
                _buildStep(3, "Diagnostic", Iconsax.frame_1, color),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildStepContent(cas, isDark, color),
            ),
          ),
          // Navigation
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_step > 0) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("Précédent"),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _step == 3 && !_submitted
                        ? (_selectedDiagnosis != null ? _submitDiagnosis : null)
                        : (_step < 3 ? () => setState(() => _step++) : (_submitted ? _nextCase : null)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      _step == 3 ? (_submitted ? "Cas Suivant →" : "Valider le Diagnostic") : "Étape Suivante →",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int stepIndex, String label, IconData icon, Color color) {
    final isActive = _step == stepIndex;
    final isDone = _step > stepIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDone ? color : isActive ? color.withOpacity(0.15) : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
            shape: BoxShape.circle,
            border: Border.all(color: isActive || isDone ? color : Colors.transparent),
          ),
          alignment: Alignment.center,
          child: Icon(
            isDone ? Iconsax.tick_circle : icon,
            size: 16,
            color: isDone ? Colors.white : isActive ? color : Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 9, color: isActive ? color : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildStepConnector(int stepIndex) {
    final color = (_cases[_caseIndex]['color'] as Color);
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: _step > stepIndex ? color : (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black.withOpacity(0.06)),
      ),
    );
  }

  Widget _buildStepContent(Map<String, dynamic> cas, bool isDark, Color color) {
    return switch (_step) {
      0 => _buildHistory(cas, isDark, color),
      1 => _buildExam(cas, isDark, color),
      2 => _buildLabs(cas, isDark, color),
      3 => _buildDiagnosisStep(cas, isDark, color),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildHistory(Map<String, dynamic> cas, bool isDark, Color color) {
    final history = cas['history'] as Map<String, String>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(cas['title'].toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 4),
        Text("ÉTAPE 1 : ANAMNÈSE", style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
        const SizedBox(height: 16),
        ...history.entries.map((e) => _buildInfoTile(e.key, e.value, isDark, color)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildExam(Map<String, dynamic> cas, bool isDark, Color color) {
    final exam = cas['exam'] as Map<String, String>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ÉTAPE 2 : EXAMEN CLINIQUE", style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
        const SizedBox(height: 16),
        ...exam.entries.map((e) => _buildInfoTile(e.key, e.value, isDark, color)),
      ],
    );
  }

  Widget _buildLabs(Map<String, dynamic> cas, bool isDark, Color color) {
    final labs = cas['labs'] as Map<String, String>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ÉTAPE 3 : EXAMENS COMPLÉMENTAIRES", style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
        const SizedBox(height: 16),
        ...labs.entries.map((e) => _buildInfoTile(e.key, e.value, isDark, color)),
      ],
    );
  }

  Widget _buildInfoTile(String key, String value, bool isDark, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(key, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 13, height: 1.4, color: isDark ? Colors.white70 : Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisStep(Map<String, dynamic> cas, bool isDark, Color color) {
    final diagnoses = cas['diagnoses'] as List<Map<String, dynamic>>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ÉTAPE 4 : VOTRE DIAGNOSTIC", style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
        const SizedBox(height: 8),
        Text(
          "Sur la base de l'anamnèse, l'examen clinique et les bilans, quel est votre diagnostic principal ?",
          style: TextStyle(fontSize: 14, height: 1.5, color: isDark ? Colors.white70 : Colors.black87),
        ),
        const SizedBox(height: 20),
        ...diagnoses.map((d) {
          final isSelected = _selectedDiagnosis == d['text'];
          final isCorrect = d['correct'] as bool;
          Color bgColor;
          Color borderColor;

          if (_submitted) {
            if (isCorrect) { bgColor = const Color(0xFF10B981).withOpacity(0.1); borderColor = const Color(0xFF10B981); }
            else if (isSelected && !isCorrect) { bgColor = const Color(0xFFEF4444).withOpacity(0.1); borderColor = const Color(0xFFEF4444); }
            else { bgColor = isDark ? Colors.white.withOpacity(0.02) : Colors.white; borderColor = isDark ? Colors.white10 : Colors.black.withOpacity(0.04); }
          } else {
            bgColor = isSelected ? color.withOpacity(0.08) : (isDark ? Colors.white.withOpacity(0.04) : Colors.white);
            borderColor = isSelected ? color : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05));
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _submitted ? null : () => setState(() => _selectedDiagnosis = d['text'].toString()),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor)),
                  child: Row(
                    children: [
                      Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor, width: 2),
                          color: isSelected && !_submitted ? color : Colors.transparent,
                        ),
                        child: isSelected && !_submitted ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(d['text'].toString(), style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87))),
                      if (_submitted && (isCorrect || isSelected)) Icon(
                        isCorrect ? Iconsax.tick_circle : Iconsax.close_circle,
                        size: 20,
                        color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        if (_submitted) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Iconsax.info_circle, size: 16, color: Color(0xFF3B82F6)),
                  SizedBox(width: 6),
                  Text("RAISONNEMENT CLINIQUE", style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 11)),
                ]),
                const SizedBox(height: 8),
                Text(cas['explanation'].toString(), style: TextStyle(fontSize: 13, height: 1.5, color: isDark ? Colors.white70 : Colors.black87)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  void _submitDiagnosis() {
    if (_selectedDiagnosis == null) return;
    final diagnoses = _cases[_caseIndex]['diagnoses'] as List<Map<String, dynamic>>;
    final isCorrect = diagnoses.firstWhere((d) => d['text'] == _selectedDiagnosis)['correct'] as bool;
    if (isCorrect) _score += 30;
    setState(() => _submitted = true);
  }

  void _nextCase() {
    setState(() {
      _caseIndex++;
      _step = 0;
      _selectedDiagnosis = null;
      _submitted = false;
      _cluesRevealed.clear();
    });
  }

  Widget _buildFinalScreen(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_2, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.3), width: 3),
                ),
                child: const Icon(Iconsax.award, size: 60, color: Color(0xFFFFC107)),
              ),
              const SizedBox(height: 24),
              const Text("Analyse Terminée !", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              const SizedBox(height: 8),
              Text("$_score / $_maxScore points", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFFFC107))),
              const SizedBox(height: 16),
              Text(
                _score >= _maxScore * 0.8 ? "Excellent raisonnement clinique !" : "Continuez à pratiquer votre démarche diagnostique.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: const Text("Quitter"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() { _caseIndex = 0; _score = 0; _step = 0; _selectedDiagnosis = null; _submitted = false; }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("Rejouer", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
