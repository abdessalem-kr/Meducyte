import 'package:meducyte_app/features/observation/data/models/specialty_config.dart';
import 'package:meducyte_app/features/observation/data/services/pathology_data_service.dart';

class PathologyDirectoryService {
  static const List<MedicalSpecialty> specialtiesWithData = [
    MedicalSpecialty.cardiology,
    MedicalSpecialty.chirurgiegenerale,
    MedicalSpecialty.dermatologieetvenereologie,
    MedicalSpecialty.diabetologieendocrinologieetmaladiesmetaboliques,
    MedicalSpecialty.general,
    MedicalSpecialty.hematologie,
    MedicalSpecialty.hepatogastroenterologie,
    MedicalSpecialty.infectiologie,
    MedicalSpecialty.nephrologie,
    MedicalSpecialty.neurology,
    MedicalSpecialty.ophtalmologie,
    MedicalSpecialty.orl,
    MedicalSpecialty.pediatrie,
    MedicalSpecialty.pneumophtisiologie,
    MedicalSpecialty.psychiatrie,
    MedicalSpecialty.rhumatologie,
  ];

  static final Map<MedicalSpecialty, List<PathologyGuide>> _cachedAll = {};

  /// Loads all pathologies across all 16 specialties with JSON files.
  static Future<Map<MedicalSpecialty, List<PathologyGuide>>> getAllPathologies() async {
    if (_cachedAll.isNotEmpty) return _cachedAll;
    for (final specialty in specialtiesWithData) {
      final list = await PathologyDataService.loadPathologies(specialty);
      _cachedAll[specialty] = list;
    }
    return _cachedAll;
  }

  /// Classifies a raw search query into its most likely MedicalSpecialty based on keyword mapping.
  static MedicalSpecialty classifySpecialty(String query) {
    final q = query.toLowerCase();
    if (q.contains("card") ||
        q.contains("coeur") ||
        q.contains("infarct") ||
        q.contains("coron") ||
        q.contains("valvul") ||
        q.contains("hypertens") ||
        q.contains("rythm") ||
        q.contains("fa") ||
        q.contains("tension") ||
        q.contains("péricard") ||
        q.contains("insuffisance cardiaque")) {
      return MedicalSpecialty.cardiology;
    }
    if (q.contains("neur") ||
        q.contains("avc") ||
        q.contains("cerve") ||
        q.contains("méning") ||
        q.contains("céphal") ||
        q.contains("épilep") ||
        q.contains("paraly") ||
        q.contains("coma") ||
        q.contains("démenc") ||
        q.contains("alzheimer")) {
      return MedicalSpecialty.neurology;
    }
    if (q.contains("diab") ||
        q.contains("insul") ||
        q.contains("gland") ||
        q.contains("thyro") ||
        q.contains("hormon") ||
        q.contains("endo") ||
        q.contains("métabol")) {
      return MedicalSpecialty.diabetologieendocrinologieetmaladiesmetaboliques;
    }
    if (q.contains("poumon") ||
        q.contains("asthm") ||
        q.contains("bronch") ||
        q.contains("toux") ||
        q.contains("respir") ||
        q.contains("pleur") ||
        q.contains("pneumo") ||
        q.contains("dyspn")) {
      return MedicalSpecialty.pneumophtisiologie;
    }
    if (q.contains("rein") ||
        q.contains("néphr") ||
        q.contains("créat") ||
        q.contains("dialy") ||
        q.contains("glomér") ||
        q.contains("urin") ||
        q.contains("vess") ||
        q.contains("giordano")) {
      return MedicalSpecialty.nephrologie;
    }
    if (q.contains("gastro") ||
        q.contains("estomac") ||
        q.contains("col") ||
        q.contains("intestin") ||
        q.contains("foie") ||
        q.contains("pancré") ||
        q.contains("hépat") ||
        q.contains("appendic") ||
        q.contains("biliair")) {
      return MedicalSpecialty.hepatogastroenterologie;
    }
    if (q.contains("peau") ||
        q.contains("derm") ||
        q.contains("acn") ||
        q.contains("psor") ||
        q.contains("eczé") ||
        q.contains("mélan") ||
        q.contains("zona") ||
        q.contains("urtic")) {
      return MedicalSpecialty.dermatologieetvenereologie;
    }
    if (q.contains("fract") ||
        q.contains("os") ||
        q.contains("articul") ||
        q.contains("arthr") ||
        q.contains("rhum") ||
        q.contains("genou") ||
        q.contains("hanch") ||
        q.contains("rachis")) {
      return MedicalSpecialty.rhumatologie;
    }
    if (q.contains("infect") ||
        q.contains("fièvr") ||
        q.contains("seps") ||
        q.contains("palu") ||
        q.contains("covid") ||
        q.contains("bactér") ||
        q.contains("viru") ||
        q.contains("antibio")) {
      return MedicalSpecialty.infectiologie;
    }
    if (q.contains("œil") ||
        q.contains("oeil") ||
        q.contains("ophtal") ||
        q.contains("visio") ||
        q.contains("rétin") ||
        q.contains("glauc") ||
        q.contains("conjonct")) {
      return MedicalSpecialty.ophtalmologie;
    }
    if (q.contains("oreil") ||
        q.contains("orl") ||
        q.contains("gorg") ||
        q.contains("sinu") ||
        q.contains("otit") ||
        q.contains("rhin") ||
        q.contains("amygd")) {
      return MedicalSpecialty.orl;
    }
    if (q.contains("sang") ||
        q.contains("hégat") ||
        q.contains("hémato") ||
        q.contains("aném") ||
        q.contains("leucé") ||
        q.contains("lymph") ||
        q.contains("plaquet")) {
      return MedicalSpecialty.hematologie;
    }
    if (q.contains("psy") ||
        q.contains("dépres") ||
        q.contains("anxié") ||
        q.contains("schiz") ||
        q.contains("bipol") ||
        q.contains("halluc")) {
      return MedicalSpecialty.psychiatrie;
    }
    if (q.contains("chir") || q.contains("herni") || q.contains("appendice") || q.contains("calcul")) {
      return MedicalSpecialty.chirurgiegenerale;
    }
    if (q.contains("enfant") || q.contains("pédia") || q.contains("bébé") || q.contains("nourris")) {
      return MedicalSpecialty.pediatrie;
    }
    return MedicalSpecialty.general;
  }

