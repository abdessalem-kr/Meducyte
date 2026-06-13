import json

with open('/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/assets/data/medicalcul_ultimate_master.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

print(f"Total calculators: {len(data)}")

# Print keys of the first few
for idx, item in enumerate(data[:10]):
    print(f"\n{idx}: {item.get('name')}")
    print(f"  URL: {item.get('url')}")
    print(f"  structured_items count: {len(item.get('structured_items', []))}")
    for qi, q in enumerate(item.get('structured_items', [])):
        print(f"    Q{qi}: {q.get('question')} (Options: {len(q.get('options', []))})")
    
    print(f"  detailed_sections keys: {list(item.get('detailed_sections', {}).keys())}")
    for section_name, sections in item.get('detailed_sections', {}).items():
        print(f"    Section {section_name}: {len(sections)} items")
        for si, s in enumerate(sections[:3]):
            print(f"      Item {si}: text length: {len(s.get('text', ''))}, html length: {len(s.get('html', ''))}")
