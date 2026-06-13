import 'package:meducyte_app/export.dart';

class VirtualWardRoundsScreen extends StatefulWidget {
  const VirtualWardRoundsScreen({super.key});

  @override
  State<VirtualWardRoundsScreen> createState() => _VirtualWardRoundsScreenState();
}

class _VirtualWardRoundsScreenState extends State<VirtualWardRoundsScreen> {
  int _activePatient = -1;
  final Set<String> _completedActions = {};

  final List<Map<String, dynamic>> _patients = [
    {
      "id": "P-101",
      "name": "Mohamed B.",
      "age": "67 ans",
      "room": "Chambre 12 – Lit A",
      "diagnosis": "Insuffisance Cardiaque Décompensée",
      "status": "critical",
      "icon": Iconsax.heart,
      "color": const Color(0xFFEF4444),
      "vitals": {"PA": "170/105 mmHg", "FC": "105 bpm", "SpO2": "89%", "Diurèse": "200 mL/24h"},
      "notes": "Patient admis la nuit dernière pour dyspnée de repos. ATCD : HTA, Fibrillation auriculaire. Sous Bisoprolol 5mg, Furosémide 40mg. Râles crépitants bilatéraux à l'auscultation. Œdème des membres inférieurs jusqu'aux genoux.",
      "tasks": [
        {"key": "P-101-exam", "label": "Réaliser l'examen clinique", "icon": Iconsax.activity},
        {"key": "P-101-labo", "label": "Commander NFS + BNP + Troponine", "icon": Iconsax.microscope},
        {"key": "P-101-traitement", "label": "Ajuster la posologie du Furosémide (80mg/j)", "icon": Iconsax.note_21},
        {"key": "P-101-radio", "label": "Demander radiographie thoracique", "icon": Iconsax.scanning},
        {"key": "P-101-team", "label": "Transmettre à l'équipe de nuit", "icon": Iconsax.people},
      ],
    },
    {
      "id": "P-102",
      "name": "Fatima L.",
      "age": "45 ans",
      "room": "Chambre 14 – Lit C",
      "diagnosis": "Appendicite Aiguë – Post-op J1",
      "status": "stable",
      "icon": Iconsax.scissor,
      "color": const Color(0xFFF59E0B),
      "vitals": {"PA": "120/75 mmHg", "FC": "82 bpm", "SpO2": "98%", "T": "37.8°C"},
      "notes": "Appendicectomie laparoscopique hier 14h00. Pas de complications per-opératoires. Plaie opératoire propre. Reprise du transit. Légère douleur 3/10 au site opératoire. CRP post-op : 45 mg/L.",
      "tasks": [
        {"key": "P-102-douleur", "label": "Évaluer et traiter la douleur (EVA)", "icon": Iconsax.activity},
        {"key": "P-102-plaie", "label": "Vérifier et panser la plaie opératoire", "icon": Iconsax.health},
        {"key": "P-102-antibio", "label": "Adapter l'antibiothérapie prophylactique", "icon": Iconsax.note_21},
        {"key": "P-102-levée", "label": "Autoriser la levée et la déambulation", "icon": Iconsax.activity},
        {"key": "P-102-sortie", "label": "Planifier la sortie pour J3", "icon": Iconsax.home_2},
      ],
    },
    {
      "id": "P-103",
      "name": "Amine K.",
      "age": "28 ans",
      "room": "Chambre 8 – Lit B",
      "diagnosis": "Pneumonie Bactérienne Sévère (CURB-65 : 2)",
      "status": "moderate",
      "icon": Iconsax.wind,
      "color": const Color(0xFF3B82F6),
      "vitals": {"PA": "110/70 mmHg", "FC": "96 bpm", "SpO2": "93%", "T": "38.9°C"},
      "notes": "Admission il y a 48h pour fièvre + toux productive. Scanner thoracique : foyer de condensation lobe inférieur droit. ECBC en cours. Mise sous Amoxicilline-Acide Clavulanique 1g x3/j en IV depuis hier. Légère amélioration clinique.",
      "tasks": [
        {"key": "P-103-bio", "label": "Évaluer les résultats de l'hémoculture & CRP", "icon": Iconsax.microscope},
        {"key": "P-103-relais", "label": "Valider le relais per os si fièvre < 38°C", "icon": Iconsax.note_21},
        {"key": "P-103-kine", "label": "Prescrire kinésithérapie respiratoire", "icon": Iconsax.wind},
        {"key": "P-103-o2", "label": "Objectif SpO2 > 95% avec O2 nasal", "icon": Iconsax.flash_1},
        {"key": "P-103-ecbc", "label": "Vérifier résultat de l'ECBC et adapter ATB", "icon": Iconsax.document},
      ],
    },
    {
      "id": "P-104",
      "name": "Amina T.",
      "age": "34 ans",
      "room": "Chambre 3 – Lit A",
      "diagnosis": "Pré-éclampsie Sévère (32 SA)",
      "status": "critical",
      "icon": Iconsax.health,
      "color": const Color(0xFF8B5CF6),
      "vitals": {"PA": "162/108 mmHg", "FC": "88 bpm", "SpO2": "97%", "Protéinurie": "3+ "},
      "notes": "G2P1, 32 SA. Admise ce matin pour céphalées + phosphènes. TA à 162/108. Protéinurie 3+ à la bandelette. Pas de douleur en barre épigastrique. Monitoring fœtal rassurant. Consultation gynéco-obstétricale urgente demandée.",
      "tasks": [
        {"key": "P-104-sulfate", "label": "Sulfate de Magnésie : 4g en 20min (neuroprotection)", "icon": Iconsax.flash_1},
        {"key": "P-104-antihta", "label": "Antihypertenseur IV : Nicardipine ou Labétalol", "icon": Iconsax.note_21},
        {"key": "P-104-gyneco", "label": "Organiser la consultation gynéco urgente", "icon": Iconsax.people},
        {"key": "P-104-echo", "label": "Demander echo doppler fœto-placentaire", "icon": Iconsax.scanning},
        {"key": "P-104-rcp", "label": "RCP multi-disciplinaire : décision de naissance", "icon": Iconsax.message_2},
      ],
    },
  ];

