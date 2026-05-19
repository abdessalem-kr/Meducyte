//Mapping radiological findings to syndromes and categories.

enum RadiologySyndrome {
  alveolar,
  interstitial,
  bronchial,
  pleural,
  cavitary,
  mediastinal,
  parietal,
}

enum RadiologyCategory { A, B, C, D, E }

class RadiologySyndromeInfo {
  final RadiologySyndrome syndrome;
  final String title;
  final String definition;
  final List<String> signs;
  final List<String> etiologies;
  final String? clinicalPearls; //Malignancy rule,OAP time,etc.

  const RadiologySyndromeInfo({
    required this.syndrome,
    required this.title,
    required this.definition,
    required this.signs,
    required this.etiologies,
    this.clinicalPearls,
  });
}

class RadiologyDifferential {
  final String title;
  final String logic;
  final List<String> triggerFindingIds;

  const RadiologyDifferential({
    required this.title,
    required this.logic,
    required this.triggerFindingIds,
  });
}

class RadiologyTechnicalCriteria {
  final String id;
  final String name;
  final String description;
  final String target;

  const RadiologyTechnicalCriteria({
    required this.id,
    required this.name,
    required this.description,
    required this.target,
  });
}

class RadiologyFinding {
  final String id;
  final String name;
  final String description;
  final String? fullDescription;
  final String? imagePath;
  final List<RadiologySyndrome> relatedSyndromes;
  final List<String>? etiologies; //Added etiologies
  final RadiologyCategory category;

  const RadiologyFinding({
    required this.id,
    required this.name,
    required this.description,
    this.fullDescription,
    this.imagePath,
    required this.relatedSyndromes,
    this.etiologies,
    required this.category,
  });
}

