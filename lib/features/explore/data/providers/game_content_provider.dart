import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/features/explore/domain/models/game_models.dart';

final anatomyGamesProvider = Provider<List<AnatomyQuestion>>((ref) {
  return [
    const AnatomyQuestion(
      id: '1',
      question:
          "Quel muscle est principalement responsable de l'abduction de l'épaule au-delàde 15 degrés?",
      options: ['Deltoïde', 'Supraspinatus', 'Pectoralis Major', 'Trapezius'],
      correctIndex: 0,
    ),
    const AnatomyQuestion(
      id: '2',
      question: "Laquelle de ces structures traverse le canal carpien?",
      options: ['Nerf Ulnaire', 'Nerf Médian', 'Artère Radiale', 'Nerf Radial'],
      correctIndex: 1,
    ),
    const AnatomyQuestion(
      id: '3',
      question: "Combien de vertèbres compte normalement la colonne cervicale?",
      options: ['5', '6', '7', '8'],
      correctIndex: 2,
    ),
    const AnatomyQuestion(
      id: '4',
      question: "Quel est l'os le plus long du corps humain?",
      options: ['Humerus', 'Tibia', 'Fémur', 'Fibula'],
      correctIndex: 2,
    ),
  ];
});

final wordAssociationProvider = Provider<List<WordAssociationPair>>((ref) {
  return [
    const WordAssociationPair(
      id: 'w1',
      word: 'Diabète',
      relatedWord: 'Insuline',
      logic: 'Traitement principal',
    ),
    const WordAssociationPair(
      id: 'w2',
      word: 'Asthme',
      relatedWord: 'Salbutamol',
      logic: 'Bronchodilatateur',
    ),
    const WordAssociationPair(
      id: 'w3',
      word: 'Infarctus',
      relatedWord: 'Troponine',
      logic: 'Marqueur biologique',
    ),
    const WordAssociationPair(
      id: 'w4',
      word: 'Anémie',
      relatedWord: 'Ferritine',
      logic: 'Stock de fer',
    ),
  ];
});

final diagnosisCasesProvider = Provider<List<DiagnosisCase>>((ref) {
  return [
    const DiagnosisCase(
      id: 'c1',
      patientProfile: 'Homme,65 ans,Fumeur chronique',
      symptoms:
          'Douleur thoracique oppressive irradiant vers le bras gauche depuis 30 min.',
      findings: ['Dyspnée', 'Sueurs froides', 'Nausées'],
      options: [
        'Embolie Pulmonaire',
        'Infarctus du Myocarde',
        'Pneumothorax',
        'Péricardite',
      ],
      correctIndex: 1,
      explanation:
          'Le profil de risque et la douleur oppressive typique suggèrent un syndrome coronaire aigu.',
    ),
    const DiagnosisCase(
      id: 'c2',
      patientProfile: 'Femme,28 ans',
      symptoms: 'Douleur abdominale en fosse iliaque droite,fièvreà38.5°C.',
      findings: ['Signe de McBurney+', 'Défense abdominale', 'Anorexie'],
      options: [
        'Gestation Extra-Utérine',
        'Appendicite Aiguë',
        'Pyélonéphrite',
        'Calcul Rénal',
      ],
      correctIndex: 1,
      explanation:
          'La douleur localisée avec signe de McBurney et fièvre est caractéristique de l\'appendicite.',
    ),
  ];
});

final ecgHeroProvider = Provider<List<EcgStrip>>((ref) {
  return [
    const EcgStrip(
      id: 'e1',
      imagePath: 'assets/ecg/afib.png',
      diagnosis: 'Fibrillation Atriale',
      options: [
        'Flutter Atrial',
        'Fibrillation Atriale',
        'Tachycardie Sinusale',
        'Bloc de Branche',
      ],
      correctIndex: 1,
      keyFeature: 'Absence d\'ondes P et rythme irrégulièrement irrégulier.',
    ),
    const EcgStrip(
      id: 'e2',
      imagePath: 'assets/ecg/st_elevation.png',
      diagnosis: 'STEMI',
      options: ['Ischémie', 'Péricardite', 'STEMI', 'Hypokalémie'],
      correctIndex: 2,
      keyFeature: 'Sus-décalage du segment ST en dôme.',
    ),
  ];
});

