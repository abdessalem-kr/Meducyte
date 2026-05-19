import pandas as pd
import json
import os

# Configuration
EXCEL_FILE = "NOMENCLATURE-VERSION-FEVRIER-2026-.xlsx"
OUTPUT_FILE = "assets/data/algerian_drugs.json"

# Therapeutic Categories based on the 2-digit prefix in the CODE column
CATEGORIES = {
    "01": "Allergologie",
    "02": "Anesthésiologie",
    "03": "Antalgiques / Antispasmodiques",
    "04": "Antibactériens / Antibiotiques",
    "05": "Anti-inflammatoires",
    "06": "Cardiologie / Angéiologie",
    "07": "Dermatologie",
    "08": "Endocrinologie / Métabolisme",
    "09": "Gastro-Entéro-Hépatologie",
    "10": "Gynécologie / Obstétrique",
    "11": "Hématologie",
    "12": "Infectiologie / Parasitologie",
    "13": "Neurologie / Psychiatrie",
    "14": "Ophtalmologie",
    "15": "Oto-rhino-laryngologie (ORL)",
    "16": "Pneumologie",
    "17": "Stomatologie",
    "18": "Urologie / Néphrologie",
    "19": "Antinéoplasiques / Cancérologie",
    "20": "Immunologie",
    "21": "Produits de contraste",
    "22": "Divers / Nutrition",
}