class RadiologyMapping {
  static const List<RadiologyFinding> findings = [
    // ---AIRWAY(A) ---
    RadiologyFinding(
      id: 'rad_atelectasis',
      name: 'Atélectasie',
      description: 'Opacitérétractile avec attraction du médiastin.',
      fullDescription:
          'L\'atélectasie pulmonaire est un signe de collapsus des alvéoles pulmonaires,entraînant une perte de volume d\'un lobe ou d\'un poumon entier.Sur la radiographie thoracique face,elle se manifeste par une opacitéhomogène aux contours souvent nets lorsqu\'ils sont délimités par une scissure.Le signe diagnostique cléest son caractère rétractile:on observe systématiquement un déplacement des structures adjacentes vers la zone lésée.Cela inclut une déviation de la trachée et du médiastin vers le côtéatteint,uneélévation de la coupole diaphragmatique homolatérale,et un pincement visible des espaces intercostaux.C\'est un signe majeur d\'échec de ventilation pulmonaire,souvent secondaireàune obstruction bronchique complète par un bouchon muqueux,un corpsétranger ou une masse tumorale endobronchique.',
      imagePath: 'assets/images/radiology/rad_sign_atelectasis.jpg',
      relatedSyndromes: [RadiologySyndrome.bronchial],
      category: RadiologyCategory.A,
    ),
    RadiologyFinding(
      id: 'rad_wall_thickening',
      name: 'Épaississement pariétal',
      description: 'Images en anneaux ou rails(bronchesépaissies).',
      fullDescription:
          'L\'épaississement des parois bronchiques est une manifestation caractéristique du syndrome bronchique,traduisant une inflammation,une infiltration ou unœdème de la gaine péribronchique.Sur le clichéde thorax,ce signe s\'interprète selon l\'orientation des bronches par rapport au faisceau de rayons X.Lorsque les bronches sont visualisées longitudinalement,elles apparaissent sous la forme de deux lignes opaques fines et parallèles,mimant des rails de chemin de fer(signe du rail).En revanche,lorsque les bronches sont coupées transversalement(boutàbout),elles prennent l\'aspect de petits anneaux opaques entourant une clartécentrale(signe de l\'anneau).Ces images sont fréquemment observées dans la bronchite chronique,la dilatation des bronches,l\'asthme ou l\'œdème interstitiel pré-alvéolaire.',
      imagePath: 'assets/images/radiology/rad_sign_wall_thickening.jpg',
      relatedSyndromes: [RadiologySyndrome.bronchial],
      category: RadiologyCategory.A,
    ),

    // ---BREATHING(B) ---
    RadiologyFinding(
      id: 'rad_blurred_limits',
      name: 'Limites floues',
      description:
          'Opacitéaux contours imprécis,sauf au contact d\'une scissure.',
      fullDescription:
          'Les limites floues d\'une opacitéparenchymateuse sont le témoin direct d\'un comblement de l\'espace aérien alvéolaire par du liquide(œdème,pus,sang).Contrairement au syndrome interstitiel oùles contours sont nets,le syndrome alvéolaire se diffuse de proche en procheàtravers les pores de Kohn,rendant les berges de l\'opacitévaporeuses et mal systématisées(aspect"cotonneux").La seule exception est la rencontre d\'une scissure interlobaire,qui stoppe net la progression du liquide et crée alors une limite rectiligne et précise.Ce caractère flou est fondamental pour orienter vers une pathologie du sac alvéolaire comme une pneumonie infectieuse,unœdème pulmonaire ou une hémorragie alvéolaire diffuse.',
      imagePath: 'assets/images/radiology/rad_sign_lobar_pneumonia.jpg',
      relatedSyndromes: [RadiologySyndrome.alveolar],
      category: RadiologyCategory.B,
    ),
    RadiologyFinding(
      id: 'rad_confluence',
      name: 'Confluence',
      description: 'Tendance des opacitésàse rejoindre par les pores de Kohn.',
      fullDescription:
          'La confluence est une propriétédynamique essentielle des opacités alvéolaires.Elle s\'explique par la communication directe entre les sacs alvéolaires via les pores de Kohn et les canaux de Lambert.Très tôt dans le processus pathologique,de petites opacités nodulaires aux contours imprécis ont tendanceàse rejoindre pour former des foyers de condensation plus larges et homogènes.On observe alors une opacitéplus vaste,souvent systématiséeàun segment ouàun lobe entier.Cette fusion des lésions est un critère diagnostique fort permettant de différencier un syndrome alvéolaire actif d\'une lésion interstitielle oùleséléments restent individualisés et séparés les uns des autres par un parenchyme sain.',
      imagePath: 'assets/images/radiology/rad_sign_lobar_pneumonia.jpg',
      relatedSyndromes: [RadiologySyndrome.alveolar],
      category: RadiologyCategory.B,
    ),
    RadiologyFinding(
      id: 'rad_bronchogram',
      name: 'Bronchogramme aérien',
      description: 'Visibilitédes bronches aérées au sein de l\'opacité.',
      fullDescription:
          'Le bronchogramme aérien correspondàla visualisation anormale d\'une bronche aérée,apparaissant sous forme de clartétubulaire ramifiée,au sein d\'une zone de condensation parenchymateuse opaque.Ce signe se produit lorsque les alvéoles environnantes sont comblées par du liquide(ou des cellules),créant un contraste de densitéavec l\'air contenu dans les bronches qui restent perméables.C\'est un signe quasi pathognomonique de l\'atteinte alvéolaire et il permet d\'affirmer que la lésion siège bien dans le parenchyme pulmonaire et non dans la plèvre ou le médiastin.On le rencontre typiquement dans la pneumonie lobaire bactérienne(ex:pneumococcie),l\'œdème pulmonaire ou certains lymphomes pulmonaires.',
      imagePath: 'assets/images/radiology/rad_sign_bronchogram.jpg',
      relatedSyndromes: [RadiologySyndrome.alveolar],
      category: RadiologyCategory.B,
    ),
    RadiologyFinding(
      id: 'rad_butterfly',
      name: 'Ailes de papillon',
      description:
          'Opacités péri-hilaires symétriques respectant la périphérie.',
      fullDescription:
          'L\'aspect en"ailes de papillon" (ou Bat-wing appearance)désigne une distribution spécifique des opacités alvéolaires,caractérisée par une infiltration bilatérale,symétrique et centrale,occupant les régions péri-hilaires tout enépargnant la périphérie des champs pulmonaires(le liserécortical).Cette image est le reflet d\'une inondation alvéolaire massive et rapide.Elle est classiquement rencontrée dans l\'œdème aigu du poumon(OAP)d\'origine cardiogénique lors d\'une insuffisance ventriculaire gauche brutale.Moins fréquemment,cet aspect peut se voir dans l\'hémorragie alvéolaire diffuse,la pneumopathieàPneumocystis jirovecii ou certaines formes de toxicitémédicamenteuse.C\'est un signe de gravitéclinique immédiate.',
      imagePath: 'assets/images/radiology/rad_sign_butterfly.jpg',
      relatedSyndromes: [RadiologySyndrome.alveolar],
      category: RadiologyCategory.B,
    ),
    RadiologyFinding(
      id: 'rad_sharp_limits',
      name: 'Limites nettes',
      description: 'Contours précis des opacités.',
      fullDescription:
          'Contrairement au syndrome alvéolaire,les opacités du syndrome interstitiel possèdent des contours nets et précis.Cela s\'explique par la localisation de la pathologie dans le tissu de soutien du poumon(septums interlobulaires,gaines péribronchovasculaires)et non dans les espaces aériens.Les structures alvéolaires restent aérées,ce qui crée un contraste naturel avec l\'interstitiumépaissi.Que les opacités soient nodulaires,réticulaires ou linéaires,elles restent bien individualisées et ne confluent jamais.Cette nettetédes contours est unélément sémiologique capital pour orienter le diagnostic vers des pathologies chroniques comme la fibrose pulmonaire idiopathique,la sarcoïdose,ou des atteintes aiguës comme l\'œdème interstitiel précoce.',
      imagePath: 'assets/images/radiology/rad_sign_miliary.jpg',
      relatedSyndromes: [RadiologySyndrome.interstitial],
      category: RadiologyCategory.B,
    ),
    RadiologyFinding(
      id: 'rad_kerley_b',
      name: 'Lignes de Kerley B',
      description: 'Lignes horizontales courtesàla base du poumon.',
      fullDescription:
          'Les lignes de Kerley B sont de petites opacités linéaires horizontales,fines,nettes,mesurant environ 1à2 cm de long.Elles sont situéesàla périphérie des bases pulmonaires,souvent dans les culs-de-sac pleuraux,et sont perpendiculairesàla paroi thoracique en contact avec la plèvre.Elles sont le reflet d\'unépaississement des septums interlobulaires,le plus souvent par accumulation de liquide lymphatique ou d\'œdème.Sur une radiographie de face,leur présence est un excellent marqueur d\'uneélévation de la pression capillaire pulmonaire,typiquement observée dans l\'insuffisance cardiaque gauche.Elles peuvent aussi se rencontrer dans la lymphangite carcinomateuse ou certains types de pneumopathies interstitielles chroniques.',
      imagePath: 'assets/images/radiology/rad_sign_kerley_b.jpg',
      relatedSyndromes: [RadiologySyndrome.interstitial],
      category: RadiologyCategory.B,
    ),
    RadiologyFinding(
      id: 'rad_miliaire',
      name: 'Miliaire',
      description: 'Micronodules(<3 mm)diffus.',
      fullDescription:
          'La miliaire pulmonaire se définit par la présence d\'une multitude de petites opacités nodulaires punctiformes,appelées micronodules,mesurant généralement moins de 3 millimètres de diamètre.Ces micronodules sont répartis de manière diffuse et uniforme dans les deux champs pulmonaires,sans tendanceàla confluence.L\'aspect obtenuévoque une semée de grains de mil,d\'oùle terme de"miliaire".Radiologiquement,cette image traduit une dissémination hématogène(par le sang)d\'un processus pathologique.La cause classique et redoutable est la miliaire tuberculeuse,une forme grave de tuberculose.On peutégalement observer cet aspect dans certaines métastases pulmonaires(cancer thyroïdien),la sarcoïdose ou la silicoseàun stade précoce.',
      imagePath: 'assets/images/radiology/rad_sign_miliary.jpg',
      relatedSyndromes: [RadiologySyndrome.interstitial],
      category: RadiologyCategory.B,
    ),
    RadiologyFinding(
      id: 'rad_honeycomb',
      name: 'Rayon de miel',
      description: 'Cavités kystiques jointives(fibrose).',
      fullDescription:
          'L\'image en"rayon de miel"ou honeycombing est le stade ultime de la destruction et du remodelage du parenchyme pulmonaire par un processus de fibrose.Elle se manifeste par des cavités kystiques de petite taille(3à10 mm),jointives, àparoisépaisses,disposées en plusieurs couches empilées.Cet aspect est particulièrement bien visible en scanographie de haute résolution(HRCT)mais peutêtre suspectésur une radiographie de face par un aspect réticulaire très dense et irrégulier des bases.Radiologiquement,c\'est un signe irréversible de perte de l\'architecture pulmonaire normale.On le rencontre principalement dans la fibrose pulmonaire idiopathique(UIP)ou au stade terminal de toute pneumopathie interstitielle chronique.',
      imagePath: 'assets/images/radiology/rad_sign_honeycomb.jpg',
      relatedSyndromes: [RadiologySyndrome.interstitial],
      category: RadiologyCategory.B,
    ),
    RadiologyFinding(
      id: 'rad_bronchiectasis',
      name: 'Bronchectasie(DDB)',
      description: 'Diamètre bronchique supérieuràl\'artère homologue.',
      fullDescription:
          'La dilatation des bronches(ou bronchectasie)correspondàune augmentation permanente et irréversible du calibre des bronches de petit et moyen calibre.Sur une radiographie de thorax,on peut suspecter des DDB cylindriques par le signe du rail(double ligne opaque)ou des DDB kystiques par des clartés arrondiesàparoisépaisses.Le critère diagnostique de référence est scannographique:le diamètre de la bronche est supérieuràcelui de l\'artère pulmonaire adjacente,créant le"signe du bagueàchaton" (signet ring sign).Cette pathologie perturbe l\'épuration muco-ciliaire et favorise les infections respiratoiresàrépétition.Elle peutêtre localisée ou diffuse selon la cause(séquelles de coqueluche,mucoviscidose,dyskinésie ciliaire).',
      imagePath: 'assets/images/radiology/rad_sign_signet_ring.png',
      relatedSyndromes: [RadiologySyndrome.bronchial],
      category: RadiologyCategory.B,
    ),
    RadiologyFinding(
      id: 'rad_pneumothorax_line',
      name: 'Ligne pleurale(PNX)',
      description: 'Ligne fine séparant le poumon de l\'hyperclartéaérienne.',
      fullDescription:
          'La visualisation de la ligne pleurale viscérale est le signe direct et indispensable d\'un pneumothorax.On observe une fine ligne blanche,nette et tranchée,délimitant le poumon qui s\'est rétractévers le hile sous l\'effet de la pression de l\'air entrédans la cavitépleurale.Au-delàde cette ligne,vers la périphérie du thorax,on note une zone de"noir complet" (hyperclarté)totalement dépourvue de trame bronchovasculaire(avasculaire).Ce signe est mieux visualiséau sommet du poumon sur un clichéen inspiration profonde,ou parfois en expiration.Sa recherche est cruciale car elle permet d\'évaluer l\'importance du décollement et de guider l\'indication d\'un drainage pleural en cas de compression ou de gêne respiratoire aiguë.',
      imagePath: 'assets/images/radiology/rad_sign_pneumothorax.jpg',
      relatedSyndromes: [RadiologySyndrome.pleural],
      category: RadiologyCategory.B,
    ),
    RadiologyFinding(
      id: 'rad_fluid_level',
      name: 'Niveau hydro-aérique',
      description: 'Limite horizontale entre air et liquide.',
      fullDescription:
          'Un niveau hydro-aérique est une ligne horizontale parfaite séparant une clartéaérienne supérieure d\'une opacitéliquidienne inférieure au sein d\'une cavité.Ce signe est la preuve formelle de la coexistence d\'air et de liquide dans un espace clos.Pourêtre visualisé,le clichédoit impérativementêtre réaliséavec le patient debout et un faisceau de rayons X horizontal.Dans le parenchyme pulmonaire,il suggère un abcèsévidéou une caverne tuberculeuse surinfectée.Si le niveau occupe une grande partie de l\'hémithorax,il traduit un hydro-pneumothorax(mélange d\'air et d\'épanchement pleural).Sa modification lors des changements de position est un argument décisif pour affirmer le caractère liquide et libre de la collection.',
      imagePath: 'assets/images/radiology/rad_sign_fluid_level.jpg',
      relatedSyndromes: [RadiologySyndrome.pleural, RadiologySyndrome.cavitary],
      category: RadiologyCategory.B,
    ),
    RadiologyFinding(
      id: 'rad_grelot',
      name: 'Image en grelot',
      description: 'Masse mobile au sein d\'une cavité.',
      fullDescription:
          'L\'image en"grelot" (ou Monod sign)est une image radiologique trèsévocatrice consistant en une opacitéarrondie ou ovalaire,de densitéhydrique,situéeàl\'intérieur d\'une cavitépréexistante pulmonaire.Sa caractéristique principale est la présence d\'un croissant d\'air clair entourant la masse,séparant cette dernière de la paroi de la cavité.Ce signe est classique de l\'aspergillome,qui est le développement d\'un"feutrage de filaments mycéliens" (une boule de champignon)dans une ancienne caverne de tuberculose ou une dilatation des bronches.Une particularitésémiologique est la mobilitéde la masse lors des changements de position du patient,confirmant qu\'elle n\'est pas fixéeàla paroi,miment ainsi la billeàl\'intérieur d\'un grelot.',
      imagePath: 'assets/images/radiology/rad_sign_grelot.jpg',
      relatedSyndromes: [RadiologySyndrome.cavitary],
      category: RadiologyCategory.B,
    ),
    RadiologyFinding(
      id: 'rad_nenuphar',
      name: 'Image en nénuphar',
      description: 'Membrane flottante d\'un kyste hydatique rompu.',
      fullDescription:
          'L\'image en"nénuphar" (ou Water-lily sign)est un signe radiologique spécifique d\'un kyste hydatique pulmonaire après rupture ouévacuation partielle de son contenu liquide dans une bronche.Lorsque le kyste se fissure,l\'air pénètre entre la membrane proligère(le sac interne du parasite)et le périkyste(la paroi formée par le poumon).La membrane s\'affaisse alors et se metàflotteràla surface du liquide hydatique restant.Sur la radiographie,cela se traduit par la visualisation de lignes ondulées,fines et opaques,flottant sur un niveau hydro-aérique horizontal.C\'est un aspect caractéristique témoignant de la mort du parasite et de la vidange du kyste,imposant une prise en charge chirurgicale spécifique pouréviter les complications infectieuses.',
      relatedSyndromes: [RadiologySyndrome.cavitary],
      category: RadiologyCategory.B,
    ),

    // ---CIRCULATION/MEDIASTINUM(C) ---
    RadiologyFinding(
      id: 'rad_silhouette',
      name: 'Signe de la silhouette',
      description: 'Effacement d\'un bord du cœur ou de l\'aorte.',
      fullDescription:
          'Énoncépar Felson,le signe de la silhouette est l\'un des principes fondamentaux de la radio-anatomie clinique.Il repose sur le fait que lorsque deux structures de même densitéradiologique(eau/tissu)sont situées dans le même plan anatomique et se touchent,leur limite de séparation disparaît sur l\'image.Inversement,si elles sont dans des plans différents,le bord est conservé.Par exemple,une opacitépulmonaire effaçant le bord droit du cœur permet d\'affirmer que la lésion est antérieure,située dans le lobe moyen.Si le bord du cœur reste visibleàtravers l\'opacité,la lésion est postérieure(lobe inférieur).Ce signe est d\'une aide précieuse pour localiser précisément une pathologie thoracique en trois dimensionsàpartir d\'un simple clichéde face.',
      imagePath: 'assets/images/radiology/rad_sign_silhouette.jpg',
      relatedSyndromes: [RadiologySyndrome.mediastinal],
      category: RadiologyCategory.C,
    ),
    RadiologyFinding(
      id: 'rad_iceberg',
      name: 'Signe de l\'iceberg',
      description: 'Masse thoraco-abdominale s\'écartant du rachis.',
      fullDescription:
          'Le signe de l\'iceberg est utilisépour caractériser une masse médiastinale postérieure dont la limite supérieure est bien visible au-dessus de l\'orifice supérieur du thorax,tandis que sa base semble s\'évanouir dans l\'opacitéde l\'abdomen.Ce signe s\'explique par la position anatomique de la masse par rapport au médiastin et au diaphragme.Si la masse possède des contours externes qui s\'écartent du rachis au fur etàmesure qu\'ils descendent sous le diaphragme,cela signifie que la masse traverse le diaphragme ou qu\'elle provient de la loge rénale.Il est classique dans les tumeurs neuroblastiques de l\'enfant ou certaines hernies hiatales.Ce signe permet d\'anticiper le caractère thoraco-abdominal d\'une lésion avant d\'approfondir les investigations par scanner ou IRM.',
      relatedSyndromes: [RadiologySyndrome.mediastinal],
      category: RadiologyCategory.C,
    ),

    // ---DIAPHRAGM/PLEURA(D) ---
    RadiologyFinding(
      id: 'rad_damoiseau',
      name: 'Ligne de Damoiseau',
      description: 'Limite supérieure d\'unépanchement liquide.',
      fullDescription:
          'La ligne de Damoiseau(ou courbe de Damoiseau-Ellis)correspondàla limite supérieure d\'unépanchement pleural liquide libre de moyenne abondance sur un clichéréalisédebout.Elle se présente comme une opacitébasale dense,homogène,dont le bord supérieur dessine une courbe concave vers le haut et vers le dedans.Cette courbe est plus haute en périphérie qu\'au centre(près du rachis),ce qui s\'explique par la capillaritédu liquide entre les feuillets pleuraux et le vide pleural.C\'est le signe radiologique standard de la pleurésie liquidienne libre.Son aspect change complètement si de l\'air est introduit(niveau hydro-aérique horizontal),ce qui permet de vérifier l\'absence de pneumothorax associéou de pneumopéritoine par simple examen visuel des angles costophréniques.',
      imagePath: 'assets/images/radiology/rad_sign_damoiseau.png',
      relatedSyndromes: [RadiologySyndrome.pleural],
      category: RadiologyCategory.D,
    ),
    RadiologyFinding(
      id: 'rad_efface_costophrenic',
      name: 'Comblement de cul-de-sac',
      description: 'Disparition de l\'angle costodiaphragmatique.',
      fullDescription:
          'Le comblement ou l\'effacement du cul-de-sac costophrenique latéral est le signe radiologique le plus précoce d\'unépanchement pleural liquide.Normalement,l\'angle forméentre la coupole diaphragmatique et la paroi thoracique est aigu,tranchéet clair(noir).L\'accumulation de seulement 50à100 ml de liquide suffit déjà àcombler cet angle,qui devient alors obtus, émousséou totalement opaque.Ce signe doitêtre recherchéavec attention au niveau des deux bases pulmonaires.Un cul-de-sac"comblé"peut rester stable pendant des années en cas de séquelles de pleurésie(symphyse pleurale),ouêtre le signe d\'une inflammation aiguëdébutante.En cas de doute,un clichéde profil ou en décubitus latéral peut aideràconfirmer le caractère mobile ou fixe du liquide.',
      imagePath: 'assets/images/radiology/rad_sign_efface_costophrenic.jpg',
      relatedSyndromes: [RadiologySyndrome.pleural],
      category: RadiologyCategory.D,
    ),

    // ---EVERYTHING ELSE/PARIETAL(E) ---
    RadiologyFinding(
      id: 'rad_bone_lysis',
      name: 'Lyse osseuse',
      description: 'Destruction localisée d\'un os(côte,vertèbre).',
      fullDescription:
          'La lyse osseuse(ostéolyse)est un signe de gravitéextrême dans le cadre du syndrome pariétal.Elle correspondàla destruction localisée d\'unélément du gril costal,d\'une vertèbre ou d\'une clavicule par un processus envahissant.Radiographiquement,on observe une disparition d\'un segment de l\'os,ou un aspect"rongé"des contours corticaux.Ce signe est presque toujours le témoin d\'un processus cancéreux,soit par invasion directe(tumeur de Pancoast-Tobias envahissant les premières côtes),soit par métastase osseuse.Une attention particulière doitêtre portéeàla continuitédes arcs costaux lors de l\'examen systématique de la radiographie,car une petite lyse peut passer inaperçue derrière une opacitépulmonaire plus importante,alors qu\'elle modifie radicalement le pronostic et le stade de la pathologie.',
      imagePath: 'assets/images/radiology/rad_sign_bone_lysis.jpg',
      relatedSyndromes: [RadiologySyndrome.parietal],
      category: RadiologyCategory.E,
    ),
    RadiologyFinding(
      id: 'rad_smooth_attachment',
      name: 'Raccordement en pente douce',
      description: 'Angle obtus avec la paroi thoracique.',
      fullDescription:
          'Le raccordement en"pente douce"est un critère morphologique essentiel pour affirmer l\'origine pariétale d\'une opacitépériphérique.Lorsqu\'une masse se développeàpartir de la paroi(os,muscles,nerfs)et refoule la plèvre vers l\'intérieur de la cavitéthoracique,elle forme avec la paroi thoracique des angles de raccordement obtus(>90 degrés),mimant une pente douce. Àl\'inverse,une masse purement intrapulmonaire qui vient buter contre la paroi forme des angles aigus.Cet aspect est souvent complétépar une limite interne nette(pleurale)et un diamètre de base d\'attachement large.Ce signe permet d\'identifier les tumeurs costales,les hématomes pariétaux ou les neurinomes intercostaux, évitant ainsi de les confondre avec une lésion purement parenchymateuse ou une pleurésie enkystée.',
      imagePath: 'assets/images/radiology/rad_sign_smooth_attachment.jpg',
      relatedSyndromes: [RadiologySyndrome.parietal],
      category: RadiologyCategory.E,
      etiologies: [
        'Tumeur costale',
        'Myélome',
        'Neurinome intercostal',
        'Hématome pariétal',
      ],
    ),

    // ---NEW HILAR&MEDIASTINAL SIGNS---
    RadiologyFinding(
      id: 'rad_recouvrement_hilum',
      name: 'Signe du recouvrement du hile',
      description: 'L\'artère pulmonaire est visibleàtravers la masse.',
      fullDescription:
          'Le signe du recouvrement du hile permet d\'affirmer l\'origine médiastinale d\'une opacitéoccupant la région du hile.Si l\'on continue de percevoir les vaisseaux hilaires(artères pulmonaires) àtravers l\'opacité,cela signifie que la masse est située soit en avant,soit en arrière du hile,et qu\'elle appartient donc au médiastin(antérieur ou postérieur).Inversement,si les vaisseaux s\'arrêtent net au contact de la masse,celle-ci est située dans le plan hilaire lui-même,suggérant une origine pulmonaire ou une adénopathie hilaire massive.',
      relatedSyndromes: [RadiologySyndrome.mediastinal],
      category: RadiologyCategory.C,
      etiologies: [
        'Masse du médiastin antérieur',
        'Masse du médiastin postérieur',
      ],
    ),
    RadiologyFinding(
      id: 'rad_convergence_hilum',
      name: 'Signe de la convergence du hile',
      description: 'Les vaisseaux convergent vers le centre de la masse.',
      fullDescription:
          'Le signe de la convergence du hile sertàdistinguer un hile de gros volume d\'origine vasculaire(ex:hypertension pulmonaire)d\'une masse hilaire vraie(ex:cancer bronchique ou adénopathie).Si les branches de l\'artère pulmonaire convergent vers le centre de l\'opacitéhilaire,il s\'agit d\'une dilatation de l\'artère pulmonaire elle-même.Si elles convergent en dehors du bord externe de l\'opacité,il s\'agit d\'une masse médiastinale.Ce signe est crucial pouréviter des erreurs diagnostiques majeures dans l\'évaluation des hiles pulmonaires.',
      relatedSyndromes: [RadiologySyndrome.mediastinal],
      category: RadiologyCategory.C,
      etiologies: ['Hypertension pulmonaire', 'Gros cœur gauche'],
    ),
    RadiologyFinding(
      id: 'rad_cervico_thoracic',
      name: 'Signe cervico-thoracique',
      description: 'Masse dont le bord supérieur dépasse la clavicule.',
      fullDescription:
          'Le signe cervico-thoracique est un critère de localisation pour les masses du médiastin supérieur.Comme le médiastin antérieur s\'arrête au niveau de la clavicule,toute opacitédont la limite supérieure dépasse le bord supérieur de la clavicule est nécessairement située dans le médiastin postérieur.Inversement,une opacitédu médiastin antérieur verra son bord supérieur disparaître en contact avec la clavicule(signe de la silhouette).Ce signe anatomique simple permet d\'orienter immédiatement vers une tumeur neurogène(postérieur)ou un goitre plongeant/tumeur du thymus(antérieur).',
      relatedSyndromes: [RadiologySyndrome.mediastinal],
      category: RadiologyCategory.C,
      etiologies: ['Tumeur neurogène', 'Goitre plongeant', 'Lymphome'],
    ),
  ];

