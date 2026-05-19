#!/usr/bin/env python3
import json
import re
import pdfplumber
from unidecode import unidecode

PDF_PATH = "/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/pdfs/250 examens de laboratoire, Prescription et interprétation.pdf"
OUTPUT_PATH = "/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/assets/data/lab_encyclopedia.json"

FIRST_PAGE = 21
LAST_PAGE = 405

def slugify(text):
    t = unidecode(text).lower().strip()
    return re.sub(r'[^a-z0-9]+', '_', t).strip('_')

def get_exam_name(text):
    lines = [l.strip() for l in text.split('\n') if l.strip()]
    if not lines: return "Unknown"
    l1 = lines[0]
    m1 = re.match(r'^(\d{1,3})\s+(.+)$', l1)
    m2 = re.match(r'^(.+?)\s+(\d{1,3})$', l1)
    if m1: return m1.group(2).strip()
    elif m2: return m2.group(1).strip()
    return l1

def is_exam_header(text):
    lines = [l.strip() for l in text.split('\n') if l.strip()]
    if len(lines) < 2: return False
    l1 = lines[0]
    l2 = lines[1]
    
    m1 = re.match(r'^(\d{1,3})\s+(.+)$', l1)
    m2 = re.match(r'^(.+?)\s+(\d{1,3})$', l1)
    
    name_part = None
    if m1: name_part = m1.group(2).strip()
    elif m2: name_part = m2.group(1).strip()
    
    if name_part:
        n_norm = unidecode(name_part.strip().lower()).replace('-', ' ').replace('_', ' ')
        l2_norm = unidecode(l2.strip().lower()).replace('-', ' ').replace('_', ' ')
        if n_norm in l2_norm or l2_norm in n_norm or (len(n_norm)>5 and n_norm[:10] == l2_norm[:10]):
            return True
    return False

def is_bold_line(line, bold_phrases):
    if not line.strip(): return False
    l_clean = line.strip().replace(' ', '')
    for bp in bold_phrases:
        bp_clean = bp.replace(' ', '')
        if len(bp_clean) > 5 and l_clean in bp_clean:
            return True
    return False

def parse_exam_text(name, full_text, bold_phrases):
    lines = [l.strip() for l in full_text.split('\n')]
    
    # 1. Skip page number and item name (e.g. "10 Acide urique" or "Acide urique 10")
    if len(lines) > 0 and (re.match(r'^\d{1,3}\s+', lines[0]) or re.search(r'\s+\d{1,3}$', lines[0])):
        lines = lines[1:]
        
    # 2. Skip item name in bold
    if len(lines) > 0:
        lines = lines[1:]
        
    intro_lines = []
    precautions_lines = []
    valeurs_lines = []
    clinique_lines = []
    
    current_list = intro_lines
    
    for line in lines:
        if not line: continue
        lower = line.lower()
        
        if lower.startswith(('précautions de prélèvement', 'prélèvement')):
            current_list = precautions_lines
            continue
        elif lower.startswith(('valeurs usuelles', 'valeurs de référence', 'valeurs normales')):
            current_list = valeurs_lines
            continue
        elif lower.startswith(('clinique', 'interprétation', 'variations pathologiques')):
            current_list = clinique_lines
            continue
            
        if current_list is clinique_lines and is_bold_line(line, bold_phrases):
            current_list.append(f"## {line}")
        else:
            current_list.append(line)
        
    entry = {
        "id": slugify(name),
        "name": name,
        "abbreviation": "",
        "category": "Général",
        "introduction": " ".join(intro_lines).strip(),
        "collectionPrecautions": " ".join(precautions_lines).strip(),
        "normalValues": [],
        "clinique": "\n".join(clinique_lines).strip(),
        "remarks": []
    }
    
    # Process normalValues from the lines we captured
    for v_line in valeurs_lines:
        if v_line.startswith(('•', '-')):
            val = v_line.strip('•- \t')
            entry["normalValues"].append({"traditionalValue": val})
        elif len(v_line) < 100 and sum(c.isdigit() for c in v_line) > 0:
            entry["normalValues"].append({"traditionalValue": v_line})
            
    return entry