# Clinical Enrichment Data for the most frequent DCIs
ENRICHMENT_DATA = {
    "PARACETAMOL": {
        "indications": ["Douleurs d'intensité légère à modérée", "États fébriles (fièvre)", "Maux de tête", "Douleurs dentaires"],
        "contraindications": ["Insuffisance hépatocellulaire sévère", "Hypersensibilité au paracétamol", "Maladies graves du foie"],
        "side_effects": "Rarement : réactions cutanées, allergiques. En cas de surdosage : toxicité hépatique grave.",
        "mechanism_of_action": "Antalgique et antipyrétique. Agit principalement par inhibition de la synthèse des prostaglandines dans le système nerveux central."
    },
    "IBUPROFENE": {
        "indications": ["Douleurs inflammatoires", "Rhumatismes", "Céphalées", "Règles douloureuses", "Fièvre"],
        "contraindications": ["Ulcère gastroduodénal en évolution", "Insuffisance rénale ou hépatique sévère", "Grossesse (à partir du 6ème mois)", "Antécédents d'asthme déclenchés par AINS"],
        "side_effects": "Troubles digestifs (nausées, gastralgies), risque d'ulcère, réactions allergiques, vertiges.",
        "mechanism_of_action": "Anti-inflammatoire non stéroïdien (AINS). Inhibe les cyclo-oxygénases (COX-1 et COX-2), bloquant ainsi la synthèse des prostaglandines."
    },
    "AMOXICILLINE": {
        "indications": ["Infections ORL (otite, sinusite)", "Infections respiratoires (bronchite, pneumonie)", "Infections urinaires", "Éradication d'H. pylori"],
        "contraindications": ["Allergie aux bétalactamines (pénicillines, céphalosporines)", "Mononucléose infectieuse (risque d'éruption cutanée)"],
        "side_effects": "Diarrhée, nausées, éruptions cutanées, candidose, troubles digestifs légers.",
        "mechanism_of_action": "Antibiotique bactéricide de la famille des aminopénicillines. Inhibe la synthèse de la paroi bactérienne."
    },
    "METFORMINE": {
        "indications": ["Diabète de type 2 (non insulinodépendant)", "Surcharge pondérale associée au diabète", "Syndrome des ovaires polykystiques (hors AMM)"],
        "contraindications": ["Insuffisance rénale sévère", "Acidose métabolique aiguë", "Insuffisance cardiaque instable", "Alcoolisme chronique"],
        "side_effects": "Troubles digestifs (diarrhée, nausées) surtout en début de traitement, goût métallique, rare acidose lactique.",
        "mechanism_of_action": "Antidiabétique biguanide. Réduit la production hépatique de glucose, augmente la sensibilité à l'insuline et retarde l'absorption intestinale du glucose."
    },
    "ATORVASTATINE": {
        "indications": ["Hypercholestérolémie primaire", "Prévention des événements cardiovasculaires", "Réduction du cholestérol LDL et des triglycérides"],
        "contraindications": ["Affection hépatique évolutive", "Grossesse et allaitement", "Augmentation inexpliquée des transaminases hépatiques"],
        "side_effects": "Myalgies (douleurs musculaires), troubles digestifs (constipation, gaz), céphalées, fatigue, hyperglycémie.",
        "mechanism_of_action": "Inhibiteur de l'HMG-CoA réductase (statine). Bloque la synthèse hépatique du cholestérol et augmente le captage du LDL sanguin."
    },
    "VALSARTAN": {
        "indications": ["Hypertension artérielle", "Insuffisance cardiaque chronique", "Post-infarctus du myocarde stable"],
        "contraindications": ["Insuffisance hépatique sévère", "Grossesse (2ème et 3ème trimestres)", "Sténose biliaire", "Association avec l'aliskiren chez les patients diabétiques"],
        "side_effects": "Sensations vertigineuses, hypotension, fatigue, toux (rare), troubles de la fonction rénale.",
        "mechanism_of_action": "Antagoniste des récepteurs de l'angiotensine II (ARA II). Provoque une vasodilatation et réduit la pression artérielle en bloquant le récepteur AT1."
    },
    "DICLOFENAC": {
        "indications": ["Rhumatismes inflammatoires chroniques", "Douleurs aiguës (radiculalgies, coliques néphrétiques)", "Arthrose", "Migraine aiguë"],
        "contraindications": ["Ulcère gastro-intestinal", "Insuffisance cardiaque sévère", "Grossesse (à partir du 6ème mois)", "Insuffisance rénale ou hépatique sévère"],
        "side_effects": "Troubles gastro-intestinaux, risque d'ulcère, céphalées, vertiges, réactions cutanées, risque cardiovasculaire.",
        "mechanism_of_action": "Anti-inflammatoire non stéroïdien (AINS) puissant. Inhibe la synthèse des prostaglandines par blocage des COX."
    },
    "AMLODIPINE": {
        "indications": ["Hypertension artérielle", "Angor (angine de poitrine stable)", "Angor vasospastique (Prinzmetal)"],
        "contraindications": ["Hypotension sévère", "Choc cardiogénique", "Sténose aortique cliniquement significative", "Insuffisance cardiaque instable après infarctus"],
        "side_effects": "Edèmes des chevilles, céphalées, bouffées de chaleur, palpitations, fatigue, somnolence.",
        "mechanism_of_action": "Inhibiteur calcique de la famille des dihydropyridines. Relâche les muscles lisses vasculaires et dilate les artères coronaires."
    },
    "GLIMEPIRIDE": {
        "indications": ["Diabète de type 2 lorsque le régime et l'exercice sont insuffisants"],
        "contraindications": ["Diabète de type 1", "Acidocétose diabétique", "Insuffisance rénale ou hépatique sévère", "Grossesse / Allaitement"],
        "side_effects": "Hypoglycémie (principal risque), troubles visuels transitoires, troubles digestifs, réactions allergiques.",
        "mechanism_of_action": "Sulfamide hypoglycémiant. Stimule la libération d'insuline par les cellules bêta du pancréas."
    },
    "RISPERIDONE": {
        "indications": ["Schizophrénie", "Épisodes maniaques modérés à sévères (bipolaires)", "Agressivité persistante dans la maladie d'Alzheimer", "Troubles sévères du comportement chez l'enfant"],
        "contraindications": ["Hypersensibilité à la rispéridone", "Prudence chez les patients avec troubles cardiovasculaires ou parkinsonisme"],
        "side_effects": "Somnolence, prise de poids, syndrome extrapyramidal (tremblements, rigidité), insomnie, anxiété, hyperprolactinémie.",
        "mechanism_of_action": "Antipsychotique atypique. Antagoniste sélectif monoaminergique avec forte affinité pour les récepteurs sérotoninergiques 5HT2 et dopaminergiques D2."
    },
    "CELECOXIB": {
        "indications": ["Arthrose", "Polyarthrite rhumatoïde", "Spondylarthrite ankylosante"],
        "contraindications": ["Ulcère gastrique actif", "Insuffisance cardiaque sévère", "Antécédents d'AVC ou d'infarctus", "Allergie aux sulfamides"],
        "side_effects": "Troubles digestifs, œdèmes périphériques, risque cardiovasculaire (thromboses), hypertension.",
        "mechanism_of_action": "Inhibiteur sélectif de la cyclo-oxygénase-2 (COX-2). Réduit l'inflammation et la douleur avec moins de toxicité gastrique que les AINS non sélectifs."
    },
    "PREGABALINE": {
        "indications": ["Douleurs neuropathiques périphériques et centrales", "Épilepsie (traitement adjuvant des crises partielles)", "Trouble anxieux généralisé"],
        "contraindications": ["Hypersensibilité à la prégabaline", "Insuffisance respiratoire (chez patients à risque)", "Grossesse (sauf nécessité absolue)"],
        "side_effects": "Somnolence, vertiges, œdème des membres, prise de poids, confusion, troubles de la vision.",
        "mechanism_of_action": "Analogue du GABA. Se lie à une sous-unité des canaux calciques voltage-dépendants dans le SNC, réduisant la libération de neurotransmetteurs excitateurs."
    },
    "LEVETIRACETAM": {
        "indications": ["Épilepsie (crises partielles avec ou sans généralisation)", "Crises myocloniques de l'adulte", "Crises tonico-cloniques généralisées primaires"],
        "contraindications": ["Hypersensibilité au lévétiracétam ou aux dérivés de la pyrrolidone"],
        "side_effects": "Somnolence, fatigue, maux de tête, irritabilité, agressivité, sensations vertigineuses, anorexie.",
        "mechanism_of_action": "Anticonvulsivant. Mécanisme unique lié à la protéine vésiculaire synaptique SV2A, modulant la libération des neurotransmetteurs."
    },
    "METRONIDAZOLE": {
        "indications": ["Infections à germes anaérobies", "Amibiase", "Giardiase", "Trichomonase urogénitale", "Vaginites non spécifiques"],
        "contraindications": ["Hypersensibilité aux imidazolés", "Consommation d'alcool (risque d'effet antabuse)"],
        "side_effects": "Troubles digestifs (nausées, goût métallique), céphalées, vertiges, rare coloration brune des urines.",
        "mechanism_of_action": "Antibiotique et antiparasitaire du groupe des nitro-imidazolés. Inhibe la synthèse des acides nucléiques en rompant l'ADN."
    },
    "PHLOROGLUCINOL": {
        "indications": ["Spasmes douloureux digestifs (colopathie)", "Coliques néphrétiques (douleurs urinaires)", "Douleurs gynécologiques (dysménorrhée)"],
        "contraindications": ["Hypersensibilité au phloroglucinol"],
        "side_effects": "Exceptionnellement : réactions cutanées allergiques (urticaire, prurit).",
        "mechanism_of_action": "Antispasmodique musculotrope. Relâche les fibres musculaires lisses et calme le spasme sans effet atropinique."
    },
    "IRBESARTAN": {
        "indications": ["Hypertension artérielle essentielle", "Néphropathie diabétique chez les hypertendus de type 2"],
        "contraindications": ["Grossesse (2ème et 3ème trimestres)", "Insuffisance hépatique sévère", "Association avec l'aliskiren chez les patients insuffisants rénaux"],
        "side_effects": "Fatigue, vertiges, nausées, hyperkaliémie (augmentation du potassium), élévation de la créatinine.",
        "mechanism_of_action": "Antagoniste des récepteurs de l'angiotensine II (ARA II). Bloque sélectivement les récepteurs AT1 pour induire une vasodilatation."
    },
    "ROSUVASTATINE": {
        "indications": ["Hypercholestérolémie", "Prévention des événements cardiovasculaires", "Hypercholestérolémie familiale"],
        "contraindications": ["Maladie hépatique évolutive", "Insuffisance rénale sévère", "Grossesse et allaitement", "Myopathie"],
        "side_effects": "Myalgies, céphalées, vertiges, constipation, nausées, fatigue, risque de diabète.",
        "mechanism_of_action": "Statine puissante. Inhibe spécifiquement l'HMG-CoA réductase hépatique pour réduire drastiquement le cholestérol LDL."
    }
}

