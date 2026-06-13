import json
from bs4 import BeautifulSoup

with open('/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/assets/data/medicalcul_ultimate_master.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

no_table_but_has_items = []
other_table_classes = set()

for idx, item in enumerate(data):
    html = item.get('full_html_content', '')
    soup = BeautifulSoup(html, 'html.parser')
    table = soup.find('table', class_='score_table')
    has_items = len(item.get('structured_items', [])) > 0
    
    # Find all table classes
    for t in soup.find_all('table'):
        classes = t.get('class', [])
        for c in classes:
            other_table_classes.add(c)
            
    if has_items and not table:
        no_table_but_has_items.append((idx, item['name']))

print(f"Calculators with structured items but no class='score_table': {len(no_table_but_has_items)}")
for idx, name in no_table_but_has_items:
    print(f"  {idx}: {name}")
print("All table classes found in HTML content:", list(other_table_classes))
