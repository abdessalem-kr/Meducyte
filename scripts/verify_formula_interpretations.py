import json
import os
import re
import sys
import time
import requests
from bs4 import BeautifulSoup
from concurrent.futures import ThreadPoolExecutor, as_completed

# Groq Configuration
API_KEY = "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"
GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
MODEL = "llama-3.3-70b-versatile"

DATA_PATH = "assets/data/medical_calculators.json"

def fetch_html(url):
    if not url:
        return ""
    try:
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        }
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')
        # Remove script/style
        for script in soup(["script", "style"]):
            script.decompose()
        # Clean text
        text = soup.get_text(separator='\n', strip=True)
        # Remove excessive blank lines
        text = re.sub(r'\n{3,}', '\n\n', text)
        return text[:6000] # Limit size to fit prompt cleanly
    except Exception as e:
        print(f"  [Fetch Error] {url}: {e}")
        return ""

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
    for attempt in range(3):
        try:
            response = requests.post(GROQ_URL, headers=headers, json=payload, timeout=30)
            if response.status_code == 200:
                return response.json()['choices'][0]['message']['content']
            elif response.status_code == 429:
                wait = (attempt + 1) * 30
                time.sleep(wait)
            else:
                time.sleep(2)
        except Exception as e:
            time.sleep(2)
    return None

def verify_calculator(calc):
    name = calc['name']
    url = calc.get('url', '')
    scoring_logic = calc.get('scoring_logic', [])
    current_formula = calc.get('formula', 'Sum of all items')
    
    # Leverages pre-trained clinical knowledge of Llama-3.3-70b-versatile for standard calculators
    source_content = f"Medical Calculator: {name}. Specialty: {calc.get('specialty', '')}. Formula: {current_formula}."

    system_prompt = """
    You are a clinical informatics consultant. Your task is to verify the calculation formula and extract/generate the clinical score interpretation ranges for the provided medical calculator based on standard clinical literature and the scoring logic items structure.

    Your output MUST be a valid JSON object with the following keys:
    {
      "formula": "Verified formula, e.g., 'Sum of all items' or specific mathematical formula in French/standard math terms.",
      "interpretations": [
        {
          "min": 0,
          "max": 3,
          "label": "Low risk / clinical description in French",
          "color": "green|orange|red"
        }
      ]
    }

    Rules:
    1. If the calculator is point-based (uses simple addition of scoring items), set the "formula" to "Sum of all items".
    2. Define standard clinical score interpretation ranges/tiers (min, max, label, color) based on standard clinical literature.
    3. Ensure interpretation labels are in professional French.
    4. Set the color field based on risk/severity level:
       - Low/normal: 'green'
       - Moderate/intermediate: 'orange'
       - High/severe: 'red'
    """

    user_prompt = f"""
    CALCULATOR NAME: {name}
    CURRENT FORMULA: {current_formula}
    CURRENT SCORING LOGIC ITEMS: {json.dumps(scoring_logic, ensure_ascii=False)[:2000]}
    
    Extract or construct the verified formula and interpretations list.
    """

    res_str = call_groq(system_prompt, user_prompt)
    if res_str:
        try:
            res_json = json.loads(res_str)
            if 'interpretations' in res_json:
                clean_interps = []
                for interp in res_json["interpretations"]:
                    min_val = interp.get("min")
                    max_val = interp.get("max")
                    if isinstance(min_val, str):
                        try:
                            if min_val.strip().lower() in ['infinity', 'inf', '+infini', 'infini']:
                                min_val = "Infinity"
                            elif min_val.strip().lower() in ['-infinity', '-inf', '-infini']:
                                min_val = "-Infinity"
                            else:
                                min_val = float(min_val)
                        except ValueError:
                            pass
                    if isinstance(max_val, str):
                        try:
                            if max_val.strip().lower() in ['infinity', 'inf', '+infini', 'infini']:
                                max_val = "Infinity"
                            elif max_val.strip().lower() in ['-infinity', '-inf', '-infini']:
                                max_val = "-Infinity"
                            else:
                                max_val = float(max_val)
                        except ValueError:
                            pass
                    interp["min"] = min_val
                    interp["max"] = max_val
                    clean_interps.append(interp)
                return {
                    "formula": res_json.get("formula", current_formula),
                    "interpretations": clean_interps
                }
        except Exception as e:
            print(f"  [JSON Parse Error] {name}: {e}")
    return None

def main():
    if not os.path.exists(DATA_PATH):
        print(f"File not found: {DATA_PATH}")
        return

    with open(DATA_PATH, 'r', encoding='utf-8') as f:
        data = json.load(f)

    print(f"Total calculators in database: {len(data)}")
    
    # Let's count how many have already been verified
    todo = []
    for c in data:
        if 'interpretations' not in c or not c['interpretations']:
            todo.append(c)

    print(f"Calculators needing verification: {len(todo)}")
    if not todo:
        print("All calculators are already verified!")
        return

    # Use ThreadPoolExecutor to run verification concurrently
    max_workers = 12
    print(f"Running verification with {max_workers} threads...")

    completed = 0
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        future_to_calc = {executor.submit(verify_calculator, calc): calc for calc in todo}
        for future in as_completed(future_to_calc):
            calc = future_to_calc[future]
            try:
                result = future.result()
                if result:
                    calc['formula'] = result['formula']
                    calc['interpretations'] = result['interpretations']
                    calc['verified'] = True
                    print(f"  [OK] Verified: {calc['name']} | Formula: {calc['formula']} | {len(calc['interpretations'])} ranges")
                else:
                    print(f"  [FAILED] {calc['name']}")
            except Exception as exc:
                print(f"  [ERROR] {calc['name']} generated an exception: {exc}")

            completed += 1
            if completed % 10 == 0 or completed == len(todo):
                # Save progress incrementally
                with open(DATA_PATH, 'w', encoding='utf-8') as f:
                    json.dump(data, f, ensure_ascii=False, indent=2)
                print(f"Progress saved: {completed}/{len(todo)} processed.")
                
            time.sleep(0.02) # Polite sleep between tasks

if __name__ == "__main__":
    main()
