import pdfplumber

pdf = pdfplumber.open('/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/pdfs/250 examens de laboratoire, Prescription et interprétation.pdf')
page = pdf.pages[30]

words = page.extract_words(keep_blank_chars=True, extra_attrs=["fontname", "size"])
print("Sample words from page:")
for i, w in enumerate(words):
    if 250 < i < 280:  # Around where Clinique might start
        print(f"'{w['text']}' font: {w['fontname']} size: {round(w['size'], 2)}")

print("\nFinding words with 'bold' or 'bd' in fontname:")
bold_fonts = set()
for w in words:
    if 'bold' in w['fontname'].lower() or 'bd' in w['fontname'].lower() or 'heavy' in w['fontname'].lower():
        bold_fonts.add(w['fontname'])

print("Detected Bold Fonts on this page:", bold_fonts)

print("\nPrinting full text lines with font properties to see how Clinique titles are styled:")
for w in words:
    if 'Hyperuricémie' in w['text'] or 'Clinique' in w['text']:
        print(f"'{w['text']}' -> font: {w['fontname']}, size: {round(w['size'],2)}")

pdf.close()
