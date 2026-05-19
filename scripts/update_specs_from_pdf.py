import re

categories = {
    "cardio": ["cardiology", "chirurgiecardiaque", "chirurgievasculaire"],
    "neuro": ["neurology", "chirurgieneurologique", "medecinephysiqueetreadaptation"],
    "resp": ["pneumophtisiologie", "chirurgiethoracique"],
    "digest": ["hepatogastroenterologie", "chirurgiegenerale"],
    "uro": ["nephrologie", "chirurgieurologique", "gynecologieobstetrique"],
    "loco": ["rhumatologie", "chirurgieorthopediqueettraumatologie", "medecinedusport"],
    "derm": ["dermatologieetvenereologie", "chirurgieplastiquereconstructriceesthetiqueetdebrulologie"],
    "psych": ["psychiatrie", "pedopsychiatrie"],
    "ent": ["orl", "ophtalmologie", "chirurgiemaxillofaciale"],
    "endo": ["diabetologieendocrinologieetmaladiesmetaboliques"],
    "hemato": ["hematologie", "oncologiemedicale", "radiotherapieoncologie"]
}

exam_fields_templates = {
    "cardio": [
        ("insp_omi", "Inspection : OMI (Œdèmes)", "Absents"),
        ("insp_cyanose", "Inspection : Cyanose", "Absente"),
        ("insp_tvj", "Turgescence Veines Jugulaires", "Absente"),
        ("palp_choc", "Palpation : Choc de pointe", "En place, non dévié, normocinétique"),
        ("palp_thrill", "Palpation : Frémissement / Thrill", "Absent"),
        ("palp_harzer", "Signe de Harzer", "Négatif"),
        ("ausc_rythme", "Rythme Cardiaque", "Régulier"),
        ("ausc_bruits", "Bruits du cœur", "B1 et B2 présents et bien frappés, pas de B3 ni de B4"),
        ("ausc_ao", "Auscultation : Foyer Aortique", "Libre, pas de souffle"),
        ("ausc_pulm", "Auscultation : Foyer Pulmonaire", "Libre, pas de souffle"),
        ("ausc_mitral", "Auscultation : Foyer Mitral", "Libre, pas de souffle"),
        ("ausc_tricuspid", "Auscultation : Foyer Tricuspidien", "Libre, pas de souffle"),
        ("pouls_periph", "Pouls périphériques", "Présents, symétriques, synchrones et réguliers"),
        ("ausc_vasc", "Auscultation vasculaire (Carotides, Fémorales)", "Pas de souffle vasculaire"),
    ],
    "neuro": [
        ("conscience", "Conscience (Glasgow)", "15/15"),
        ("orientation", "Orientation", "Orienté(e) dans le temps et l'espace"),
        ("marche", "Station debout et Marche", "Marche normale, pas de déficit, pas d'ataxie"),
        ("romberg", "Signe de Romberg", "Négatif"),
        ("force_ms", "Force Musculaire - Membres Sup.", "5/5 bilatéral et symétrique"),
        ("force_mi", "Force Musculaire - Membres Inf.", "5/5 bilatéral et symétrique"),
        ("tonus", "Tonus musculaire", "Normal, pas d'hypertonie ni d'hypotonie"),
        ("sens_super", "Sensibilité superficielle", "Normale, symétrique"),
        ("sens_prof", "Sensibilité profonde (Proprioception)", "Normale, pallesthésie conservée"),
        ("rot_ms", "ROT Membres Supérieurs (Bicipital, Tricipital)", "Présents, symétriques, normo-vifs"),
        ("rot_mi", "ROT Membres Inférieurs (Rotulien, Achilléen)", "Présents, symétriques, normo-vifs"),
        ("babinski", "Réflexe cutané plantaire", "En flexion bilatéralement (Babinski négatif)"),
        ("nerfs_craniens", "Nerfs Crâniens (I à XII)", "Pas de déficit sensitivo-moteur facial, paires intactes"),
        ("meninges", "Signes Méningés", "Nuque souple, Kernig et Brudzinski négatifs"),
        ("langage", "Langage et Paroles", "Fluide, pas d'aphasie ni de dysarthrie"),
    ],
    "resp": [
        ("insp_morpho", "Morphologie Thoracique", "Symétrique, pas de déformation"),
        ("insp_signes_lutte", "Signes de lutte", "Absents (pas de tirage, pas de battement des ailes du nez)"),
        ("insp_cyanose", "Cyanose / Hippocratisme", "Absents"),
        ("palp_vv", "Vibrations Vocales", "Normalement transmises bilatéralement"),
        ("perc_sonorite", "Percussion", "Sonorité normale bilatérale, pas de matité ni de tympanisme anormal"),
        ("ausc_mv", "Murmure Vésiculaire", "Présent, normal et symétrique, pas d'allongement du temps expiratoire"),
        ("ausc_rales", "Râles et bruits surajoutés", "Absents (pas de crépitants, sibilants ou ronchis)"),
        ("ausc_frottement", "Frottement pleural", "Absent"),
        ("sat_oxy", "Saturation en O2", "Normale à l'air ambiant"),
    ],
    "digest": [
        ("cavite_buccale", "Cavité Buccale / Dents / Muqueuses", "Langue propre, humides, dentition en bon état, gencives saines"),
        ("insp_abd", "Inspection Abdominale", "Ventre plat, respire avec l'abdomen, pas de CVC, orifices herniaires libres"),
        ("palp_paroi", "Palpation : Paroi Abdominale", "Souple globale, pas de défense ni de contracture"),
        ("palp_dlr", "Palpation : Douleur Provoquée", "Indolore dans les 4 quadrants, Murphy et MacBurney négatifs"),
        ("palp_foie", "Palpation : Foie", "Bord inférieur non palpable, pas d'hépatomégalie (flèche hépatique normale)"),
        ("palp_rate", "Palpation : Rate", "Non palpable (pas de splénomégalie)"),
        ("perc_abd", "Percussion Abdominale", "Tympanisme centromédian physiologique, matité déclive absente"),
        ("ausc_bha", "Auscultation : Bruits Hydro-Aériques", "Normaux, réguliers. Pas de souffle artériel abdominal"),
        ("tr_marge", "Examen Proctologique : Marge anale", "Saine, pas de fissure, pas d'hémorroïde externe"),
        ("tr_ampoule", "Toucher Rectal", "Ampoule rectale vide, prostate lisse et indolore (homme), pas de sang sur le doigtier"),
    ],
    "uro": [
        ("fosses_lomb", "Fosses Lombaires", "Inspection normale, pas de voussure"),
        ("contact_lomb", "Palpation : Contact Lombaire / Ballottement", "Négatif bilatéralement"),
        ("points_ureteraux", "Points Urétéraux", "Indolores"),
        ("globe_vesical", "Palpation Pelvienne", "Pas de globe vésical"),
        ("oge_femme", "OGE (Femme)", "Vulve d'aspect normal, sans lésion"),
        ("tv", "Toucher Vaginal (Femme)", "Col normal, culs-de-sac souples et indolores"),
        ("oge_homme", "OGE (Homme)", "Verge sans lésion, testicules en place, indolores, volume normal"),
        ("tr_prostate", "Toucher Rectal (Homme) : Prostate", "Taille normale, souple, symétrique, sillon médian conservé, indolore")
    ],
    "loco": [
        ("marche", "Marche et Posture", "Normale, sans claudication, pas de boiterie"),
        ("axes", "Axes des membres", "Normaux, pas de varus ni valgus pathologique"),
        ("art_insp", "Inspection articulaire", "Pas de rougeur, pas de tuméfaction, pas de déformation"),
        ("art_palp", "Palpation articulaire", "Température locale normale, pas de choc rotulien, pas d'épanchement"),
        ("art_mob_active", "Mobilité articulaire (Active)", "Amplitudes conservées et indolores"),
        ("art_mob_passive", "Mobilité articulaire (Passive)", "Normale et sans ressaut"),
        ("rachis_insp", "Rachis : Inspection", "Courbures normales (lordose cervicale, cyphose dorsale, lordose lombaire), pas de scoliose"),
        ("rachis_palp", "Rachis : Palpation", "Épineuses indolores, pas de contracture paravertébrale"),
        ("rachis_mobilite", "Rachis : Mobilité et Signes Radiculaires", "Souple, Schober normal, Lasègue et Léri négatifs, pas de point de Valleix"),
        ("muscles", "Examen Musculaire", "Trophicité normale, force 5/5, pas de myalgies"),
    ],
    "derm": [
        ("peau_couleur", "Peau : Coloration", "Normale, pas de pâleur, d'ictère ou de cyanose"),
        ("peau_trophicite", "Peau : Trophicité / Température / Hydratation", "Élastique, normotherme, bien hydratée, pas de pli cutané"),
        ("lesions_elem", "Lésions Élémentaires", "Absentes (pas de macule, papule, vésicule, bulle, ulcération, squame)"),
        ("lesions_topog", "Topographie des lésions", "N/A"),
        ("cheveux", "Phanères : Cheveux", "Aspect normal, pas d'alopécie, cuir chevelu sain"),
        ("ongles", "Phanères : Ongles", "Pas de modification de couleur, de surface ou de fragilité (pas d'onycholyse ou de leuconychie)"),
        ("muqueuses_orales", "Muqueuses Orales", "Saines, de coloration normale"),
        ("ganglions", "Aires Ganglionnaires", "Libres, pas d'adénopathie palpable"),
    ],
    "psych": [
        ("presentation", "Présentation / Tenue", "Tenue soignée et adaptée, hygiène conservée"),
        ("contact", "Contact / Mimique", "Contact facile, mimique concordante et expressive"),
        ("conscience", "Niveau de Conscience", "Vigilance normale, orienté(e) temporo-spatialement"),
        ("psychomoteur", "Activité Psychomotrice", "Pas de ralentissement ni d'agitation, pas de stéréotypies"),
        ("langage", "Langage", "Débit normal, cohérent, pas de logorrhée ni de mutisme"),
        ("pensee_cours", "Cours de la Pensée", "Fluide, pas de fuite des idées ni de barrage"),
        ("pensee_contenu", "Contenu de la Pensée / Délires", "Pas d'idées délirantes, pas de phobies ou d'obsessions prévalentes"),
        ("perceptions", "Perceptions / Hallucinations", "Absence d'hallucinations (auditives, visuelles, sensorielles)"),
        ("affectivite", "Affectivité (Humeur, Émotions)", "Euthymique, pas d'idées noires ou suicidaires, réactivité conservée"),
        ("fonctions_cogn", "Fonctions Cognitives", "Mémoire à court et long terme intactes, attention conservée, jugement critique présent"),
        ("sommeil_appetit", "Instincts (Sommeil, Appétit)", "Sommeil réparateur, appétit conservé, pas de trouble du comportement alimentaire"),
    ],
    "ent": [
        ("face_insp", "Face : Inspection", "Symétrique, sans lésion cutanée, pas d'œdème"),
        ("oreille_ext", "Oreille Externe et Tympan", "Pavillon indolore, CAE libre, tympan normal sans otorrhée"),
        ("audition", "Audition", "Acuité auditive bilatérale normale à la voix parlée/chuchotée"),
        ("fosse_nasale", "Fosses Nasales", "Perméables, sans rhinorrhée, muqueuse saine"),
        ("cav_buccale", "Cavité Buccale / Dents", "Dentition en bon état, langue et muqueuses saines"),
        ("oropharynx", "Oropharynx / Amygdales", "Amygdales non hypertrophiques, non inflammatoires, luette médiane"),
        ("cou_thyroide", "Cou et Thyroïde", "Glande thyroïde non augmentée de volume, non nodulaire, mobile à la déglutition"),
        ("cou_adp", "Aires Ganglionnaires Cervicales", "Absence d'adénopathie cervicale, sous-maxillaire, ou sus-claviculaire palpable"),
        ("oeil_annexes", "Œil - Annexes (Paupières, Conjonctives)", "Pas de ptosis, conjonctives rosées (pas d'anémie) et claires (pas d'ictère)"),
        ("oeil_visuel", "Acuité et Mobilité Visuelle", "Vision normale grossièrement, mouvements oculaires préservés dans les 9 axes"),
    ],
    "endo": [
        ("poids_taille", "Morphologie (Poids, Taille, IMC)", "Morphotype normal"),
        ("repartition_graisse", "Répartition des Graisses", "Homogène, pas de répartition facio-tronculaire (aspect cushingoïde)"),
        ("peau_vergetures", "Peau : Aspect et Vergetures", "Normale, pas de vergetures larges et pourpres, pas d'acanthosis nigricans"),
        ("pilosite", "Pilosité", "Répartition et abondance normales (pas d'hirsutisme ni de dépilation)"),
        ("thyroide_insp", "Thyroïde : Inspection", "Pas de goitre visible, cou symétrique"),
        ("thyroide_palp", "Thyroïde : Palpation", "Taille normale, pas de nodule, consistance élastique homogène"),
        ("thyroide_signes", "Signes de Dysthyroïdie", "Pas d'exophtalmie, de tremblement, de tachycardie, ni de frilosité/thermophobie"),
        ("seins_gyn", "Glandes mammaires / Gynécomastie", "Absence d'écoulement mamelonnaire ou de gynécomastie"),
        ("diabete_neuro", "Pied et Diabète : Neurologique", "Sensibilité au monofilament conservée (10g) et diapason normal, ROT présents"),
        ("diabete_vasc", "Pied et Diabète : Vasculaire", "Pouls pédieux et tibiaux postérieurs perçus symétriquement"),
    ],
    "hemato": [
        ("paleur", "Peau et Muqueuses : Pâleur", "Absente (conjonctives et muqueuses normalement colorées)"),
        ("hemato_cutane", "Syndrome Hémorragique Cutané", "Pas de pétéchies, purpura, ecchymoses ou hématomes"),
        ("hemato_muqueux", "Syndrome Hémorragique Muqueux", "Pas d'épistaxis, de gingivorragie spontanée ou de bulles hémorragiques intrabuccales"),
        ("adp_cervicales", "Adénopathies : Cervicales", "Absentes"),
        ("adp_axill_ing", "Adénopathies : Axillaires et Inguinales", "Absentes"),
        ("foie", "Hépatomégalie", "Absente"),
        ("rate", "Splénomégalie", "Absente"),
        ("hypertrophie_gingivale", "Hypertrophie Gingivale / Angines", "Absente"),
        ("os", "Douleurs Osseuses Provoquées", "Indolore à la percussion du sternum et des crêtes iliaques"),
    ]
}