  Color _statusColor(String status) => switch (status) {
    "critical" => const Color(0xFFEF4444),
    "moderate" => const Color(0xFFF59E0B),
    _ => const Color(0xFF10B981),
  };

  String _statusLabel(String status) => switch (status) {
    "critical" => "CRITIQUE",
    "moderate" => "MODÉRÉ",
    _ => "STABLE",
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          "Visite des Patients",
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${_completedActions.length}/${_patients.fold<int>(0, (sum, p) => sum + (p['tasks'] as List).length)}",
                  style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text("TÂCHES", style: TextStyle(color: Colors.grey[500], fontSize: 8, letterSpacing: 0.5)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Iconsax.hospital, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Service de Médecine Interne", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      SizedBox(height: 4),
                      Text("4 patients à visiter · Complétez toutes les tâches", style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
              itemCount: _patients.length,
              itemBuilder: (context, index) {
                final patient = _patients[index];
                final isExpanded = _activePatient == index;
                final tasks = patient['tasks'] as List<Map<String, dynamic>>;
                final completedCount = tasks.where((t) => _completedActions.contains(t['key'])).length;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: (patient['color'] as Color).withOpacity(isExpanded ? 0.4 : 0.15)),
                    boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      onExpansionChanged: (v) => setState(() => _activePatient = v ? index : -1),
                      iconColor: patient['color'] as Color,
                      collapsedIconColor: isDark ? Colors.white54 : Colors.black45,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: (patient['color'] as Color).withOpacity(0.12), shape: BoxShape.circle),
                        child: Icon(patient['icon'] as IconData, color: patient['color'] as Color, size: 20),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${patient['name']} · ${patient['age']}",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _statusColor(patient['status'].toString()).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _statusLabel(patient['status'].toString()),
                              style: TextStyle(color: _statusColor(patient['status'].toString()), fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(patient['room'].toString(), style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black45)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: tasks.isEmpty ? 0 : completedCount / tasks.length,
                                      backgroundColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                                      valueColor: AlwaysStoppedAnimation(patient['color'] as Color),
                                      minHeight: 4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text("$completedCount/${tasks.length}", style: TextStyle(color: patient['color'] as Color, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(height: 1),
                              const SizedBox(height: 12),

                              // Vitals
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: (patient['vitals'] as Map<String, String>).entries.map((e) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(e.key, style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                                      Text(e.value, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  ),
                                )).toList(),
                              ),
                              const SizedBox(height: 12),

                              // Notes
                              Text(patient['notes'].toString(), style: TextStyle(fontSize: 12, height: 1.5, color: isDark ? Colors.white60 : Colors.black54)),
                              const SizedBox(height: 16),

                              Text("TÂCHES DE VISITE", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.8)),
                              const SizedBox(height: 10),

                              // Tasks
                              ...tasks.map((task) {
                                final isDone = _completedActions.contains(task['key']);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Material(
                                    color: isDone ? (patient['color'] as Color).withOpacity(0.08) : (isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02)),
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        setState(() {
                                          if (isDone) {
                                            _completedActions.remove(task['key']);
                                          } else {
                                            _completedActions.add(task['key'].toString());
                                          }
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        child: Row(
                                          children: [
                                            Icon(task['icon'] as IconData, size: 18, color: isDone ? patient['color'] as Color : Colors.grey),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                task['label'].toString(),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: isDone ? (isDark ? Colors.white : Colors.black87) : (isDark ? Colors.white70 : Colors.black54),
                                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              isDone ? Iconsax.tick_circle : Iconsax.record_circle,
                                              size: 20,
                                              color: isDone ? patient['color'] as Color : Colors.grey.withOpacity(0.4),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
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
        ],
      ),
    );
  }
}
