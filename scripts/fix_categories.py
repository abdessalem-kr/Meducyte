import json
import time
import os
import requests
import re

# 1. Groq Configuration
API_KEY = "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"
GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
MODEL_NAME = "llama-3.3-70b-versatile" # High quality medical categorization

INPUT_PATH = 'assets/data/algerian_drugs.json'
OUTPUT_PATH = 'assets/data/algerian_drugs_fixed.json'
CACHE_PATH = 'category_mapping_cache.json'
BATCH_SIZE = 50 

CATEGORIES = [
    "Cardiologie et Angéiologie",
    "Gastro-Entérologie",
    "Pneumologie",
    "Neurologie",
    "Psychiatrie",
    "Rhumatologie",
    "Urologie et Néphrologie",
    "Gynécologie",
    "Endocrinologie (Métabolisme)",
    "Infectiologie",
    "Cancérologie",
    "Dermatologie",
    "Ophtalmologie",
    "ORL",
    "Stomatologie",
    "Allergologie",
    "Anesthésiologie",
    "Hématologie",
    "Immunologie",
    "Autres"
]

def normalize_dci(name):
    """
    Cleans a DCI name by removing dosages, forms, and some salt details 
    to simplify categorization.
    """
    if not name: return ""
    # Remove dosages e.g. "500MG", "100 MG", "10% / 5 ML"
    cleaned = re.sub(r'[\d.,/]+\s*(MG|ML|G|UI|IU|GR|%|UNITE|UNITES|MICROGRAMMES|MCG)\b', '', name, flags=re.IGNORECASE)
    # Remove some extra parenthetical/bracketed info
    cleaned = re.sub(r'\[.*?\]|\(.*?\)', '', cleaned)
    # Remove common extra salt mentions that don't change category
    cleaned = re.sub(r'\b(EXPRIME|EN|POUR|DL|LYSINE|CHLORHYDRATE|PHOSPHATE|SULFATE|SODIQUE|POTASSIQUE)\b', '', cleaned, flags=re.IGNORECASE)
    # Clean up spaces/commas/slashes at ends
    cleaned = re.sub(r'[\s,/]+', ' ', cleaned).strip()
    return cleaned

def call_groq(prompt):
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    
    data = {
        "model": MODEL_NAME,
        "messages": [
            {"role": "system", "content": "You are a medical pharmacology expert. Categorize the following drug molecules accurately. Return ONLY a JSON object."},
            {"role": "user", "content": prompt}
        ],
        "response_format": { "type": "json_object" },
        "max_tokens": 2048
    }
    
    max_retries = 3
    for attempt in range(max_retries):
        try:
            response = requests.post(GROQ_URL, headers=headers, json=data, timeout=60)
            if response.status_code == 429:
                wait_time = (attempt + 1) * 10
                print(f"Groq Rate limited (429). Retrying in {wait_time}s...")
                time.sleep(wait_time)
                continue
            response.raise_for_status()
            result = response.json()
            
            if 'choices' in result and len(result['choices']) > 0:
                return result['choices'][0]['message']['content']
            return None
        except Exception as e:
            print(f"Request Error (Attempt {attempt+1}): {e}")
            time.sleep(2)
    return None

def fix_drug_categories():
    print("Loading drug database...")
    if not os.path.exists(INPUT_PATH):
        print(f"Error: {INPUT_PATH} not found.")
        return

    with open(INPUT_PATH, 'r', encoding='utf-8') as f:
        drugs = json.load(f)

    # Use cleaned DCI for categorization to reduce API calls
    unique_dcis = list({normalize_dci(drug['generic_name']) for drug in drugs if drug.get('generic_name')})
    unique_dcis = sorted([d for d in unique_dcis if d])
    
    category_mapping = {}
    if os.path.exists(CACHE_PATH):
        with open(CACHE_PATH, 'r', encoding='utf-8') as f:
            category_mapping = json.load(f)
        print(f"Loaded {len(category_mapping)} molecules from cache.")

    to_process = [m for m in unique_dcis if m not in category_mapping]
    total_to_process = len(to_process)
    print(f"Found {len(unique_dcis)} unique DCIs. {total_to_process} remaining to categorize.")

    if total_to_process > 0:
        i = 0
        while i < total_to_process:
            batch = to_process[i:i + BATCH_SIZE]
            print(f"Processing batch {i//BATCH_SIZE + 1}/{(total_to_process + BATCH_SIZE - 1)//BATCH_SIZE}...")
            
            molecule_list = "\n".join([f"- {m}" for m in batch])
            prompt = f"""
            Identify the core therapeutic category and a specific therapeutic class for these drug molecules.
            
            Allowed Categories (must be ONE of these):
            {", ".join(CATEGORIES)}
            
            Molecules:
            {molecule_list}
            
            Return a JSON object where EACH key is the molecule name EXACTLY as provided, and value is:
            {{
                "category": "One of the allowed categories",
                "therapeutic_class": "A specific class (e.g., 'Anti-hypertenseur', 'Antibiotique β-lactamine', 'Analgésique')"
            }}
            """
            
            result_text = call_groq(prompt)
            
            if result_text:
                try:
                    if "```json" in result_text:
                         result_text = result_text.split("```json")[1].split("```")[0].strip()
                    elif "```" in result_text:
                         result_text = result_text.split("```")[1].strip()
                    
                    batch_results = json.loads(result_text)
                    
                    # Robust parsing of various AI formats (list, dict, wrapped)
                    processed_batch = []
                    if isinstance(batch_results, list):
                         for item in batch_results:
                             mol = item.get('molecule') or item.get('name') or list(item.keys())[0]
                             category_mapping[mol] = item
                             processed_batch.append(mol)
                    elif isinstance(batch_results, dict):
                        if "molecules" in batch_results and isinstance(batch_results["molecules"], list):
                            for item in batch_results["molecules"]:
                                mol = item.get('molecule') or item.get('name')
                                category_mapping[mol] = item
                                processed_batch.append(mol)
                        else:
                            for mol, data in batch_results.items():
                                category_mapping[mol] = data
                                processed_batch.append(mol)
                    
                    with open(CACHE_PATH, 'w', encoding='utf-8') as f:
                        json.dump(category_mapping, f, ensure_ascii=False, indent=2)
                    
                    i += BATCH_SIZE
                    print(f"Successfully processed batch. Total molecules in cache: {len(category_mapping)}")
                    time.sleep(1) # Groq is very fast
                except Exception as e:
                    print(f"Parsing Error: {e}. Output was: {result_text[:200]}...")
                    time.sleep(2)
            else:
                print("No response. Retrying...")
                time.sleep(2)

    # Final Mapping
    print("Updating drug database with correct categories...")
    updated_count = 0
    for drug in drugs:
        gn = drug.get('generic_name')
        normalized_gn = normalize_dci(gn)
        
        data = category_mapping.get(normalized_gn) or category_mapping.get(gn)
        
        if data:
            drug['category'] = data.get('category', 'Autres')
            drug['therapeutic_class'] = data.get('therapeutic_class', 'Non documenté')
            updated_count += 1
        else:
            if not drug.get('category') or drug['category'] == 'Général':
                drug['category'] = 'Autres'

    with open(OUTPUT_PATH, 'w', encoding='utf-8') as f:
        json.dump(drugs, f, ensure_ascii=False, indent=2)
    
    with open(INPUT_PATH, 'w', encoding='utf-8') as f:
        json.dump(drugs, f, ensure_ascii=False, indent=2)

    print(f"Success! Final count: Updated {updated_count} drug entries in {INPUT_PATH}")

if __name__ == "__main__":
    fix_drug_categories()
