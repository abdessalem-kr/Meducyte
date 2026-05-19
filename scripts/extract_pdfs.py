import os
import PyPDF2

pdf_dir = "pdfs"
output_file = "extracted_pdf_text.txt"

all_text = ""

for filename in os.listdir(pdf_dir):
    if filename.endswith(".pdf"):
        filepath = os.path.join(pdf_dir, filename)
        all_text += f"=== START OF {filename} ===\n\n"
        try:
            with open(filepath, 'rb') as file:
                reader = PyPDF2.PdfReader(file)
                for page_num in range(len(reader.pages)):
                    page = reader.pages[page_num]
                    all_text += f"--- Page {page_num + 1} ---\n"
                    all_text += page.extract_text() + "\n\n"
        except Exception as e:
            all_text += f"Error reading {filename}: {str(e)}\n\n"
        all_text += f"=== END OF {filename} ===\n\n"

with open(output_file, 'w', encoding='utf-8') as out_f:
    out_f.write(all_text)

print(f"Extraction complete. Wrote to {output_file}")