  static const List<RadiologyTechnicalCriteria> technicalCriteria = [
    RadiologyTechnicalCriteria(
      id: 'tech_rotation',
      name: 'Centrage(Rotation)',
      description:
          'Symétrie des extrémités internes des clavicules par rapport aux apophysesépineuses.',
      target: 'Claviculeséquidistantes de la ligne desépineuses.',
    ),
    RadiologyTechnicalCriteria(
      id: 'tech_inspiration',
      name: 'Inspiration',
      description:
          'L\'inspiration est suffisante si l\'on compte au moins 6 arcs costaux antérieurs ou 10 postérieurs au-dessus de la coupole diaphragmatique.',
      target: '6 arcs ant. /10 arcs post.',
    ),
    RadiologyTechnicalCriteria(
      id: 'tech_penetration',
      name: 'Pénétration(Noircissement)',
      description:
          'On doit pouvoir distinguer les 4 premières vertèbres thoraciques et la trame vasculaire derrière le cœur.',
      target: 'T1-T4 visibles+trame rétro-cardiaque.',
    ),
    RadiologyTechnicalCriteria(
      id: 'tech_position',
      name: 'Position(Bout debout)',
      description: 'Présence de la pocheàair gastrique sous la coupole gauche.',
      target: 'Pocheàair gastrique présente.',
    ),
  ];

