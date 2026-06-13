import 'package:meducyte_app/export.dart';

class ProceduralGuideScreen extends StatefulWidget {
  const ProceduralGuideScreen({super.key});

  @override
  State<ProceduralGuideScreen> createState() => _ProceduralGuideScreenState();
}

class _ProceduralGuideScreenState extends State<ProceduralGuideScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';
  int? _expandedProcedure;

  final List<Map<String, dynamic>> _procedures = [
    {
      "id": 0,
      "category": "invasive",
      "title": "Pose de Voie Veineuse Centrale (VVC)",
      "specialty": "Réanimation",
      "difficulty": "Expert",
      "time": "20–40 min",
      "color": const Color(0xFFEF4444),
      "icon": Iconsax.health,
      "indications": "Nécessité d'un accès veineux de gros calibre (remplissage rapide, nutrition parentérale, mesure PVC, cathéchol amines).",
      "contraindications": "Troubles de coagulation sévères (TP < 50%, plaquettes < 50 000), infection locale au site de ponction.",
      "materiel": ["Kit de VVC stérile", "Seringue 10 mL + aiguille de Seldinger", "Guide métallique souple", "Dilatateur", "Cathéter multilumière", "Champ stérile, casaque, gants stériles", "Lame bistoury n°11", "Fils de fixation"],
      "steps": [
        "Expliquer le geste au patient et obtenir son consentement éclairé.",
        "Positionner le patient en Trendelenburg 15° (voie sous-clavière ou jugulaire).",
        "Réaliser un lavage chirurgical des mains et habillage stérile complet.",
        "Désinfecter largement la zone de ponction avec Bétadine ou Chlorhexidine alcoolique.",
        "Repérer le site de ponction à l'écho-guidage si disponible.",
        "Ponctionner la veine cible avec l'aiguille de Seldinger, aspirer du sang veineux.",
        "Introduire délicatement le guide métallique à travers l'aiguille.",
        "Retirer l'aiguille en maintenant le guide en place.",
        "Inciser légèrement la peau avec le bistouri, passer le dilatateur sur le guide.",
        "Introduire le cathéter sur le guide, retirer le guide, vérifier le reflux sanguin.",
        "Suture et fixation du cathéter. Pansement stérile occlusif.",
        "Contrôle par radiographie thoracique pour vérifier la position et l'absence de pneumothorax.",
      ],
      "complications": ["Pneumothorax (voie sous-clavière ++)", "Hémothorax", "Infection sur cathéter (CRBSI)", "Thrombose veineuse", "Arythmies (guide dans le cœur droit)"],
    },
    {
      "id": 1,
      "category": "invasive",
      "title": "Ponction Lombaire (PL)",
      "specialty": "Neurologie",
      "difficulty": "Intermédiaire",
      "time": "15–30 min",
      "color": const Color(0xFF8B5CF6),
      "icon": Iconsax.microscope,
      "indications": "Suspicion de méningite, encéphalite, hémorragie sous-arachnoïdienne (si scanner normal), HTIC idiopathique.",
      "contraindications": "Hypertension intracrânienne avec engagement imminent, syndrome de coagulation, infection locale, refus du patient.",
      "materiel": ["Aiguille de PL 20G ou 22G", "Manomètre de pression", "3 tubes à LCR numérotés", "Gants stériles + champ troué", "Chlorhexidine alcoolique", "Anesthésique local (Lidocaïne 1%)"],
      "steps": [
        "Vérifier l'absence de contre-indication (fond d'œil ou scanner cérébral si nécessaire).",
        "Positionner le patient en position fœtale (décubitus latéral) ou assis penché en avant.",
        "Repérer l'espace L3-L4 ou L4-L5 (ligne inter-cristale = L4).",
        "Désinfecter largement en circulaire avec Chlorhexidine alcoolique. Poser champ stérile.",
        "Anesthésier le plan cutané et sous-cutané avec Lidocaïne 1%.",
        "Introduire l'aiguille de PL biseautée vers le haut, légèrement oblique céphalique.",
        "Progresser lentement jusqu'à sentir le 'ressaut' dural (passage de la dure-mère).",
        "Retirer le mandrin et vérifier le reflux spontané du LCR.",
        "Mesurer la pression d'ouverture avec le manomètre.",
        "Recueillir 3 à 4 tubes de LCR (citrate, EDTA, tube sec, tube glucose).",
        "Réintroduire le mandrin avant de retirer l'aiguille.",
        "Pansement compressif. Allonger le patient 30 min pour limiter le syndrome post-PL.",
      ],
      "complications": ["Syndrome post-PL (céphalée orthostatique)", "Engagement cérébral (si HIC méconnue)", "Hématome spinal", "Méningite iatrogène", "Douleur locale"],
    },
    {
      "id": 2,
      "category": "clinical",
      "title": "ECG 12 Dérivations",
      "specialty": "Cardiologie",
      "difficulty": "Débutant",
      "time": "5–10 min",
      "color": const Color(0xFF3B82F6),
      "icon": Iconsax.activity,
      "indications": "Douleur thoracique, palpitations, syncope, dyspnée, bilan pré-opératoire, suivi cardio.",
      "contraindications": "Aucune contre-indication absolue.",
      "materiel": ["Électrocardiographe 12 dérivations", "Électrodes jetables (10 au total)", "Gel conducteur si nécessaire", "Coton + alcool pour nettoyage cutané"],
      "steps": [
        "Expliquer le geste au patient : indolore, durée < 5 min.",
        "Allonger le patient en décubitus dorsal, thorax dénudé.",
        "Nettoyer et sécher les zones de pose des électrodes.",
        "DÉRIVATIONS DES MEMBRES (4 électrodes) : Bras droit (rouge/R), Bras gauche (jaune/L), Cheville gauche (vert/F), Cheville droite (noir/N – masse).",
        "PRÉCORDIALES (6 électrodes) : V1 = 4ème espace intercostal droit, V2 = 4ème EIC gauche, V3 = entre V2 et V4, V4 = 5ème EIC ligne médioclaviculaire gauche, V5 = ligne axillaire antérieure, V6 = ligne axillaire moyenne.",
        "Vérifier la qualité du signal : pas d'artefact, ligne de base stable.",
        "Lancer l'enregistrement (vitesse 25 mm/s, calibration 10 mm/mV).",
        "Annoter l'ECG avec nom, prénom, date, heure et motif.",
        "Interpréter selon la méthode systématique : rythme, fréquence, axe, ondes P, PR, QRS, QT, ST-T.",
      ],
      "complications": ["Aucune complication directe", "Risque de faux positif si électrodes mal placées", "Artefact de mouvement si patient agité"],
    },
    {
      "id": 3,
      "category": "clinical",
      "title": "Examen Neurologique Standard",
      "specialty": "Neurologie",
      "difficulty": "Débutant",
      "time": "20–30 min",
      "color": const Color(0xFF10B981),
      "icon": Iconsax.activity,
      "indications": "Céphalées, déficit neurologique, troubles de conscience, AIT/AVC, épilepsie.",
      "contraindications": "Aucune.",
      "materiel": ["Marteau à réflexes", "Aiguille ou rouleau épinglé (sensibilité)", "Torche lumineuse", "Diapason 128 Hz", "Coton (tact épicritique)"],
      "steps": [
        "ÉTAT DE CONSCIENCE : Score de Glasgow (ouverture yeux, réponse verbale, réponse motrice).",
        "PAIRES CRÂNIENNES : I (olfaction), II (acuité visuelle, CV), III-IV-VI (oculomotricité, pupilles), V (sensibilité faciale, masséter), VII (motricité faciale), VIII (audition, Rinne/Weber), IX-X (déglutition, voix), XI (trapèze/sterno-cleido), XII (langue).",
        "FORCE MUSCULAIRE : Testing musculaire 0/5 à 5/5 aux 4 membres, comparatif.",
        "TONUS MUSCULAIRE : Hypotonie, hypertonie spastique ou rigidité.",
        "RÉFLEXES OSTÉOTENDINEUX : Bicipital, styloradial, rotulien, achilléen. Clonique ? Signe de Babinski ?",
        "SENSIBILITÉ : Toucher léger, douleur, vibration (diapason), proprioception.",
        "COORDINATION ET ÉQUILIBRE : Épreuve doigt-nez, diadococinésie, signe de Romberg, démarche.",
        "SIGNES MÉNINGÉS : Raideur de nuque, signe de Kernig, signe de Brudzinski.",
        "FONCTIONS SUPÉRIEURES : Orientation T-L, langage (Broca/Wernicke), mémoire récente, calcul, praxies.",
      ],
      "complications": ["Aucune complication directe"],
    },
    {
      "id": 4,
      "category": "invasive",
      "title": "Intubation Oro-Trachéale (IOT)",
      "specialty": "Urgences / Réanimation",
      "difficulty": "Expert",
      "time": "5–15 min",
      "color": const Color(0xFFF59E0B),
      "icon": Iconsax.danger,
      "indications": "Arrêt cardiorespiratoire, coma profond GCS ≤ 8, détresse respiratoire sévère, protection des voies aériennes.",
      "contraindications": "Pas de CI absolue en urgence vitale. Relative : polytraumatisé (lésion rachis cervical).",
      "materiel": ["Laryngoscope avec lame de Macintosh n°3 ou 4", "Sonde d'intubation 7.0-8.0 (homme) / 6.5-7.5 (femme)", "Mandrin semi-rigide", "Seringue 10 mL pour le ballonnet", "Ambu + O2 haute concentration", "Aspiration (Yankauer)", "Capnographe (EtCO2)", "Hypnotique + curare (séquence rapide)"],
      "steps": [
        "PRÉOXYGÉNATION : O2 100% au masque pendant 3 minutes. SpO2 cible > 95% avant induction.",
        "INDUCTION EN SÉQUENCE RAPIDE (ISR) : Kétamine 1-2 mg/kg IV + Succinylcholine 1 mg/kg IV.",
        "Manœuvre de BURP (Back Up Right Pressure) si exposition difficile.",
        "Introduire le laryngoscope en bouche, refouler la langue à gauche. Visualiser l'épiglotte.",
        "Abaisser l'épiglotte pour exposer les cordes vocales.",
        "Introduire la sonde d'intubation entre les cordes vocales sous contrôle visuel direct.",
        "Gonfler le ballonnet (5-10 mL d'air), retirer le mandrin.",
        "VÉRIFIER LA BONNE POSITION : Capnographie (EtCO2 > 0), auscultation symétrique des 2 champs pulmonaires, absence de gargouillis épigastriques.",
        "Fixer la sonde et documenter la profondeur d'introduction (22 cm chez la femme, 23 cm chez l'homme).",
        "Radio thoracique pour confirmer la position idéale (2 cm au-dessus de la carène).",
      ],
      "complications": ["Intubation sélective (bronche souche droite)", "Intubation oesophagienne (FATALE si non détectée)", "Traumatisme laryngé", "Hypoxémie perigeste", "Hypotension sur induction"],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = _procedures.where((p) {
      final matchSearch = p['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p['specialty'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCat = _selectedCategory == 'all' || p['category'] == _selectedCategory;
      return matchSearch && matchCat;
    }).toList();

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
          "Guide des Procédures Médicales",
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: "Rechercher une procédure...",
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 14),
                  prefixIcon: Icon(Iconsax.search_normal, color: isDark ? Colors.white54 : Colors.black54, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          // Category filters
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildChip("all", "Toutes", Iconsax.category, const Color(0xFF6366F1)),
                  const SizedBox(width: 8),
                  _buildChip("invasive", "Gestes Invasifs", Iconsax.health, const Color(0xFFEF4444)),
                  const SizedBox(width: 8),
                  _buildChip("clinical", "Examens Cliniques", Iconsax.activity, const Color(0xFF3B82F6)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final proc = filtered[index];
                final isExpanded = _expandedProcedure == proc['id'];
                return _buildProcedureCard(proc, isDark, isExpanded);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String value, String label, IconData icon, Color color) {
    final isSelected = _selectedCategory == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = value),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? color : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? color : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54)),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87), fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcedureCard(Map<String, dynamic> proc, bool isDark, bool isExpanded) {
    final color = proc['color'] as Color;
    final steps = proc['steps'] as List<String>;
    final materiel = proc['materiel'] as List<String>;
    final complications = proc['complications'] as List<String>;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(isExpanded ? 0.4 : 0.15)),
        boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: color,
          collapsedIconColor: isDark ? Colors.white54 : Colors.black45,
          onExpansionChanged: (v) => setState(() => _expandedProcedure = v ? proc['id'] as int : null),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(proc['icon'] as IconData, color: color, size: 20),
          ),
          title: Text(proc['title'].toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              spacing: 6,
              children: [
                _tag(proc['specialty'].toString(), color),
                _tag(proc['difficulty'].toString(), _difficultyColor(proc['difficulty'].toString())),
                _tag("⏱ ${proc['time']}", Colors.grey),
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  _sectionHeader("INDICATIONS", color),
                  const SizedBox(height: 6),
                  Text(proc['indications'].toString(), style: TextStyle(fontSize: 13, height: 1.5, color: isDark ? Colors.white70 : Colors.black87)),

                  const SizedBox(height: 14),
                  _sectionHeader("CONTRE-INDICATIONS", const Color(0xFFEF4444)),
                  const SizedBox(height: 6),
                  Text(proc['contraindications'].toString(), style: TextStyle(fontSize: 13, height: 1.5, color: isDark ? Colors.white70 : Colors.black87)),

                  const SizedBox(height: 14),
                  _sectionHeader("MATÉRIEL NÉCESSAIRE", color),
                  const SizedBox(height: 6),
                  ...materiel.map((m) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Iconsax.tick_circle, size: 14, color: color),
                        const SizedBox(width: 8),
                        Expanded(child: Text(m, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87))),
                      ],
                    ),
                  )),

                  const SizedBox(height: 14),
                  _sectionHeader("ÉTAPES DE LA PROCÉDURE", color),
                  const SizedBox(height: 8),
                  ...steps.asMap().entries.map((e) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text("${e.key + 1}", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(e.value, style: TextStyle(fontSize: 12.5, height: 1.5, color: isDark ? Colors.white70 : Colors.black87))),
                      ],
                    ),
                  )),

                  const SizedBox(height: 14),
                  _sectionHeader("COMPLICATIONS POTENTIELLES", const Color(0xFFEF4444)),
                  const SizedBox(height: 6),
                  ...complications.map((c) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Iconsax.warning_2, size: 14, color: Color(0xFFEF4444)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(c, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87))),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String label, Color color) {
    return Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.8));
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Color _difficultyColor(String diff) => switch (diff) {
    "Expert" => const Color(0xFFEF4444),
    "Intermédiaire" => const Color(0xFFF59E0B),
    _ => const Color(0xFF10B981),
  };
}