  /// Dynamically constructs a high-precision PathologyGuide for any user query.
  static PathologyGuide generateDynamicGuide(String query, MedicalSpecialty specialty) {
    final title = query.trim().split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    List<String> redFlags = [];
    List<ExaminationStep> focusedExam = [];
    List<String> immediateManagement = [];
    List<DiagnosticScore> scores = [];

    switch (specialty) {
      case MedicalSpecialty.cardiology:
        redFlags = [
          "Douleur thoracique constrictive > 20 min",
          "Dyspnée de repos ou orthopnée",
          "Instabilité hémodynamique / Choc",
          "Syncope à l'effort"
        ];
        focusedExam = [
          const ExaminationStep(
            title: "Examen Cardio-Vasculaire Orienté",
            relatedFieldKeys: ["bruits_coeur", "pouls_periph", "pression_arterielle"],
            steps: [
              ExaminationSubStep(
                action: "Auscultation des bruits et souffles cardiaques",
                description: "Rechercher un souffle d'apparition récente ou un bruit de galop B3/B4.",
                interpretation: "B3 évoque une décompensation VG ; un souffle peut indiquer une valvulopathie ou une complication mécanique.",
              ),
              ExaminationSubStep(
                action: "Palpation des pouls périphériques et mesure bilatérale de la PA",
                description: "Vérifier la symétrie des pouls et éliminer une asymétrie tensionnelle.",
                interpretation: "Asymétrie évoque une dissection aortique. L'absence de pouls distal signe une AOMI.",
              ),
            ],
          )
        ];
        immediateManagement = [
          "Repos strict au lit, monitoring ECG continu",
          "Mettre en place une voie veineuse périphérique",
          "Oxygénothérapie si saturation < 90%",
          "Contacter l'unité de soins intensifs cardiologiques (USIC)"
        ];
        scores = [
          const DiagnosticScore(
            name: "Score de Glasgow (GCS) adaptatif",
            description: "Évalue la conscience en cas de retentissement hémodynamique",
            criteria: ["Ouverture des yeux (1-4) (+1)", "Réponse verbale (1-5) (+1)", "Réponse motrice (1-6) (+1)"],
            interpretation: "Score <= 8 : Coma grave nécessitant une protection des voies aériennes.",
          )
        ];
        break;
      case MedicalSpecialty.pneumophtisiologie:
        redFlags = [
          "Dyspnée aiguë avec tirage ou cyanose",
          "Saturation en oxygène (SpO2) < 90% en air ambiant",
          "Fréquence respiratoire > 25 ou < 10 respirations/min",
          "Silence auscultatoire (thorax muet)"
        ];
        focusedExam = [
          const ExaminationStep(
            title: "Examen Pleuro-Pulmonaire Orienté",
            relatedFieldKeys: ["inspection_thorax", "palpation_thorax", "percussion_thorax", "auscultation_poumons"],
            steps: [
              ExaminationSubStep(
                action: "Auscultation pulmonaire bilatérale",
                description: "Rechercher des râles crépitants, des sibilants, ou une abolition du murmure vésiculaire.",
                interpretation: "Des sibilants orientent vers un bronchospasme (asthme, BPCO). Des crépitants localisés évoquent une pneumonie.",
              ),
              ExaminationSubStep(
                action: "Évaluation de la mécanique respiratoire",
                description: "Rechercher des signes de lutte : tirage intercostal, battement des ailes du nez, balancement thoraco-abdominal.",
                interpretation: "Signe de fatigue musculaire respiratoire imminente, risque d'arrêt respiratoire.",
              ),
            ],
          )
        ];
        immediateManagement = [
          "Position demi-assise obligatoire",
          "Oxygénothérapie à fort débit pour cibler SpO2 94-98%",
          "Nébulisation de bronchodilatateurs (ex. Salbutamol) si sibilants",
          "Préparer le matériel de ventilation assistée en cas de détresse majeure"
        ];
        break;
      case MedicalSpecialty.neurology:
        redFlags = [
          "Déficit moteur ou sensitif d'apparition brutale",
          "Troubles de la parole ou aphasie brutale",
          "Céphalée explosive d'intensité maximale d'emblée (coup de tonnerre)",
          "Crise convulsive prolongée > 5 min"
        ];
        focusedExam = [
          const ExaminationStep(
            title: "Examen Neurologique Ciblé",
            relatedFieldKeys: ["fonctions_superieures", "paires_craniennes", "motricite_force", "sensibilite"],
            steps: [
              ExaminationSubStep(
                action: "Évaluation de la force motrice (Manœuvres de Barré et Mingazzini)",
                description: "Demander au patient de maintenir les bras tendus en avant pendant 10 secondes.",
                interpretation: "Un déficit ou un affaissement unilatéral oriente vers une atteinte pyramidale controlatérale (ex: AVC).",
              ),
              ExaminationSubStep(
                action: "Examen des paires crâniennes et de la symétrie faciale",
                description: "Demander au patient de sourire, gonfler les joues et fermer les yeux.",
                interpretation: "Une asymétrie du bas du visage avec respect du front indique une paralysie faciale centrale.",
              ),
            ],
          )
        ];
        immediateManagement = [
          "Laisser le patient à jeun strict (risque de fausses routes)",
          "Noter l'heure de début des signes neurologiques",
          "Positionner en décubitus dorsal avec tête à 30° ou PLS si altération conscience",
          "Alerter la filière AVC/UNV en urgence"
        ];
        scores = [
          const DiagnosticScore(
            name: "Échelle de Glasgow (GCS)",
            description: "Évalue la profondeur du coma et l'état de conscience",
            criteria: [
              "Yeux : Pas d'ouverture (+1)",
              "Yeux : Ouverture à la douleur (+2)",
              "Yeux : Ouverture à la demande (+3)",
              "Yeux : Ouverture spontanée (+4)",
              "Verbal : Pas de réponse (+1)",
              "Verbal : Sons incompréhensibles (+2)",
              "Verbal : Mots inappropriés (+3)",
              "Verbal : Confuse (+4)",
              "Verbal : Orientée (+5)",
              "Moteur : Pas de réponse (+1)",
              "Moteur : Extension stéréotypée (+2)",
              "Moteur : Flexion stéréotypée (+3)",
              "Moteur : Évitement non adapté (+4)",
              "Moteur : Localisation à la douleur (+5)",
              "Moteur : Obéissance aux ordres (+6)"
            ],
            interpretation: "Score <= 8 : Coma nécessitant une intubation trachéale.",
          )
        ];
        break;
      case MedicalSpecialty.nephrologie:
        redFlags = [
          "Anurie complète (absence d'urine) > 12h",
          "Signes de surcharge pulmonaire (OAP : crépitants bilatéraux)",
          "Hyperkaliémie menaçante (> 6.0 mmol/L) avec troubles ECG",
          "Acidose métabolique sévère"
        ];
        focusedExam = [
          const ExaminationStep(
            title: "Examen Rénal et Hydratation",
            relatedFieldKeys: ["points_ureteraux", "globe_vesical", "recherche_oedemes"],
            steps: [
              ExaminationSubStep(
                action: "Recherche de globe vésical (matité hypogastrique)",
                description: "Percuter et palper la région sus-pubienne.",
                interpretation: "Une matité à convexité supérieure douloureuse confirme une rétention aiguë d'urine.",
              ),
              ExaminationSubStep(
                action: "Recherche d'œdèmes des membres inférieurs (signe du godet)",
                description: "Appliquer une pression ferme sur la face interne du tibia.",
                interpretation: "Des œdèmes bilatéraux blancs, mous, indolores prenant le godet évoquent un syndrome néphrotique ou une insuffisance cardiaque.",
              ),
            ],
          )
        ];
        immediateManagement = [
          "Restriction hydrique stricte si oligo-anurie",
          "Arrêt immédiat de tout médicament néphrotoxique (AINS, IEC/ARA2)",
          "Pose d'une sonde urinaire si globe vésical présent",
          "Préparer le transfert en hémodialyse en urgence si critères de dialyse atteints"
        ];
        break;
      case MedicalSpecialty.diabetologieendocrinologieetmaladiesmetaboliques:
        redFlags = [
          "Trouble de la conscience ou coma avec glycémie < 0.5 g/L ou > 3 g/L",
          "Haleine cétonique (pomme de reinette) avec polypnée de Kussmaul",
          "Déshydratation globale profonde",
          "Fièvre élevée associée à une plaie du pied"
        ];
        focusedExam = [
          const ExaminationStep(
            title: "Examen Endocrinien et Neuropathique",
            relatedFieldKeys: ["thyroide_palp", "diabete_neuro", "diabete_vasc"],
            steps: [
              ExaminationSubStep(
                action: "Test de sensibilité au monofilament de 10g",
                description: "Appliquer le monofilament sur les points d'appui plantaires.",
                interpretation: "La perte de sensibilité au monofilament signe une neuropathie sensitive augmentant le risque d'ulcère du pied.",
              ),
            ],
          )
        ];
        immediateManagement = [
          "Resucitation hydro-électrolytique (Sérum Salé 0.9%) si acidocétose ou syndrome hyperosmolaire",
          "Protocoles d'insuline intraveineuse si glycémie très élevée avec cétonurie",
          "Re-sucrage d'urgence (Glucosé 30% IV ou glucagon) si hypoglycémie sévère",
          "Décharge stricte du pied en cas d'ulcération suspecte"
        ];
        break;
      default:
        redFlags = [
          "Altération sévère de l'état général",
          "Instabilité des constantes vitales (TA < 90 mmHg, FC > 120/min)",
          "Fièvre élevée (> 39°C) ou hypothermie (< 36°C)",
          "Troubles de conscience ou désorientation"
        ];
        focusedExam = [
          const ExaminationStep(
            title: "Examen Clinique Général",
            relatedFieldKeys: ["etat_general", "hydratation_nutrition", "constantes_physiques"],
            steps: [
              ExaminationSubStep(
                action: "Prise complète des constantes vitales",
                description: "Prendre la pression artérielle, la fréquence cardiaque, la température, la fréquence respiratoire et la saturation.",
                interpretation: "Permet de classer le degré d'urgence et d'orienter la prise en charge immédiate.",
              ),
            ],
          )
        ];
        immediateManagement = [
          "Sécuriser le patient (repos au lit)",
          "Poser une voie veineuse périphérique",
          "Monitorer les constantes toutes les 15 minutes",
          "Alerter le médecin sénior responsable"
        ];
        break;
    }

    return PathologyGuide(
      name: title,
      description: "Fiche d'aide diagnostique dynamique pour : $title. Adaptée aux protocoles de la spécialité ${specialty.name}.",
      redFlags: redFlags,
      focusedExam: focusedExam,
      immediateManagement: immediateManagement,
      scores: scores,
      differentialDiagnosis: [
        "Autres diagnostics de la spécialité ${specialty.name}",
        "Diagnostic différentiel général"
      ],
    );
  }
}
