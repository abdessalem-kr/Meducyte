import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:json_annotation/json_annotation.dart';

part 'specialty_config.g.dart';

enum MedicalSpecialty {
  general,
  cardiology,
  neurology,
  anesthesiereanimation,
  anesthesiereanimationpediatrique,
  biophysiquemedicale,
  dermatologieetvenereologie,
  diabetologieendocrinologieetmaladiesmetaboliques,
  epidemiologieetmedecinepreventive,
  hepatogastroenterologie,
  hematologie,
  gynecologieobstetrique,
  infectiologie,
  medecineinterne,
  medecinelegaledroitmedicaletethique,
  medecinenucleaireetimageriemoleculaire,
  medecinedusport,
  medecinedutravail,
  medecinephysiqueetreadaptation,
  nephrologie,
  oncologiemedicale,
  ophtalmologie,
  orl,
  pediatrie,
  psychiatrie,
  pedopsychiatrie,
  pneumophtisiologie,
  radiotherapieoncologie,
  rhumatologie,
  reanimationmedicale,
  chirurgiegenerale,
  chirurgiecardiaque,
  chirurgiemaxillofaciale,
  chirurgieneurologique,
  chirurgieorthopediqueettraumatologie,
  chirurgiepediatrique,
  chirurgiethoracique,
  chirurgieurologique,
  chirurgievasculaire,
  chirurgieplastiquereconstructriceesthetiqueetdebrulologie,
}

@JsonSerializable()
class ExamFieldConfig {
  final String key;
  final String label;
  final String normalText;
  final String? localizationKey;

  const ExamFieldConfig({
    required this.key,
    required this.label,
    required this.normalText,
    this.localizationKey,
  });

  factory ExamFieldConfig.fromJson(Map<String, dynamic> json) =>
      _$ExamFieldConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ExamFieldConfigToJson(this);
}

@JsonSerializable()
class ExaminationSubStep {
  final String action;
  final String? description;
  final String? interpretation;
  const ExaminationSubStep({
    required this.action,
    this.description,
    this.interpretation,
  });

  factory ExaminationSubStep.fromJson(Map<String, dynamic> json) =>
      _$ExaminationSubStepFromJson(json);
  Map<String, dynamic> toJson() => _$ExaminationSubStepToJson(this);
}

@JsonSerializable()
class ExaminationStep {
  final String title;
  final List<ExaminationSubStep> steps;
  final String? clinicalPearl;
  final List<String>? relatedFieldKeys;
  const ExaminationStep({
    required this.title,
    required this.steps,
    this.clinicalPearl,
    this.relatedFieldKeys,
  });

  factory ExaminationStep.fromJson(Map<String, dynamic> json) =>
      _$ExaminationStepFromJson(json);
  Map<String, dynamic> toJson() => _$ExaminationStepToJson(this);
}

@JsonSerializable()
class DiagnosticScore {
  final String name;
  final String description;
  final List<String> criteria;
  final String interpretation;

  const DiagnosticScore({
    required this.name,
    required this.description,
    required this.criteria,
    required this.interpretation,
  });

  factory DiagnosticScore.fromJson(Map<String, dynamic> json) =>
      _$DiagnosticScoreFromJson(json);
  Map<String, dynamic> toJson() => _$DiagnosticScoreToJson(this);
}

@JsonSerializable()
class PathologyGuide {
  final String name;
  final String? description;
  final List<ExaminationStep>? focusedExam;
  final List<DiagnosticScore>? scores;
  final List<String>? redFlags;
  final List<String>? immediateManagement;
  final List<String>? differentialDiagnosis;

  const PathologyGuide({
    required this.name,
    this.description,
    this.focusedExam,
    this.scores,
    this.redFlags,
    this.immediateManagement,
    this.differentialDiagnosis,
  });

  factory PathologyGuide.fromJson(Map<String, dynamic> json) =>
      _$PathologyGuideFromJson(json);
  Map<String, dynamic> toJson() => _$PathologyGuideToJson(this);
}

class SpecialtyFormConfig {
  final MedicalSpecialty specialty;
  final String title;
  final IconData icon;
  final List<String> commonSymptoms;
  final List<ExamFieldConfig> examFields;
  final List<ExaminationStep>? examinationGuide;
  final List<PathologyGuide>? pathologies;

  const SpecialtyFormConfig({
    required this.specialty,
    required this.title,
    required this.icon,
    required this.commonSymptoms,
    required this.examFields,
    this.examinationGuide,
    this.pathologies,
  });
}

class SpecialtyConfigs {
  static const general = SpecialtyFormConfig(
    specialty: MedicalSpecialty.general,
    title: 'General',
    icon: Iconsax.health,
    commonSymptoms: [],
    pathologies: [],
    examinationGuide: [
      ExaminationStep(
        title: "Introduction et Approche",
        relatedFieldKeys: ["etat_general", "hydratation_nutrition", "tete_cou"],
        steps: [
          ExaminationSubStep(
            action: "Lavage des mains et Présentation",
            description:
                "Se laver les mains et se présenter clairement au patient.",
            interpretation:
                "Mesure d'hygiène fondamentale etétablissement du contact.",
          ),
          ExaminationSubStep(
            action: "Vérifier l'Identité",
            description: "Nom,Prénom,Date de Naissance.",
            interpretation: "Sécurisation de l'identitédu patient.",
          ),
        ],
      ),
      ExaminationStep(
        title: "Paramètres Vitaux",
        relatedFieldKeys: ["thoracique_resp", "cardio_vasc"],
        clinicalPearl:
            "Pensez toujoursàcomparer les pouls et la PA aux deux bras en cas de doute.",
        steps: [
          ExaminationSubStep(
            action: "Pression Artérielle(PA)",
            description: "Mesurer au repos,aux deux bras si possible.",
            interpretation:
                "Dépistage de l'HTA ou d'une hypotension orthostatique.",
          ),
          ExaminationSubStep(
            action: "Fréquence Respiratoire",
            description: "Compter sur 1 minute sans prévenir le patient.",
            interpretation:
                "Détection d'une tachypnée ou d'une bradyppnée silencieuse.",
          ),
        ],
      ),
    ],
    examFields: [
      ExamFieldConfig(
        key: 'etat_general',
        label: "Impression Globale/Etat Général",
        normalText: "Bonétat général,patient conscient,coopérant,bien orienté",
      ),
      ExamFieldConfig(
        key: 'hydratation_nutrition',
        label: "Hydratation et Nutrition",
        normalText:
            "Pas de pli de déshydratation,IMC dans les normes,pas d'oedèmes marginaux",
      ),
      ExamFieldConfig(
        key: 'tete_cou',
        label: "Examen Tête et Cou",
        normalText:
            "Conjonctives rosées,pas d'ictère scléral,cavitébuccale saine,cou souple,pas de goitre,pas d'ADP",
      ),
      ExamFieldConfig(
        key: 'thoracique_resp',
        label: "Examen Pleuro-Pulmonaire",
        normalText:
            "Respiration calme,pas de tirage,murmure vésiculaire présent et symétrique bilatéralement,pas de bruits surajoutés",
      ),
      ExamFieldConfig(
        key: 'cardio_vasc',
        label: "Examen Cardio-Vasculaire",
        normalText:
            "Bruits du cœur réguliers et bien frappés,pas de souffle,pouls périphériques perçus et symétriques",
      ),
      ExamFieldConfig(
        key: 'abd_digestif',
        label: "Examen Abdominal",
        normalText:
            "Ventre souple,dépressible,indolore,pas de masse,foie et rate non palpables,orifices herniaires libres",
      ),
      ExamFieldConfig(
        key: 'uro_genital',
        label: "Examen Uro-Génital",
        normalText: "Fosses lombaires libres,pas de globe vésical",
      ),
      ExamFieldConfig(
        key: 'osteo_articulaire',
        label: "Examen Ostéo-Articulaire",
        normalText:
            "Articulations libres,sans signe inflammatoire,marche normale",
      ),
      ExamFieldConfig(
        key: 'neuro_psych',
        label: "Examen Neurologique et Mental",
        normalText:
            "Force et sensibilitégrossièrement conservées,ROT normaux,pas de signe méningé,discours cohérent",
      ),
      ExamFieldConfig(
        key: 'cutane',
        label: "Examen Cutané",
        normalText:
            "Pas de lésion suspecte,pas de purpura,ongle sans déformation",
      ),
    ],
  );

  static const cardiology = SpecialtyFormConfig(
    specialty: MedicalSpecialty.cardiology,
    title: 'Cardiology',
    icon: Iconsax.health,
    commonSymptoms: [],
    pathologies: [],
    examinationGuide: [
      ExaminationStep(
        title: "Introduction et Préparation",
        relatedFieldKeys: ["etat_general", "hydratation_nutrition", "tete_cou"],
        steps: [
          ExaminationSubStep(
            action: "Présentation et Consentement",
            description:
                "Se présenter,vérifier l'identitédu patient et expliquer l'examen.",
            interpretation:
                "Établit la confiance et assure la coopération du patient.",
          ),
          ExaminationSubStep(
            action: "Positionnementà45°",
            description: "Le patient doitêtre demi-assisà45 degrés.",
            interpretation:
                "Indispensable pourévaluer correctement la pression veineuse jugulaire(TVJ).",
          ),
        ],
      ),
      ExaminationStep(
        title: "Inspection Périphérique",
        relatedFieldKeys: ["insp_omi", "insp_cyanose", "pouls_periph"],
        steps: [
          ExaminationSubStep(
            action: "Examen des mains",
            description:
                "Chercher:Hippocratisme digital, éclats hémorragiques,nodosités d'Osler.",
            interpretation:
                "Signesévocateurs d'endocardite infectieuse ou de cardiopathie cyanogène.",
          ),
          ExaminationSubStep(
            action: "Pouls radial",
            description: "Évaluer la fréquence et le rythme.",
            interpretation:
                "Un rythme irrégulier peutévoquer une fibrillation atriale.",
          ),
        ],
      ),
      ExaminationStep(
        title: "Cou et Face",
        relatedFieldKeys: ["insp_tvj"],
        steps: [
          ExaminationSubStep(
            action: "Rechercher une TVJ",
            description:
                "Inspecter les veines jugulaires internes avec le patientà45°.",
            interpretation:
                "Une TVJélevée est un signe direct d'insuffisance cardiaque droite.",
          ),
          ExaminationSubStep(
            action: "Rechercher un Reflux Hépato-Jugulaire(RHJ)",
            description:
                "Pression ferme sur le quadrant supérieur droit de l'abdomen.",
            interpretation:
                "Un RHJ positif confirme une congestion veineuse systémique.",
          ),
        ],
      ),
      ExaminationStep(
        title: "Examen du Précordium",
        relatedFieldKeys: [
          "palp_choc",
          "palp_thrill",
          "palp_harzer",
          "ausc_rythme",
          "ausc_bruits",
          "ausc_ao",
          "ausc_pulm",
          "ausc_mitral",
          "ausc_tricuspid",
          "ausc_vasc",
        ],
        clinicalPearl:
            "N'oubliez pas de palper le choc de pointe avant d'ausculter!",
        steps: [
          ExaminationSubStep(
            action: "Palpation du choc de pointe",
            description:
                "5ème espace intercostal gauche,ligne médio-claviculaire.",
            interpretation:
                "Un choc déviévers la gauche suggère une cardiomégalie(dilatation du VG).",
          ),
          ExaminationSubStep(
            action: "Auscultation des 4 foyers",
            description:
                "Aortique(2e EID),Pulmonaire(2e EIG),Tricuspide(4e EIG),Mitral(5e EIG).",
            interpretation:
                "Identifier les souffles(systoliques/diastoliques)et les bruits surajoutés(B3,B4).",
          ),
        ],
      ),
    ],
    examFields: [
      ExamFieldConfig(
        key: 'insp_omi',
        label: "Inspection:OMI(Œdèmes)",
        normalText: "Absents",
      ),
      ExamFieldConfig(
        key: 'insp_cyanose',
        label: "Inspection:Cyanose",
        normalText: "Absente",
      ),
      ExamFieldConfig(
        key: 'insp_tvj',
        label: "Turgescence Veines Jugulaires",
        normalText: "Absente",
      ),
      ExamFieldConfig(
        key: 'palp_choc',
        label: "Palpation:Choc de pointe",
        normalText: "En place,non dévié,normocinétique",
      ),
      ExamFieldConfig(
        key: 'palp_thrill',
        label: "Palpation:Frémissement/Thrill",
        normalText: "Absent",
      ),
      ExamFieldConfig(
        key: 'palp_harzer',
        label: "Signe de Harzer",
        normalText: "Négatif",
      ),
      ExamFieldConfig(
        key: 'ausc_rythme',
        label: "Rythme Cardiaque",
        normalText: "Régulier",
      ),
      ExamFieldConfig(
        key: 'ausc_bruits',
        label: "Bruits du cœur",
        normalText: "B1 et B2 présents et bien frappés,pas de B3 ni de B4",
      ),
      ExamFieldConfig(
        key: 'ausc_ao',
        label: "Auscultation:Foyer Aortique",
        normalText: "Libre,pas de souffle",
      ),
      ExamFieldConfig(
        key: 'ausc_pulm',
        label: "Auscultation:Foyer Pulmonaire",
        normalText: "Libre,pas de souffle",
      ),
      ExamFieldConfig(
        key: 'ausc_mitral',
        label: "Auscultation:Foyer Mitral",
        normalText: "Libre,pas de souffle",
      ),
      ExamFieldConfig(
        key: 'ausc_tricuspid',
        label: "Auscultation:Foyer Tricuspidien",
        normalText: "Libre,pas de souffle",
      ),
      ExamFieldConfig(
        key: 'pouls_periph',
        label: "Pouls périphériques",
        normalText: "Présents,symétriques,synchrones et réguliers",
      ),
      ExamFieldConfig(
        key: 'ausc_vasc',
        label: "Auscultation vasculaire(Carotides,Fémorales)",
        normalText: "Pas de souffle vasculaire",
      ),
    ],
  );

