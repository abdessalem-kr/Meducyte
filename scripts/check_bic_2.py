import pdfplumber
import re
from unidecode import unidecode
from extract_local_lab import LAST_PAGE

pdf = pdfplumber.open('/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/pdfs/250 examens de laboratoire, Prescription et interprétation.pdf')
all_lines = []
for i in range(80, 85):
    text = (pdf.pages[i].extract_text() or '').strip()
    page_lines = [l.strip() for l in text.split('\n') if l.strip()]
    for l in page_lines:
        all_lines.append((i, l))

current_name = None
current_text = []

idx = 0
found = False
while idx < len(all_lines) - 1:
    pg_i, l1 = all_lines[idx]
    pg2_i, l2 = all_lines[idx+1]
        
    m1 = re.match(r'^(\d{1,3})\s+(.+)$', l1)
    m2 = re.match(r'^(.+?)\s+(\d{1,3})$', l1)
    name_part = None
    if m1: name_part = m1.group(2).strip()
    elif m2: name_part = m2.group(1).strip()
    
    if name_part and len(name_part) < 60:
        n_norm = unidecode(name_part.lower()).replace('-', ' ').replace('_', ' ')
        l2_norm = unidecode(l2.lower()).replace('-', ' ').replace('_', ' ')
        if n_norm in l2_norm or l2_norm in n_norm or (len(n_norm)>5 and n_norm[:10] == l2_norm[:10]):
            if current_name and 'bicarb' in current_name.lower():
                print(f'\n[Bicarbonates ended naturally! Next exam is {name_part}]')
                print(f'Length of Bicarbonate lines: {len(current_text)}')
                print(f'Last 10 lines:\n' + '\n'.join(current_text[-10:]))
                found = True
            current_name = name_part
            current_text = [l1]
            idx += 1
            if current_name and 'bicarb' in current_name.lower():
                print(f'[STARTED Bicarbonates at index {idx}]')
            continue

    if current_name and 'bicarb' in current_name.lower():
        current_text.append(l1)
    idx += 1

if current_name and 'bicarb' in current_name.lower() and not found:
    current_text.append(all_lines[-1][1])
    print(f'\n[Bicarbonates ended at end of loop!]')
    print(f'Length of Bicarbonate lines: {len(current_text)}')
    print(f'Last 10 lines:\n' + '\n'.join(current_text[-10:]))
