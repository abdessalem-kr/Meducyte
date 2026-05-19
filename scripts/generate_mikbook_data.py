import os
import json
import argparse
from typing import List, Dict
import requests

# Define the Specialties as per MedicalSpecialty enum in specialty_config.dart
SPECIALTIES = [
    "general", "cardiology", "neurology", "anesthesiereanimation", 
    "dermatologieetvenereologie", "diabetologieendocrinologieetmaladiesmetaboliques",
    "hepatogastroenterologie", "hematologie", "gynecologieobstetrique",
    "infectiologie", "medecineinterne", "nephrologie", "oncologiemedicale",
    "ophtalmologie", "orl", "pediatrie", "psychiatrie", "pneumophtisiologie",
    "rhumatologie", "urologie", "chirurgiegenerale"
]

SCHEMA_INSTRUCTIONS = """
You must output a JSON array of objects follows this exact schema:
[
  {
    "name": "Pathology Name (French)",
    "description": "Short description (French)",
    "redFlags": ["List of warning signs"],
    "scores": [
      {
        "name": "Score Name (e.g. qSOFA)",
        "description": "What it measures",
        "criteria": ["Criterion 1", "Criterion 2"],
        "interpretation": "Point threshold meaning"
      }
    ],
    "focusedExam": [
      {
        "title": "Exam Step Group (e.g. Auscultation)",
        "steps": [
          { "action": "What to do", "interpretation": "What it means" }
        ]
      }
    ],
    "immediateManagement": ["Step 1", "Step 2"],
    "differentialDiagnosis": ["Alt 1", "Alt 2"]
  }
]
"""

class MikbookGenerator:
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.url = "https://api.groq.com/openai/v1/chat/completions"
        self.headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }

    def generate_for_specialty(self, specialty: str):
        print(f"Generating pathologies for: {specialty}...")
        
        prompt = f"""
        Act as a senior medical professor and expert in the 'Mikbook 4th Edition' (French medical reference).
        Generate a list of the most important clinical pathologies (Items) for the specialty: {specialty}.
        
        For each pathology, provide high-yield internship-level clinical pearls including:
        1. Pathognomonic signs during physical examination.
        2. Clinical scores (e.g. NYHA, Wells, NIHSS, qSOFA, etc.).
        3. Red flags that an intern must not miss.
        4. Immediate 'Conduite à tenir' (Management) as taught in Mikbook.
        
        {SCHEMA_INSTRUCTIONS}
        
        IMPORTANT: Use French medical terminology as it appears in Mikbook.
        Return ONLY the raw JSON array. No markdown, no explanations.
        """

        payload = {
            "model": "llama-3.3-70b-versatile",
            "messages": [{"role": "user", "content": prompt}],
            "temperature": 0.2,
            "response_format": {"type": "json_object"}
        }

        try:
            response = requests.post(self.url, headers=self.headers, json=payload)
            response.raise_for_status()
            content = response.json()['choices'][0]['message']['content']
            
            # The API might return {"pathologies": [...]} or just the array
            data = json.loads(content)
            if isinstance(data, dict) and len(data) == 1:
                key = list(data.keys())[0]
                data = data[key]
            
            return data
        except Exception as e:
            print(f"Error generating {specialty}: {e}")
            return None

    def save_json(self, specialty: str, data: List):
        output_dir = "assets/data/pathologies"
        os.makedirs(output_dir, exist_ok=True)
        
        file_path = os.path.join(output_dir, f"{specialty}.json")
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"Successfully saved {file_path}")

def main():
    parser = argparse.ArgumentParser(description="Generate Mikbook pathology data using Groq.")
    parser.add_argument("--api-key", required=True, help="Groq API Key")
    parser.add_argument("--specialty", help="Target a specific specialty (optional)")
    args = parser.parse_args()

    generator = MikbookGenerator(args.api_key)
    
    targets = [args.specialty] if args.specialty else SPECIALTIES
    
    for spec in targets:
        data = generator.generate_for_specialty(spec)
        if data:
            generator.save_json(spec, data)

if __name__ == "__main__":
    main()
