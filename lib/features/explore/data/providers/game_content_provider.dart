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