def clean_name(name):
    if not isinstance(name, str): return ""
    return name.strip()

def main():
    if not os.path.exists(EXCEL_FILE):
        print(f"Error: {EXCEL_FILE} not found.")
        return

    print(f"Reading {EXCEL_FILE}...")
    df = pd.read_excel(EXCEL_FILE)

    # Find the header row (contains 'Dénomination Commune Internationale' or similar)
    header_row = 0
    for i, row in df.iterrows():
        if any('COMMUNE' in str(cell).upper() for cell in row):
            header_row = i
            break
    
    df.columns = df.iloc[header_row]
    df = df.iloc[header_row+1:].reset_index(drop=True)

    # Clean column names
    df.columns = [str(c).strip() for c in df.columns]
    
    # Required columns (based on previous analysis)
    # DCI = 'Dénomination Commune Internationale'
    # CODE = 'CODE'
    # NOM = 'NOM DE MARQUE'
    # FORME = 'FORME'
    # DOSAGE = 'DOSAGE'
    # COND = 'CONDITIONNEMENT'
    # LABO = 'LABORATOIRE'

    drugs = []
    for i, row in df.iterrows():
        code = str(row.get('CODE', '')).strip()
        if not code or code == 'nan': continue
        
        name = clean_name(row.get('NOM DE MARQUE', ''))
        generic_name = clean_name(row.get('Dénomination Commune Internationale', ''))
        dosage = clean_name(row.get('DOSAGE', ''))
        forme = clean_name(row.get('FORME', ''))
        cond = clean_name(row.get('CONDITIONNEMENT', ''))
        labo = clean_name(row.get('LABORATOIRE', ''))
        
        if not name or not generic_name: continue

        # Normalization for enrichment check
        dci_norm = generic_name.upper().split('/')[0].split('+')[0].strip()
        # Handle some variations
        if "DICLOFENAC" in dci_norm: dci_norm = "DICLOFENAC"
        if "METFORMINE" in dci_norm: dci_norm = "METFORMINE"
        if "ATORVASTATINE" in dci_norm: dci_norm = "ATORVASTATINE"
        if "VALSARTAN" in dci_norm: dci_norm = "VALSARTAN"
        if "IRBESARTAN" in dci_norm: dci_norm = "IRBESARTAN"
        if "ROSUVASTATINE" in dci_norm: dci_norm = "ROSUVASTATINE"

        # Determine category and therapeutic class
        cat_key = code[:2]
        category = CATEGORIES.get(cat_key, "Autres")

        # Clinical enrichment
        enrichment = ENRICHMENT_DATA.get(dci_norm, {
            "indications": [],
            "contraindications": [],
            "side_effects": "",
            "mechanism_of_action": ""
        })

        drugs.append({
            "id": f"dz-{i}",
            "name": name,
            "generic_name": generic_name,
            "drug_class": f"{labo} - {forme} ({cond})",
            "therapeutic_class": category,
            "category": category,
            "indications": enrichment["indications"],
            "contraindications": enrichment["contraindications"],
            "dosage": dosage,
            "side_effects": enrichment["side_effects"],
            "mechanism_of_action": enrichment["mechanism_of_action"]
        })

    print(f"Processed {len(drugs)} drugs.")
    
    # Create directory if needed
    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
    
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(drugs, f, ensure_ascii=False, indent=2)
    
    print(f"Saved to {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
