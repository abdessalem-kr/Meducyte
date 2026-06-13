import 'dart:async';
import 'package:meducyte_app/export.dart';

class EcosScreen extends StatefulWidget {
  const EcosScreen({super.key});

  @override
  State<EcosScreen> createState() => _EcosScreenState();
}

class _EcosScreenState extends State<EcosScreen> with TickerProviderStateMixin {
  int _selectedStation = -1;
  bool _examStarted = false;
  int _secondsLeft = 0;
  Timer? _timer;
  late AnimationController _pulseController;

  final List<Map<String, dynamic>> _stations = [
    {
      "id": 1,
      "title": "Station A – Cardio",
      "task": "Anamnèse & Examen Physique",
      "description": "Un patient de 58 ans se présente avec une douleur thoracique irradiant vers le bras gauche depuis 2 heures. Réalisez l'anamnèse complète et l'examen physique cardio-vasculaire.",
      "duration": 480,
      "specialty": "Cardiologie",
      "difficulty": "Resident",
      "checklist": [
        "Demander la localisation et irradiation",
        "Évaluer les facteurs de risque cardiovasculaires",
        "Réaliser l'auscultation cardiaque",
        "Prendre la pression artérielle aux deux bras",
        "Demander un ECG",
        "Formuler une hypothèse diagnostique",
      ],
      "color": const Color(0xFFEF4444),
      "icon": Iconsax.heart,
    },
    {
      "id": 2,
      "title": "Station B – Pédiatrie",
      "task": "Prescription & Conseil parental",
      "description": "Enfant de 4 ans amené par ses parents pour de la fièvre à 39.5°C depuis 3 jours. Rédigez une ordonnance et donnez les conseils aux parents.",
      "duration": 420,
      "specialty": "Pédiatrie",
      "difficulty": "Extern",
      "checklist": [
        "Évaluer l'état général de l'enfant",
        "Rechercher un foyer infectieux",
        "Vérifier le statut vaccinal",
        "Prescrire un traitement antipyrétique adapté",
        "Indiquer les signes d'alarme nécessitant un retour",
        "Planifier le suivi",
      ],
      "color": const Color(0xFF3B82F6),
      "icon": Iconsax.people,
    },
    {
      "id": 3,
      "title": "Station C – Urgences",
      "task": "Prise en Charge de l'Urgence",
      "description": "Patient de 35 ans victime d'un accident de la route. Il est conscient mais agité, PA = 80/50 mmHg, FC = 130 bpm. Gérez l'urgence.",
      "duration": 540,
      "specialty": "Urgences",
      "difficulty": "Senior",
      "checklist": [
        "Appliquer le bilan ABCDE",
        "Assurer la liberté des voies aériennes",
        "Poser deux voies veineuses périphériques de gros calibre",
        "Lancer le remplissage vasculaire",
        "Commander un bilan biologique en urgence",
        "Contacter le chirurgien de garde",
      ],
      "color": const Color(0xFFF59E0B),
      "icon": Iconsax.danger,
    },
    {
      "id": 4,
      "title": "Station D – Gynéco",
      "task": "Consultation & Annonce",
      "description": "Patiente de 28 ans, G2P1, à 32 SA, se présente pour bilan de suivi. La TA est à 150/100 mmHg avec une protéinurie 2+. Posez le diagnostic et annoncez-le.",
      "duration": 480,
      "specialty": "Gynécologie",
      "difficulty": "Resident",
      "checklist": [
        "Compléter le dossier obstétrical",
        "Évaluer les signes cliniques de pré-éclampsie",
        "Interpréter les résultats biologiques",
        "Annoncer le diagnostic avec empathie",
        "Expliquer la prise en charge prévue",
        "Organiser l'hospitalisation",
      ],
      "color": const Color(0xFF8B5CF6),
      "icon": Iconsax.health,
    },
    {
      "id": 5,
      "title": "Station E – Interprétation",
      "task": "Lecture d'Examens Complémentaires",
      "description": "Analysez l'ECG, la radio thoracique et les résultats biologiques présentés. Formulez votre diagnostic et proposez une prise en charge.",
      "duration": 360,
      "specialty": "Multi-disciplinaire",
      "difficulty": "Resident",
      "checklist": [
        "Lire et interpréter l'ECG correctement",
        "Analyser la radiographie thoracique",
        "Corréler les résultats biologiques",
        "Formuler un diagnostic différentiel",
        "Proposer les examens complémentaires de 2ème intention",
        "Rédiger la conclusion diagnostique",
      ],
      "color": const Color(0xFF10B981),
      "icon": Iconsax.graph,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startStation(int index) {
    setState(() {
      _selectedStation = index;
      _examStarted = true;
      _secondsLeft = _stations[index]['duration'] as int;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        t.cancel();
        _showTimeUpDialog();
      }
    });
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Iconsax.timer_1, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text("Temps écoulé !"),
          ],
        ),
        content: const Text("La station est terminée. Vous pouvez passer à la station suivante."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _examStarted = false;
                _selectedStation = -1;
              });
            },
            child: const Text("Retour au menu"),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_examStarted && _selectedStation >= 0) {
      return _buildActiveStation(isDark);
    }

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
          "ECOS – Examen Clinique Objectif Structuré",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header banner
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D1FF), Color(0xFF0091B8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.clipboard_tick, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Session ECOS",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "5 stations cliniques chronométrées\nEvaluez vos compétences pratiques",
                        style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildStatBadge("5", "STATIONS", const Color(0xFF00D1FF)),
                const SizedBox(width: 12),
                _buildStatBadge("38 min", "DURÉE TOTALE", const Color(0xFF8B5CF6)),
                const SizedBox(width: 12),
                _buildStatBadge("100 pts", "SCORE MAX", const Color(0xFF10B981)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "CHOISIR UNE STATION",
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
              itemCount: _stations.length,
              itemBuilder: (context, index) => _buildStationCard(index, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildStationCard(int index, bool isDark) {
    final station = _stations[index];
    final color = station['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _startStation(index),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(station['icon'] as IconData, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station['title'].toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        station['task'].toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildTag(station['specialty'].toString(), color),
                          const SizedBox(width: 6),
                          _buildTag("${(station['duration'] as int) ~/ 60} min", isDark ? Colors.white30 : Colors.black26),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Iconsax.arrow_right_3, size: 18, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActiveStation(bool isDark) {
    final station = _stations[_selectedStation];
    final color = station['color'] as Color;
    final totalDuration = station['duration'] as int;
    final progress = _secondsLeft / totalDuration;
    final isUrgent = _secondsLeft < 60;
    final checklist = station['checklist'] as List<String>;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_2, color: isDark ? Colors.white : Colors.black87),
          onPressed: () {
            _timer?.cancel();
            setState(() { _examStarted = false; _selectedStation = -1; });
          },
        ),
        title: Text(
          station['title'].toString(),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isUrgent
                        ? Color.lerp(const Color(0xFFEF4444), Colors.orange, _pulseController.value)!.withOpacity(0.15)
                        : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isUrgent ? const Color(0xFFEF4444).withOpacity(0.5) : color.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.timer_1, size: 14, color: isUrgent ? const Color(0xFFEF4444) : color),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(_secondsLeft),
                        style: TextStyle(
                          color: isUrgent ? const Color(0xFFEF4444) : color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                valueColor: AlwaysStoppedAnimation(isUrgent ? const Color(0xFFEF4444) : color),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 20),

            // Task banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(station['icon'] as IconData, color: color, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        station['task'].toString().toUpperCase(),
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    station['description'].toString(),
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Checklist
            Text(
              "LISTE DE CONTRÔLE",
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            ...checklist.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${entry.key + 1}",
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _timer?.cancel();
                  setState(() { _examStarted = false; _selectedStation = -1; });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Terminer la Station", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