# The default "general" exam gathers key aspects across systems:
exam_fields_templates["general"] = [
    ("etat_general", "Impression Globale / Etat Général", "Bon état général, patient conscient, coopérant, bien orienté"),
    ("hydratation_nutrition", "Hydratation et Nutrition", "Pas de pli de déshydratation, IMC dans les normes, pas d'oedèmes marginaux"),
    ("tete_cou", "Examen Tête et Cou", "Conjonctives rosées, pas d'ictère scléral, cavité buccale saine, cou souple, pas de goitre, pas d'ADP"),
    ("thoracique_resp", "Examen Pleuro-Pulmonaire", "Respiration calme, pas de tirage, murmure vésiculaire présent et symétrique bilatéralement, pas de bruits surajoutés"),
    ("cardio_vasc", "Examen Cardio-Vasculaire", "Bruits du cœur réguliers et bien frappés, pas de souffle, pouls périphériques perçus et symétriques"),
    ("abd_digestif", "Examen Abdominal", "Ventre souple, dépressible, indolore, pas de masse, foie et rate non palpables, orifices herniaires libres"),
    ("uro_genital", "Examen Uro-Génital", "Fosses lombaires libres, pas de globe vésical"),
    ("osteo_articulaire", "Examen Ostéo-Articulaire", "Articulations libres, sans signe inflammatoire, marche normale"),
    ("neuro_psych", "Examen Neurologique et Mental", "Force et sensibilité grossièrement conservées, ROT normaux, pas de signe méningé, discours cohérent"),
    ("cutane", "Examen Cutané", "Pas de lésion suspecte, pas de purpura, ongle sans déformation"),
]

