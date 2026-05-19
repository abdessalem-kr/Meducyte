//Mapping lab findings to syndromes and categories.

enum LabSyndrome {
  inflammatory,
  anemia,
  thrombopenia,
  hyperkalemia,
  hypokalemia,
  acuteRenalFailure,
  metabolicAcidosis,
  dehydration,
  cholestasis,
  liverCytolysis,
}

enum LabCategory { hematology, electrolytes, gasometry, hepatorenal }

class LabFinding {
  final String id;
  final String name;
  final String description;
  final String normalRange;
  final List<LabSyndrome> relatedSyndromes;
  final LabCategory category;
  final String? encyclopediaId; //Used to link to lab encyclopedia entry
  final List<String>? etiologies;
  final String? fullDescription;

  const LabFinding({
    required this.id,
    required this.name,
    required this.description,
    required this.normalRange,
    required this.relatedSyndromes,
    required this.category,
    this.encyclopediaId,
    this.etiologies,
    this.fullDescription,
  });
}

class LabSyndromeInfo {
  final LabSyndrome syndrome;
  final String title;
  final String definition;
  final List<String> signs;
  final List<String> etiologies;
  final String? clinicalPearls;

  const LabSyndromeInfo({
    required this.syndrome,
    required this.title,
    required this.definition,
    required this.signs,
    required this.etiologies,
    this.clinicalPearls,
  });
}

class LabDifferential {
  final String title;
  final String logic;
  final List<String> triggerFindingIds;

  const LabDifferential({
    required this.title,
    required this.logic,
    required this.triggerFindingIds,
  });
}

class LabTechnicalCriteria {
  final String id;
  final String name;
  final String description;
  final String target;

  const LabTechnicalCriteria({
    required this.id,
    required this.name,
    required this.description,
    required this.target,
  });
}