def main():
    print(f"Opening PDF: {PDF_PATH}")
    pdf = pdfplumber.open(PDF_PATH)
    
    # Extract all text into a linear list of (page_num, line_text)
    all_lines = []
    bold_phrases_by_page = {}
    
    for i in range(FIRST_PAGE, min(LAST_PAGE, len(pdf.pages))):
        page = pdf.pages[i]
        text = (page.extract_text() or "").strip()
        if not text: continue
        
        # Get bold phrases from this page
        words = page.extract_words(keep_blank_chars=True, extra_attrs=["fontname"])
        bold_phrases_page = []
        current_phrase = ""
        for w in words:
            if 'Semibold' in w['fontname'] or 'bold' in w['fontname'].lower() or 'heavy' in w['fontname'].lower():
                current_phrase += w['text']
            else:
                if current_phrase.strip():
                    bold_phrases_page.append(current_phrase.strip())
                current_phrase = ""
        if current_phrase.strip():
            bold_phrases_page.append(current_phrase.strip())
            
        bold_phrases_by_page[i] = bold_phrases_page
        
        page_lines = [l.strip() for l in text.split('\n') if l.strip()]
        for l in page_lines:
            all_lines.append((i, l))
            
    exams = []
    current_name = None
    current_text = []
    current_bolds = []
    
    idx = 0
    while idx < len(all_lines) - 1:
        pg_i, l1 = all_lines[idx]
        pg2_i, l2 = all_lines[idx+1]
        
        # Detect 'voir' skips
        if l2.lower().startswith('voir ') and len(l1) < 60:
            # We skip this exam (l1) and its voir line (l2)
            idx += 2
            
            # The next line (if any) is a MID-PAGE EXAM TITLE!
            if idx < len(all_lines):
                next_pg, next_l = all_lines[idx]
                if current_name:
                    exams.append((current_name, "\n".join(current_text), current_bolds))
                current_name = next_l
                current_text = [next_l]
                current_bolds = bold_phrases_by_page.get(next_pg, [])
                idx += 1
            continue
            
        # Detect standard TOP-OF-PAGE headers
        m1 = re.match(r'^(\d{1,3})\s+(.+)$', l1)
        m2 = re.match(r'^(.+?)\s+(\d{1,3})$', l1)
        name_part = None
        if m1: name_part = m1.group(2).strip()
        elif m2: name_part = m2.group(1).strip()
        
        if name_part and len(name_part) > 3 and len(name_part) < 60:
            n_norm = unidecode(name_part.lower()).replace('-', ' ').replace('_', ' ')
            l2_norm = unidecode(l2.lower()).replace('-', ' ').replace('_', ' ')
            if n_norm in l2_norm or l2_norm in n_norm or (len(n_norm)>5 and n_norm[:10] == l2_norm[:10]):
                # If this header is just a repeat of the current exam (multi-page continuation), skip it
                if current_name and unidecode(current_name.strip().lower()).replace('-', ' ') == n_norm:
                    idx += 2
                    continue
                    
                if current_name:
                    exams.append((current_name, "\n".join(current_text), current_bolds))
                current_name = name_part
                current_text = [l1]
                current_bolds = bold_phrases_by_page.get(pg_i, [])
                idx += 1
                continue
                
        # Accumulate text for the current exam
        if current_name:
            current_text.append(l1)
            # Add bold phrases from the current page if it's a new page
            if idx > 0 and all_lines[idx][0] != all_lines[idx-1][0]:
                current_bolds.extend(bold_phrases_by_page.get(pg_i, []))
                
        idx += 1
        
    if current_name:
        current_text.append(all_lines[-1][1])
        exams.append((current_name, "\n".join(current_text), current_bolds))
        
    print(f"Found {len(exams)} exams. Extracting data...")
    
    parsed_entries = []
    for name, text, bp in exams:
        parsed_entries.append(parse_exam_text(name, text, bp))
        
    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump({"entries": parsed_entries}, f, ensure_ascii=False, indent=2)
        
    print(f"Saved {len(parsed_entries)} entries to {OUTPUT_PATH}")

if __name__ == "__main__":
    main()