  static const neurology = SpecialtyFormConfig(
    specialty: MedicalSpecialty.neurology,
    title: 'Neurology',
    icon: Iconsax.health,
    commonSymptoms: [],
    pathologies: [],
    examinationGuide: [
      ExaminationStep(
        title: "Introduction et Nerfs Crâniens",
        relatedFieldKeys: [
          "nerfs_craniens",
          "conscience",
          "langage",
          "orientation",
        ],
        steps: [
          ExaminationSubStep(
            action: "Paires Crâniennes II,III,IV,VI",
            description:
                "Acuitévisuelle,champs visuels,oculomotricité (test en H).",
            interpretation:
                "Évalue les nerfs optiques et les muscles oculo-moteurs.",
          ),
          ExaminationSubStep(
            action: "Paires Crâniennes VII(Facial)",
            description:
                "Demander de sourire,gonfler les joues,fermer les yeux fort.",
            interpretation:
                "Distinguer une paralysie faciale centrale vs périphérique.",
          ),
        ],
      ),
      ExaminationStep(
        title: "Membres Supérieurs et Inférieurs",
        relatedFieldKeys: [
          "force_ms",
          "force_mi",
          "tonus",
          "rot_ms",
          "rot_mi",
          "sens_super",
          "sens_prof",
          "babinski",
        ],
        clinicalPearl:
            "La comparaison symétrique'côtépar côté'est la règle d'or en neurologie.",
        steps: [
          ExaminationSubStep(
            action: "Évaluation de la Force(0-5)",
            description:
                "0:aucune contraction,3:contre pesanteur,5:force normale.",
            interpretation:
                "Permet de quantifier précisément un déficit moteur.",
          ),
          ExaminationSubStep(
            action: "Réflexes Ostéo-Tendonux(ROT)",
            description: "Bicipital,Tricipital,Rotulien,Achilléen.",
            interpretation:
                "Vifs ou polycinétiques:syndrome pyramidal.Abolis:syndrome périphérique.",
          ),
        ],
      ),
      ExaminationStep(
        title: "Coordination et Marche",
        relatedFieldKeys: ["marche", "romberg"],
        steps: [
          ExaminationSubStep(
            action: "Épreuve Doigt-Nez",
            description:
                "Demander au patient de toucher son nez puis votre doigt rapidement.",
            interpretation: "Une dysmétrieévoque un syndrome cérébelleux.",
          ),
          ExaminationSubStep(
            action: "Station debout(Romberg)",
            description: "Debout,pieds joints,yeux ouverts puis fermés.",
            interpretation:
                "Oscillationsàla fermeture des yeux:atteinte de la sensibilitéprofonde(Ataxie proprioceptive).",
          ),
        ],
      ),
    ],
    examFields: [
      ExamFieldConfig(
        key: 'conscience',
        label: "Conscience(Glasgow)",
        normalText: "15/15",
      ),
      ExamFieldConfig(
        key: 'orientation',
        label: "Orientation",
        normalText: "Orienté(e)dans le temps et l'espace",
      ),
      ExamFieldConfig(
        key: 'marche',
        label: "Station debout et Marche",
        normalText: "Marche normale,pas de déficit,pas d'ataxie",
      ),
      ExamFieldConfig(
        key: 'romberg',
        label: "Signe de Romberg",
        normalText: "Négatif",
      ),
      ExamFieldConfig(
        key: 'force_ms',
        label: "Force Musculaire-Membres Sup.",
        normalText: "5/5 bilatéral et symétrique",
      ),
      ExamFieldConfig(
        key: 'force_mi',
        label: "Force Musculaire-Membres Inf.",
        normalText: "5/5 bilatéral et symétrique",
      ),
      ExamFieldConfig(
        key: 'tonus',
        label: "Tonus musculaire",
        normalText: "Normal,pas d'hypertonie ni d'hypotonie",
      ),
      ExamFieldConfig(
        key: 'sens_super',
        label: "Sensibilitésuperficielle",
        normalText: "Normale,symétrique",
      ),
      ExamFieldConfig(
        key: 'sens_prof',
        label: "Sensibilitéprofonde(Proprioception)",
        normalText: "Normale,pallesthésie conservée",
      ),
      ExamFieldConfig(
        key: 'rot_ms',
        label: "ROT Membres Supérieurs(Bicipital,Tricipital)",
        normalText: "Présents,symétriques,normo-vifs",
      ),
      ExamFieldConfig(
        key: 'rot_mi',
        label: "ROT Membres Inférieurs(Rotulien,Achilléen)",
        normalText: "Présents,symétriques,normo-vifs",
      ),
      ExamFieldConfig(
        key: 'babinski',
        label: "Réflexe cutanéplantaire",
        normalText: "En flexion bilatéralement(Babinski négatif)",
      ),
      ExamFieldConfig(
        key: 'nerfs_craniens',
        label: "Nerfs Crâniens(IàXII)",
        normalText: "Pas de déficit sensitivo-moteur facial,paires intactes",
      ),
      ExamFieldConfig(
        key: 'meninges',
        label: "Signes Méningés",
        normalText: "Nuque souple,Kernig et Brudzinski négatifs",
      ),
      ExamFieldConfig(
        key: 'langage',
        label: "Langage et Paroles",
        normalText: "Fluide,pas d'aphasie ni de dysarthrie",
      ),
    ],
  );

