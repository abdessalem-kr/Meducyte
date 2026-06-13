import json

with open('/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/assets/data/medicalcul_ultimate_master.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

types_found = set()
for item in data:
    for q in item.get('structured_items', []):
        for opt in q.get('options', []):
            t = opt.get('type')
            if t:
                types_found.add(t)

print("Option types found in master JSON:", list(types_found))

# Print examples of non-radio, non-checkbox options if they exist
for idx, item in enumerate(data):
    for q in item.get('structured_items', []):
        for opt in q.get('options', []):
            if opt.get('type') not in ['radio', 'checkbox']:
                print(f"Calculator {idx} '{item['name']}':")
                print(f"  Question: '{q.get('question')}'")
                print(f"  Option: {opt}")
                break
