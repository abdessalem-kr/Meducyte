import json
from bs4 import BeautifulSoup

indices = [148, 215, 300, 329, 382]

with open('/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/assets/data/medicalcul_ultimate_master.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

for idx in indices:
    item = data[idx]
    print(f"\n======================================")
    print(f"Calculator {idx}: {item['name']}")
    html = item['full_html_content']
    soup = BeautifulSoup(html, 'html.parser')
    
    # Check tables
    tables = soup.find_all('table')
    print(f"Tables found: {len(tables)}")
    for ti, t in enumerate(tables):
        print(f"  Table {ti} class: {t.get('class')}")
        # Print first 2 rows
        rows = t.find_all('tr')
        print(f"    Rows: {len(rows)}")
        for ri, r in enumerate(rows[:2]):
            print(f"      Row {ri}: {str(r).strip()[:150]}...")
            
    # Check inputs outside tables
    inputs = soup.find_all('input')
    print(f"Inputs outside tables: {len(inputs)}")