final pharmaPairsProvider = Provider<List<PharmaPair>>((ref) {
  return [
    const PharmaPair(
      id: 'p1',
      drug: 'Amoxicilline',
      drugClass: 'Pénicillines',
      mechanism: 'Inhibition de la synthèse de la paroi bactérienne.',
    ),
    const PharmaPair(
      id: 'p2',
      drug: 'Atorvastatine',
      drugClass: 'Statines',
      mechanism: 'Inhibition de l\'HMG-CoA réductase.',
    ),
    const PharmaPair(
      id: 'p3',
      drug: 'Furosémide',
      drugClass: 'Diurétiques de l\'anse',
      mechanism: 'Inhibition du co-transporteur Na+/K+/2Cl-.',
    ),
  ];
});

final labResultsProvider = Provider<List<LabResult>>((ref) {
  return [
    const LabResult(
      id: 'l1',
      parameter: 'Potassium(K+)',
      value: 6.2,
      unit: 'mmol/L',
      minNormal: 3.5,
      maxNormal: 5.0,
      interpretation: 'Hyperkaliémie sévère(Risque arythmogène).',
    ),
    const LabResult(
      id: 'l2',
      parameter: 'Hémoglobine',
      value: 9.5,
      unit: 'g/dL',
      minNormal: 12.0,
      maxNormal: 16.0,
      interpretation: 'Anémie modérée.',
    ),
  ];
});

final surgicalStepsProvider = Provider<List<SurgicalStep>>((ref) {
  return [
    const SurgicalStep(
      id: 's1',
      instruction: 'Pratiquer l\'incision cutanée.',
      tool: 'Scalpel',
      order: 0,
    ),
    const SurgicalStep(
      id: 's2',
      instruction: 'Assurer l\'hémostase des vaisseaux.',
      tool: 'Pince bipolaire',
      order: 1,
    ),
    const SurgicalStep(
      id: 's3',
      instruction: 'Suturer le fascia.',
      tool: 'Porte-aiguille',
      order: 2,
    ),
  ];
});

final crosswordProvider = Provider<CrosswordGame>((ref) {
  return const CrosswordGame(
    id: 'cw1',
    title: 'Anatomie Cardiaque',
    words: [
      CrosswordWord(
        word: 'AORTE',
        clue: 'Plus grande artère du corps.',
        row: 0,
        col: 0,
        isHorizontal: true,
      ),
      CrosswordWord(
        word: 'VALVE',
        clue: 'Structure empêchant le reflux.',
        row: 0,
        col: 0,
        isHorizontal: false,
      ),
    ],
  );
});