# Provide fallback for all categories not specifically listed in dictionaries
with open("lib/features/observation/data/models/specialty_config.dart", "r") as f:
    content = f.read()

enum_match = re.search(r'enum MedicalSpecialty\s*{(.*?)}', content, re.DOTALL)
if not enum_match:
    print("Could not find enum!")
    exit(1)

raw_enums = enum_match.group(1).split(",")
specialties = [x.strip() for x in raw_enums if x.strip()]

new_block = "class SpecialtyConfigs {\n"

for spec in specialties:
    cat = "general"
    for c, specs in categories.items():
        if spec in specs:
            cat = c
            break
            
    fields = exam_fields_templates[cat]
    
    fields_str = ""
    for f_key, f_label, f_normal in fields:
        f_normal = f_normal.replace('"', '\\"') # escape double quotes just in case
        fields_str += f"""      ExamFieldConfig(
        key: '{f_key}',
        label: "{f_label}",
        normalText: "{f_normal}",
      ),
"""
    
    title_str = spec.capitalize()
    
    config_chunk = f"""  static const {spec} = SpecialtyFormConfig(
    specialty: MedicalSpecialty.{spec},
    title: '{title_str}',
    icon: Iconsax.health,
    commonSymptoms: [],
    examFields: [
{fields_str}    ],
  );

"""
    new_block += config_chunk

new_block += "  static const List<SpecialtyFormConfig> all = [\n"
for spec in specialties:
    new_block += f"    {spec},\n"
new_block += "  ];\n}"

parts = content.split("class SpecialtyConfigs {")
if len(parts) == 2:
    final_content = parts[0] + new_block
    with open("lib/features/observation/data/models/specialty_config.dart", "w") as f:
        f.write(final_content)
    print("Successfully updated specialty_config.dart with DEEP medical details.")
else:
    print("Failed to split content properly.")
