import pdfplumber

pdf = pdfplumber.open('/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/pdfs/250 examens de laboratoire, Prescription et interprétation.pdf')
page = pdf.pages[30]
text = page.extract_text()
words = page.extract_words(keep_blank_chars=True, extra_attrs=["fontname"])

# lines from text
lines = [l.strip() for l in text.split('\n')]

# words by line ? No, words have text. We can join words that are bold to see what phrases they make.
bold_phrases = []
current_phrase = ""
for w in words:
    if 'Semibold' in w['fontname']:
        current_phrase += w['text']
    else:
        if current_phrase.strip():
            bold_phrases.append(current_phrase.strip())
        current_phrase = ""

if current_phrase.strip():
    bold_phrases.append(current_phrase.strip())

print("Detected Bold phrases:")
print(bold_phrases)

pdf.close()
