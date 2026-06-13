import os
import json
import time
import requests

API_KEY = "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"
URL = "https://api.groq.com/openai/v1/chat/completions"
MODEL = "qwen/qwen3-32b"

specialties = [
    'general',
    'cardiology',
    'neurology',
    'anesthesiereanimation',
    'anesthesiereanimationpediatrique',
    'biophysiquemedicale',
    'dermatologieetvenereologie',
    'diabetologieendocrinologieetmaladiesmetaboliques',
    'epidemiologieetmedecinepreventive',
    'hepatogastroenterologie',
    'hematologie',
    'gynecologieobstetrique',
    'infectiologie',
    'medecineinterne',
    'medecinelegaledroitmedicaletethique',
    'medecinenucleaireetimageriemoleculaire',
    'medecinedusport',
    'medecinedutravail',
    'medecinephysiqueetreadaptation',
    'nephrologie',
    'oncologiemedicale',
    'ophtalmologie',
    'orl',
    'pediatrie',
    'psychiatrie',
    'pedopsychiatrie',
    'pneumophtisiologie',
    'radiotherapieoncologie',
    'rhumatologie',
    'reanimationmedicale',
    'chirurgiegenerale',
    'chirurgiecardiaque',
    'chirurgiemaxillofaciale',
    'chirurgieneurologique',
    'chirurgieorthopediqueettraumatologie',
    'chirurgiepediatrique',
    'chirurgiethoracique',
    'chirurgieurologique',
    'chirurgievasculaire',
    'chirurgieplastiquereconstructriceesthetiqueetdebrulologie'
]

PROMPT_TEMPLATE = """
Tu es un expert médical chevronné et un professeur de médecine. Génère des guides cliniques de pathologies pour la spécialité médicale : "{specialty}".
Renvoie un tableau JSON contenant exactement 2 pathologies majeures, courantes ou urgentes de cette spécialité.

IMPORTANT : Évite ABSOLUMENT de générer des pathologies qui existent déjà dans cette liste : {existing_pathologies}.
Nous voulons de NOUVELLES pathologies distinctes et pertinentes.

Chaque pathologie doit être extrêmement complète et détaillée sur le plan clinique. Évite les réponses courtes de quelques mots. 
Chaque pathologie doit respecter EXACTEMENT la structure JSON suivante :
[
  {{
    "name": "Nom complet de la pathologie en Français (ex: Infarctus du myocarde)",
    "description": "Description médicale détaillée de la physiopathologie et de la présentation clinique typique.",
    "redFlags": [
      "Drapeau rouge 1 détaillé avec contexte clinique (ex: Douleur constrictive rétro-sternale irradiant vers la mâchoire gauche prolongée > 20 minutes)",
      "Drapeau rouge 2 détaillé avec contexte clinique",
      "Drapeau rouge 3 détaillé",
      "Drapeau rouge 4 détaillé",
      "Drapeau rouge 5 détaillé"
    ],
    "scores": [
      {{
        "name": "Nom officiel du score clinique ou classification de référence (ex: Classification de Killip)",
        "description": "Explication claire de ce que mesure le score et son intérêt clinique.",
        "criteria": [
          "Critère clinique 1 avec points (ex: Classe I: Pas d'insuffisance cardiaque clinique (+0))",
          "Critère clinique 2 avec points (ex: Classe II: Râles crépitants aux bases, galop B3 (+1))",
          "Critère clinique 3 avec points (ex: Classe III: OEdème aigu du poumon clinique (+2))",
          "Critère clinique 4 avec points (ex: Classe IV: Choc cardiogénique clinique (+3))"
        ],
        "interpretation": "Guide d'interprétation précis et complet de la somme des points."
      }}
    ],
    "focusedExam": [
      {{
        "title": "Titre complet de l'examen clinique ciblé (ex: Examen cardiovasculaire et pulmonaire)",
        "steps": [
          {{
            "action": "Action clinique ou geste d'examen concret et précis à réaliser (ex: Auscultation pulmonaire bilatérale comparative)",
            "interpretation": "Interprétation clinique approfondie et détaillée de ce que signifie la présence ou l'absence du signe (ex: La présence de râles crépitants bilatéraux soufflant vers les sommets évoque fortement une surcharge alvéolaire de type OAP secondaire à une insuffisance ventriculaire gauche)"
          }},
          {{
            "action": "Autre action d'examen concrète (ex: Recherche de signes d'insuffisance ventriculaire droite comme une turgescence jugulaire ou reflux hépato-jugulaire)",
            "interpretation": "Interprétation clinique approfondie et détaillée"
          }}
        ]
      }}
    ],
    "immediateManagement": [
      "Mesure d'urgence 1 détaillée (ex: Repos strict au lit, position demi-assise pour réduire le retour veineux et soulager la dyspnée)",
      "Mesure d'urgence 2 détaillée (ex: Oxygénothérapie nasale visant une saturation > 90% pour corriger l'hypoxie)",
      "Mesure d'urgence 3 détaillée",
      "Mesure d'urgence 4 détaillée",
      "Mesure d'urgence 5 détaillée"
    ],
    "differentialDiagnosis": [
      "Diagnostic différentiel 1 avec son élément de distinction",
      "Diagnostic différentiel 2 avec son élément de distinction",
      "Diagnostic différentiel 3 avec son élément de distinction"
    ]
  }}
]

IMPORTANT :
1. Réponds UNIQUEMENT avec le JSON valide, sans aucune phrase d'introduction ni de conclusion, sans aucun bloc de code markdown. Ton texte doit commencer directement par `[` et se terminer par `]`.
2. Tout le texte doit être rédigé dans un style médical professionnel et en Français correct.
3. Si aucun score clinique officiel n'existe pour une pathologie, tu peux inclure un score clinique plus général ou laisser la liste "scores" vide [].
4. Assure-toi que les actions d'examen ("focusedExam") sont très détaillées, explicatives et didactiques pour aider les étudiants en médecine et les internes.
"""

