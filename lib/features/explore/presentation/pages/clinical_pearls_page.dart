import 'package:flutter/services.dart';
import 'package:meducyte_app/export.dart';

class ClinicalPearlsPage extends StatefulWidget {
  const ClinicalPearlsPage({super.key});

  @override
  State<ClinicalPearlsPage> createState() => _ClinicalPearlsPageState();
}

class _ClinicalPearlsPageState extends State<ClinicalPearlsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedTab = 'all'; // 'all', 'tips', 'prescriptions', 'emergency'

  final List<Map<String, dynamic>> _pearls = [
    // --- PRESCRIPTIONS ---
    {
      "type": "prescriptions",
      "title": "Pneumopathie Franche Lobaire Aiguë (PFLA)",
      "category": "Infectiologie",
      "subtitle": "Prescription de première intention",
      "protocol": "• Amoxicilline PO : 1g trois fois par jour (3g/j) pendant 7 jours.\n"
          "• En cas d'allergie aux pénicillines (sans contre-indication aux céphalosporines) : Céfuroxime-axétil 500mg deux fois par jour (1g/j).\n"
          "• En cas d'allergie majeure (alternative) : Lévofloxacine 500mg une fois par jour (PO ou IV).",
      "warning": "Vérifier systématiquement l'absence d'antécédents d'allergie grave aux bétalactamines. Réévaluation clinique obligatoire à 48-72 heures.",
      "icon": Iconsax.note_21,
      "color": const Color(0xFF3B82F6),
    },
    {
      "type": "prescriptions",
      "title": "Crise d'Asthme Aiguë Grave (AAG)",
      "category": "Urgences / Pneumo",
      "subtitle": "Traitement de crise immédiat",
      "protocol": "• Nébulisation continue de Salbutamol (5mg) + Bromure d'Ipratropium (0.5mg) sous 6 à 8 L/min d'Oxygène.\n"
          "• Corticothérapie systémique : Hémisuccinate d'Hydrocortisone (HHC) 100mg en IV directe, à répéter toutes les 6 heures.\n"
          "• Si échec : Sulfate de Magnésium (MgSO4) 2g en perfusion IV sur 20 minutes.",
      "warning": "Surveiller la saturation (cible 93-95%), la fréquence cardiaque et l'apparition de signes d'épuisement respiratoire (silence auscultatoire, troubles de conscience).",
      "icon": Iconsax.note_21,
      "color": const Color(0xFF3B82F6),
    },
    {
      "type": "prescriptions",
      "title": "Hypertension Artérielle (HTA) Essentielle",
      "category": "Cardiologie",
      "subtitle": "Schéma thérapeutique initial",
      "protocol": "• Monothérapie ou Bithérapie de première ligne :\n"
          "  - IEC : Ramipril 5mg une fois par jour le matin.\n"
          "  - Ou Antagoniste du Calcium : Amlodipine 5mg une fois par jour le matin.\n"
          "  - Ou ARA II : Valsartan 80mg une fois par jour.\n"
          "• Si HTA non contrôlée après 4 semaines : Passer à la bithérapie combinée (ex: Ramipril + Amlodipine).",
      "warning": "Contre-indication absolue des IEC/ARA II chez la femme enceinte. Surveiller la fonction rénale et la kaliémie 1 à 2 semaines après l'initiation.",
      "icon": Iconsax.note_21,
      "color": const Color(0xFF3B82F6),
    },

    // --- CONDUITE A TENIR (EMERGENCY) ---
    {
      "type": "emergency",
      "title": "Choc Anaphylactique (Anaphylaxie Grave)",
      "category": "Réanimation / Urgences",
      "subtitle": "Conduite à tenir immédiate",
      "protocol": "1. Arrêt immédiat de l'administration de l'allergène suspecté.\n"
          "2. Adrénaline par voie Intra-Musculaire (IM) stricte (cuisse face antéro-latérale) :\n"
          "   - Adulte : 0.5 mg (Solution au 1/1000, soit 0.5 mL).\n"
          "   - Enfant : 0.01 mg/kg IM (max 0.3 mg).\n"
          "3. Répéter l'injection après 5 à 15 minutes si pas d'amélioration clinique.\n"
          "4. Oxygénothérapie à fort débit (10-15 L/min au masque à réserve).\n"
          "5. Remplissage vasculaire rapide par Cristalloïdes isotoniques (20 ml/kg chez l'enfant, 500-1000 ml chez l'adulte).",
      "warning": "Ne jamais injecter l'adrénaline en IV directe sans dilution préalable et monitorage strict (risque de trouble du rythme mortel).",
      "icon": Iconsax.danger,
      "color": const Color(0xFFEF4444),
    },
    {
      "type": "emergency",
      "title": "Hyperkaliémie Menaçante (K+ > 6.5 mmol/L)",
      "category": "Néphrologie / Urgences",
      "subtitle": "Algorithme d'urgence",
      "protocol": "1. Cardioprotection (si anomalies ECG type ondes T pointues, troubles de conduction) :\n"
          "   - Gluconate de Calcium 10% : 1 ampoule (10 ml) en IV lente sur 5 minutes.\n"
          "2. Transfert du Potassium du milieu extracellulaire vers intracellulaire :\n"
          "   - Insuline rapide (Actrapid) 10 UI dans 500 mL de Glucose 30% en perfusion IV sur 30 minutes.\n"
          "   - Nébulisation de Salbutamol (Ventoline) 10 à 20 mg sur 15 minutes.\n"
          "3. Élimination de la surcharge potassique :\n"
          "   - Diurétiques de l'anse (Furosémide 40-80mg IV) si patient non anurique.\n"
          "   - Résines échangeuses d'ions (Kayexalate 30g PO ou IR).\n"
          "4. Épuration extrarénale (Hémodialyse) en urgence si échec des mesures médicales.",
      "warning": "Le Gluconate de Calcium est contre-indiqué chez le patient traité par Digitaliques (risque de toxicité accrue).",
      "icon": Iconsax.danger,
      "color": const Color(0xFFEF4444),
    },
    {
      "type": "emergency",
      "title": "Prise en charge initiale du Syndrome Coronarien Aigu (SCA)",
      "category": "Cardiologie",
      "subtitle": "Protocole d'urgence",
      "protocol": "1. Réaliser un ECG 12 (voire 18) dérivations en moins de 10 minutes.\n"
          "2. Poser une voie veineuse périphérique et monitorer le patient en continu.\n"
          "3. Double anti-agrégation plaquettaire immédiate :\n"
          "   - Aspirine : Dose de charge de 150 à 300 mg en IVD ou PO.\n"
          "   - Plus inhibiteur de P2Y12 (Ticagrélor 180mg PO ou Clopidogrel 300-600mg PO).\n"
          "4. Anticoagulation efficace : Héparine non fractionnée (HNF) 60 UI/kg IVD ou Énoxaparine 0.5mg/kg IVD.\n"
          "5. Traitement antalgique : Morphine titrée en IV si douleurs intolérables.\n"
          "6. Transfert médicalisé immédiat (SMUR) vers une salle de coronarographie.",
      "warning": "Éviter les injections intra-musculaires (contre-indiquées en raison du risque d'hématome sous traitement thrombolytique ou anticoagulant).",
      "icon": Iconsax.danger,
      "color": const Color(0xFFEF4444),
    },

    // --- TIPS (ASTUCES) ---
    {
      "type": "tips",
      "title": "Signe de Murphy clinique",
      "category": "Gastro-entérologie",
      "subtitle": "Technique sémiologique",
      "protocol": "• Placer la main sous le rebord costal droit du patient, au niveau de la ligne médioclaviculaire.\n"
          "• Demander au patient d'inspirer profondément.\n"
          "• Le signe est positif si la douleur provoquée par le contact entre la vésicule et la main de l'examinateur interrompt brutalement l'inspiration.",
      "warning": "Signe évocateur de cholécystite aiguë. Sensibilité élevée, mais peut être négatif chez les patients âgés ou sous analgésiques.",
      "icon": Iconsax.flash_1,
      "color": const Color(0xFFF59E0B),
    },
    {
      "type": "tips",
      "title": "Règle des Neufs de Wallace",
      "category": "Urgences / Brûlures",
      "subtitle": "Évaluation de la surface corporelle",
      "protocol": "Permet d'estimer rapidement le pourcentage de surface corporelle brûlée (SCB) chez l'adulte :\n"
          "• Tête et cou : 9%\n"
          "• Chaque membre supérieur : 9% (x2)\n"
          "• Face antérieure du tronc : 18%\n"
          "• Face postérieure du tronc : 18%\n"
          "• Chaque membre inférieur : 18% (x2)\n"
          "• Organes génitaux externes : 1%",
      "warning": "Ne pas inclure les brûlures du premier degré (érythème simple) dans le calcul de la surface brûlée totale.",
      "icon": Iconsax.flash_1,
      "color": const Color(0xFFF59E0B),
    },
    {
      "type": "tips",
      "title": "Interprétation du liquide céphalorachidien (LCR)",
      "category": "Infectiologie / Pédiatrie",
      "subtitle": "Aide au diagnostic différentiel",
      "protocol": "• Aspect purulent / Prédominance de Polynucléaires Neutrophiles / Hypoglycorachie marquée = Origine Bactérienne.\n"
          "• Aspect clair / Prédominance Lymphocytaire / Glycorachie normale = Origine Virale.\n"
          "• Aspect clair ou opalin / Prédominance Lymphocytaire / Hypoglycorachie = Évoquer la Tuberculose ou la Listériose.",
      "warning": "Toute suspicion de méningite bactérienne impose une antibiothérapie immédiate, idéalement après la PL (ou avant si purpura fulminans).",
      "icon": Iconsax.flash_1,
      "color": const Color(0xFFF59E0B),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredPearls = _pearls.where((pearl) {
      final matchesSearch =
          pearl['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
              pearl['category'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
              pearl['protocol'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesTab = _selectedTab == 'all' || pearl['type'] == _selectedTab;
      
      return matchesSearch && matchesTab;
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
          "Fiches de Pratique Médicale",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                ),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: "Rechercher un traitement, signe ou symptôme...",
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 14),
                  prefixIcon: Icon(Iconsax.search_normal, color: isDark ? Colors.white54 : Colors.black54, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Horizontal Category Tabs
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildTabChip("all", "Tout", Iconsax.category, const Color(0xFF6366F1)),
                  const SizedBox(width: 8),
                  _buildTabChip("tips", "Astuces Médicales", Iconsax.flash_1, const Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  _buildTabChip("prescriptions", "Prescriptions", Iconsax.note_21, const Color(0xFF3B82F6)),
                  const SizedBox(width: 8),
                  _buildTabChip("emergency", "Conduites à Tenir", Iconsax.danger, const Color(0xFFEF4444)),
                ],
              ),
            ),
          ),

          // List of Pearls
          Expanded(
            child: filteredPearls.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.document_filter, size: 48, color: isDark ? Colors.white30 : Colors.black26),
                        const SizedBox(height: 12),
                        Text(
                          "Aucune fiche trouvée",
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
                    itemCount: filteredPearls.length,
                    itemBuilder: (context, index) {
                      final pearl = filteredPearls[index];
                      return _buildPearlCard(context, pearl, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(String value, String label, IconData icon, Color color) {
    final isSelected = _selectedTab == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = value;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color
                : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? color
                  : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPearlCard(BuildContext context, Map<String, dynamic> pearl, bool isDark) {
    final color = pearl['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: color,
          collapsedIconColor: isDark ? Colors.white54 : Colors.black45,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(pearl['icon'] as IconData, color: color, size: 22),
          ),
          title: Text(
            pearl['title'].toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    pearl['category'].toString().toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pearl['subtitle'].toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: Colors.white10),
                  const SizedBox(height: 16),
                  
                  // Content Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pearl['type'] == 'prescriptions' ? "ORDONNANCE" : "PROTOCOLE CLINIQUE",
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: "${pearl['title']}\n\n${pearl['protocol']}"));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Copié dans le presse-papier !"),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Iconsax.copy),
                        iconSize: 18,
                        color: isDark ? Colors.white54 : Colors.black54,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Protocol text
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                      ),
                    ),
                    child: Text(
                      pearl['protocol'].toString(),
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                  
                  // Warning section
                  if (pearl['warning'] != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Iconsax.warning_2,
                          size: 16,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pearl['warning'].toString(),
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 12,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
