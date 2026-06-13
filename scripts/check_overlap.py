import json

with open('/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/assets/data/medicalcul_ultimate_master.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

overlaps_found = []

for idx, item in enumerate(data):
    name = item.get('name')
    q_texts = set()
    opt_labels = set()
    for q in item.get('structured_items', []):
        if q.get('question'):
            q_texts.add(q.get('question').strip().lower())
        for opt in q.get('options', []):
            if opt.get('label'):
                opt_labels.add(opt.get('label').strip().lower())
    
    # Check in detailed_sections
    for section_name, sections in item.get('detailed_sections', {}).items():
        for si, sec_item in enumerate(sections):
            text = sec_item.get('text', '').strip()
            if not text:
                continue
            text_lower = text.lower()
            
            # Check for exact matches or substrings
            matched = False
            for q_t in q_texts:
                if text_lower == q_t or (len(text_lower) > 10 and text_lower in q_t):
                    overlaps_found.append({
                        "calc_index": idx,
                        "calc_name": name,
                        "section": section_name,
                        "item_index": si,
                        "text": text,
                        "matched_with": f"Question: {q_t}"
                    })
                    matched = True
                    break
            if matched:
                continue
                
            for opt_l in opt_labels:
                if text_lower == opt_l or (len(text_lower) > 10 and text_lower in opt_l) or (len(opt_l) > 10 and opt_l in text_lower):
                    overlaps_found.append({
                        "calc_index": idx,
                        "calc_name": name,
                        "section": section_name,
                        "item_index": si,
                        "text": text,
                        "matched_with": f"Option: {opt_l}"
                    })
                    break

print(f"Total overlapping items found: {len(overlaps_found)}")
# Print first 20 overlaps
for overlap in overlaps_found[:20]:
    print(f"\nCalculator: {overlap['calc_name']} (index {overlap['calc_index']})")
    print(f"  Section: {overlap['section']}, Item index: {overlap['item_index']}")
    print(f"  Text: '{overlap['text']}'")
    print(f"  Matched with: '{overlap['matched_with']}'")