class LabMapping {
  static const List<LabFinding> findings = [
    // ---Hematology(NFS) ---
    LabFinding(
      id: 'hgb_low',
      name: 'Hémoglobine↓',
      description: 'Hb<12 g/dL(F) / <13 g/dL(H)',
      normalRange: '12–16 g/dL(F),13–17 g/dL(H)',
      relatedSyndromes: [LabSyndrome.anemia],
      category: LabCategory.hematology,
      encyclopediaId: 'hemoglobine_hb',
      fullDescription:
          'L\'anémie se définit par une diminution de la masse d\'hémoglobine circulante.Le diagnostic est biologique:Hgb<13 g/dL chez l\'homme, <12 g/dL chez la femme.Chez le sujetâgéou la femme enceinte,les seuils peuvent varier.Cliniquement,elle se manifeste par une pâleur cutanéo-muqueuse,une asthénie,une dyspnée d\'effort et une tachycardie de compensation.',
      etiologies: [
        'Carence martiale',
        'Hémorragie',
        'Hémolyse',
        'Inflammation',
        'Carence B12/Folates',
      ],
    ),
    LabFinding(
      id: 'crp_high',
      name: 'CRP↑',
      description: 'CRP>6 mg/L',
      normalRange: '<6 mg/L',
      relatedSyndromes: [LabSyndrome.inflammatory],
      category: LabCategory.hematology,
      encyclopediaId: 'c_reactive_proteine_crp',
      fullDescription:
          'La C-Reactive Protein(CRP)est la protéine de la phase aiguëde l’inflammation la plus utilisée en pratique.Synthétisée par le foie en réponseàl’IL-6,elle augmente rapidement(en 6à12h)après une agression tissulaire.Sa demi-vie courte(19h)en fait un excellent marqueur pour suivre l\'efficacitéd\'un traitement antibiotique.',
      etiologies: [
        'Infection bactérienne',
        'Infection virale(modérée)',
        'Nécrose(IDM)',
        'Post-opératoire',
      ],
    ),
    LabFinding(
      id: 'wbc_high',
      name: 'Leucocytes↑',
      description: 'GB>10 000/μL(hyperleucocytose)',
      normalRange: '4 000–10 000/μL',
      relatedSyndromes: [LabSyndrome.inflammatory],
      category: LabCategory.hematology,
      encyclopediaId: 'numeration_formule_sanguine_nfs',
    ),
    LabFinding(
      id: 'wbc_low',
      name: 'Leucocytes↓',
      description: 'GB<4 000/μL(leucopénie)',
      normalRange: '4 000–10 000/μL',
      relatedSyndromes: [LabSyndrome.inflammatory],
      category: LabCategory.hematology,
      encyclopediaId: 'numeration_formule_sanguine_nfs',
    ),
    LabFinding(
      id: 'plt_low',
      name: 'Plaquettes↓',
      description: 'PLT<150 000/μL(thrombopénie)',
      normalRange: '150 000–400 000/μL',
      relatedSyndromes: [LabSyndrome.thrombopenia],
      category: LabCategory.hematology,
      encyclopediaId: 'numeration_des_plaquettes',
    ),
    LabFinding(
      id: 'ferritin_low',
      name: 'Ferritine↓',
      description: 'Ferritine basse=carence martiale',
      normalRange: '12–200µg/L(F),12–300µg/L(H)',
      relatedSyndromes: [LabSyndrome.anemia],
      category: LabCategory.hematology,
      encyclopediaId: 'ferritine',
    ),

    // ---Electrolytes(Ionogramme) ---
    LabFinding(
      id: 'k_high',
      name: 'Kaliémie↑',
      description: 'K+ >5 mEq/L(hyperkaliémie)',
      normalRange: '3.5–5.0 mEq/L',
      relatedSyndromes: [LabSyndrome.hyperkalemia],
      category: LabCategory.electrolytes,
      encyclopediaId: 'potassium_sanguin',
    ),
    LabFinding(
      id: 'k_low',
      name: 'Kaliémie↓',
      description: 'K+ <3.5 mEq/L(hypokaliémie)',
      normalRange: '3.5–5.0 mEq/L',
      relatedSyndromes: [LabSyndrome.hypokalemia],
      category: LabCategory.electrolytes,
      encyclopediaId: 'potassium_sanguin',
    ),
    LabFinding(
      id: 'na_high',
      name: 'Natrémie↑',
      description: 'Na+ >145 mEq/L(hypernatrémie)',
      normalRange: '135–145 mEq/L',
      relatedSyndromes: [LabSyndrome.dehydration],
      category: LabCategory.electrolytes,
      encyclopediaId: 'sodium_sanguin',
    ),
    LabFinding(
      id: 'na_low',
      name: 'Natrémie↓',
      description: 'Na+ <135 mEq/L(hyponatrémie)',
      normalRange: '135–145 mEq/L',
      relatedSyndromes: [LabSyndrome.dehydration],
      category: LabCategory.electrolytes,
      encyclopediaId: 'sodium_sanguin',
    ),
    LabFinding(
      id: 'creatinine_high',
      name: 'Créatininémie↑',
      description: 'Créatinine>104µmol/L(H) / >80µmol/L(F)',
      normalRange: '45–80µmol/L(F),57–104µmol/L(H)',
      relatedSyndromes: [LabSyndrome.acuteRenalFailure],
      category: LabCategory.electrolytes,
      encyclopediaId: 'creatinine',
    ),
    LabFinding(
      id: 'urea_high',
      name: 'Urée↑',
      description: 'Urée>8.3 mmol/L',
      normalRange: '2.5–8.3 mmol/L',
      relatedSyndromes: [LabSyndrome.acuteRenalFailure],
      category: LabCategory.electrolytes,
      encyclopediaId: 'uree_sanguine',
    ),

    // ---Gas(Gaz du sang) ---
    LabFinding(
      id: 'ph_low',
      name: 'pH↓',
      description: 'pH<7.35(acidose)',
      normalRange: '7.35–7.45',
      relatedSyndromes: [LabSyndrome.metabolicAcidosis],
      category: LabCategory.gasometry,
      encyclopediaId: 'gaz_du_sang_arteriel',
    ),
    LabFinding(
      id: 'hco3_low',
      name: 'Bicarbonates↓',
      description: 'HCO3- <22 mEq/L',
      normalRange: '22–26 mEq/L',
      relatedSyndromes: [LabSyndrome.metabolicAcidosis],
      category: LabCategory.gasometry,
      encyclopediaId: 'bicarbonates',
    ),
    LabFinding(
      id: 'lactate_high',
      name: 'Lactates↑',
      description: 'Lactates>2 mmol/L(hyperlactatémie)',
      normalRange: '<2 mmol/L',
      relatedSyndromes: [LabSyndrome.metabolicAcidosis],
      category: LabCategory.gasometry,
      encyclopediaId: 'acide_lactique_lactate',
    ),

    // ---Hepato-renal(Bilan Hépatique/Rénal) ---
    LabFinding(
      id: 'asat_high',
      name: 'ASAT↑',
      description: 'ASAT>40 UI/L',
      normalRange: '<40 UI/L',
      relatedSyndromes: [LabSyndrome.liverCytolysis],
      category: LabCategory.hepatorenal,
      encyclopediaId: 'asat',
      fullDescription:
          'L\'aspartate aminotransférase(ASAT)est une enzyme présente dans le foie,mais aussi dans le cœur et les muscles squelettiques.Une augmentation isolée des ASAT peut doncévoquer une pathologie musculaire ou myocardique.En pathologie hépatique,sonélévation témoigne d\'une cytolyse(destruction cellulaire).',
      etiologies: [
        'Hépatite aiguë',
        'Alcoolisme(ASAT>ALAT)',
        'Infarctus du myocarde',
        'Rhabdomyolyse',
      ],
    ),
    LabFinding(
      id: 'alat_high',
      name: 'ALAT↑',
      description: 'ALAT>40 UI/L',
      normalRange: '<40 UI/L',
      relatedSyndromes: [LabSyndrome.liverCytolysis],
      category: LabCategory.hepatorenal,
      encyclopediaId: 'alat',
    ),
    LabFinding(
      id: 'ggt_high',
      name: 'GGT↑',
      description: 'GGT>55 UI/L(H) / >38 UI/L(F)',
      normalRange: '<38 UI/L(F), <55 UI/L(H)',
      relatedSyndromes: [LabSyndrome.cholestasis, LabSyndrome.liverCytolysis],
      category: LabCategory.hepatorenal,
      encyclopediaId: 'gamma_glutamylt',
    ),
    LabFinding(
      id: 'pals_high',
      name: 'Phosphatases alcalines↑',
      description: 'PAL>130 UI/L',
      normalRange: '35–130 UI/L',
      relatedSyndromes: [LabSyndrome.cholestasis],
      category: LabCategory.hepatorenal,
      encyclopediaId: 'phosphatases_alcalines',
    ),
    LabFinding(
      id: 'bili_high',
      name: 'Bilirubine totale↑',
      description: 'Bili>17µmol/L(ictère si>50µmol/L)',
      normalRange: '<17µmol/L',
      relatedSyndromes: [LabSyndrome.cholestasis],
      category: LabCategory.hepatorenal,
      encyclopediaId: 'bilirubine',
    ),
    LabFinding(
      id: 'albumin_low',
      name: 'Albumine↓',
      description: 'Albumine<35 g/L(insuffisance hépatocellulaire)',
      normalRange: '35–50 g/L',
      relatedSyndromes: [LabSyndrome.liverCytolysis],
      category: LabCategory.hepatorenal,
      encyclopediaId:
          'albumine_urinaire', //Fallback as there is only urinaire id for now
    ),
  ];