  static const List<RadiologyDifferential> differentials = [
    RadiologyDifferential(
      title: 'Alvéolaire vs Interstitiel',
      logic:
          'Les opacités alvéolaires sont floues,confluentes et systématisées,contrairement aux opacités interstitielles qui sont nettes,non confluentes et jamais systématisées.',
      triggerFindingIds: [
        'rad_blurred_limits',
        'rad_confluence',
        'rad_sharp_limits',
      ],
    ),
    RadiologyDifferential(
      title: 'Signe du Bronchogramme',
      logic:
          'Sa présence(bronches aérées au sein d\'une opacité)affirme la nature parenchymateuse(alvéolaire)de la lésion,excluant formellement une pleurésie pure ou une masse médiastinale.',
      triggerFindingIds: ['rad_bronchogram'],
    ),
    RadiologyDifferential(
      title: 'Pleurésie vs Condensation',
      logic:
          'L\'absence de bronchogramme aérien au sein d\'une opacitéhomogène comblant un cul-de-sac plaide pour unépanchement pleural liquide plutôt que pour une condensation parenchymateuse.',
      triggerFindingIds: ['rad_efface_costophrenic', 'rad_damoiseau'],
    ),
    RadiologyDifferential(
      title: 'Masse Pariétale vs Pulmonaire',
      logic:
          'Le raccordement en pente douce(angle obtus)et d\'éventuelles lésions osseuses(lyse costale)affirment l\'origine pariétale de la lésion et non pulmonaire.',
      triggerFindingIds: ['rad_smooth_attachment', 'rad_bone_lysis'],
    ),
    RadiologyDifferential(
      title: 'Signe de la Silhouette',
      logic:
          'L\'effacement d\'un bord du cœur ou de l\'aorte permet de situer la lésion dans le plan antérieur(ex:lobe moyen si bord droit du cœur effacé)ou postérieur(ex:lobe inférieur si bord conservé).',
      triggerFindingIds: ['rad_silhouette'],
    ),
  ];