def clean_json_string(response_text):
    if "</think>" in response_text:
        response_text = response_text.split("</think>")[-1]
    text = response_text.strip()
    if text.startswith("```json"):
        text = text[7:]
    elif text.startswith("```"):
        text = text[3:]
    if text.endswith("```"):
        text = text[:-3]
    return text.strip()

def is_high_quality(p):
    # Check red flags count
    if len(p.get("redFlags", [])) < 3:
        return False
    # Check description length
    if len(p.get("description", "")) < 50:
        return False
    # Check immediate management count
    if len(p.get("immediateManagement", [])) < 3:
        return False
    # Check focused exam steps
    focused_exam = p.get("focusedExam", [])
    if not focused_exam:
        return False
    steps = focused_exam[0].get("steps", [])
    if not steps:
        return False
    # If all checks pass, it's high quality
    return True

def process_specialty(specialty):
    path = f"assets/data/pathologies/{specialty}.json"
    
    # Load and filter existing pathologies
    existing_data = []
    if os.path.exists(path):
        try:
            with open(path, "r", encoding="utf-8") as f:
                raw_data = json.load(f)
                if isinstance(raw_data, list):
                    # Filter out low-quality ones
                    existing_data = [p for p in raw_data if is_high_quality(p)]
                    removed_count = len(raw_data) - len(existing_data)
                    if removed_count > 0:
                        print(f"[{specialty}] Removed {removed_count} low-quality pathologies.")
        except Exception:
            existing_data = []

    current_count = len(existing_data)
    if current_count >= 15:
        print(f"[{specialty}] Already has {current_count} high-quality pathologies. Skipping.")
        return True

    # Determine existing names to avoid duplicates
    existing_names = [p.get("name", "") for p in existing_data]
    existing_names_str = ", ".join([f'"{name}"' for name in existing_names if name])
    
    print(f"[{specialty}] Generating 2 new high-quality pathologies (Current count: {current_count}/15)...")
    prompt = PROMPT_TEMPLATE.format(specialty=specialty, existing_pathologies=existing_names_str)
    
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    
    data = {
        "model": MODEL,
        "messages": [
            {"role": "user", "content": prompt}
        ],
        "temperature": 0.2,
        "max_tokens": 4096
    }
    
    # Retry loop with backoff
    for attempt in range(5):
        try:
            response = requests.post(URL, headers=headers, json=data, timeout=60)
            if response.status_code == 200:
                result = response.json()
                raw_content = result["choices"][0]["message"]["content"]
                json_str = clean_json_string(raw_content)
                
                # Verify valid JSON
                new_pathologies = json.loads(json_str)
                if not isinstance(new_pathologies, list):
                    raise ValueError("API did not return a list")
                
                # Filter out any exact duplicate names that the model might have returned anyway
                filtered_new = []
                for p in new_pathologies:
                    if p.get("name") not in existing_names:
                        filtered_new.append(p)
                        existing_names.append(p.get("name"))
                
                combined_data = existing_data + filtered_new
                
                # Ensure directory exists
                os.makedirs(os.path.dirname(path), exist_ok=True)
                with open(path, "w", encoding="utf-8") as f:
                    json.dump(combined_data, f, ensure_ascii=False, indent=2)
                
                print(f"[{specialty}] Saved batch. New total count: {len(combined_data)} pathologies.")
                return len(combined_data) >= 15
            elif response.status_code == 429:
                print(f"Rate limit hit (429) for {specialty}. Sleeping 60 seconds before retry...")
                time.sleep(60)
            else:
                print(f"Error calling API for {specialty}: {response.status_code} - {response.text}")
                time.sleep(5)
        except Exception as e:
            print(f"Attempt {attempt+1} failed for {specialty}: {e}")
            time.sleep(5)
            
    return False

def main():
    while True:
        completed = True
        for spec in specialties:
            # Check how many high quality pathologies are in this spec
            path = f"assets/data/pathologies/{spec}.json"
            count = 0
            if os.path.exists(path):
                try:
                    with open(path, "r", encoding="utf-8") as f:
                        data = json.load(f)
                        count = sum(1 for p in data if is_high_quality(p))
                except Exception:
                    pass
            
            if count < 15:
                completed = False
                process_specialty(spec)
                time.sleep(30)  # Space out API calls to prevent 429s (qwen/qwen3-32b TPM limit)
        
        if completed:
            print("All specialties have at least 15 high-quality pathologies!")
            break
        else:
            print("Finished one full pass. Checking for remaining specialties...")
            time.sleep(10)

if __name__ == "__main__":
    main()
