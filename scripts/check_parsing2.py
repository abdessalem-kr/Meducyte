import re
import pdfplumber

def parse_text(full_text):
    lines = full_text.split('\n')
    
    # 1. Page number and item name (skip)
    # usually: "10 Acide urique (urate) sanguin"
    if len(lines) > 0 and re.match(r'^\d{1,3}\s+', lines[0]):
        lines = lines[1:]
    
    # 2. Item name in bold (skip)
    if len(lines) > 0:
        lines = lines[1:] # skip the bold title
        
    intro, precautions, valeurs, clinique = [], [], [], []
    current = intro
    
    for line in lines:
        line_clean = line.strip()
        lower_line = line_clean.lower()
        
        if lower_line.startswith('précautions de prélèvement') or lower_line.startswith('prélèvement'):
            current = precautions
            continue
        elif lower_line.startswith('valeurs usuelles') or lower_line.startswith('valeurs de référence'):
            current = valeurs
            continue
        elif lower_line.startswith('clinique') or lower_line.startswith('interprétation'):
            current = clinique
            continue
            
        current.append(line_clean)
        
    return {
        "intro": '\n'.join(intro).strip(),
        "precautions": '\n'.join(precautions).strip(),
        "valeurs": '\n'.join(valeurs).strip(),
        "clinique": '\n'.join(clinique).strip()
    }

pdf = pdfplumber.open('/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/pdfs/250 examens de laboratoire, Prescription et interprétation.pdf')
print("Testing Acide Urique:")
res = parse_text(pdf.pages[30].extract_text())
print("INTRO:", res['intro'][:100], "...")
print("PRECAUTIONS:", res['precautions'][:100], "...")
print("VALEURS:", res['valeurs'][:100], "...")
print("CLINIQUE:", res['clinique'][:100], "...")

print("\nTesting Agglutinines:")
res.update(parse_text(pdf.pages[35].extract_text()))
print("INTRO:", res['intro'][:100], "...")
print("PRECAUTIONS:", res['precautions'][:100], "...")
print("VALEURS:", res['valeurs'][:100], "...")
print("CLINIQUE:", res['clinique'][:100], "...")

pdf.close()
