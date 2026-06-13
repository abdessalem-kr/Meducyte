import json
import os
import shutil
import re
from bs4 import BeautifulSoup

master_path = '/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/assets/data/medicalcul_ultimate_master.json'
backup_path = '/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/assets/data/medicalcul_ultimate_master.json.bak'

# Create a backup first
print(f"Creating backup of master JSON to {backup_path}...")
shutil.copy(master_path, backup_path)

with open(master_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

def clean_text(text):
    if not text:
        return ""
    text = text.replace('\xa0', ' ').replace('\n', ' ')
    text = re.sub(r'\s+', ' ', text)
    return text.strip()

def should_filter(item_text, filter_texts):
    item_clean = clean_text(item_text).lower()
    if not item_clean:
        return False
    for ft in filter_texts:
        ft_clean = clean_text(ft).lower()
        if not ft_clean:
            continue
        if item_clean == ft_clean:
            return True
        if len(ft_clean) > 10 and ft_clean in item_clean:
            return True
        if len(item_clean) > 10 and item_clean in ft_clean:
            return True
    return False

def parse_and_sanitize(item):
    name = item['name']
    html = item.get('full_html_content', '')
    soup = BeautifulSoup(html, 'html.parser')
    
    tables = soup.find_all('table')
    
    structured_items = []
    criteria = []
    filter_texts = set()
    
    for table in tables:
        # Check if table has radio or checkbox inputs
        table_inputs = table.find_all('input')
        has_radio_or_checkbox = any(inp.get('type') in ['radio', 'checkbox'] for inp in table_inputs)
        if not has_radio_or_checkbox:
            continue
            
        rows = table.find_all('tr')
        temp_groups = []
        current_group = {'heading': None, 'description': None, 'rows': []}
        
        for tr in rows:
            tds = tr.find_all('td')
            if not tds:
                continue
            is_note = any('score_note' in (td.get('class') or []) for td in tds)
            has_inputs = any(tr.find_all(['input', 'select', 'textarea']))
            
            is_heading = False
            if len(tds) == 1 or (len(tds) == 2 and tds[0].get('colspan') == '2'):
                text = clean_text(tr.get_text())
                has_strong = any(td.find(['strong', 'b', 'font']) for td in tds)
                if has_strong and not is_note and not has_inputs and text:
                    is_heading = True
            
            if is_heading:
                if current_group['rows']:
                    temp_groups.append(current_group)
                current_group = {'heading': clean_text(tr.get_text()), 'description': None, 'rows': []}
            elif is_note and not has_inputs:
                current_group['description'] = clean_text(tr.get_text())
            else:
                current_group['rows'].append(tr)
                
        if current_group['rows']:
            temp_groups.append(current_group)
            
        last_heading = "Critères"
        
        for g in temp_groups:
            heading = g['heading'] or last_heading
            description = g['description'] or ""
            last_heading = heading
            
            # Find inputs in group rows
            inputs = []
            for tr in g['rows']:
                row_inputs = tr.find_all('input')
                for inp in row_inputs:
                    inp_type = inp.get('type')
                    if inp_type in ['radio', 'checkbox']:
                        name_attr = inp.get('name')
                        val_attr = inp.get('value')
                        id_attr = inp.get('id')
                        
                        label_text = ""
                        label_el = None
                        if id_attr:
                            label_el = tr.find('label', attrs={'for': id_attr})
                        if not label_el:
                            label_el = tr.find('label')
                        if label_el:
                            label_text = clean_text(label_el.get_text())
                        else:
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
                
            # Collect filter texts to remove from detailed_sections
            if heading and heading != "Critères":
                filter_texts.add(heading)
            if description:
                filter_texts.add(description)
            for inp in inputs:
                if inp['label']:
                    filter_texts.add(inp['label'])
                    
            # Group inputs by 'name' attribute
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
                
                options = []
                for inp in group_inputs:
                    pts = 0.0
                    try:
                        pts = float(inp['value'])
                    except:
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
                
                # Build criteria for Dart
                if first_inp['type'] == 'checkbox':
                    # Split checkboxes
                    for opt in options:
                        criteria.append({
                            'section': heading,
                            'question': opt['label'],
                            'options': [
                                {'label': 'Non', 'points': 0.0},
                                {'label': 'Oui', 'points': opt['points']}
                            ]
                        })
                else:
                    # Radio
                    criteria.append({
                        'section': heading,
                        'question': description or heading,
                        'options': [
                            {'label': opt['label'], 'points': opt['points']}
                            for opt in options
                        ]
                    })
                    
    # 2. Sanitize detailed_sections
    detailed_sections = item.get('detailed_sections', {})
    new_main = []
    
    for sec_item in detailed_sections.get('Main', []):
        text = sec_item.get('text', '').strip()
        html_content = sec_item.get('html', '').strip()
        
        is_title = 'scoretitle_title' in html_content
        is_button = 'type="button"' in html_content or 'type="submit"' in html_content
        is_result = 'score_result' in html_content or 'Resultat' in html_content
        
        if (is_title or is_button or is_result) or not should_filter(text, filter_texts):
            new_main.append(sec_item)
            
    sanitized_sections = dict(detailed_sections)
    sanitized_sections['Main'] = new_main
    
    return structured_items, criteria, sanitized_sections

# Process all items
modified_count = 0
total_items = len(data)

for idx, item in enumerate(data):
    s_items, crit, s_sections = parse_and_sanitize(item)
    if s_items:
        item['structured_items'] = s_items
        item['criteria'] = crit
        item['detailed_sections'] = s_sections
        modified_count += 1

# Write sanitized data back to file
print("Writing sanitized data back to master JSON...")
with open(master_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"\nProcessing Complete!")
print(f"Total calculators: {total_items}")
print(f"Calculators sanitized and populated with criteria: {modified_count}")