  static const List<LabTechnicalCriteria> technicalCriteria = [
    LabTechnicalCriteria(
      id: 'prep_fasting',
      name: 'Jeûne strict(8-12h)',
      description: 'Indispensable pour la glycémie et le bilan lipidique.',
      target: 'Patientàjeun depuis la veille au soir.',
    ),
    LabTechnicalCriteria(
      id: 'prep_time',
      name: 'Heure de prélèvement',
      description: 'Crucial pour les hormonesàcycle circadien(Cortisol,Fer).',
      target: 'Prélèvement idéalementà8h du matin.',
    ),
    LabTechnicalCriteria(
      id: 'prep_tube',
      name: 'Ordre des tubes',
      description:
          'Éviter les contaminations par les additifs(ex:Potassium-EDTA).',
      target: 'Respecter l\'ordre:Purge>Citrate>Sec>Héparine>EDTA.',
    ),
    LabTechnicalCriteria(
      id: 'prep_transport',
      name: 'Délai de transport',
      description:
          'Certains paramètres sont sensibles(Gaz du sang,Ammoniaque).',
      target:
          'Acheminement au labo en moins de 30 min(si possible sous glace).',
    ),
  ];

  static const List<LabSyndromeInfo> syndromeInfo = [
    LabSyndromeInfo(
      syndrome: LabSyndrome.inflammatory,
      title: 'Syndrome Inflammatoire',
      definition:
          'Réaction biologique non spécifiqueàune agression(infection,cancer,maladie auto-immune).',
      signs: [
        'Élévation de la CRP(marqueur précoce)',
        'Augmentation de la Vitesse de Sédimentation(VS)',
        'HyperleucocytoseàNeutrophiles',
        'Élévation de l\'Haptoglobine et du Fibrinogène',
        'Baisse de l\'albumine(marqueur négatif)',
      ],
      etiologies: [
        'Infections bactériennes ou virales',
        'Néoplasies(Cancers)',
        'Maladies de système(Lupus,PR)',
        'Infarctus ou nécrose tissulaire',
      ],
      clinicalPearls:
          'La CRP réagit en 6-12h,alors que la VS peut mettre plusieurs joursàse normaliser après la guérison.',
    ),
    LabSyndromeInfo(
      syndrome: LabSyndrome.anemia,
      title: 'Syndrome Anémique',
      definition:
          'Diminution du taux d\'hémoglobine au-dessous des valeurs normales.',
      signs: [
        'Hémoglobine<13 g/dL(H)ou<12 g/dL(F)',
        'Baisse de l\'Hématocrite',
        'Microcytose(VGM<80)ou Macrocytose(VGM>100)',
        'Hypochromie(TGMH<27 pg)',
      ],
      etiologies: [
        'Carence martiale(Saignement chronique)',
        'Carence en B12 ou Folates',
        'Hémolyse(destruction des GR)',
        'Inflammation chronique',
        'Insuffisance rénale(manque d\'EPO)',
      ],
      clinicalPearls:
          'Une anémie microcytaire régénérative oriente vers une hémorragie aiguëou une hémolyse stable.',
    ),
    LabSyndromeInfo(
      syndrome: LabSyndrome.acuteRenalFailure,
      title: 'Insuffisance Rénale Aiguë (IRA)',
      definition:
          'Baisse brutale de la fonction rénale avec accumulation de déchets azotés.',
      signs: [
        'Élévation rapide de la Créatinine plasmatique',
        'Augmentation de l\'Urée sanguine',
        'Troublesélectrolytiques(Hyperkaliémie)',
        'Acidose métabolique',
        'Oligurie(parfois)',
      ],
      etiologies: [
        'Pré-rénale(Déshydratation,Choc)',
        'Rénale(Nécrose tubulaire aiguë,Glomérulonéphrite)',
        'Post-rénale(Obstacle urinaire,Prostate,Calcul)',
      ],
      clinicalPearls:
          'Le rapport Urée/Créatinine>100(enµmol)suggère une cause fonctionnelle(pré-rénale).',
    ),
    LabSyndromeInfo(
      syndrome: LabSyndrome.hyperkalemia,
      title: 'Hyperkaliémie',
      definition:
          'Élévation du taux plasmatique de potassium au-dessus de 5.0 mEq/L.',
      signs: [
        'K+ >5.0 mEq/L',
        'Signes ECG(Ondes T pointues,symétriques)',
        'Troubles de la conduction(QRS large)',
      ],
      etiologies: [
        'Insuffisance rénale aiguëou chronique',
        'Acidose métabolique',
        'Médicaments(IEC,ARA II,Diurétiquesépargneurs de K+)',
        'Destruction cellulaire(Rhabdomyolyse,Syndrome de Lyse Tumorale)',
      ],
      clinicalPearls:
          'Toujours réaliser un ECG en urgence pourévaluer le retentissement cardiaque de l\'hyperkaliémie.',
    ),
    LabSyndromeInfo(
      syndrome: LabSyndrome.hypokalemia,
      title: 'Hypokaliémie',
      definition:
          'Baisse du taux plasmatique de potassium au-dessous de 3.5 mEq/L.',
      signs: [
        'K+ <3.5 mEq/L',
        'Signes ECG(Ondes U,Sous-décalage ST)',
        'Faiblesse musculaire,crampes',
      ],
      etiologies: [
        'Pertes digestives(Vomissements,Diarrhées)',
        'Diurétiques hypokaliémiants',
        'Carences d\'apport',
      ],
    ),
    LabSyndromeInfo(
      syndrome: LabSyndrome.cholestasis,
      title: 'Syndrome de Cholestase',
      definition:
          'Diminution ou arrêt de l\'élimination de la bile par obstruction ou atteinte hépatique.',
      signs: [
        'Élévation des GGT',
        'Élévation des Phosphatases Alcalines(PAL)',
        'Élévation de la Bilirubine totale et conjuguée',
      ],
      etiologies: [
        'Obstacle biliaire(Calcul,Cancer du Pancréas)',
        'Cirrhose,Hépatite granulomateuse',
        'Médicaments cholestatiques',
      ],
    ),
  ];

  static const List<LabDifferential> differentials = [
    LabDifferential(
      title: 'Anémie:Ferritine vs Inflammation',
      logic:
          'Une ferritine basse affirme la carence martiale.Une ferritine normale ou haute avec une CRPélevée suggère une anémie inflammatoire.',
      triggerFindingIds: ['hgb_low', 'ferritin_low', 'crp_high'],
    ),
    LabDifferential(
      title: 'Cytolyse vs Cholestase',
      logic:
          'Une prédominance des ALAT/ASATévoque une atteinte hépato-cellulaire.Une prédominance des PAL/GGTévoque une obstruction biliaire.',
      triggerFindingIds: ['alat_high', 'asat_high', 'pals_high', 'ggt_high'],
    ),
  ];
}
