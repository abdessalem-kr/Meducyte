import json
from bs4 import BeautifulSoup

with open('/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/assets/data/medicalcul_ultimate_master.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

def clean_text(text):
    if not text:
        return ""
    # Replace non-breaking spaces and collapse spaces
    text = text.replace('\xa0', ' ').replace('\n', ' ')
    import re
    text = re.sub(r'\s+', ' ', text)
    return text.strip()

def parse_calculator_html(calc_index):
    item = data[calc_index]
    name = item['name']
    html = item['full_html_content']
    soup = BeautifulSoup(html, 'html.parser')
    
    # We want to reconstruct structured_items
    structured_items = []
    
    table = soup.find('table', class_='score_table')
    if not table:
        return None
        
    current_heading = "Criteria"
    current_description = ""
    
    # We'll group rows. A group starts when we see a heading, and gathers inputs.
    # To handle radio/checkbox grouping:
    # We can iterate through table rows.
    rows = table.find_all('tr')
    
    temp_groups = []
    # Each temp_group will be: {'heading': X, 'description': Y, 'rows': [tr1, tr2, ...]}
    current_group = {'heading': None, 'description': None, 'rows': []}
    
    for tr in rows:
        # Check if it's a heading row
        # A heading row usually has td with colspan="2" and bold text, and doesn't contain inputs or score_note
        tds = tr.find_all('td')
        if not tds:
            continue
            
        is_note = any('score_note' in (td.get('class') or []) for td in tds)
        has_inputs = any(tr.find_all(['input', 'select', 'textarea']))
        
        # Check if it looks like a heading
        is_heading = False
        if len(tds) == 1 or (len(tds) == 2 and tds[0].get('colspan') == '2'):
            # Text check
            text = clean_text(tr.get_text())
            # If it has strong, color, or font tag
            has_strong = any(td.find(['strong', 'b', 'font']) for td in tds)
            if has_strong and not is_note and not has_inputs and text:
                is_heading = True
                
        if is_heading:
            # Save previous group if it had rows
            if current_group['rows']:
                temp_groups.append(current_group)
            current_group = {'heading': clean_text(tr.get_text()), 'description': None, 'rows': []}
        elif is_note and not has_inputs:
            # Description for current heading/group
            current_group['description'] = clean_text(tr.get_text())
        else:
            # Row with inputs or option labels
            current_group['rows'].append(tr)
            
    if current_group['rows']:
        temp_groups.append(current_group)
        
    # Now process each temp_group to build structured_items
    # If a temp_group has no heading, we can use a fallback or the previous heading
    last_heading = "Critères"
    
    for g in temp_groups:
        heading = g['heading'] or last_heading
        description = g['description'] or ""
        last_heading = heading
        
        # Find all inputs in the rows
        inputs = []
        for tr in g['rows']:
            # Find inputs
            row_inputs = tr.find_all('input')
            for inp in row_inputs:
                inp_type = inp.get('type')
                if inp_type in ['radio', 'checkbox']:
                    name_attr = inp.get('name')
                    val_attr = inp.get('value')
                    id_attr = inp.get('id')
                    
                    # Find label
                    label_text = ""
                    label_el = None
                    if id_attr:
                        label_el = tr.find('label', attrs={'for': id_attr})
                    if not label_el:
                        # Fallback: look for label tags inside tr
                        label_el = tr.find('label')
                    if label_el:
                        label_text = clean_text(label_el.get_text())
                    else:
                        # Fallback to td text excluding inputs
                        tds = tr.find_all('td')
                        if len(tds) > 1:
                            label_text = clean_text(tds[1].get_text())
                        else:
                            label_text = clean_text(tr.get_text())
                            
                    inputs.append({
                        'type': inp_type,
                        'name': name_attr,
                        'value': val_attr,
                        'label': label_text,
                        'raw_input_html': str(inp).strip(),
                        'raw_row_html': str(tr).strip()
                    })
                    
        if not inputs:
            continue
            
        # Group inputs by 'name' attribute (to keep radios together)
        # Checkboxes are grouped together if they share the same heading
        # Let's group them:
        from collections import defaultdict
        grouped_by_name = defaultdict(list)
        name_order = []
        for inp in inputs:
            n = inp['name']
            if n not in grouped_by_name:
                name_order.append(n)
            grouped_by_name[n].append(inp)
            
        for name_attr in name_order:
            group_inputs = grouped_by_name[name_attr]
            first_inp = group_inputs[0]
            
            # Map points from original structured_items options if possible
            # Or parse from first char or value
            options = []
            for inp in group_inputs:
                pts = 0.0
                try:
                    pts = float(inp['value'])
                except:
                    # try parsing from label
                    import re
                    m = re.match(r'^(-?\d+(?:\.\d+)?)', inp['label'])
                    if m:
                        pts = float(m.group(1))
                        
                options.append({
                    'label': inp['label'],
                    'points': pts,
                    'type': inp['type'],
                    'raw_input_html': inp['raw_input_html'],
                    'raw_row_html': inp['raw_row_html']
                })
                
            structured_items.append({
                'question': heading,
                'description': description,
                'options': options
            })
            
    return structured_items

# Test on index 0
for idx in [0, 1, 9]:
    print(f"\n--- PARSING CALCULATOR {idx}: {data[idx]['name']} ---")
    items = parse_calculator_html(idx)
    if items:
        for q_idx, q in enumerate(items):
            print(f"Question {q_idx}: '{q['question']}'")
            print(f"  Description: '{q['description']}'")
            for opt in q['options']:
                print(f"    Option: '{opt['label']}' (points: {opt['points']}, type: {opt['type']})")
    else:
        print("Could not parse table or no table found.")
