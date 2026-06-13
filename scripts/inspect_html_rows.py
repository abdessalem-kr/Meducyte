import json
from bs4 import BeautifulSoup

with open('/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/assets/data/medicalcul_ultimate_master.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# A-DIVA
item = data[0]
html = item['full_html_content']
soup = BeautifulSoup(html, 'html.parser')

table = soup.find('table', class_='score_table')
if table:
    print("Found table!")
    for i, tr in enumerate(table.find_all('tr')):
        print(f"Row {i}:")
        print(f"  HTML: {str(tr).strip()[:200]}...")
else:
    print("No table found!")
