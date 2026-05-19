import json
import re
from bs4 import BeautifulSoup
import os

def parse_medicalcul_spe(html_path):
    if not os.path.exists(html_path):
        print(f"File not found: {html_path}")
        return []
        
    with open(html_path, 'r', encoding='utf-8') as f:
        html = f.read()
    
    soup = BeautifulSoup(html, 'html.parser')
    categories = []
    
    chapters = soup.find_all('p', class_='idx_spe_chapter')
    
    for chapter in chapters:
        link = chapter.find('a')
        if not link: continue
        
        onclick = link.get('onclick', '')
        match = re.search(r"showhide\('(.+?)'\)", onclick)
        if not match: continue
        
        cat_id = match.group(1)
        # Clean up the name (remove icon images etc)
        cat_name = link.get_text(strip=True)
        
        ul = soup.find('ul', id=cat_id)
        calculators = []
        
        if ul:
            for li in ul.find_all('li', class_='idx_liline'):
                a = li.find('a')
                if not a: continue
                
                href = a.get('href', '')
                
                # Get text excluding idx_note span
                calc_name = ""
                for content in a.contents:
                    if hasattr(content, 'name') and content.name == 'span':
                        break
                    calc_name += str(content)
                
                calc_name = calc_name.strip()
                
                note = a.find('span', class_='idx_note')
                calc_description = note.get_text(strip=True) if note else ""
                
                calculators.append({
                    "id": href.replace(".html", ""),
                    "name": calc_name,
                    "description": calc_description,
                    "url": f"http://medicalcul.free.fr/{href}"
                })
        
        categories.append({
            "id": cat_id,
            "name": cat_name,
            "calculators": calculators
        })
        
    return categories

if __name__ == "__main__":
    html_file = "/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/pdfs/_indexspe.html"
    target_json = "/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/assets/data/medical_calculators.json"
    
    # Ensure assets/data directory exists
    os.makedirs(os.path.dirname(target_json), exist_ok=True)
    
    data = parse_medicalcul_spe(html_file)
    if data:
        with open(target_json, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"Successfully extracted {sum(len(c['calculators']) for c in data)} calculators in {len(data)} categories.")
    else:
        print("No data extracted.")
