import 'package:meducyte_app/export.dart';

enum FirstAidCategory { lifeSaving, traumas, medical, environment }

class FirstAidStep {
  final int number;
  final String title;
  final String description;
  final IconData? icon;

  const FirstAidStep({
    required this.number,
    required this.title,
    required this.description,
    this.icon,
  });
}

class FirstAidTopic {
  final String id;
  final String title;
  final String description;
  final FirstAidCategory category;
  final List<FirstAidStep> steps;
  final List<String> warnings;
  final List<String> callForHelp; //Specific numbers or triggers to call EMS
  final List<String> clinicalPearls; //New detailed scientific field
  final String?
  recoveryPosition; //Specific instructions for recovery position if applicable
  final String? imageUrl; //NEW:support for network images

  const FirstAidTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.steps,
    this.warnings = const [],
    this.callForHelp = const [],
    this.clinicalPearls = const [],
    this.recoveryPosition,
    this.imageUrl,
  });
}

class FirstAidMapping {
  static final List<FirstAidTopic> topics = [
    FirstAidTopic(
      id: 'cpr_adult',
      title: 'Réanimation Cardio-Pulmonaire(RCP)',
      description: 'Arrêt cardio-respiratoire chez l\'adulte.',
      category: FirstAidCategory.lifeSaving,
      callForHelp: ['Appelez le 15 ou le 112 immédiatement.'],
      warnings: [
        'Ne pas interrompre les compressions plus de 10 secondes.',
        'Assurez-vous que la zone est sûre avant d\'approcher.',
      ],
      clinicalPearls: [
        'La survie diminue de 10%par minute sans RCP ou défibrillation.',
        'Le massage cardiaque doit permettre une décompression complète du thorax.',
        'En présence d\'un DAE,la prioritéabsolue est la pose desélectrodes.',
        'Le rythme optimal(100-120/min)correspond au tempo de"Stayin\'Alive".',
      ],
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/CPR-positionning.jpg/1024px-CPR-positionning.jpg',
      steps: [
        FirstAidStep(
          number: 1,
          title: 'Vérifier la conscience',
          description:
              'Secouez doucement lesépaules et demandez: "Ça va?Vous m\'entendez?".Regardez si les yeux s\'ouvrent ou si la personne bouge.',
          icon: Iconsax.user_tick,
        ),
        FirstAidStep(
          number: 2,
          title: 'Vérifier la respiration',
          description:
              'Basculez prudemment la tête en arrière, élevez le menton.Regardez, écoutez et sentez le souffle pendant 10 secondes.',
          icon: Iconsax.status_up,
        ),
        FirstAidStep(
          number: 3,
          title: 'Alerter les secours',
          description:
              'Appelez le 15(SAMU)ou le 112.Précisez"Arrêt Cardiaque".Envoyez quelqu\'un chercher un Défibrillateur(DAE).',
          icon: Iconsax.call,
        ),
        FirstAidStep(
          number: 4,
          title: 'Compressions thoraciques',
          description:
              'Au centre de la poitrine.Bras tendus.Comprimez de 5à6 cmàun rythme de 100à120 par minute.',
          icon: Iconsax.heart,
        ),
        FirstAidStep(
          number: 5,
          title: 'Utiliser un DAE',
          description:
              'Dès que possible,allumez l\'appareil.Posez lesélectrodes sur la poitrine nue comme indiquésur le schéma du DAE.',
          icon: Iconsax.flash_1,
        ),
      ],
    ),
    FirstAidTopic(
      id: 'choking',
      title: 'Étouffement(Obstruction)',
      description: 'Obstruction brutale des voies aériennes.',
      category: FirstAidCategory.lifeSaving,
      warnings: [
        'Ne pas donner de tapes dans le dos si la personne peut encore parler ou tousser fort.',
      ],
      clinicalPearls: [
        'Une obstruction partielle(toux possible)ne doit pasêtre traitée par des tapes(risque d\'obstruction totale).',
        'La méthode de Heimlich augmente la pression intra-thoracique pour expulser le corpsétranger.',
        'Chez la femme enceinte ou la personne obèse,réalisez des compressions thoraciquesàla place des abdominales.',
      ],
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Heimlich-manoeuver.jpg/1024px-Heimlich-manoeuver.jpg',
      steps: [
        FirstAidStep(
          number: 1,
          title: 'Vérifier l\'obstruction',
          description:
              'Si la victime peut parler ou tousser,ne faites rien d\'autre qu\'encourager la toux vigoureuse.',
          icon: Iconsax.voice_square,
        ),
        FirstAidStep(
          number: 2,
          title: '5 Tapes dans le dos',
          description:
              'Penchez la victime vers l\'avant.Donnez 5 tapes sèches entre les omoplates avec le talon de la main.',
          icon: Iconsax.info_circle,
        ),
        FirstAidStep(
          number: 3,
          title: '5 Compressions abdominales',
          description:
              'Méthode de Heimlich:Entourez la taille,placez votre poing ferméjuste au-dessus du nombril.Tirez vers vous et vers le haut.',
          icon: Iconsax.user,
        ),
        FirstAidStep(
          number: 4,
          title: 'Relais si inconscience',
          description:
              'Si la victime perd connaissance,accompagnez-la au sol,alertez le 15 et débutez une RCP.',
          icon: Iconsax.refresh,
        ),
      ],
    ),
    FirstAidTopic(
      id: 'unconscious_breathing',
      title: 'Position Latérale de Sécurité (PLS)',
      description: 'Personne inconsciente qui respire normalement.',
      category: FirstAidCategory.lifeSaving,
      recoveryPosition: 'PLS',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/CPR-positionning.jpg/1024px-CPR-positionning.jpg',
      clinicalPearls: [
        'La PLS prévient l\'inhalation de vomissures(syndrome de Mendelson).',
        'Elle maintient la libertédes voies aériennes supérieures(langue qui chute).',
        'Surveillez la respiration toutes les minutes jusqu\'àl\'arrivée des secours.',
        'Si la victime est enceinte,privilégiez le côtéGAUCHE pouréviter la compression de la veine cave inférieure.',
      ],
      steps: [
        FirstAidStep(
          number: 1,
          title: 'Préparer le bras',
          description:
              'Placez le bras du côtédu sauveteuràangle droit,paume vers le haut(le"salut").',
          icon: Iconsax.user,
        ),
        FirstAidStep(
          number: 2,
          title: 'Placer l\'autre main',
          description:
              'Saisissez l\'autre main,placez le dos de cette main contre l\'oreille de la victime du côtédu sauveteur.',
          icon: Iconsax.user_square,
        ),
        FirstAidStep(
          number: 3,
          title: 'Tourner sur le côté',
          description:
              'Saisissez le genou opposé,relevez-le et tirez pour faire basculer la victime vers vous doucement.',
          icon: Iconsax.rotate_left,
        ),
        FirstAidStep(
          number: 4,
          title: 'Libérer les voies',
          description:
              'Ouvrez la bouche,assurez-vous qu\'elle est tournée vers le sol.Ajustez la jambe du dessus en angle droit.',
          icon: Iconsax.cloud_drizzle,
        ),
      ],
    ),
    FirstAidTopic(
      id: 'bleeding',
      title: 'Hémorragie Externe',
      description: 'Saignement abondant et visible.',
      category: FirstAidCategory.traumas,
      warnings: [
        'Utiliser des gants si possible.',
        'Ne pas retirer un corpsétranger plantédans la plaie.',
      ],
      clinicalPearls: [
        'Une compression efficace doit arrêter le saignement sans couper la circulation du membre.',
        'Le garrot est une mesure de dernier recours(risque d\'amputation), ànoter l\'heure de pose.',
        'L\'élévation du membre peut aideràréduire le débit sanguin local.',
      ],
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Pressure_point.jpg/640px-Pressure_point.jpg',
      steps: [
        FirstAidStep(
          number: 1,
          title: 'Compression directe',
          description:
              'Appuyez fermement sur la plaie avec la paume de la main(protégée)ou un linge propre.',
          icon: Iconsax.grammerly,
        ),
        FirstAidStep(
          number: 2,
          title: 'Allonger la victime',
          description:
              'Installez la victime en position horizontale pour prévenir le choc hypovolémique.',
          icon: Iconsax.info_circle,
        ),
        FirstAidStep(
          number: 3,
          title: 'Alerter les secours',
          description:
              'Le 15 ou 112.Une hémorragie non contrôlée peut mener au décès en quelques minutes.',
          icon: Iconsax.call,
        ),
        FirstAidStep(
          number: 4,
          title: 'Tampon compressif',
          description:
              'Si vous devez libérer vos mains,remplacez la compression manuelle par un pansement très serré.',
          icon: Iconsax.save_2,
        ),
      ],
    ),
    FirstAidTopic(
      id: 'burns',
      title: 'Brûlures',
      description:
          'Lésion de la peau par la chaleur,produit chimique ouélectricité.',
      category: FirstAidCategory.traumas,
      warnings: [
        'Ne pas percer les cloches(phlyctènes).',
        'Ne pas appliquer de corps gras(beurre,huile)ou de dentifrice.',
      ],
      clinicalPearls: [
        'La règle des 15:eauà15°C, à15 cm,pendant 15 minutes.',
        'La gravitédépend de la surface(règle des 9 de Wallace),de la profondeur et du siège(visage,mains).',
        'Une brûlure chimique nécessite un rinçage prolongéjusqu\'àl\'arrivée des secours.',
      ],
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Burn_Degree_Diagram.png/1024px-Burn_Degree_Diagram.png',
      steps: [
        FirstAidStep(
          number: 1,
          title: 'Refroidir la brûlure',
          description:
              'Faites couler de l\'eau tempérée(15-25°C)immédiatement sur la zone brûlée.',
          icon: Iconsax.cloud_drizzle,
        ),
        FirstAidStep(
          number: 2,
          title: 'Retirer les vêtements',
          description:
              'Enlevez les vêtements qui ne collent pas.Retirez bijoux,montres avant le gonflement.',
          icon: Iconsax.close_circle,
        ),
        FirstAidStep(
          number: 3,
          title: 'Évaluer la gravité',
          description:
              'Appelez le 15 si la brûlure est> àla moitiéde la paume de la victime ou si elle est noire.',
          icon: Iconsax.info_circle,
        ),
        FirstAidStep(
          number: 4,
          title: 'Protéger la plaie',
          description:
              'Couvrez avec un pansement stérile ou un film alimentaire(sans serrer)pour limiter l\'infection.',
          icon: Iconsax.shield_tick,
        ),
      ],
    ),
    FirstAidTopic(
      id: 'syncope',
      title: 'Malaise/Syncope',
      description: 'Perte de connaissance brève ou sensation de malaise.',
      category: FirstAidCategory.medical,
      clinicalPearls: [
        'La syncope vasovagale est souvent précédée de prodromes(sueur,nausée).',
        'Le lever des jambes favorise le retour veineux vers le cerveau.',
        'Un malaise qui dure ou avec des douleurs thoraciques doitêtre considérécomme une urgence vitale.',
      ],
      steps: [
        FirstAidStep(
          number: 1,
          title: 'Mettre au repos',
          description:
              'Allongez la personne si possible.Si elle se sent partir,asseyez-la au sol pouréviter la chute.',
          icon: Iconsax.user,
        ),
        FirstAidStep(
          number: 2,
          title: 'Vérifier les fonctions vitale',
          description:
              'Vérifiez la conscience et la respiration.Si inconscient et respire->PLS.',
          icon: Iconsax.status_up,
        ),
        FirstAidStep(
          number: 3,
          title: 'Interroger la victime',
          description:
              'Depuis quand?Douleur?Traitement en cours?Antécédents cardiaques?',
          icon: Iconsax.message_question,
        ),
        FirstAidStep(
          number: 4,
          title: 'Alerter si besoin',
          description:
              'Appelez le 15 si le malaise persiste ou si des signes de gravitéapparaissent(douleur,paralysie).',
          icon: Iconsax.call,
        ),
      ],
    ),
    FirstAidTopic(
      id: 'electrical',
      title: 'Électrisation/ Électrocution',
      description: 'Accident liéau courantélectrique.',
      category: FirstAidCategory.environment,
      warnings: [
        'NE JAMAIS TOUCHER LA VICTIME avant d\'avoir coupéle courant.',
      ],
      clinicalPearls: [
        'L\'électricitépeut causer des brûlures internes invisibles.',
        'Le passage du courant peut déclencher un arrêt cardiaque(fibrillation)plusieurs heures après l\'accident.',
        'L\'humiditéaugmente considérablement la conductivitédu corps.',
      ],
      steps: [
        FirstAidStep(
          number: 1,
          title: 'Couper le courant',
          description:
              'Coupez le disjoncteur ou débranchez l\'appareil.Si impossible, écartez la victime avec un objet sec et non conducteur(bois).',
          icon: Iconsax.flash_1,
        ),
        FirstAidStep(
          number: 2,
          title: 'Alerter les secours',
          description:
              'Le 15 ou le 18.Précisez la tension(basse ou haute tension)si connue.',
          icon: Iconsax.call,
        ),
        FirstAidStep(
          number: 3,
          title: 'Bilan vital',
          description:
              'Si la victime ne respire plus->RCP immédiate.Si consciente->surveillance.',
          icon: Iconsax.status_up,
        ),
        FirstAidStep(
          number: 4,
          title: 'Traiter les brûlures',
          description:
              'Refroidissez les points d\'entrée et de sortie du courant si visibles.',
          icon: Iconsax.cloud_drizzle,
        ),
      ],
    ),
    FirstAidTopic(
      id: 'poisoning',
      title: 'Intoxication/Empoisonnement',
      description: 'Ingestion,inhalation ou contact avec un produit toxique.',
      category: FirstAidCategory.medical,
      warnings: [
        'NE PAS FAIRE BOIRE(ni lait,ni eau).',
        'NE PAS FAIRE VOMIR(risque de brûlure chimique au retour).',
      ],
      clinicalPearls: [
        'Gardez le conditionnement du produit pour les secours.',
        'En cas de projection oculaire,rincer abondammentàl\'eau tiède pendant 15-20 min.',
        'La rapiditéde l\'alerte est cruciale pour l\'administrationéventuelle d\'antidotes.',
      ],
      steps: [
        FirstAidStep(
          number: 1,
          title: 'Écarter du danger',
          description:
              'Si gaz toxique->aérez ou sortez la victime la zone.Si contact cutané ->rincez.',
          icon: Iconsax.danger,
        ),
        FirstAidStep(
          number: 2,
          title: 'Identifier le toxique',
          description:
              'Récupérez l\'emballage,la bouteille ou la fiche de données de sécurité.',
          icon: Iconsax.info_circle,
        ),
        FirstAidStep(
          number: 3,
          title: 'Alerter les secours',
          description:
              'Le 15 ou le Centre Antipoison.Précisez le produit,la quantitéet l\'heure.',
          icon: Iconsax.call,
        ),
        FirstAidStep(
          number: 4,
          title: 'Position de repos',
          description:
              'Si conscient->position assise ou demi-assise.Si inconscient->PLS.',
          icon: Iconsax.user_square,
        ),
      ],
    ),
  ];
}
