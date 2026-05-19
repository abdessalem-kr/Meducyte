import pdfplumber
import json
import os

pdf_path = "/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/pdfs/250 examens de laboratoire, Prescription et interprétation.pdf"
output_path = "/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/assets/data/lab_normal_values.json"

def extract_table():
    data = []
    with pdfplumber.open(pdf_path) as pdf:
        # Pages 16 to 21 (0-indexed: 15 to 20)
        for i in range(15, 21):
            page = pdf.pages[i]
            tables = page.extract_tables()
            for table in tables:
                for row in table:
                    # Clean up row (remove None and strip whitespace)
                    clean_row = [str(cell).replace("\n", " ").strip() if cell else "" for cell in row]
                    if any(clean_row):
                        data.append(clean_row)
    
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Extracted {len(data)} rows to {output_path}")

if __name__ == "__main__":
    extract_table()
