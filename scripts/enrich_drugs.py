import json
import time
import os
import requests

# 1. Groq Configuration
API_KEY = "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"
GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
MODEL_NAME = "llama-3.3-70b-versatile"

INPUT_PATH = 'assets/data/algerian_drugs.json'
OUTPUT_PATH = 'assets/data/algerian_drugs_enriched.json'
CACHE_PATH = 'molecule_data_cache.json'
BATCH_SIZE = 25 

def call_groq(prompt):
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    
    data = {
        "model": MODEL_NAME,
        "messages": [
            {"role": "system", "content": "You are a medical pharmacology expert. Return a JSON object containing clinical info for EVERY molecule listed."},
            {"role": "user", "content": prompt}
        ],
        "response_format": { "type": "json_object" },
        "max_tokens": 4096
    }
    
    max_retries = 3
    for attempt in range(max_retries):
        try:
            response = requests.post(GROQ_URL, headers=headers, json=data, timeout=120)
            if response.status_code == 429:
                wait_time = (attempt + 1) * 10
                time.sleep(wait_time)
                continue
            response.raise_for_status()
            result = response.json()
            
            if 'choices' in result and len(result['choices']) > 0:
                return result['choices'][0]['message']['content']
            return None
        except Exception as e:
            time.sleep(2)
    return None

def update_drug_database():
    print("Loading JSON file...")
    if not os.path.exists(INPUT_PATH):
        print(f"Error: {INPUT_PATH} not found.")
        return

    with open(INPUT_PATH, 'r', encoding='utf-8') as f:
        drugs = json.load(f)

    unique_molecules = sorted(list({drug['generic_name'] for drug in drugs if drug.get('generic_name')}))
    
    molecule_data = {}
    if os.path.exists(CACHE_PATH):
        with open(CACHE_PATH, 'r', encoding='utf-8') as f:
            molecule_data = json.load(f)

    to_process = []
    for m in unique_molecules:
        if m not in molecule_data:
            to_process.append(m)
        else:
            data = molecule_data[m]
            if not data.get('indications') or len(data.get('indications')) == 0:
                to_process.append(m)

    total_to_process = len(to_process)
    print(f"Found {len(unique_molecules)} unique molecules. {total_to_process} need processing.")

    if total_to_process > 0:
        i = 0
        while i < total_to_process:
            batch = to_process[i:i + BATCH_SIZE]
            print(f"Processing batch {i//BATCH_SIZE + 1}/{(total_to_process + BATCH_SIZE - 1)//BATCH_SIZE}...")
            
            molecule_list_str = "\n".join([f"- {m}" for m in batch])
            prompt = f"""
            Provide clinical medical information in French for EACH molecule:
            {molecule_list_str}

            Return a JSON object:
            "MOLECULE_NAME": {{
                "indications": ["ind 1", "ind 2"],
                "contraindications": ["cont 1"],
                "side_effects": "Description",
                "mechanism_of_action": "Mécanisme"
            }}
            """
            
            result_text = call_groq(prompt)
            if result_text:
                try:
                    if "```json" in result_text:
                        result_text = result_text.split("```json")[1].split("```")[0].strip()
                    
                    batch_results = json.loads(result_text)
                    if len(batch_results) == 1 and 'molecules' in batch_results:
                        batch_results = batch_results['molecules']

                    for mol_name, data in batch_results.items():
                        molecule_data[mol_name] = data
                    
                    with open(CACHE_PATH, 'w', encoding='utf-8') as f:
                        json.dump(molecule_data, f, ensure_ascii=False, indent=2)
                    i += BATCH_SIZE
                    time.sleep(1)
                except:
                    time.sleep(2)
            else:
                time.sleep(2)

    for drug in drugs:
        gn = drug.get('generic_name')
        if gn in molecule_data:
            drug['indications'] = molecule_data[gn].get('indications', [])
            drug['contraindications'] = molecule_data[gn].get('contraindications', [])
            drug['side_effects'] = str(molecule_data[gn].get('side_effects', ''))
            drug['mechanism_of_action'] = str(molecule_data[gn].get('mechanism_of_action', ''))

    with open(OUTPUT_PATH, 'w', encoding='utf-8') as f:
        json.dump(drugs, f, ensure_ascii=False, indent=2)
    with open(INPUT_PATH, 'w', encoding='utf-8') as f:
         json.dump(drugs, f, ensure_ascii=False, indent=2)
    print(f"Success! Updated {INPUT_PATH}")

if __name__ == "__main__":
    update_drug_database()