final caseDetectiveCasesProvider = Provider<List<CaseDetectiveCase>>((ref) {
  return [
    const CaseDetectiveCase(
      id: 'd1',
      difficulty: 'Débutant',
      patientDemographics: 'Homme, 58 ans',
      chiefComplaint: 'Douleur thoracique oppressive constrictive rétrosternale depuis 1h, irradiant vers le bras gauche.',
      vitals: 'PA: 135/85 mmHg, FC: 95 bpm, Temp: 36.8°C, SaO2: 96% en air ambiant',
      historyOptions: [
        ClueOption(
          label: 'Antécédents familiaux',
          result: 'Père décédé d\'un infarctus aigu du myocarde à l\'âge de 52 ans.',
          cost: 5,
        ),
        ClueOption(
          label: 'Facteurs de risque cardiovasculaire',
          result: 'Fumeur actif (1 paquet/jour), dyslipidémie connue non traitée.',
          cost: 5,
        ),
        ClueOption(
          label: 'Douleur modifiée par la respiration ou position',
          result: 'Non, douleur constante et oppressante, non modifiée par les mouvements respiratoires.',
          cost: 5,
        ),
      ],
      labOptions: [
        ClueOption(
          label: 'Dosage de la Troponine I',
          result: 'Troponine I ultra-sensible élevée à 1450 ng/L (valeur normale < 14 ng/L).',
          cost: 10,
        ),
        ClueOption(
          label: 'D-Dimères',
          result: 'D-Dimères à 450 ng/mL (valeur normale < 500 ng/mL).',
          cost: 15,
        ),
        ClueOption(
          label: 'NFS & Hémogramme',
          result: 'Leucocytes: 8 900/mm³, Hémoglobine: 14.8 g/dL, Plaquettes: 240 000/mm³.',
          cost: 10,
        ),
      ],
      imagingOptions: [
        ClueOption(
          label: 'Électrocardiogramme (ECG)',
          result: 'Sus-décalage du segment ST de 3mm en V1, V2, V3 et V4. Miroir inférieur discret.',
          cost: 15,
        ),
        ClueOption(
          label: 'Radiographie du thorax',
          result: 'Index cardiothoracique normal, parenchyme pulmonaire libre, absence d\'élargissement médiastinal.',
          cost: 20,
        ),
      ],
      correctDiagnosis: 'Infarctus du Myocarde Antérieur (STEMI)',
      differentials: [
        'Infarctus du Myocarde Antérieur (STEMI)',
        'Péricardite Aiguë',
        'Embolie Pulmonaire Aiguë',
        'Pneumothorax Spontané',
      ],
      teachingPoints: 'Le tableau de douleur thoracique typique chez un patient tabagique, avec sus-décalage ST antérieur en V1-V4 et élévation marquée de la Troponine, est diagnostique d\'un STEMI antérieur. Le traitement requiert une revascularisation urgente (angioplastie coronaire).',
    ),
    const CaseDetectiveCase(
      id: 'd2',
      difficulty: 'Intermédiaire',
      patientDemographics: 'Femme, 68 ans',
      chiefComplaint: 'Dyspnée d\'apparition brutale associée à une douleur thoracique droite de type pleural.',
      vitals: 'PA: 110/70 mmHg, FC: 112 bpm (tachycardie), Temp: 37.4°C, SaO2: 89% sous air ambiant',
      historyOptions: [
        ClueOption(
          label: 'Antécédents chirurgicaux récents',
          result: 'Mise en place d\'une prothèse totale de hanche droite il y a 10 jours.',
          cost: 5,
        ),
        ClueOption(
          label: 'Traitement en cours',
          result: 'Prescription de HBPM préventive en post-opératoire, mais observance jugée médiocre.',
          cost: 5,
        ),
        ClueOption(
          label: 'Recherche de voyages ou alitement récents',
          result: 'Alitée principalement à domicile depuis la sortie de l\'hôpital.',
          cost: 5,
        ),
      ],
      labOptions: [
        ClueOption(
          label: 'Dosage des D-Dimères',
          result: 'D-Dimères très élevés à 2800 ng/mL (seuil normal < 500 ng/mL).',
          cost: 10,
        ),
        ClueOption(
          label: 'Gazométrie artérielle',
          result: 'Hypoxémie sévère (PaO2: 61 mmHg), hypocapnie (PaCO2: 29 mmHg) traduisant un effet shunt.',
          cost: 15,
        ),
        ClueOption(
          label: 'Troponine & BNP',
          result: 'Troponine I: 48 ng/L (légèrement élevée), NT-proBNP: 420 pg/mL (surcharge ventriculaire droite).',
          cost: 10,
        ),
      ],
      imagingOptions: [
        ClueOption(
          label: 'Angioscanner Thoracique',
          result: 'Défaut de remplissage dans la branche lobaire inférieure de l\'artère pulmonaire droite, confirmant un embole.',
          cost: 25,
        ),
        ClueOption(
          label: 'Écho-Doppler veineux des membres inférieurs',
          result: 'Thrombose veineuse profonde obstructive de la veine fémorale commune droite.',
          cost: 20,
        ),
        ClueOption(
          label: 'Radiographie Pulmonaire',
          result: 'Pas de foyer de condensation pneumonique net. Discret épanchement pleural droit.',
          cost: 15,
        ),
      ],
      correctDiagnosis: 'Embolie Pulmonaire Aiguë',
      differentials: [
        'Embolie Pulmonaire Aiguë',
        'Pneumopathie Lobaire Droite',
        'Infarctus du Myocarde',
        'Dissection Aortique',
      ],
      teachingPoints: 'La triade dyspnée brutale, douleur pleurale et tachycardie chez une patiente en post-opératoire de chirurgie orthopédique est hautement suspecte d\'embolie pulmonaire. Les D-Dimères guident le diagnostic et l\'angioscanner apporte la confirmation.',
    ),
    const CaseDetectiveCase(
      id: 'd3',
      difficulty: 'Avancé',
      patientDemographics: 'Femme, 42 ans',
      chiefComplaint: 'Épisodes paroxystiques de palpitations intenses, céphalées pulsatiles intolérables et sueurs profuses.',
      vitals: 'Pendant la crise: PA: 225/125 mmHg, FC: 125 bpm. Hors crise: PA: 128/82 mmHg, FC: 76 bpm',
      historyOptions: [
        ClueOption(
          label: 'Facteurs déclenchants des crises',
          result: 'Épisodes déclenchés par le stress, l\'effort physique ou parfois la palpation abdominale.',
          cost: 10,
        ),
        ClueOption(
          label: 'Évolution pondérale',
          result: 'Perte de poids involontaire de 6 kg en 3 mois avec sensation de thermophobie constante.',
          cost: 5,
        ),
        ClueOption(
          label: 'Antécédents familiaux de néoplasies',
          result: 'Mère opérée à 45 ans pour un carcinome médullaire de la thyroïde.',
          cost: 10,
        ),
      ],
      labOptions: [
        ClueOption(
          label: 'Détermination des Métanéphrines urinaires sur 24h',
          result: 'Métanéphrines urinaires à 6 fois la normale. Normétanéphrines à 4 fois la normale.',
          cost: 15,
        ),
        ClueOption(
          label: 'Ionogramme sanguin (Kaliémie)',
          result: 'Potassium à 3.3 mmol/L (hypokaliémie modérée secondaire à l\'activation surrénalienne).',
          cost: 10,
        ),
        ClueOption(
          label: 'Glycémie à jeun',
          result: '1.42 g/L (hyperglycémie modérée liée à l\'effet anti-insulinaire des catécholamines).',
          cost: 10,
        ),
      ],
      imagingOptions: [
        ClueOption(
          label: 'Scanner (TDM) Abdominal',
          result: 'Masse surrénalienne droite de 4.2 cm, hypervasculaire et hétérogène (zones de nécrose centrale).',
          cost: 20,
        ),
        ClueOption(
          label: 'Scintigraphie au MIBG (I-123)',
          result: 'Hyperfixation élective et intense de la masse surrénalienne droite sans autre localisation suspecte.',
          cost: 25,
        ),
        ClueOption(
          label: 'IRM Abdominale',
          result: 'Lésion surrénalienne droite montrant un hypersignal T2 très intense (classique aspect en ampoule).',
          cost: 25,
        ),
      ],
      correctDiagnosis: 'Phéochromocytome Surrénalien',
      differentials: [
        'Phéochromocytome Surrénalien',
        'Crise de Panique sévère',
        'Hyperthyroïdie / Orage thyroïdien',
        'Hyperaldostéronisme Primaire (Conn)',
      ],
      teachingPoints: 'La triade de Carney (céphalées, sueurs, palpitations) avec poussées d\'HTA paroxystique doit faire évoquer un phéochromocytome. Les métanéphrines urinaires ou plasmatiques en font le diagnostic biochimique avant la localisation radiologique par TDM/IRM.',
    ),
  ];
});

