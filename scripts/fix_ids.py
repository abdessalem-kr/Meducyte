import json
import re
from unidecode import unidecode

def slugify(text):
    text = unidecode(text).lower()
    return re.sub(r'[^a-z0-0]+', '_', text).strip('_')

def fix_json():
    path = "/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/assets/data/lab_encyclopedia.json"
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    for entry in data.get('entries', []):
        if 'name' in entry:
            entry['id'] = slugify(entry['name'])
            
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print("Fixed existing IDs")

if __name__ == "__main__":
    fix_json()
