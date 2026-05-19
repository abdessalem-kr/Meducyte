import json
import os
import requests
import time
from bs4 import BeautifulSoup

# Groq Configuration
API_KEY = "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"
GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
MODEL = "llama-3.3-70b-versatile"

DATA_PATH = "/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/assets/data/medical_calculators.json"

def fetch_html(url):
    try:
        response = requests.get(url, timeout=15)
        response.raise_for_status()
        # Clean up some boilerplate
        soup = BeautifulSoup(response.text, 'html.parser')
        # Remove scripts and styles
        for script in soup(["script", "style"]):
            script.decompose()
        return soup.get_text(separator='\n', strip=True)
    except Exception as e:
        print(f"  [Fetch Error] {e}")
        return None

def call_groq(system_prompt, user_prompt):
    payload = {
        "model": MODEL,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ],
        "temperature": 0.1,
        "response_format": {"type": "json_object"}
    }
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    for attempt in range(5):
        try:
            response = requests.post(GROQ_URL, headers=headers, json=payload, timeout=60)
            if response.status_code == 200:
                return response.json()['choices'][0]['message']['content']
            elif response.status_code == 429:
                wait = (attempt + 1) * 60 
                print(f"  [Rate Limit] Cooling down... {wait}s")
                time.sleep(wait)
            else:
                return None
        except Exception as e:
            print(f"  [Exception] {e}")
            time.sleep(10)
    return None

def audit_calculator(calc):
    name = calc['name']
    url = calc['url']
    schema = calc.get('schema', {})
    
    print(f"Step 1/2: Fetching source data from {url}...")
    source_content = fetch_html(url)
    if not source_content:
        print(f"  [SKIP] Could not fetch source for {name}")
        return False

    # System Prompt for medical precision using 'json' format
    system_prompt = """
    You are a Senior Clinical Informatics Consultant. Your task is to audit and perfect a medical calculator schema based STIRCTLY on the provided Medicalcul source text.
    You MUST provide your output in a valid 'json' format.
    
    GUIDELINES:
    1. SOURCE VALIDATION: Analyze the 'Source Content' to understand the exact clinical logic, points, and interpretations used by Medicalcul.
    2. CONVERT DATA: If criteria are 'static', extract the logic from the source and convert to 'radio', 'checkbox', or 'numeric'.
    3. CLINICAL LABELS: Replace generic labels like 'Criteria 1', 'Option 0' with the EXACT terminology from the source (e.g., 'Fréquence cardiaque', 'Douleur thoracique').
    4. MEDICAL ACCURACY: Ensure point values and risk ranges match the source perfectly.
    5. FRENCH CONTEXT: Provide a professional clinical 'interpretation_text' in French (2-3 sentences), summarizing the utility of the tool according to the source.
    
    REQUIRED 'json' STRUCTURE:
    {
      "improved_schema": {
        "interpretation_text": "French clinical context...",
        "criteria": [
          {"label": "Precise clinical label", "type": "radio|checkbox|numeric", "points": int, "options": [{"label": "precise label", "points": int}]}
        ],
        "interpretations": [
          {"min": int, "max": int, "label": "Professional result label", "color": "green|orange|red"}
        ],
        "ai_audited": true,
        "source_grounded": true
      }
    }
    """
    
    user_prompt = f"""
    SOURCE CONTENT FROM MEDICALCUL:
    ---
    {source_content[:4000]}  # Truncate to avoid context window issues
    ---
    
    CURRENT APP SCHEMA:
    {json.dumps(schema, ensure_ascii=False)}
    
    TASK: Verify and improve the schema based on the SOURCE CONTENT.
    """

    print(f"Step 2/2: Auditing with Groq AI...")
    result_str = call_groq(system_prompt, user_prompt)
    if result_str:
        try:
            result_json = json.loads(result_str)
            if result_json.get('improved_schema'):
                calc['schema'] = result_json['improved_schema']
                print(f"  [SUCCESS] {name} is now source-grounded and AI-Verfied.")
                return True
        except:
            print(f"  [FAIL] Failed to parse JSON for {name}")
    return False

def main():
    if not os.path.exists(DATA_PATH): return
    with open(DATA_PATH, 'r', encoding='utf-8') as f:
        data = json.load(f)

    todo = []
    for cat in data:
        for calc in cat['calculators']:
            schema = calc.get('schema', {})
            # Only audit if not marked as source_grounded
            if not schema.get('source_grounded'):
                todo.append(calc)

    print(f"Starting source-grounded audit for {len(todo)} tools.")
    
    for i, calc in enumerate(todo):
        success = audit_calculator(calc)
        
        if success:
            with open(DATA_PATH, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
        
        # Stability gap
        time.sleep(30) 
        
        if (i+1) % 5 == 0:
            print(f"Audit Status: {i+1} tools processed.")

if __name__ == "__main__":
    main()
