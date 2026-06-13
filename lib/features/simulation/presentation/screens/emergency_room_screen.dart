import 'dart:async';
import 'package:meducyte_app/export.dart';

class EmergencyRoomScreen extends StatefulWidget {
  const EmergencyRoomScreen({super.key});

  @override
  State<EmergencyRoomScreen> createState() => _EmergencyRoomScreenState();
}

class _EmergencyRoomScreenState extends State<EmergencyRoomScreen> with TickerProviderStateMixin {
  int _currentCaseIndex = 0;
  int _score = 0;
  int _casesSolved = 0;
  bool _caseActive = false;
  bool _answered = false;
  String? _selectedChoice;
  int _secondsLeft = 90;
  Timer? _timer;
  late AnimationController _shakeController;
  late AnimationController _successController;

  final List<Map<String, dynamic>> _cases = [
    {
      "title": "Douleur thoracique brutale",
      "vitals": {"PA": "80/50 mmHg", "FC": "130 bpm", "SpO2": "94%", "T": "37.2°C"},
      "context": "Homme 52 ans, douleur thoracique déchirante irradiant dans le dos, survenue au repos il y a 1h. ATCD : HTA, tabagisme actif.",
      "question": "Quelle est votre priorité diagnostique IMMÉDIATE ?",
      "choices": [
        {"text": "Dissection Aortique → Angio-TDM thoracique urgent", "correct": true},
        {"text": "Infarctus du Myocarde → Thrombolyse immédiate", "correct": false},
        {"text": "Embolie Pulmonaire → Score de Wells", "correct": false},
        {"text": "Pneumothorax → Rx thoracique de face", "correct": false},
      ],
      "explanation": "La douleur déchirante irradiant dans le dos avec PA asymétrique est pathognomonique d'une dissection aortique. L'angio-TDM confirme le diagnostic. La thrombolyse est CONTRE-INDIQUÉE en cas de dissection !",
      "points": 20,
      "urgency": "CRITIQUE",
    },
    {
      "title": "Confusion aiguë du sujet âgé",
      "vitals": {"PA": "150/90 mmHg", "FC": "95 bpm", "SpO2": "96%", "T": "38.8°C"},
      "context": "Femme 78 ans, amenée aux urgences pour confusion aiguë d'apparition progressive depuis 48h. Antécédents : diabète type 2, insuffisance cardiaque. Elle refuse de boire.",
      "question": "Quel bilan sanguin est le plus urgent à réaliser en premier ?",
      "choices": [
        {"text": "Glycémie capillaire + Ionogramme sanguin + NFS", "correct": true},
        {"text": "Bilan thyroïdien (TSH, T4)", "correct": false},
        {"text": "Sérologie des hépatites", "correct": false},
        {"text": "Bilan auto-immun complet", "correct": false},
      ],
      "explanation": "La triade confusion + déshydratation + fièvre chez un diabétique âgé impose en 1ère intention : glycémie capillaire (HHNC ?), ionogramme (hyponatrémie ?), NFS + CRP (sepsis ?). Un état confusionnel aigu est un syndrome, pas un diagnostic.",
      "points": 15,
      "urgency": "ÉLEVÉE",
    },
    {
      "title": "Nourrisson fébrile",
      "vitals": {"PA": "—", "FC": "180 bpm", "SpO2": "97%", "T": "39.8°C"},
      "context": "Nourrisson de 2 mois amené par sa mère pour de la fièvre depuis 6 heures. Il boit bien, fontanelle normale, sans autre signe. Pas de contexte épidémique.",
      "question": "Quelle conduite à tenir adoptez-vous ?",
      "choices": [
        {"text": "Hospitalisation d'urgence + bilan infectieux complet + antibiothérapie IV probabiliste", "correct": true},
        {"text": "Antipyrétiques et retour à domicile avec consignes de surveillance", "correct": false},
        {"text": "Antibiothérapie per os et rendez-vous pédiatre dans 48h", "correct": false},
        {"text": "Surveillance simple sans traitement chez un nourrisson qui mange bien", "correct": false},
      ],
      "explanation": "Tout nourrisson < 3 mois fébrile est considéré comme une urgence médicale. La probabilité d'infection bactérienne sévère (méningite, septicémie) est significative même en l'absence de signes cliniques. Bilan infectieux complet (PL, hémocultures, ECBU) et antibiothérapie IV immédiate.",
      "points": 20,
      "urgency": "CRITIQUE",
    },
    {
      "title": "Intoxication médicamenteuse",
      "vitals": {"PA": "90/60 mmHg", "FC": "45 bpm", "SpO2": "98%", "T": "36.5°C"},
      "context": "Homme de 65 ans retrouvé inconscient. Son entourage rapporte une prise de nombreux comprimés. GCS = 10. FC = 45 bpm. Pupilles en mydriase bilatérale.",
      "question": "Quelle est la principale hypothèse toxicologique ?",
      "choices": [
        {"text": "Intoxication aux béta-bloquants → Glucagon IV en antidote", "correct": true},
        {"text": "Intoxication aux benzodiazépines → Flumazénil IV", "correct": false},
        {"text": "Intoxication aux anticholinergiques → Physostigmine", "correct": false},
        {"text": "Intoxication aux opioïdes → Naloxone IV", "correct": false},
      ],
      "explanation": "La bradycardie extrême + hypotension + troubles de conscience est la présentation typique d'une intoxication aux béta-bloquants. La mydriase peut être liée à d'autres substances co-ingérées. Le Glucagon est l'antidote spécifique (active l'AMPc indépendamment des récepteurs béta).",
      "points": 25,
      "urgency": "CRITIQUE",
    },
    {
      "title": "Crise convulsive tonico-clonique",
      "vitals": {"PA": "145/88 mmHg", "FC": "110 bpm", "SpO2": "88%", "T": "37.1°C"},
      "context": "Femme de 32 ans, épileptique connue, en état de mal épileptique (convulsions depuis > 5 minutes sans retour à la conscience). Pas de traitement antiépileptique récent.",
      "question": "Quel est le traitement antiépileptique de 1ère ligne en IV ?",
      "choices": [
        {"text": "Lorazépam ou Diazépam en IV lente", "correct": true},
        {"text": "Phénytoine en IV rapide", "correct": false},
        {"text": "Valproate de sodium en IV direct", "correct": false},
        {"text": "Lévetiracétam per os", "correct": false},
      ],
      "explanation": "Les benzodiazépines (Lorazépam, Diazépam) sont le traitement de 1ère ligne de l'état de mal épileptique par voie IV. La Phénytoine est utilisée en 2ème ligne mais nécessite une perfusion lente (risque d'arythmie en IV rapide). La voie orale est inadaptée en urgence.",
      "points": 15,
      "urgency": "ÉLEVÉE",
    },
  ];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _successController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _startCase() {
    setState(() {
      _caseActive = true;
      _answered = false;
      _selectedChoice = null;
      _secondsLeft = 90;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        t.cancel();
        _onAnswer(null, false);
      }
    });
  }

  void _onAnswer(String? choice, bool isCorrect) {
    if (_answered) return;
    _timer?.cancel();
    setState(() {
      _answered = true;
      _selectedChoice = choice;
    });
    if (isCorrect) {
      _score += _cases[_currentCaseIndex]['points'] as int;
      _casesSolved++;
      _successController.forward(from: 0);
    } else {
      _shakeController.forward(from: 0);
    }
  }

  void _nextCase() {
    if (_currentCaseIndex < _cases.length - 1) {
      setState(() {
        _currentCaseIndex++;
        _caseActive = false;
        _answered = false;
        _selectedChoice = null;
      });
    } else {
      _showFinalScore();
    }
  }

  void _showFinalScore() {
    final maxScore = _cases.fold<int>(0, (sum, c) => sum + (c['points'] as int));
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Session Terminée 🏆", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$_score / $maxScore",
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFFFF5252)),
            ),
            Text("$_casesSolved/${_cases.length} cas résolus"),
            const SizedBox(height: 8),
            Text(
              _score >= maxScore * 0.8 ? "Excellent ! Vous êtes prêt pour les urgences." : "Continuez à pratiquer pour améliorer votre réponse clinique.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () { Navigator.pop(ctx); context.pop(); }, child: const Text("Fermer")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() { _currentCaseIndex = 0; _score = 0; _casesSolved = 0; _caseActive = false; _answered = false; });
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5252)),
            child: const Text("Rejouer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentCase = _cases[_currentCaseIndex];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_2, color: isDark ? Colors.white : Colors.black87),
          onPressed: () { _timer?.cancel(); context.pop(); },
        ),
        title: Text(
          "Emergency Room Challenge",
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("$_score pts", style: const TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.bold, fontSize: 16)),
                Text("SCORE", style: TextStyle(color: Colors.grey[500], fontSize: 9, letterSpacing: 0.5)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Case progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(_cases.length, (i) => Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i <= _currentCaseIndex ? const Color(0xFFFF5252) : (isDark ? Colors.white10 : Colors.black.withOpacity(0.08)),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              )),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Cas ${_currentCaseIndex + 1}/${_cases.length}", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _urgencyColor(currentCase['urgency'].toString()).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _urgencyColor(currentCase['urgency'].toString()).withOpacity(0.3)),
                  ),
                  child: Text(
                    currentCase['urgency'].toString(),
                    style: TextStyle(color: _urgencyColor(currentCase['urgency'].toString()), fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: !_caseActive ? _buildCaseIntro(currentCase, isDark) : _buildCaseQuestion(currentCase, isDark),
            ),
          ),
          if (_caseActive && _answered)
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextCase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5252),
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _currentCaseIndex < _cases.length - 1 ? "Cas Suivant →" : "Voir le Score Final",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _urgencyColor(String urgency) {
    return urgency == "CRITIQUE" ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
  }

  Widget _buildCaseIntro(Map<String, dynamic> cas, bool isDark) {
    final vitals = cas['vitals'] as Map<String, String>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Case header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF5252), Color(0xFFB71C1C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Iconsax.danger, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text("PRISE EN CHARGE URGENTE", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                cas['title'].toString(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Vitals
        Text("PARAMÈTRES VITAUX", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: vitals.entries.map((e) {
            final isAbnormal = _isVitalAbnormal(e.key, e.value);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isAbnormal ? const Color(0xFFEF4444).withOpacity(0.1) : (isDark ? Colors.white.withOpacity(0.04) : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isAbnormal ? const Color(0xFFEF4444).withOpacity(0.3) : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
              ),
              child: Column(
                children: [
                  Text(e.key, style: TextStyle(color: isAbnormal ? const Color(0xFFEF4444) : Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(e.value, style: TextStyle(color: isAbnormal ? const Color(0xFFEF4444) : (isDark ? Colors.white : Colors.black87), fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Context
        Text("PRÉSENTATION CLINIQUE", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
          ),
          child: Text(cas['context'].toString(), style: TextStyle(fontSize: 13.5, height: 1.6, color: isDark ? Colors.white70 : Colors.black87)),
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _startCase,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.timer_1, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text("Démarrer (90 sec)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  bool _isVitalAbnormal(String key, String value) {
    if (value == "—") return false;
    if (key == "SpO2") { return value.contains("88") || value.contains("8"); }
    if (key == "FC") {
      final parsed = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
      if (parsed == null) return false;
      return parsed > 120 || parsed < 50;
    }
    return false;
  }

  Widget _buildCaseQuestion(Map<String, dynamic> cas, bool isDark) {
    final choices = cas['choices'] as List<Map<String, dynamic>>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timer bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _secondsLeft < 20 ? const Color(0xFFEF4444).withOpacity(0.08) : (isDark ? Colors.white.withOpacity(0.04) : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _secondsLeft < 20 ? const Color(0xFFEF4444).withOpacity(0.3) : (isDark ? Colors.white10 : Colors.black.withOpacity(0.04))),
          ),
          child: Row(
            children: [
              Icon(Iconsax.timer_1, size: 16, color: _secondsLeft < 20 ? const Color(0xFFEF4444) : Colors.grey),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _secondsLeft / 90,
                    backgroundColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                    valueColor: AlwaysStoppedAnimation(_secondsLeft < 20 ? const Color(0xFFEF4444) : const Color(0xFFFF5252)),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "${_secondsLeft}s",
                style: TextStyle(
                  color: _secondsLeft < 20 ? const Color(0xFFEF4444) : (isDark ? Colors.white : Colors.black87),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Question
        Text(
          cas['question'].toString(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: isDark ? Colors.white : Colors.black87, height: 1.4),
        ),
        const SizedBox(height: 20),

        // Choices
        ...choices.asMap().entries.map((entry) {
          final choice = entry.value;
          final text = choice['text'] as String;
          final isCorrect = choice['correct'] as bool;
          final isSelected = _selectedChoice == text;

          Color? bgColor;
          Color? borderColor;
          IconData? trailingIcon;

          if (_answered) {
            if (isCorrect) {
              bgColor = const Color(0xFF10B981).withOpacity(0.1);
              borderColor = const Color(0xFF10B981);
              trailingIcon = Iconsax.tick_circle;
            } else if (isSelected && !isCorrect) {
              bgColor = const Color(0xFFEF4444).withOpacity(0.1);
              borderColor = const Color(0xFFEF4444);
              trailingIcon = Iconsax.close_circle;
            } else {
              bgColor = isDark ? Colors.white.withOpacity(0.02) : Colors.white;
              borderColor = isDark ? Colors.white10 : Colors.black.withOpacity(0.05);
            }
          } else {
            bgColor = isDark ? Colors.white.withOpacity(0.04) : Colors.white;
            borderColor = isDark ? Colors.white10 : Colors.black.withOpacity(0.05);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _answered ? null : () => _onAnswer(text, isCorrect),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(text, style: TextStyle(fontSize: 13, height: 1.4, color: isDark ? Colors.white70 : Colors.black87)),
                      ),
                      if (trailingIcon != null) ...[
                        const SizedBox(width: 10),
                        Icon(trailingIcon, size: 20, color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),

        // Explanation
        if (_answered) ...[
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
                const Row(
                  children: [
                    Icon(Iconsax.info_circle, size: 16, color: Color(0xFF3B82F6)),
                    SizedBox(width: 6),
                    Text("EXPLICATION", style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.8)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  cas['explanation'].toString(),
                  style: TextStyle(fontSize: 13, height: 1.5, color: isDark ? Colors.white70 : Colors.black87),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