final physiologyFlowCasesProvider = Provider<List<PhysiologyFlowCase>>((ref) {
  return [
    const PhysiologyFlowCase(
      id: 'f1',
      title: 'Oedème Périphérique (Cardiaque)',
      description: 'Reconstituez la cascade physiopathologique menant à l\'oedème périphérique dans l\'insuffisance cardiaque droite.',
      correctSteps: [
        'Insuffisance ventriculaire droite',
        'Stase veineuse en amont (Veines caves)',
        'Augmentation de la pression veineuse systémique',
        'Augmentation de la pression hydrostatique capillaire',
        'Transsudation de liquide dans l\'espace interstitiel (Oedème)',
      ],
      explanations: [
        'La faillite du ventricule droit empêche la propulsion correcte du sang vers les poumons.',
        'Le sang s\'accumule dans le secteur veineux systémique (veines caves supérieure et inférieure).',
        'La stase augmente directement la pression à l\'intérieur du réseau veineux.',
        'La hausse de pression veineuse se répercute sur les capillaires, augmentant la force de filtration hydrostatique.',
        "Le gradient dépasse la pression oncotique plasmatique, poussant l'eau hors des vaisseaux vers les tissus.",
      ],
    ),
    const PhysiologyFlowCase(
      id: 'f2',
      title: 'Oedème de la Cirrhose',
      description: 'Reconstituez la cascade menant à l\'oedème et à l\'ascite chez un patient cirrhotique.',
      correctSteps: [
        'Insuffisance hépatocellulaire',
        'Diminution de la synthèse d\'albumine',
        'Baisse de la pression oncotique plasmatique',
        "Diminution de l'attraction d'eau vers le secteur vasculaire",
        'Fuite liquidienne interstitielle et ascite',
      ],
      explanations: [
        'La destruction des hépatocytes altère les fonctions de synthèse du foie.',
        'Le foie ne produit plus assez d\'albumine, principale protéine plasmatique.',
        'L\'albumine génère 80% de la pression oncotique; sa baisse réduit cette force de rappel.',
        'Sans pression oncotique suffisante, le secteur vasculaire ne peut plus retenir l\'eau face à la pression hydrostatique.',
        'L\'eau diffuse librement vers le péritoine (ascite) et les membres inférieurs.',
      ],
    ),
    const PhysiologyFlowCase(
      id: 'f3',
      title: 'Cascade du Système RAA',
      description: 'Reconstituez l\'activation compensatrice rénale en cas d\'hypovolémie efficace.',
      correctSteps: [
        'Baisse de perfusion de l\'artériole afférente rénale',
        'Sécrétion de Rénine par l\'appareil juxtaglomérulaire',
        'Conversion de l\'Angiotensinogène en Angiotensine I',
        'Génération d\'Angiotensine II par l\'enzyme de conversion (ECA)',
        'Sécrétion d\'Aldostérone et vasoconstriction',
      ],
      explanations: [
        'L\'hypoperfusion ou la baisse de sodium est détectée au niveau rénal.',
        'Les cellules juxtaglomérulaires libèrent la rénine dans la circulation.',
        "La rénine clive l'angiotensinogène d'origine hépatique pour former l'angiotensine I inactive.",
        'L\'angiotensine I est convertie au niveau pulmonaire par l\'ECA en angiotensine II, puissant vasoconstricteur.',
        'L\'angiotensine II stimule la surrénale pour produire l\'aldostérone, favorisant la rétention de sodium et d\'eau.',
      ],
    ),
  ];
});
