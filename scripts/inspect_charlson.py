import json

with open('/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/assets/data/medicalcul_ultimate_master.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

item = data[61] # Charlson index
print(f"Name: {item['name']}")
print("\n--- STRUCTURED ITEMS ---")
for idx, q in enumerate(item.get('structured_items', [])):
    print(f"Question: {q.get('question')}")
    for opt in q.get('options', []):
        print(f"  Option Label: {opt.get('label')}")
        print(f"  Option Raw Row: {opt.get('raw_row_html')}")

print("\n--- DETAILED SECTIONS ---")
for sec, items in item.get('detailed_sections', {}).items():
    print(f"Section: {sec}")
    for i, it in enumerate(items):
        print(f"  Item {i}: text='{it.get('text')}'")
        print(f"  Item {i}: html='{it.get('html')}'")