  static const List<RadiologySyndromeInfo> syndromeInfo = [
    RadiologySyndromeInfo(
      syndrome: RadiologySyndrome.alveolar,
      title: 'Syndrome Alvéolaire',
      definition:
          'Comblement des alvéoles pulmonaires par du liquide(œdème,pus,sang)ou des cellules.',
      signs: [
        'Opacitésàlimites floues(aspect cotonneux)',
        'Confluence(se rejoint par les pores de Kohn)',
        'Bronchogramme aérien(Signe pathognomonique)',
        'Répartition systématisée(lobaire ou segmentaire)',
        'Ailes de papillon(Hiles vers la périphérie)',
        'Évolution rapide en quelques heures ou jours',
      ],
      etiologies: [
        'œdème aigu du poumon(OAP)',
        'Pneumonies bactériennes',
        'Hémorragie alvéolaire diffuse',
        'Noyade',
      ],
      clinicalPearls:
          'Unœdème aigu du poumon(OAP)s\'efface en 24h-48h,tandis qu\'une pneumonie met plusieurs semainesàdisparaître radiologiquement.',
    ),
    RadiologySyndromeInfo(
      syndrome: RadiologySyndrome.interstitial,
      title: 'Syndrome Interstitiel',
      definition:
          'Épaississement du tissu de soutien du poumon(septums interlobulaires,gaines péribronchiolaires).',
      signs: [
        'Opacitésàlimites nettes',
        'Non confluentes',
        'Pas de bronchogramme aérien',
        'Non systématisées',
        'Aspects:Miliaire(<3mm),Réticulé (Kerley B),Rayon de miel(stade ultime)',
        'Évolution lente(semaines ou mois)',
      ],
      etiologies: [
        'Œdème interstitiel(OAP débutant)',
        'Fibrose pulmonaire idiopathique',
        'Tuberculose miliaire',
        'Sarcoïdose',
        'Lymphangite carcinomateuse',
      ],
      clinicalPearls:
          'L\'absence de bronchogramme aérien est fondamentale pour différencier l\'interstitiel de l\'alvéolaire.',
    ),
    RadiologySyndromeInfo(
      syndrome: RadiologySyndrome.bronchial,
      title: 'Syndrome Bronchique',
      definition:
          'Manifestations directes et indirectes de l\'atteinte des bronches.',
      signs: [
        'Directs: Épaississement pariétal(Signe du rail/anneau),Dilatation(Signe de la bagueàchaton)',
        'Indirects(Ventilation):Atélectasie(rétractile),Emphysème obstructif(distension)',
      ],
      etiologies: [
        'Bronchite chronique(rails)',
        'Mucoviscidose(DDB diffuse)',
        'Corpsétranger(atélectasie)',
        'Asthme',
      ],
      clinicalPearls:
          'Le diamètre de la bronche dilatée devient supérieuràcelui de l\'artère homologue(Signe de la bagueàchaton).',
    ),
    RadiologySyndromeInfo(
      syndrome: RadiologySyndrome.pleural,
      title: 'Syndrome Pleural',
      definition: 'Présence de liquide ou d\'air dans la cavitépleurale.',
      signs: [
        'Épanchement libre:Opacitéhomogène basale dense,courbe de Damoiseau concave',
        'Pneumothorax:Ligne fine(plèvre viscérale)séparant le poumon d\'une hyperclartéavasculaire',
        'Effacement des culs-de-sac costophréniques(signe précoce)',
      ],
      etiologies: [
        'Transudat:Insuffisance cardiaque,Cirrhose',
        'Exudat:Cancer,Tuberculose,Infection(Pleurésie)',
      ],
      clinicalPearls:
          'Unépanchement"phantom tumor"peut se former dans une scissure en cas d\'insuffisance cardiaque(scissuralitas).',
    ),
    RadiologySyndromeInfo(
      syndrome: RadiologySyndrome.mediastinal,
      title: 'Syndrome Médiastinal',
      definition:
          'Développement d\'une masse(tumorale ou vasculaire)au sein du médiastin.',
      signs: [
        'Limite interne noyée dans le médiastin',
        'Limite externe nette et convexe vers le poumon',
        'Signe de la silhouette(Localisation antéro-postérieure)',
        'Signe cervico-thoracique(Médiastin supérieur)',
        'Convergence vs Recouvrement du hile(Artère vs Masse)',
      ],
      etiologies: [
        'Antérieur:Goitre,Thymome,Lymphome',
        'Moyen:Adénopathies,Kyste bronchogénique',
        'Postérieur:Tumeurs neurogènes',
      ],
      clinicalPearls:
          'Classification de Felson:Antérieur(Cœur/Gros vaisseaux),Moyen(Trachée/Hiles),Postérieur(Gouttière costovertébrale).',
    ),
    RadiologySyndromeInfo(
      syndrome: RadiologySyndrome.parietal,
      title: 'Syndrome Pariétal',
      definition:
          'Lésions provenant de la paroi thoracique(os,parties molles).',
      signs: [
        'Raccordement en pente douce(angle obtus)',
        'Lésions osseuses associées(Lyse d\'une côte)',
        'Refoulement de la plèvre vers l\'intérieur',
      ],
      etiologies: [
        'Tumeur primitive de côte',
        'Métastase osseuse',
        'Abcès de paroi',
        'Hématome',
      ],
      clinicalPearls:
          'L\'angle de raccordement obtus(>90°)est le signe cardinal de l\'origine pariétale.',
    ),
    RadiologySyndromeInfo(
      syndrome: RadiologySyndrome.cavitary,
      title: 'Syndrome Cavitaire',
      definition:
          'Destruction localisée du parenchyme créant une image de clartécernée par une paroi.',
      signs: [
        'Paroi d\'épaisseur variable',
        'Niveau hydro-aérique(si air+liquide)',
        'Signe du grelot(masse mobile/Aspergillome)',
        'Signe du nénuphar(Kyste hydatique rompu)',
      ],
      etiologies: [
        'Cancer nécrosé (paroiépaisse/irrégulière)',
        'Abcès de poumon(niveau)',
        'Tuberculose(cavernes apicales)',
        'Kyste aérien simple',
      ],
      clinicalPearls:
          'Règle des 15mm:Une paroi<5mm est bénigneà95%, >15mm est maligneà95%.',
    ),
  ];
}