  static const anesthesiereanimation = SpecialtyFormConfig(
    specialty: MedicalSpecialty.anesthesiereanimation,
    title: 'Anesthesiereanimation',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'etat_general',
        label: "Impression Globale/Etat Général",
        normalText: "Bonétat général,patient conscient,coopérant,bien orienté",
      ),
      ExamFieldConfig(
        key: 'hydratation_nutrition',
        label: "Hydratation et Nutrition",
        normalText:
            "Pas de pli de déshydratation,IMC dans les normes,pas d'oedèmes marginaux",
      ),
      ExamFieldConfig(
        key: 'tete_cou',
        label: "Examen Tête et Cou",
        normalText:
            "Conjonctives rosées,pas d'ictère scléral,cavitébuccale saine,cou souple,pas de goitre,pas d'ADP",
      ),
      ExamFieldConfig(
        key: 'thoracique_resp',
        label: "Examen Pleuro-Pulmonaire",
        normalText:
            "Respiration calme,pas de tirage,murmure vésiculaire présent et symétrique bilatéralement,pas de bruits surajoutés",
      ),
      ExamFieldConfig(
        key: 'cardio_vasc',
        label: "Examen Cardio-Vasculaire",
        normalText:
            "Bruits du cœur réguliers et bien frappés,pas de souffle,pouls périphériques perçus et symétriques",
      ),
      ExamFieldConfig(
        key: 'abd_digestif',
        label: "Examen Abdominal",
        normalText:
            "Ventre souple,dépressible,indolore,pas de masse,foie et rate non palpables,orifices herniaires libres",
      ),
      ExamFieldConfig(
        key: 'uro_genital',
        label: "Examen Uro-Génital",
        normalText: "Fosses lombaires libres,pas de globe vésical",
      ),
      ExamFieldConfig(
        key: 'osteo_articulaire',
        label: "Examen Ostéo-Articulaire",
        normalText:
            "Articulations libres,sans signe inflammatoire,marche normale",
      ),
      ExamFieldConfig(
        key: 'neuro_psych',
        label: "Examen Neurologique et Mental",
        normalText:
            "Force et sensibilitégrossièrement conservées,ROT normaux,pas de signe méningé,discours cohérent",
      ),
      ExamFieldConfig(
        key: 'cutane',
        label: "Examen Cutané",
        normalText:
            "Pas de lésion suspecte,pas de purpura,ongle sans déformation",
      ),
    ],
  );

  static const anesthesiereanimationpediatrique = SpecialtyFormConfig(
    specialty: MedicalSpecialty.anesthesiereanimationpediatrique,
    title: 'Anesthesiereanimationpediatrique',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'etat_general',
        label: "Impression Globale/Etat Général",
        normalText: "Bonétat général,patient conscient,coopérant,bien orienté",
      ),
      ExamFieldConfig(
        key: 'hydratation_nutrition',
        label: "Hydratation et Nutrition",
        normalText:
            "Pas de pli de déshydratation,IMC dans les normes,pas d'oedèmes marginaux",
      ),
      ExamFieldConfig(
        key: 'tete_cou',
        label: "Examen Tête et Cou",
        normalText:
            "Conjonctives rosées,pas d'ictère scléral,cavitébuccale saine,cou souple,pas de goitre,pas d'ADP",
      ),
      ExamFieldConfig(
        key: 'thoracique_resp',
        label: "Examen Pleuro-Pulmonaire",
        normalText:
            "Respiration calme,pas de tirage,murmure vésiculaire présent et symétrique bilatéralement,pas de bruits surajoutés",
      ),
      ExamFieldConfig(
        key: 'cardio_vasc',
        label: "Examen Cardio-Vasculaire",
        normalText:
            "Bruits du cœur réguliers et bien frappés,pas de souffle,pouls périphériques perçus et symétriques",
      ),
      ExamFieldConfig(
        key: 'abd_digestif',
        label: "Examen Abdominal",
        normalText:
            "Ventre souple,dépressible,indolore,pas de masse,foie et rate non palpables,orifices herniaires libres",
      ),
      ExamFieldConfig(
        key: 'uro_genital',
        label: "Examen Uro-Génital",
        normalText: "Fosses lombaires libres,pas de globe vésical",
      ),
      ExamFieldConfig(
        key: 'osteo_articulaire',
        label: "Examen Ostéo-Articulaire",
        normalText:
            "Articulations libres,sans signe inflammatoire,marche normale",
      ),
      ExamFieldConfig(
        key: 'neuro_psych',
        label: "Examen Neurologique et Mental",
        normalText:
            "Force et sensibilitégrossièrement conservées,ROT normaux,pas de signe méningé,discours cohérent",
      ),
      ExamFieldConfig(
        key: 'cutane',
        label: "Examen Cutané",
        normalText:
            "Pas de lésion suspecte,pas de purpura,ongle sans déformation",
      ),
    ],
  );

  static const biophysiquemedicale = SpecialtyFormConfig(
    specialty: MedicalSpecialty.biophysiquemedicale,
    title: 'Biophysiquemedicale',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'etat_general',
        label: "Impression Globale/Etat Général",
        normalText: "Bonétat général,patient conscient,coopérant,bien orienté",
      ),
      ExamFieldConfig(
        key: 'hydratation_nutrition',
        label: "Hydratation et Nutrition",
        normalText:
            "Pas de pli de déshydratation,IMC dans les normes,pas d'oedèmes marginaux",
      ),
      ExamFieldConfig(
        key: 'tete_cou',
        label: "Examen Tête et Cou",
        normalText:
            "Conjonctives rosées,pas d'ictère scléral,cavitébuccale saine,cou souple,pas de goitre,pas d'ADP",
      ),
      ExamFieldConfig(
        key: 'thoracique_resp',
        label: "Examen Pleuro-Pulmonaire",
        normalText:
            "Respiration calme,pas de tirage,murmure vésiculaire présent et symétrique bilatéralement,pas de bruits surajoutés",
      ),
      ExamFieldConfig(
        key: 'cardio_vasc',
        label: "Examen Cardio-Vasculaire",
        normalText:
            "Bruits du cœur réguliers et bien frappés,pas de souffle,pouls périphériques perçus et symétriques",
      ),
      ExamFieldConfig(
        key: 'abd_digestif',
        label: "Examen Abdominal",
        normalText:
            "Ventre souple,dépressible,indolore,pas de masse,foie et rate non palpables,orifices herniaires libres",
      ),
      ExamFieldConfig(
        key: 'uro_genital',
        label: "Examen Uro-Génital",
        normalText: "Fosses lombaires libres,pas de globe vésical",
      ),
      ExamFieldConfig(
        key: 'osteo_articulaire',
        label: "Examen Ostéo-Articulaire",
        normalText:
            "Articulations libres,sans signe inflammatoire,marche normale",
      ),
      ExamFieldConfig(
        key: 'neuro_psych',
        label: "Examen Neurologique et Mental",
        normalText:
            "Force et sensibilitégrossièrement conservées,ROT normaux,pas de signe méningé,discours cohérent",
      ),
      ExamFieldConfig(
        key: 'cutane',
        label: "Examen Cutané",
        normalText:
            "Pas de lésion suspecte,pas de purpura,ongle sans déformation",
      ),
    ],
  );

  static const dermatologieetvenereologie = SpecialtyFormConfig(
    specialty: MedicalSpecialty.dermatologieetvenereologie,
    title: 'Dermatologieetvenereologie',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'peau_couleur',
        label: "Peau:Coloration",
        normalText: "Normale,pas de pâleur,d'ictère ou de cyanose",
      ),
      ExamFieldConfig(
        key: 'peau_trophicite',
        label: "Peau:Trophicité /Température/Hydratation",
        normalText: "Élastique,normotherme,bien hydratée,pas de pli cutané",
      ),
      ExamFieldConfig(
        key: 'lesions_elem',
        label: "LésionsÉlémentaires",
        normalText:
            "Absentes(pas de macule,papule,vésicule,bulle,ulcération,squame)",
      ),
      ExamFieldConfig(
        key: 'lesions_topog',
        label: "Topographie des lésions",
        normalText: "N/A",
      ),
      ExamFieldConfig(
        key: 'cheveux',
        label: "Phanères:Cheveux",
        normalText: "Aspect normal,pas d'alopécie,cuir chevelu sain",
      ),
      ExamFieldConfig(
        key: 'ongles',
        label: "Phanères:Ongles",
        normalText:
            "Pas de modification de couleur,de surface ou de fragilité (pas d'onycholyse ou de leuconychie)",
      ),
      ExamFieldConfig(
        key: 'muqueuses_orales',
        label: "Muqueuses Orales",
        normalText: "Saines,de coloration normale",
      ),
      ExamFieldConfig(
        key: 'ganglions',
        label: "Aires Ganglionnaires",
        normalText: "Libres,pas d'adénopathie palpable",
      ),
    ],
  );

  static const diabetologieendocrinologieetmaladiesmetaboliques = SpecialtyFormConfig(
    specialty:
        MedicalSpecialty.diabetologieendocrinologieetmaladiesmetaboliques,
    title: 'Diabetologieendocrinologieetmaladiesmetaboliques',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'poids_taille',
        label: "Morphologie(Poids,Taille,IMC)",
        normalText: "Morphotype normal",
      ),
      ExamFieldConfig(
        key: 'repartition_graisse',
        label: "Répartition des Graisses",
        normalText:
            "Homogène,pas de répartition facio-tronculaire(aspect cushingoïde)",
      ),
      ExamFieldConfig(
        key: 'peau_vergetures',
        label: "Peau:Aspect et Vergetures",
        normalText:
            "Normale,pas de vergetures larges et pourpres,pas d'acanthosis nigricans",
      ),
      ExamFieldConfig(
        key: 'pilosite',
        label: "Pilosité",
        normalText:
            "Répartition et abondance normales(pas d'hirsutisme ni de dépilation)",
      ),
      ExamFieldConfig(
        key: 'thyroide_insp',
        label: "Thyroïde:Inspection",
        normalText: "Pas de goitre visible,cou symétrique",
      ),
      ExamFieldConfig(
        key: 'thyroide_palp',
        label: "Thyroïde:Palpation",
        normalText:
            "Taille normale,pas de nodule,consistanceélastique homogène",
      ),
      ExamFieldConfig(
        key: 'thyroide_signes',
        label: "Signes de Dysthyroïdie",
        normalText:
            "Pas d'exophtalmie,de tremblement,de tachycardie,ni de frilosité/thermophobie",
      ),
      ExamFieldConfig(
        key: 'seins_gyn',
        label: "Glandes mammaires/Gynécomastie",
        normalText: "Absence d'écoulement mamelonnaire ou de gynécomastie",
      ),
      ExamFieldConfig(
        key: 'diabete_neuro',
        label: "Pied et Diabète:Neurologique",
        normalText:
            "Sensibilitéau monofilament conservée(10g)et diapason normal,ROT présents",
      ),
      ExamFieldConfig(
        key: 'diabete_vasc',
        label: "Pied et Diabète:Vasculaire",
        normalText:
            "Pouls pédieux et tibiaux postérieurs perçus symétriquement",
      ),
    ],
  );

  static const epidemiologieetmedecinepreventive = SpecialtyFormConfig(
    specialty: MedicalSpecialty.epidemiologieetmedecinepreventive,
    title: 'Epidemiologieetmedecinepreventive',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'etat_general',
        label: "Impression Globale/Etat Général",
        normalText: "Bonétat général,patient conscient,coopérant,bien orienté",
      ),
      ExamFieldConfig(
        key: 'hydratation_nutrition',
        label: "Hydratation et Nutrition",
        normalText:
            "Pas de pli de déshydratation,IMC dans les normes,pas d'oedèmes marginaux",
      ),
      ExamFieldConfig(
        key: 'tete_cou',
        label: "Examen Tête et Cou",
        normalText:
            "Conjonctives rosées,pas d'ictère scléral,cavitébuccale saine,cou souple,pas de goitre,pas d'ADP",
      ),
      ExamFieldConfig(
        key: 'thoracique_resp',
        label: "Examen Pleuro-Pulmonaire",
        normalText:
            "Respiration calme,pas de tirage,murmure vésiculaire présent et symétrique bilatéralement,pas de bruits surajoutés",
      ),
      ExamFieldConfig(
        key: 'cardio_vasc',
        label: "Examen Cardio-Vasculaire",
        normalText:
            "Bruits du cœur réguliers et bien frappés,pas de souffle,pouls périphériques perçus et symétriques",
      ),
      ExamFieldConfig(
        key: 'abd_digestif',
        label: "Examen Abdominal",
        normalText:
            "Ventre souple,dépressible,indolore,pas de masse,foie et rate non palpables,orifices herniaires libres",
      ),
      ExamFieldConfig(
        key: 'uro_genital',
        label: "Examen Uro-Génital",
        normalText: "Fosses lombaires libres,pas de globe vésical",
      ),
      ExamFieldConfig(
        key: 'osteo_articulaire',
        label: "Examen Ostéo-Articulaire",
        normalText:
            "Articulations libres,sans signe inflammatoire,marche normale",
      ),
      ExamFieldConfig(
        key: 'neuro_psych',
        label: "Examen Neurologique et Mental",
        normalText:
            "Force et sensibilitégrossièrement conservées,ROT normaux,pas de signe méningé,discours cohérent",
      ),
      ExamFieldConfig(
        key: 'cutane',
        label: "Examen Cutané",
        normalText:
            "Pas de lésion suspecte,pas de purpura,ongle sans déformation",
      ),
    ],
  );

  static const hepatogastroenterologie = SpecialtyFormConfig(
    specialty: MedicalSpecialty.hepatogastroenterologie,
    title: 'Hepatogastroenterologie',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'cavite_buccale',
        label: "CavitéBuccale/Dents/Muqueuses",
        normalText:
            "Langue propre,humides,dentition en bonétat,gencives saines",
      ),
      ExamFieldConfig(
        key: 'insp_abd',
        label: "Inspection Abdominale",
        normalText:
            "Ventre plat,respire avec l'abdomen,pas de CVC,orifices herniaires libres",
      ),
      ExamFieldConfig(
        key: 'palp_paroi',
        label: "Palpation:Paroi Abdominale",
        normalText: "Souple globale,pas de défense ni de contracture",
      ),
      ExamFieldConfig(
        key: 'palp_dlr',
        label: "Palpation:Douleur Provoquée",
        normalText:
            "Indolore dans les 4 quadrants,Murphy et MacBurney négatifs",
      ),
      ExamFieldConfig(
        key: 'palp_foie',
        label: "Palpation:Foie",
        normalText:
            "Bord inférieur non palpable,pas d'hépatomégalie(flèche hépatique normale)",
      ),
      ExamFieldConfig(
        key: 'palp_rate',
        label: "Palpation:Rate",
        normalText: "Non palpable(pas de splénomégalie)",
      ),
      ExamFieldConfig(
        key: 'perc_abd',
        label: "Percussion Abdominale",
        normalText:
            "Tympanisme centromédian physiologique,matitédéclive absente",
      ),
      ExamFieldConfig(
        key: 'ausc_bha',
        label: "Auscultation:Bruits Hydro-Aériques",
        normalText: "Normaux,réguliers.Pas de souffle artériel abdominal",
      ),
      ExamFieldConfig(
        key: 'tr_marge',
        label: "Examen Proctologique:Marge anale",
        normalText: "Saine,pas de fissure,pas d'hémorroïde externe",
      ),
      ExamFieldConfig(
        key: 'tr_ampoule',
        label: "Toucher Rectal",
        normalText:
            "Ampoule rectale vide,prostate lisse et indolore(homme),pas de sang sur le doigtier",
      ),
    ],
  );

  static const hematologie = SpecialtyFormConfig(
    specialty: MedicalSpecialty.hematologie,
    title: 'Hematologie',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'paleur',
        label: "Peau et Muqueuses:Pâleur",
        normalText: "Absente(conjonctives et muqueuses normalement colorées)",
      ),
      ExamFieldConfig(
        key: 'hemato_cutane',
        label: "Syndrome Hémorragique Cutané",
        normalText: "Pas de pétéchies,purpura,ecchymoses ou hématomes",
      ),
      ExamFieldConfig(
        key: 'hemato_muqueux',
        label: "Syndrome Hémorragique Muqueux",
        normalText:
            "Pas d'épistaxis,de gingivorragie spontanée ou de bulles hémorragiques intrabuccales",
      ),
      ExamFieldConfig(
        key: 'adp_cervicales',
        label: "Adénopathies:Cervicales",
        normalText: "Absentes",
      ),
      ExamFieldConfig(
        key: 'adp_axill_ing',
        label: "Adénopathies:Axillaires et Inguinales",
        normalText: "Absentes",
      ),
      ExamFieldConfig(
        key: 'foie',
        label: "Hépatomégalie",
        normalText: "Absente",
      ),
      ExamFieldConfig(
        key: 'rate',
        label: "Splénomégalie",
        normalText: "Absente",
      ),
      ExamFieldConfig(
        key: 'hypertrophie_gingivale',
        label: "Hypertrophie Gingivale/Angines",
        normalText: "Absente",
      ),
      ExamFieldConfig(
        key: 'os',
        label: "Douleurs Osseuses Provoquées",
        normalText: "Indoloreàla percussion du sternum et des crêtes iliaques",
      ),
    ],
  );

  static const gynecologieobstetrique = SpecialtyFormConfig(
    specialty: MedicalSpecialty.gynecologieobstetrique,
    title: 'Gynecologieobstetrique',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'fosses_lomb',
        label: "Fosses Lombaires",
        normalText: "Inspection normale,pas de voussure",
      ),
      ExamFieldConfig(
        key: 'contact_lomb',
        label: "Palpation:Contact Lombaire/Ballottement",
        normalText: "Négatif bilatéralement",
      ),
      ExamFieldConfig(
        key: 'points_ureteraux',
        label: "Points Urétéraux",
        normalText: "Indolores",
      ),
      ExamFieldConfig(
        key: 'globe_vesical',
        label: "Palpation Pelvienne",
        normalText: "Pas de globe vésical",
      ),
      ExamFieldConfig(
        key: 'oge_femme',
        label: "OGE(Femme)",
        normalText: "Vulve d'aspect normal,sans lésion",
      ),
      ExamFieldConfig(
        key: 'tv',
        label: "Toucher Vaginal(Femme)",
        normalText: "Col normal,culs-de-sac souples et indolores",
      ),
      ExamFieldConfig(
        key: 'oge_homme',
        label: "OGE(Homme)",
        normalText:
            "Verge sans lésion,testicules en place,indolores,volume normal",
      ),
      ExamFieldConfig(
        key: 'tr_prostate',
        label: "Toucher Rectal(Homme) :Prostate",
        normalText:
            "Taille normale,souple,symétrique,sillon médian conservé,indolore",
      ),
    ],
  );

  static const infectiologie = SpecialtyFormConfig(
    specialty: MedicalSpecialty.infectiologie,
    title: 'Infectiologie',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'etat_general',
        label: "Impression Globale/Etat Général",
        normalText: "Bonétat général,patient conscient,coopérant,bien orienté",
      ),
      ExamFieldConfig(
        key: 'hydratation_nutrition',
        label: "Hydratation et Nutrition",
        normalText:
            "Pas de pli de déshydratation,IMC dans les normes,pas d'oedèmes marginaux",
      ),
      ExamFieldConfig(
        key: 'tete_cou',
        label: "Examen Tête et Cou",
        normalText:
            "Conjonctives rosées,pas d'ictère scléral,cavitébuccale saine,cou souple,pas de goitre,pas d'ADP",
      ),
      ExamFieldConfig(
        key: 'thoracique_resp',
        label: "Examen Pleuro-Pulmonaire",
        normalText:
            "Respiration calme,pas de tirage,murmure vésiculaire présent et symétrique bilatéralement,pas de bruits surajoutés",
      ),
      ExamFieldConfig(
        key: 'cardio_vasc',
        label: "Examen Cardio-Vasculaire",
        normalText:
            "Bruits du cœur réguliers et bien frappés,pas de souffle,pouls périphériques perçus et symétriques",
      ),
      ExamFieldConfig(
        key: 'abd_digestif',
        label: "Examen Abdominal",
        normalText:
            "Ventre souple,dépressible,indolore,pas de masse,foie et rate non palpables,orifices herniaires libres",
      ),
      ExamFieldConfig(
        key: 'uro_genital',
        label: "Examen Uro-Génital",
        normalText: "Fosses lombaires libres,pas de globe vésical",
      ),
      ExamFieldConfig(
        key: 'osteo_articulaire',
        label: "Examen Ostéo-Articulaire",
        normalText:
            "Articulations libres,sans signe inflammatoire,marche normale",
      ),
      ExamFieldConfig(
        key: 'neuro_psych',
        label: "Examen Neurologique et Mental",
        normalText:
            "Force et sensibilitégrossièrement conservées,ROT normaux,pas de signe méningé,discours cohérent",
      ),
      ExamFieldConfig(
        key: 'cutane',
        label: "Examen Cutané",
        normalText:
            "Pas de lésion suspecte,pas de purpura,ongle sans déformation",
      ),
    ],
  );

  static const medecineinterne = SpecialtyFormConfig(
    specialty: MedicalSpecialty.medecineinterne,
    title: 'Medecineinterne',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'etat_general',
        label: "Impression Globale/Etat Général",
        normalText: "Bonétat général,patient conscient,coopérant,bien orienté",
      ),
      ExamFieldConfig(
        key: 'hydratation_nutrition',
        label: "Hydratation et Nutrition",
        normalText:
            "Pas de pli de déshydratation,IMC dans les normes,pas d'oedèmes marginaux",
      ),
      ExamFieldConfig(
        key: 'tete_cou',
        label: "Examen Tête et Cou",
        normalText:
            "Conjonctives rosées,pas d'ictère scléral,cavitébuccale saine,cou souple,pas de goitre,pas d'ADP",
      ),
      ExamFieldConfig(
        key: 'thoracique_resp',
        label: "Examen Pleuro-Pulmonaire",
        normalText:
            "Respiration calme,pas de tirage,murmure vésiculaire présent et symétrique bilatéralement,pas de bruits surajoutés",
      ),
      ExamFieldConfig(
        key: 'cardio_vasc',
        label: "Examen Cardio-Vasculaire",
        normalText:
            "Bruits du cœur réguliers et bien frappés,pas de souffle,pouls périphériques perçus et symétriques",
      ),
      ExamFieldConfig(
        key: 'abd_digestif',
        label: "Examen Abdominal",
        normalText:
            "Ventre souple,dépressible,indolore,pas de masse,foie et rate non palpables,orifices herniaires libres",
      ),
      ExamFieldConfig(
        key: 'uro_genital',
        label: "Examen Uro-Génital",
        normalText: "Fosses lombaires libres,pas de globe vésical",
      ),
      ExamFieldConfig(
        key: 'osteo_articulaire',
        label: "Examen Ostéo-Articulaire",
        normalText:
            "Articulations libres,sans signe inflammatoire,marche normale",
      ),
      ExamFieldConfig(
        key: 'neuro_psych',
        label: "Examen Neurologique et Mental",
        normalText:
            "Force et sensibilitégrossièrement conservées,ROT normaux,pas de signe méningé,discours cohérent",
      ),
      ExamFieldConfig(
        key: 'cutane',
        label: "Examen Cutané",
        normalText:
            "Pas de lésion suspecte,pas de purpura,ongle sans déformation",
      ),
    ],
  );

  static const medecinelegaledroitmedicaletethique = SpecialtyFormConfig(
    specialty: MedicalSpecialty.medecinelegaledroitmedicaletethique,
    title: 'Medecinelegaledroitmedicaletethique',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'etat_general',
        label: "Impression Globale/Etat Général",
        normalText: "Bonétat général,patient conscient,coopérant,bien orienté",
      ),
      ExamFieldConfig(
        key: 'hydratation_nutrition',
        label: "Hydratation et Nutrition",
        normalText:
            "Pas de pli de déshydratation,IMC dans les normes,pas d'oedèmes marginaux",
      ),
      ExamFieldConfig(
        key: 'tete_cou',
        label: "Examen Tête et Cou",
        normalText:
            "Conjonctives rosées,pas d'ictère scléral,cavitébuccale saine,cou souple,pas de goitre,pas d'ADP",
      ),
      ExamFieldConfig(
        key: 'thoracique_resp',
        label: "Examen Pleuro-Pulmonaire",
        normalText:
            "Respiration calme,pas de tirage,murmure vésiculaire présent et symétrique bilatéralement,pas de bruits surajoutés",
      ),
      ExamFieldConfig(
        key: 'cardio_vasc',
        label: "Examen Cardio-Vasculaire",
        normalText:
            "Bruits du cœur réguliers et bien frappés,pas de souffle,pouls périphériques perçus et symétriques",
      ),
      ExamFieldConfig(
        key: 'abd_digestif',
        label: "Examen Abdominal",
        normalText:
            "Ventre souple,dépressible,indolore,pas de masse,foie et rate non palpables,orifices herniaires libres",
      ),
      ExamFieldConfig(
        key: 'uro_genital',
        label: "Examen Uro-Génital",
        normalText: "Fosses lombaires libres,pas de globe vésical",
      ),
      ExamFieldConfig(
        key: 'osteo_articulaire',
        label: "Examen Ostéo-Articulaire",
        normalText:
            "Articulations libres,sans signe inflammatoire,marche normale",
      ),
      ExamFieldConfig(
        key: 'neuro_psych',
        label: "Examen Neurologique et Mental",
        normalText:
            "Force et sensibilitégrossièrement conservées,ROT normaux,pas de signe méningé,discours cohérent",
      ),
      ExamFieldConfig(
        key: 'cutane',
        label: "Examen Cutané",
        normalText:
            "Pas de lésion suspecte,pas de purpura,ongle sans déformation",
      ),
    ],
  );

  static const medecinenucleaireetimageriemoleculaire = SpecialtyFormConfig(
    specialty: MedicalSpecialty.medecinenucleaireetimageriemoleculaire,
    title: 'Medecinenucleaireetimageriemoleculaire',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'etat_general',
        label: "Impression Globale/Etat Général",
        normalText: "Bonétat général,patient conscient,coopérant,bien orienté",
      ),
      ExamFieldConfig(
        key: 'hydratation_nutrition',
        label: "Hydratation et Nutrition",
        normalText:
            "Pas de pli de déshydratation,IMC dans les normes,pas d'oedèmes marginaux",
      ),
      ExamFieldConfig(
        key: 'tete_cou',
        label: "Examen Tête et Cou",
        normalText:
            "Conjonctives rosées,pas d'ictère scléral,cavitébuccale saine,cou souple,pas de goitre,pas d'ADP",
      ),
      ExamFieldConfig(
        key: 'thoracique_resp',
        label: "Examen Pleuro-Pulmonaire",
        normalText:
            "Respiration calme,pas de tirage,murmure vésiculaire présent et symétrique bilatéralement,pas de bruits surajoutés",
      ),
      ExamFieldConfig(
        key: 'cardio_vasc',
        label: "Examen Cardio-Vasculaire",
        normalText:
            "Bruits du cœur réguliers et bien frappés,pas de souffle,pouls périphériques perçus et symétriques",
      ),
      ExamFieldConfig(
        key: 'abd_digestif',
        label: "Examen Abdominal",
        normalText:
            "Ventre souple,dépressible,indolore,pas de masse,foie et rate non palpables,orifices herniaires libres",
      ),
      ExamFieldConfig(
        key: 'uro_genital',
        label: "Examen Uro-Génital",
        normalText: "Fosses lombaires libres,pas de globe vésical",
      ),
      ExamFieldConfig(
        key: 'osteo_articulaire',
        label: "Examen Ostéo-Articulaire",
        normalText:
            "Articulations libres,sans signe inflammatoire,marche normale",
      ),
      ExamFieldConfig(
        key: 'neuro_psych',
        label: "Examen Neurologique et Mental",
        normalText:
            "Force et sensibilitégrossièrement conservées,ROT normaux,pas de signe méningé,discours cohérent",
      ),
      ExamFieldConfig(
        key: 'cutane',
        label: "Examen Cutané",
        normalText:
            "Pas de lésion suspecte,pas de purpura,ongle sans déformation",
      ),
    ],
  );

  static const medecinedusport = SpecialtyFormConfig(
    specialty: MedicalSpecialty.medecinedusport,
    title: 'Medecinedusport',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'marche',
        label: "Marche et Posture",
        normalText: "Normale,sans claudication,pas de boiterie",
      ),
      ExamFieldConfig(
        key: 'axes',
        label: "Axes des membres",
        normalText: "Normaux,pas de varus ni valgus pathologique",
      ),
      ExamFieldConfig(
        key: 'art_insp',
        label: "Inspection articulaire",
        normalText: "Pas de rougeur,pas de tuméfaction,pas de déformation",
      ),
      ExamFieldConfig(
        key: 'art_palp',
        label: "Palpation articulaire",
        normalText:
            "Température locale normale,pas de choc rotulien,pas d'épanchement",
      ),
      ExamFieldConfig(
        key: 'art_mob_active',
        label: "Mobilitéarticulaire(Active)",
        normalText: "Amplitudes conservées et indolores",
      ),
      ExamFieldConfig(
        key: 'art_mob_passive',
        label: "Mobilitéarticulaire(Passive)",
        normalText: "Normale et sans ressaut",
      ),
      ExamFieldConfig(
        key: 'rachis_insp',
        label: "Rachis:Inspection",
        normalText:
            "Courbures normales(lordose cervicale,cyphose dorsale,lordose lombaire),pas de scoliose",
      ),
      ExamFieldConfig(
        key: 'rachis_palp',
        label: "Rachis:Palpation",
        normalText: "Épineuses indolores,pas de contracture paravertébrale",
      ),
      ExamFieldConfig(
        key: 'rachis_mobilite',
        label: "Rachis:Mobilitéet Signes Radiculaires",
        normalText:
            "Souple,Schober normal,Lasègue et Léri négatifs,pas de point de Valleix",
      ),
      ExamFieldConfig(
        key: 'muscles',
        label: "Examen Musculaire",
        normalText: "Trophiciténormale,force 5/5,pas de myalgies",
      ),
    ],
  );

  static const medecinedutravail = SpecialtyFormConfig(
    specialty: MedicalSpecialty.medecinedutravail,
    title: 'Medecinedutravail',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'etat_general',
        label: "Impression Globale/Etat Général",
        normalText: "Bonétat général,patient conscient,coopérant,bien orienté",
      ),
      ExamFieldConfig(
        key: 'hydratation_nutrition',
        label: "Hydratation et Nutrition",
        normalText:
            "Pas de pli de déshydratation,IMC dans les normes,pas d'oedèmes marginaux",
      ),
      ExamFieldConfig(
        key: 'tete_cou',
        label: "Examen Tête et Cou",
        normalText:
            "Conjonctives rosées,pas d'ictère scléral,cavitébuccale saine,cou souple,pas de goitre,pas d'ADP",
      ),
      ExamFieldConfig(
        key: 'thoracique_resp',
        label: "Examen Pleuro-Pulmonaire",
        normalText:
            "Respiration calme,pas de tirage,murmure vésiculaire présent et symétrique bilatéralement,pas de bruits surajoutés",
      ),
      ExamFieldConfig(
        key: 'cardio_vasc',
        label: "Examen Cardio-Vasculaire",
        normalText:
            "Bruits du cœur réguliers et bien frappés,pas de souffle,pouls périphériques perçus et symétriques",
      ),
      ExamFieldConfig(
        key: 'abd_digestif',
        label: "Examen Abdominal",
        normalText:
            "Ventre souple,dépressible,indolore,pas de masse,foie et rate non palpables,orifices herniaires libres",
      ),
      ExamFieldConfig(
        key: 'uro_genital',
        label: "Examen Uro-Génital",
        normalText: "Fosses lombaires libres,pas de globe vésical",
      ),
      ExamFieldConfig(
        key: 'osteo_articulaire',
        label: "Examen Ostéo-Articulaire",
        normalText:
            "Articulations libres,sans signe inflammatoire,marche normale",
      ),
      ExamFieldConfig(
        key: 'neuro_psych',
        label: "Examen Neurologique et Mental",
        normalText:
            "Force et sensibilitégrossièrement conservées,ROT normaux,pas de signe méningé,discours cohérent",
      ),
      ExamFieldConfig(
        key: 'cutane',
        label: "Examen Cutané",
        normalText:
            "Pas de lésion suspecte,pas de purpura,ongle sans déformation",
      ),
    ],
  );

  static const medecinephysiqueetreadaptation = SpecialtyFormConfig(
    specialty: MedicalSpecialty.medecinephysiqueetreadaptation,
    title: 'Medecinephysiqueetreadaptation',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'conscience',
        label: "Conscience(Glasgow)",
        normalText: "15/15",
      ),
      ExamFieldConfig(
        key: 'orientation',
        label: "Orientation",
        normalText: "Orienté(e)dans le temps et l'espace",
      ),
      ExamFieldConfig(
        key: 'marche',
        label: "Station debout et Marche",
        normalText: "Marche normale,pas de déficit,pas d'ataxie",
      ),
      ExamFieldConfig(
        key: 'romberg',
        label: "Signe de Romberg",
        normalText: "Négatif",
      ),
      ExamFieldConfig(
        key: 'force_ms',
        label: "Force Musculaire-Membres Sup.",
        normalText: "5/5 bilatéral et symétrique",
      ),
      ExamFieldConfig(
        key: 'force_mi',
        label: "Force Musculaire-Membres Inf.",
        normalText: "5/5 bilatéral et symétrique",
      ),
      ExamFieldConfig(
        key: 'tonus',
        label: "Tonus musculaire",
        normalText: "Normal,pas d'hypertonie ni d'hypotonie",
      ),
      ExamFieldConfig(
        key: 'sens_super',
        label: "Sensibilitésuperficielle",
        normalText: "Normale,symétrique",
      ),
      ExamFieldConfig(
        key: 'sens_prof',
        label: "Sensibilitéprofonde(Proprioception)",
        normalText: "Normale,pallesthésie conservée",
      ),
      ExamFieldConfig(
        key: 'rot_ms',
        label: "ROT Membres Supérieurs(Bicipital,Tricipital)",
        normalText: "Présents,symétriques,normo-vifs",
      ),
      ExamFieldConfig(
        key: 'rot_mi',
        label: "ROT Membres Inférieurs(Rotulien,Achilléen)",
        normalText: "Présents,symétriques,normo-vifs",
      ),
      ExamFieldConfig(
        key: 'babinski',
        label: "Réflexe cutanéplantaire",
        normalText: "En flexion bilatéralement(Babinski négatif)",
      ),
      ExamFieldConfig(
        key: 'nerfs_craniens',
        label: "Nerfs Crâniens(IàXII)",
        normalText: "Pas de déficit sensitivo-moteur facial,paires intactes",
      ),
      ExamFieldConfig(
        key: 'meninges',
        label: "Signes Méningés",
        normalText: "Nuque souple,Kernig et Brudzinski négatifs",
      ),
      ExamFieldConfig(
        key: 'langage',
        label: "Langage et Paroles",
        normalText: "Fluide,pas d'aphasie ni de dysarthrie",
      ),
    ],
  );

  static const nephrologie = SpecialtyFormConfig(
    specialty: MedicalSpecialty.nephrologie,
    title: 'Nephrologie',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'fosses_lomb',
        label: "Fosses Lombaires",
        normalText: "Inspection normale,pas de voussure",
      ),
      ExamFieldConfig(
        key: 'contact_lomb',
        label: "Palpation:Contact Lombaire/Ballottement",
        normalText: "Négatif bilatéralement",
      ),
      ExamFieldConfig(
        key: 'points_ureteraux',
        label: "Points Urétéraux",
        normalText: "Indolores",
      ),
      ExamFieldConfig(
        key: 'globe_vesical',
        label: "Palpation Pelvienne",
        normalText: "Pas de globe vésical",
      ),
      ExamFieldConfig(
        key: 'oge_femme',
        label: "OGE(Femme)",
        normalText: "Vulve d'aspect normal,sans lésion",
      ),
      ExamFieldConfig(
        key: 'tv',
        label: "Toucher Vaginal(Femme)",
        normalText: "Col normal,culs-de-sac souples et indolores",
      ),
      ExamFieldConfig(
        key: 'oge_homme',
        label: "OGE(Homme)",
        normalText:
            "Verge sans lésion,testicules en place,indolores,volume normal",
      ),
      ExamFieldConfig(
        key: 'tr_prostate',
        label: "Toucher Rectal(Homme) :Prostate",
        normalText:
            "Taille normale,souple,symétrique,sillon médian conservé,indolore",
      ),
    ],
  );

  static const oncologiemedicale = SpecialtyFormConfig(
    specialty: MedicalSpecialty.oncologiemedicale,
    title: 'Oncologiemedicale',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'paleur',
        label: "Peau et Muqueuses:Pâleur",
        normalText: "Absente(conjonctives et muqueuses normalement colorées)",
      ),
      ExamFieldConfig(
        key: 'hemato_cutane',
        label: "Syndrome Hémorragique Cutané",
        normalText: "Pas de pétéchies,purpura,ecchymoses ou hématomes",
      ),
      ExamFieldConfig(
        key: 'hemato_muqueux',
        label: "Syndrome Hémorragique Muqueux",
        normalText:
            "Pas d'épistaxis,de gingivorragie spontanée ou de bulles hémorragiques intrabuccales",
      ),
      ExamFieldConfig(
        key: 'adp_cervicales',
        label: "Adénopathies:Cervicales",
        normalText: "Absentes",
      ),
      ExamFieldConfig(
        key: 'adp_axill_ing',
        label: "Adénopathies:Axillaires et Inguinales",
        normalText: "Absentes",
      ),
      ExamFieldConfig(
        key: 'foie',
        label: "Hépatomégalie",
        normalText: "Absente",
      ),
      ExamFieldConfig(
        key: 'rate',
        label: "Splénomégalie",
        normalText: "Absente",
      ),
      ExamFieldConfig(
        key: 'hypertrophie_gingivale',
        label: "Hypertrophie Gingivale/Angines",
        normalText: "Absente",
      ),
      ExamFieldConfig(
        key: 'os',
        label: "Douleurs Osseuses Provoquées",
        normalText: "Indoloreàla percussion du sternum et des crêtes iliaques",
      ),
    ],
  );

  static const ophtalmologie = SpecialtyFormConfig(
    specialty: MedicalSpecialty.ophtalmologie,
    title: 'Ophtalmologie',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'face_insp',
        label: "Face:Inspection",
        normalText: "Symétrique,sans lésion cutanée,pas d'œdème",
      ),
      ExamFieldConfig(
        key: 'oreille_ext',
        label: "Oreille Externe et Tympan",
        normalText: "Pavillon indolore,CAE libre,tympan normal sans otorrhée",
      ),
      ExamFieldConfig(
        key: 'audition',
        label: "Audition",
        normalText:
            "Acuitéauditive bilatérale normaleàla voix parlée/chuchotée",
      ),
      ExamFieldConfig(
        key: 'fosse_nasale',
        label: "Fosses Nasales",
        normalText: "Perméables,sans rhinorrhée,muqueuse saine",
      ),
      ExamFieldConfig(
        key: 'cav_buccale',
        label: "CavitéBuccale/Dents",
        normalText: "Dentition en bonétat,langue et muqueuses saines",
      ),
      ExamFieldConfig(
        key: 'oropharynx',
        label: "Oropharynx/Amygdales",
        normalText:
            "Amygdales non hypertrophiques,non inflammatoires,luette médiane",
      ),
      ExamFieldConfig(
        key: 'cou_thyroide',
        label: "Cou et Thyroïde",
        normalText:
            "Glande thyroïde non augmentée de volume,non nodulaire,mobileàla déglutition",
      ),
      ExamFieldConfig(
        key: 'cou_adp',
        label: "Aires Ganglionnaires Cervicales",
        normalText:
            "Absence d'adénopathie cervicale,sous-maxillaire,ou sus-claviculaire palpable",
      ),
      ExamFieldConfig(
        key: 'oeil_annexes',
        label: "Œil-Annexes(Paupières,Conjonctives)",
        normalText:
            "Pas de ptosis,conjonctives rosées(pas d'anémie)et claires(pas d'ictère)",
      ),
      ExamFieldConfig(
        key: 'oeil_visuel',
        label: "Acuitéet MobilitéVisuelle",
        normalText:
            "Vision normale grossièrement,mouvements oculaires préservés dans les 9 axes",
      ),
    ],
  );

  static const orl = SpecialtyFormConfig(
    specialty: MedicalSpecialty.orl,
    title: 'Orl',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'face_insp',
        label: "Face:Inspection",
        normalText: "Symétrique,sans lésion cutanée,pas d'œdème",
      ),
      ExamFieldConfig(
        key: 'oreille_ext',
        label: "Oreille Externe et Tympan",
        normalText: "Pavillon indolore,CAE libre,tympan normal sans otorrhée",
      ),
      ExamFieldConfig(
        key: 'audition',
        label: "Audition",
        normalText:
            "Acuitéauditive bilatérale normaleàla voix parlée/chuchotée",
      ),
      ExamFieldConfig(
        key: 'fosse_nasale',
        label: "Fosses Nasales",
        normalText: "Perméables,sans rhinorrhée,muqueuse saine",
      ),
      ExamFieldConfig(
        key: 'cav_buccale',
        label: "CavitéBuccale/Dents",
        normalText: "Dentition en bonétat,langue et muqueuses saines",
      ),
      ExamFieldConfig(
        key: 'oropharynx',
        label: "Oropharynx/Amygdales",
        normalText:
            "Amygdales non hypertrophiques,non inflammatoires,luette médiane",
      ),
      ExamFieldConfig(
        key: 'cou_thyroide',
        label: "Cou et Thyroïde",
        normalText:
            "Glande thyroïde non augmentée de volume,non nodulaire,mobileàla déglutition",
      ),
      ExamFieldConfig(
        key: 'cou_adp',
        label: "Aires Ganglionnaires Cervicales",
        normalText:
            "Absence d'adénopathie cervicale,sous-maxillaire,ou sus-claviculaire palpable",
      ),
      ExamFieldConfig(
        key: 'oeil_annexes',
        label: "Œil-Annexes(Paupières,Conjonctives)",
        normalText:
            "Pas de ptosis,conjonctives rosées(pas d'anémie)et claires(pas d'ictère)",
      ),
      ExamFieldConfig(
        key: 'oeil_visuel',
        label: "Acuitéet MobilitéVisuelle",
        normalText:
            "Vision normale grossièrement,mouvements oculaires préservés dans les 9 axes",
      ),
    ],
  );

  static const pediatrie = SpecialtyFormConfig(
    specialty: MedicalSpecialty.pediatrie,
    title: 'Pediatrie',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'etat_general',
        label: "Impression Globale/Etat Général",
        normalText: "Bonétat général,patient conscient,coopérant,bien orienté",
      ),
      ExamFieldConfig(
        key: 'hydratation_nutrition',
        label: "Hydratation et Nutrition",
        normalText:
            "Pas de pli de déshydratation,IMC dans les normes,pas d'oedèmes marginaux",
      ),
      ExamFieldConfig(
        key: 'tete_cou',
        label: "Examen Tête et Cou",
        normalText:
            "Conjonctives rosées,pas d'ictère scléral,cavitébuccale saine,cou souple,pas de goitre,pas d'ADP",
      ),
      ExamFieldConfig(
        key: 'thoracique_resp',
        label: "Examen Pleuro-Pulmonaire",
        normalText:
            "Respiration calme,pas de tirage,murmure vésiculaire présent et symétrique bilatéralement,pas de bruits surajoutés",
      ),
      ExamFieldConfig(
        key: 'cardio_vasc',
        label: "Examen Cardio-Vasculaire",
        normalText:
            "Bruits du cœur réguliers et bien frappés,pas de souffle,pouls périphériques perçus et symétriques",
      ),
      ExamFieldConfig(
        key: 'abd_digestif',
        label: "Examen Abdominal",
        normalText:
            "Ventre souple,dépressible,indolore,pas de masse,foie et rate non palpables,orifices herniaires libres",
      ),
      ExamFieldConfig(
        key: 'uro_genital',
        label: "Examen Uro-Génital",
        normalText: "Fosses lombaires libres,pas de globe vésical",
      ),
      ExamFieldConfig(
        key: 'osteo_articulaire',
        label: "Examen Ostéo-Articulaire",
        normalText:
            "Articulations libres,sans signe inflammatoire,marche normale",
      ),
      ExamFieldConfig(
        key: 'neuro_psych',
        label: "Examen Neurologique et Mental",
        normalText:
            "Force et sensibilitégrossièrement conservées,ROT normaux,pas de signe méningé,discours cohérent",
      ),
      ExamFieldConfig(
        key: 'cutane',
        label: "Examen Cutané",
        normalText:
            "Pas de lésion suspecte,pas de purpura,ongle sans déformation",
      ),
    ],
  );

  static const psychiatrie = SpecialtyFormConfig(
    specialty: MedicalSpecialty.psychiatrie,
    title: 'Psychiatrie',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'presentation',
        label: "Présentation/Tenue",
        normalText: "Tenue soignée et adaptée,hygiène conservée",
      ),
      ExamFieldConfig(
        key: 'contact',
        label: "Contact/Mimique",
        normalText: "Contact facile,mimique concordante et expressive",
      ),
      ExamFieldConfig(
        key: 'conscience',
        label: "Niveau de Conscience",
        normalText: "Vigilance normale,orienté(e)temporo-spatialement",
      ),
      ExamFieldConfig(
        key: 'psychomoteur',
        label: "ActivitéPsychomotrice",
        normalText: "Pas de ralentissement ni d'agitation,pas de stéréotypies",
      ),
      ExamFieldConfig(
        key: 'langage',
        label: "Langage",
        normalText: "Débit normal,cohérent,pas de logorrhée ni de mutisme",
      ),
      ExamFieldConfig(
        key: 'pensee_cours',
        label: "Cours de la Pensée",
        normalText: "Fluide,pas de fuite des idées ni de barrage",
      ),
      ExamFieldConfig(
        key: 'pensee_contenu',
        label: "Contenu de la Pensée/Délires",
        normalText:
            "Pas d'idées délirantes,pas de phobies ou d'obsessions prévalentes",
      ),
      ExamFieldConfig(
        key: 'perceptions',
        label: "Perceptions/Hallucinations",
        normalText:
            "Absence d'hallucinations(auditives,visuelles,sensorielles)",
      ),
      ExamFieldConfig(
        key: 'affectivite',
        label: "Affectivité (Humeur, Émotions)",
        normalText:
            "Euthymique,pas d'idées noires ou suicidaires,réactivitéconservée",
      ),
      ExamFieldConfig(
        key: 'fonctions_cogn',
        label: "Fonctions Cognitives",
        normalText:
            "Mémoireàcourt et long terme intactes,attention conservée,jugement critique présent",
      ),
      ExamFieldConfig(
        key: 'sommeil_appetit',
        label: "Instincts(Sommeil,Appétit)",
        normalText:
            "Sommeil réparateur,appétit conservé,pas de trouble du comportement alimentaire",
      ),
    ],
  );

  static const pedopsychiatrie = SpecialtyFormConfig(
    specialty: MedicalSpecialty.pedopsychiatrie,
    title: 'Pedopsychiatrie',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'presentation',
        label: "Présentation/Tenue",
        normalText: "Tenue soignée et adaptée,hygiène conservée",
      ),
      ExamFieldConfig(
        key: 'contact',
        label: "Contact/Mimique",
        normalText: "Contact facile,mimique concordante et expressive",
      ),
      ExamFieldConfig(
        key: 'conscience',
        label: "Niveau de Conscience",
        normalText: "Vigilance normale,orienté(e)temporo-spatialement",
      ),
      ExamFieldConfig(
        key: 'psychomoteur',
        label: "ActivitéPsychomotrice",
        normalText: "Pas de ralentissement ni d'agitation,pas de stéréotypies",
      ),
      ExamFieldConfig(
        key: 'langage',
        label: "Langage",
        normalText: "Débit normal,cohérent,pas de logorrhée ni de mutisme",
      ),
      ExamFieldConfig(
        key: 'pensee_cours',
        label: "Cours de la Pensée",
        normalText: "Fluide,pas de fuite des idées ni de barrage",
      ),
      ExamFieldConfig(
        key: 'pensee_contenu',
        label: "Contenu de la Pensée/Délires",
        normalText:
            "Pas d'idées délirantes,pas de phobies ou d'obsessions prévalentes",
      ),
      ExamFieldConfig(
        key: 'perceptions',
        label: "Perceptions/Hallucinations",
        normalText:
            "Absence d'hallucinations(auditives,visuelles,sensorielles)",
      ),
      ExamFieldConfig(
        key: 'affectivite',
        label: "Affectivité (Humeur, Émotions)",
        normalText:
            "Euthymique,pas d'idées noires ou suicidaires,réactivitéconservée",
      ),
      ExamFieldConfig(
        key: 'fonctions_cogn',
        label: "Fonctions Cognitives",
        normalText:
            "Mémoireàcourt et long terme intactes,attention conservée,jugement critique présent",
      ),
      ExamFieldConfig(
        key: 'sommeil_appetit',
        label: "Instincts(Sommeil,Appétit)",
        normalText:
            "Sommeil réparateur,appétit conservé,pas de trouble du comportement alimentaire",
      ),
    ],
  );

  static const pneumophtisiologie = SpecialtyFormConfig(
    specialty: MedicalSpecialty.pneumophtisiologie,
    title: 'Pneumophtisiologie',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'insp_morpho',
        label: "Morphologie Thoracique",
        normalText: "Symétrique,pas de déformation",
      ),
      ExamFieldConfig(
        key: 'insp_signes_lutte',
        label: "Signes de lutte",
        normalText: "Absents(pas de tirage,pas de battement des ailes du nez)",
      ),
      ExamFieldConfig(
        key: 'insp_cyanose',
        label: "Cyanose/Hippocratisme",
        normalText: "Absents",
      ),
      ExamFieldConfig(
        key: 'palp_vv',
        label: "Vibrations Vocales",
        normalText: "Normalement transmises bilatéralement",
      ),
      ExamFieldConfig(
        key: 'perc_sonorite',
        label: "Percussion",
        normalText:
            "Sonoriténormale bilatérale,pas de matiténi de tympanisme anormal",
      ),
      ExamFieldConfig(
        key: 'ausc_mv',
        label: "Murmure Vésiculaire",
        normalText:
            "Présent,normal et symétrique,pas d'allongement du temps expiratoire",
      ),
      ExamFieldConfig(
        key: 'ausc_rales',
        label: "Râles et bruits surajoutés",
        normalText: "Absents(pas de crépitants,sibilants ou ronchis)",
      ),
      ExamFieldConfig(
        key: 'ausc_frottement',
        label: "Frottement pleural",
        normalText: "Absent",
      ),
      ExamFieldConfig(
        key: 'sat_oxy',
        label: "Saturation en O2",
        normalText: "Normaleàl'air ambiant",
      ),
    ],
  );

  static const radiotherapieoncologie = SpecialtyFormConfig(
    specialty: MedicalSpecialty.radiotherapieoncologie,
    title: 'Radiotherapieoncologie',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'paleur',
        label: "Peau et Muqueuses:Pâleur",
        normalText: "Absente(conjonctives et muqueuses normalement colorées)",
      ),
      ExamFieldConfig(
        key: 'hemato_cutane',
        label: "Syndrome Hémorragique Cutané",
        normalText: "Pas de pétéchies,purpura,ecchymoses ou hématomes",
      ),
      ExamFieldConfig(
        key: 'hemato_muqueux',
        label: "Syndrome Hémorragique Muqueux",
        normalText:
            "Pas d'épistaxis,de gingivorragie spontanée ou de bulles hémorragiques intrabuccales",
      ),
      ExamFieldConfig(
        key: 'adp_cervicales',
        label: "Adénopathies:Cervicales",
        normalText: "Absentes",
      ),
      ExamFieldConfig(
        key: 'adp_axill_ing',
        label: "Adénopathies:Axillaires et Inguinales",
        normalText: "Absentes",
      ),
      ExamFieldConfig(
        key: 'foie',
        label: "Hépatomégalie",
        normalText: "Absente",
      ),
      ExamFieldConfig(
        key: 'rate',
        label: "Splénomégalie",
        normalText: "Absente",
      ),
      ExamFieldConfig(
        key: 'hypertrophie_gingivale',
        label: "Hypertrophie Gingivale/Angines",
        normalText: "Absente",
      ),
      ExamFieldConfig(
        key: 'os',
        label: "Douleurs Osseuses Provoquées",
        normalText: "Indoloreàla percussion du sternum et des crêtes iliaques",
      ),
    ],
  );

  static const rhumatologie = SpecialtyFormConfig(
    specialty: MedicalSpecialty.rhumatologie,
    title: 'Rhumatologie',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'marche',
        label: "Marche et Posture",
        normalText: "Normale,sans claudication,pas de boiterie",
      ),
      ExamFieldConfig(
        key: 'axes',
        label: "Axes des membres",
        normalText: "Normaux,pas de varus ni valgus pathologique",
      ),
      ExamFieldConfig(
        key: 'art_insp',
        label: "Inspection articulaire",
        normalText: "Pas de rougeur,pas de tuméfaction,pas de déformation",
      ),
      ExamFieldConfig(
        key: 'art_palp',
        label: "Palpation articulaire",
        normalText:
            "Température locale normale,pas de choc rotulien,pas d'épanchement",
      ),
      ExamFieldConfig(
        key: 'art_mob_active',
        label: "Mobilitéarticulaire(Active)",
        normalText: "Amplitudes conservées et indolores",
      ),
      ExamFieldConfig(
        key: 'art_mob_passive',
        label: "Mobilitéarticulaire(Passive)",
        normalText: "Normale et sans ressaut",
      ),
      ExamFieldConfig(
        key: 'rachis_insp',
        label: "Rachis:Inspection",
        normalText:
            "Courbures normales(lordose cervicale,cyphose dorsale,lordose lombaire),pas de scoliose",
      ),
      ExamFieldConfig(
        key: 'rachis_palp',
        label: "Rachis:Palpation",
        normalText: "Épineuses indolores,pas de contracture paravertébrale",
      ),
      ExamFieldConfig(
        key: 'rachis_mobilite',
        label: "Rachis:Mobilitéet Signes Radiculaires",
        normalText:
            "Souple,Schober normal,Lasègue et Léri négatifs,pas de point de Valleix",
      ),
      ExamFieldConfig(
        key: 'muscles',
        label: "Examen Musculaire",
        normalText: "Trophiciténormale,force 5/5,pas de myalgies",
      ),
    ],
  );

  static const reanimationmedicale = SpecialtyFormConfig(
    specialty: MedicalSpecialty.reanimationmedicale,
    title: 'Reanimationmedicale',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'etat_general',
        label: "Impression Globale/Etat Général",
        normalText: "Bonétat général,patient conscient,coopérant,bien orienté",
      ),
      ExamFieldConfig(
        key: 'hydratation_nutrition',
        label: "Hydratation et Nutrition",
        normalText:
            "Pas de pli de déshydratation,IMC dans les normes,pas d'oedèmes marginaux",
      ),
      ExamFieldConfig(
        key: 'tete_cou',
        label: "Examen Tête et Cou",
        normalText:
            "Conjonctives rosées,pas d'ictère scléral,cavitébuccale saine,cou souple,pas de goitre,pas d'ADP",
      ),
      ExamFieldConfig(
        key: 'thoracique_resp',
        label: "Examen Pleuro-Pulmonaire",
        normalText:
            "Respiration calme,pas de tirage,murmure vésiculaire présent et symétrique bilatéralement,pas de bruits surajoutés",
      ),
      ExamFieldConfig(
        key: 'cardio_vasc',
        label: "Examen Cardio-Vasculaire",
        normalText:
            "Bruits du cœur réguliers et bien frappés,pas de souffle,pouls périphériques perçus et symétriques",
      ),
      ExamFieldConfig(
        key: 'abd_digestif',
        label: "Examen Abdominal",
        normalText:
            "Ventre souple,dépressible,indolore,pas de masse,foie et rate non palpables,orifices herniaires libres",
      ),
      ExamFieldConfig(
        key: 'uro_genital',
        label: "Examen Uro-Génital",
        normalText: "Fosses lombaires libres,pas de globe vésical",
      ),
      ExamFieldConfig(
        key: 'osteo_articulaire',
        label: "Examen Ostéo-Articulaire",
        normalText:
            "Articulations libres,sans signe inflammatoire,marche normale",
      ),
      ExamFieldConfig(
        key: 'neuro_psych',
        label: "Examen Neurologique et Mental",
        normalText:
            "Force et sensibilitégrossièrement conservées,ROT normaux,pas de signe méningé,discours cohérent",
      ),
      ExamFieldConfig(
        key: 'cutane',
        label: "Examen Cutané",
        normalText:
            "Pas de lésion suspecte,pas de purpura,ongle sans déformation",
      ),
    ],
  );

  static const chirurgiegenerale = SpecialtyFormConfig(
    specialty: MedicalSpecialty.chirurgiegenerale,
    title: 'Chirurgiegenerale',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'cavite_buccale',
        label: "CavitéBuccale/Dents/Muqueuses",
        normalText:
            "Langue propre,humides,dentition en bonétat,gencives saines",
      ),
      ExamFieldConfig(
        key: 'insp_abd',
        label: "Inspection Abdominale",
        normalText:
            "Ventre plat,respire avec l'abdomen,pas de CVC,orifices herniaires libres",
      ),
      ExamFieldConfig(
        key: 'palp_paroi',
        label: "Palpation:Paroi Abdominale",
        normalText: "Souple globale,pas de défense ni de contracture",
      ),
      ExamFieldConfig(
        key: 'palp_dlr',
        label: "Palpation:Douleur Provoquée",
        normalText:
            "Indolore dans les 4 quadrants,Murphy et MacBurney négatifs",
      ),
      ExamFieldConfig(
        key: 'palp_foie',
        label: "Palpation:Foie",
        normalText:
            "Bord inférieur non palpable,pas d'hépatomégalie(flèche hépatique normale)",
      ),
      ExamFieldConfig(
        key: 'palp_rate',
        label: "Palpation:Rate",
        normalText: "Non palpable(pas de splénomégalie)",
      ),
      ExamFieldConfig(
        key: 'perc_abd',
        label: "Percussion Abdominale",
        normalText:
            "Tympanisme centromédian physiologique,matitédéclive absente",
      ),
      ExamFieldConfig(
        key: 'ausc_bha',
        label: "Auscultation:Bruits Hydro-Aériques",
        normalText: "Normaux,réguliers.Pas de souffle artériel abdominal",
      ),
      ExamFieldConfig(
        key: 'tr_marge',
        label: "Examen Proctologique:Marge anale",
        normalText: "Saine,pas de fissure,pas d'hémorroïde externe",
      ),
      ExamFieldConfig(
        key: 'tr_ampoule',
        label: "Toucher Rectal",
        normalText:
            "Ampoule rectale vide,prostate lisse et indolore(homme),pas de sang sur le doigtier",
      ),
    ],
  );

  static const chirurgiecardiaque = SpecialtyFormConfig(
    specialty: MedicalSpecialty.chirurgiecardiaque,
    title: 'Chirurgiecardiaque',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'insp_omi',
        label: "Inspection:OMI(Œdèmes)",
        normalText: "Absents",
      ),
      ExamFieldConfig(
        key: 'insp_cyanose',
        label: "Inspection:Cyanose",
        normalText: "Absente",
      ),
      ExamFieldConfig(
        key: 'insp_tvj',
        label: "Turgescence Veines Jugulaires",
        normalText: "Absente",
      ),
      ExamFieldConfig(
        key: 'palp_choc',
        label: "Palpation:Choc de pointe",
        normalText: "En place,non dévié,normocinétique",
      ),
      ExamFieldConfig(
        key: 'palp_thrill',
        label: "Palpation:Frémissement/Thrill",
        normalText: "Absent",
      ),
      ExamFieldConfig(
        key: 'palp_harzer',
        label: "Signe de Harzer",
        normalText: "Négatif",
      ),
      ExamFieldConfig(
        key: 'ausc_rythme',
        label: "Rythme Cardiaque",
        normalText: "Régulier",
      ),
      ExamFieldConfig(
        key: 'ausc_bruits',
        label: "Bruits du cœur",
        normalText: "B1 et B2 présents et bien frappés,pas de B3 ni de B4",
      ),
      ExamFieldConfig(
        key: 'ausc_ao',
        label: "Auscultation:Foyer Aortique",
        normalText: "Libre,pas de souffle",
      ),
      ExamFieldConfig(
        key: 'ausc_pulm',
        label: "Auscultation:Foyer Pulmonaire",
        normalText: "Libre,pas de souffle",
      ),
      ExamFieldConfig(
        key: 'ausc_mitral',
        label: "Auscultation:Foyer Mitral",
        normalText: "Libre,pas de souffle",
      ),
      ExamFieldConfig(
        key: 'ausc_tricuspid',
        label: "Auscultation:Foyer Tricuspidien",
        normalText: "Libre,pas de souffle",
      ),
      ExamFieldConfig(
        key: 'pouls_periph',
        label: "Pouls périphériques",
        normalText: "Présents,symétriques,synchrones et réguliers",
      ),
      ExamFieldConfig(
        key: 'ausc_vasc',
        label: "Auscultation vasculaire(Carotides,Fémorales)",
        normalText: "Pas de souffle vasculaire",
      ),
    ],
  );

  static const chirurgiemaxillofaciale = SpecialtyFormConfig(
    specialty: MedicalSpecialty.chirurgiemaxillofaciale,
    title: 'Chirurgiemaxillofaciale',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'face_insp',
        label: "Face:Inspection",
        normalText: "Symétrique,sans lésion cutanée,pas d'œdème",
      ),
      ExamFieldConfig(
        key: 'oreille_ext',
        label: "Oreille Externe et Tympan",
        normalText: "Pavillon indolore,CAE libre,tympan normal sans otorrhée",
      ),
      ExamFieldConfig(
        key: 'audition',
        label: "Audition",
        normalText:
            "Acuitéauditive bilatérale normaleàla voix parlée/chuchotée",
      ),
      ExamFieldConfig(
        key: 'fosse_nasale',
        label: "Fosses Nasales",
        normalText: "Perméables,sans rhinorrhée,muqueuse saine",
      ),
      ExamFieldConfig(
        key: 'cav_buccale',
        label: "CavitéBuccale/Dents",
        normalText: "Dentition en bonétat,langue et muqueuses saines",
      ),
      ExamFieldConfig(
        key: 'oropharynx',
        label: "Oropharynx/Amygdales",
        normalText:
            "Amygdales non hypertrophiques,non inflammatoires,luette médiane",
      ),
      ExamFieldConfig(
        key: 'cou_thyroide',
        label: "Cou et Thyroïde",
        normalText:
            "Glande thyroïde non augmentée de volume,non nodulaire,mobileàla déglutition",
      ),
      ExamFieldConfig(
        key: 'cou_adp',
        label: "Aires Ganglionnaires Cervicales",
        normalText:
            "Absence d'adénopathie cervicale,sous-maxillaire,ou sus-claviculaire palpable",
      ),
      ExamFieldConfig(
        key: 'oeil_annexes',
        label: "Œil-Annexes(Paupières,Conjonctives)",
        normalText:
            "Pas de ptosis,conjonctives rosées(pas d'anémie)et claires(pas d'ictère)",
      ),
      ExamFieldConfig(
        key: 'oeil_visuel',
        label: "Acuitéet MobilitéVisuelle",
        normalText:
            "Vision normale grossièrement,mouvements oculaires préservés dans les 9 axes",
      ),
    ],
  );

  static const chirurgieneurologique = SpecialtyFormConfig(
    specialty: MedicalSpecialty.chirurgieneurologique,
    title: 'Chirurgieneurologique',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'conscience',
        label: "Conscience(Glasgow)",
        normalText: "15/15",
      ),
      ExamFieldConfig(
        key: 'orientation',
        label: "Orientation",
        normalText: "Orienté(e)dans le temps et l'espace",
      ),
      ExamFieldConfig(
        key: 'marche',
        label: "Station debout et Marche",
        normalText: "Marche normale,pas de déficit,pas d'ataxie",
      ),
      ExamFieldConfig(
        key: 'romberg',
        label: "Signe de Romberg",
        normalText: "Négatif",
      ),
      ExamFieldConfig(
        key: 'force_ms',
        label: "Force Musculaire-Membres Sup.",
        normalText: "5/5 bilatéral et symétrique",
      ),
      ExamFieldConfig(
        key: 'force_mi',
        label: "Force Musculaire-Membres Inf.",
        normalText: "5/5 bilatéral et symétrique",
      ),
      ExamFieldConfig(
        key: 'tonus',
        label: "Tonus musculaire",
        normalText: "Normal,pas d'hypertonie ni d'hypotonie",
      ),
      ExamFieldConfig(
        key: 'sens_super',
        label: "Sensibilitésuperficielle",
        normalText: "Normale,symétrique",
      ),
      ExamFieldConfig(
        key: 'sens_prof',
        label: "Sensibilitéprofonde(Proprioception)",
        normalText: "Normale,pallesthésie conservée",
      ),
      ExamFieldConfig(
        key: 'rot_ms',
        label: "ROT Membres Supérieurs(Bicipital,Tricipital)",
        normalText: "Présents,symétriques,normo-vifs",
      ),
      ExamFieldConfig(
        key: 'rot_mi',
        label: "ROT Membres Inférieurs(Rotulien,Achilléen)",
        normalText: "Présents,symétriques,normo-vifs",
      ),
      ExamFieldConfig(
        key: 'babinski',
        label: "Réflexe cutanéplantaire",
        normalText: "En flexion bilatéralement(Babinski négatif)",
      ),
      ExamFieldConfig(
        key: 'nerfs_craniens',
        label: "Nerfs Crâniens(IàXII)",
        normalText: "Pas de déficit sensitivo-moteur facial,paires intactes",
      ),
      ExamFieldConfig(
        key: 'meninges',
        label: "Signes Méningés",
        normalText: "Nuque souple,Kernig et Brudzinski négatifs",
      ),
      ExamFieldConfig(
        key: 'langage',
        label: "Langage et Paroles",
        normalText: "Fluide,pas d'aphasie ni de dysarthrie",
      ),
    ],
  );

  static const chirurgieorthopediqueettraumatologie = SpecialtyFormConfig(
    specialty: MedicalSpecialty.chirurgieorthopediqueettraumatologie,
    title: 'Chirurgieorthopediqueettraumatologie',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'marche',
        label: "Marche et Posture",
        normalText: "Normale,sans claudication,pas de boiterie",
      ),
      ExamFieldConfig(
        key: 'axes',
        label: "Axes des membres",
        normalText: "Normaux,pas de varus ni valgus pathologique",
      ),
      ExamFieldConfig(
        key: 'art_insp',
        label: "Inspection articulaire",
        normalText: "Pas de rougeur,pas de tuméfaction,pas de déformation",
      ),
      ExamFieldConfig(
        key: 'art_palp',
        label: "Palpation articulaire",
        normalText:
            "Température locale normale,pas de choc rotulien,pas d'épanchement",
      ),
      ExamFieldConfig(
        key: 'art_mob_active',
        label: "Mobilitéarticulaire(Active)",
        normalText: "Amplitudes conservées et indolores",
      ),
      ExamFieldConfig(
        key: 'art_mob_passive',
        label: "Mobilitéarticulaire(Passive)",
        normalText: "Normale et sans ressaut",
      ),
      ExamFieldConfig(
        key: 'rachis_insp',
        label: "Rachis:Inspection",
        normalText:
            "Courbures normales(lordose cervicale,cyphose dorsale,lordose lombaire),pas de scoliose",
      ),
      ExamFieldConfig(
        key: 'rachis_palp',
        label: "Rachis:Palpation",
        normalText: "Épineuses indolores,pas de contracture paravertébrale",
      ),
      ExamFieldConfig(
        key: 'rachis_mobilite',
        label: "Rachis:Mobilitéet Signes Radiculaires",
        normalText:
            "Souple,Schober normal,Lasègue et Léri négatifs,pas de point de Valleix",
      ),
      ExamFieldConfig(
        key: 'muscles',
        label: "Examen Musculaire",
        normalText: "Trophiciténormale,force 5/5,pas de myalgies",
      ),
    ],
  );

  static const chirurgiepediatrique = SpecialtyFormConfig(
    specialty: MedicalSpecialty.chirurgiepediatrique,
    title: 'Chirurgiepediatrique',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'etat_general',
        label: "Impression Globale/Etat Général",
        normalText: "Bonétat général,patient conscient,coopérant,bien orienté",
      ),
      ExamFieldConfig(
        key: 'hydratation_nutrition',
        label: "Hydratation et Nutrition",
        normalText:
            "Pas de pli de déshydratation,IMC dans les normes,pas d'oedèmes marginaux",
      ),
      ExamFieldConfig(
        key: 'tete_cou',
        label: "Examen Tête et Cou",
        normalText:
            "Conjonctives rosées,pas d'ictère scléral,cavitébuccale saine,cou souple,pas de goitre,pas d'ADP",
      ),
      ExamFieldConfig(
        key: 'thoracique_resp',
        label: "Examen Pleuro-Pulmonaire",
        normalText:
            "Respiration calme,pas de tirage,murmure vésiculaire présent et symétrique bilatéralement,pas de bruits surajoutés",
      ),
      ExamFieldConfig(
        key: 'cardio_vasc',
        label: "Examen Cardio-Vasculaire",
        normalText:
            "Bruits du cœur réguliers et bien frappés,pas de souffle,pouls périphériques perçus et symétriques",
      ),
      ExamFieldConfig(
        key: 'abd_digestif',
        label: "Examen Abdominal",
        normalText:
            "Ventre souple,dépressible,indolore,pas de masse,foie et rate non palpables,orifices herniaires libres",
      ),
      ExamFieldConfig(
        key: 'uro_genital',
        label: "Examen Uro-Génital",
        normalText: "Fosses lombaires libres,pas de globe vésical",
      ),
      ExamFieldConfig(
        key: 'osteo_articulaire',
        label: "Examen Ostéo-Articulaire",
        normalText:
            "Articulations libres,sans signe inflammatoire,marche normale",
      ),
      ExamFieldConfig(
        key: 'neuro_psych',
        label: "Examen Neurologique et Mental",
        normalText:
            "Force et sensibilitégrossièrement conservées,ROT normaux,pas de signe méningé,discours cohérent",
      ),
      ExamFieldConfig(
        key: 'cutane',
        label: "Examen Cutané",
        normalText:
            "Pas de lésion suspecte,pas de purpura,ongle sans déformation",
      ),
    ],
  );

  static const chirurgiethoracique = SpecialtyFormConfig(
    specialty: MedicalSpecialty.chirurgiethoracique,
    title: 'Chirurgiethoracique',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'insp_morpho',
        label: "Morphologie Thoracique",
        normalText: "Symétrique,pas de déformation",
      ),
      ExamFieldConfig(
        key: 'insp_signes_lutte',
        label: "Signes de lutte",
        normalText: "Absents(pas de tirage,pas de battement des ailes du nez)",
      ),
      ExamFieldConfig(
        key: 'insp_cyanose',
        label: "Cyanose/Hippocratisme",
        normalText: "Absents",
      ),
      ExamFieldConfig(
        key: 'palp_vv',
        label: "Vibrations Vocales",
        normalText: "Normalement transmises bilatéralement",
      ),
      ExamFieldConfig(
        key: 'perc_sonorite',
        label: "Percussion",
        normalText:
            "Sonoriténormale bilatérale,pas de matiténi de tympanisme anormal",
      ),
      ExamFieldConfig(
        key: 'ausc_mv',
        label: "Murmure Vésiculaire",
        normalText:
            "Présent,normal et symétrique,pas d'allongement du temps expiratoire",
      ),
      ExamFieldConfig(
        key: 'ausc_rales',
        label: "Râles et bruits surajoutés",
        normalText: "Absents(pas de crépitants,sibilants ou ronchis)",
      ),
      ExamFieldConfig(
        key: 'ausc_frottement',
        label: "Frottement pleural",
        normalText: "Absent",
      ),
      ExamFieldConfig(
        key: 'sat_oxy',
        label: "Saturation en O2",
        normalText: "Normaleàl'air ambiant",
      ),
    ],
  );

  static const chirurgieurologique = SpecialtyFormConfig(
    specialty: MedicalSpecialty.chirurgieurologique,
    title: 'Chirurgieurologique',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'fosses_lomb',
        label: "Fosses Lombaires",
        normalText: "Inspection normale,pas de voussure",
      ),
      ExamFieldConfig(
        key: 'contact_lomb',
        label: "Palpation:Contact Lombaire/Ballottement",
        normalText: "Négatif bilatéralement",
      ),
      ExamFieldConfig(
        key: 'points_ureteraux',
        label: "Points Urétéraux",
        normalText: "Indolores",
      ),
      ExamFieldConfig(
        key: 'globe_vesical',
        label: "Palpation Pelvienne",
        normalText: "Pas de globe vésical",
      ),
      ExamFieldConfig(
        key: 'oge_femme',
        label: "OGE(Femme)",
        normalText: "Vulve d'aspect normal,sans lésion",
      ),
      ExamFieldConfig(
        key: 'tv',
        label: "Toucher Vaginal(Femme)",
        normalText: "Col normal,culs-de-sac souples et indolores",
      ),
      ExamFieldConfig(
        key: 'oge_homme',
        label: "OGE(Homme)",
        normalText:
            "Verge sans lésion,testicules en place,indolores,volume normal",
      ),
      ExamFieldConfig(
        key: 'tr_prostate',
        label: "Toucher Rectal(Homme) :Prostate",
        normalText:
            "Taille normale,souple,symétrique,sillon médian conservé,indolore",
      ),
    ],
  );

  static const chirurgievasculaire = SpecialtyFormConfig(
    specialty: MedicalSpecialty.chirurgievasculaire,
    title: 'Chirurgievasculaire',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
      ExamFieldConfig(
        key: 'insp_omi',
        label: "Inspection:OMI(Œdèmes)",
        normalText: "Absents",
      ),
      ExamFieldConfig(
        key: 'insp_cyanose',
        label: "Inspection:Cyanose",
        normalText: "Absente",
      ),
      ExamFieldConfig(
        key: 'insp_tvj',
        label: "Turgescence Veines Jugulaires",
        normalText: "Absente",
      ),
      ExamFieldConfig(
        key: 'palp_choc',
        label: "Palpation:Choc de pointe",
        normalText: "En place,non dévié,normocinétique",
      ),
      ExamFieldConfig(
        key: 'palp_thrill',
        label: "Palpation:Frémissement/Thrill",
        normalText: "Absent",
      ),
      ExamFieldConfig(
        key: 'palp_harzer',
        label: "Signe de Harzer",
        normalText: "Négatif",
      ),
      ExamFieldConfig(
        key: 'ausc_rythme',
        label: "Rythme Cardiaque",
        normalText: "Régulier",
      ),
      ExamFieldConfig(
        key: 'ausc_bruits',
        label: "Bruits du cœur",
        normalText: "B1 et B2 présents et bien frappés,pas de B3 ni de B4",
      ),
      ExamFieldConfig(
        key: 'ausc_ao',
        label: "Auscultation:Foyer Aortique",
        normalText: "Libre,pas de souffle",
      ),
      ExamFieldConfig(
        key: 'ausc_pulm',
        label: "Auscultation:Foyer Pulmonaire",
        normalText: "Libre,pas de souffle",
      ),
      ExamFieldConfig(
        key: 'ausc_mitral',
        label: "Auscultation:Foyer Mitral",
        normalText: "Libre,pas de souffle",
      ),
      ExamFieldConfig(
        key: 'ausc_tricuspid',
        label: "Auscultation:Foyer Tricuspidien",
        normalText: "Libre,pas de souffle",
      ),
      ExamFieldConfig(
        key: 'pouls_periph',
        label: "Pouls périphériques",
        normalText: "Présents,symétriques,synchrones et réguliers",
      ),
      ExamFieldConfig(
        key: 'ausc_vasc',
        label: "Auscultation vasculaire(Carotides,Fémorales)",
        normalText: "Pas de souffle vasculaire",
      ),
    ],
  );

  static const chirurgieplastiquereconstructriceesthetiqueetdebrulologie =
      SpecialtyFormConfig(
        specialty: MedicalSpecialty
            .chirurgieplastiquereconstructriceesthetiqueetdebrulologie,
        title: 'Chirurgieplastiquereconstructriceesthetiqueetdebrulologie',
        icon: Iconsax.health,
        commonSymptoms: [],
        examFields: [
          ExamFieldConfig(
            key: 'peau_couleur',
            label: "Peau:Coloration",
            normalText: "Normale,pas de pâleur,d'ictère ou de cyanose",
          ),
          ExamFieldConfig(
            key: 'peau_trophicite',
            label: "Peau:Trophicité /Température/Hydratation",
            normalText: "Élastique,normotherme,bien hydratée,pas de pli cutané",
          ),
          ExamFieldConfig(
            key: 'lesions_elem',
            label: "LésionsÉlémentaires",
            normalText:
                "Absentes(pas de macule,papule,vésicule,bulle,ulcération,squame)",
          ),
          ExamFieldConfig(
            key: 'lesions_topog',
            label: "Topographie des lésions",
            normalText: "N/A",
          ),
          ExamFieldConfig(
            key: 'cheveux',
            label: "Phanères:Cheveux",
            normalText: "Aspect normal,pas d'alopécie,cuir chevelu sain",
          ),
          ExamFieldConfig(
            key: 'ongles',
            label: "Phanères:Ongles",
            normalText:
                "Pas de modification de couleur,de surface ou de fragilité (pas d'onycholyse ou de leuconychie)",
          ),
          ExamFieldConfig(
            key: 'muqueuses_orales',
            label: "Muqueuses Orales",
            normalText: "Saines,de coloration normale",
          ),
          ExamFieldConfig(
            key: 'ganglions',
            label: "Aires Ganglionnaires",
            normalText: "Libres,pas d'adénopathie palpable",
          ),
        ],
      );

  static const List<SpecialtyFormConfig> all = [
    general,
    cardiology,
    neurology,
    anesthesiereanimation,
    anesthesiereanimationpediatrique,
    biophysiquemedicale,
    dermatologieetvenereologie,
    diabetologieendocrinologieetmaladiesmetaboliques,
    epidemiologieetmedecinepreventive,
    hepatogastroenterologie,
    hematologie,
    gynecologieobstetrique,
    infectiologie,
    medecineinterne,
    medecinelegaledroitmedicaletethique,
    medecinenucleaireetimageriemoleculaire,
    medecinedusport,
    medecinedutravail,
    medecinephysiqueetreadaptation,
    nephrologie,
    oncologiemedicale,
    ophtalmologie,
    orl,
    pediatrie,
    psychiatrie,
    pedopsychiatrie,
    pneumophtisiologie,
    radiotherapieoncologie,
    rhumatologie,
    reanimationmedicale,
    chirurgiegenerale,
    chirurgiecardiaque,
    chirurgiemaxillofaciale,
    chirurgieneurologique,
    chirurgieorthopediqueettraumatologie,
    chirurgiepediatrique,
    chirurgiethoracique,
    chirurgieurologique,
    chirurgievasculaire,
    chirurgieplastiquereconstructriceesthetiqueetdebrulologie,
  ];
}
