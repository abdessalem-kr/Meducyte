#!/usr/bin/env python3
"""
Lab Encyclopedia Extractor — 250 Examens de Laboratoire
Extracts every exam entry from the PDF verbatim and saves to JSON.
Uses Groq llama-3.3-70b for structured extraction with exact source fidelity.
"""

import json
import os
import re
import time
import pdfplumber
import requests
from unidecode import unidecode

# ─── Configuration ───────────────────────────────────────────────────────────

API_KEY     = "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"
GROQ_URL    = "https://api.groq.com/openai/v1/chat/completions"
MODEL       = "llama-3.3-70b-versatile"

PDF_PATH    = "/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/pdfs/250 examens de laboratoire, Prescription et interprétation.pdf"
OUTPUT_PATH = "/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/assets/data/lab_encyclopedia.json"
PROGRESS_PATH = "/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/scripts/extraction_progress.json"

# Pages 29-400 contain the individual exam entries (0-indexed: 28-399)
FIRST_PAGE = 28   # 0-indexed (page 29 in PDF viewer)
LAST_PAGE  = 405  # 0-indexed exclusive — scan all pages

# ─── Helpers ─────────────────────────────────────────────────────────────────

def slugify(text: str) -> str:
    t = unidecode(text).lower().strip()
    t = re.sub(r'[^a-z0-9]+', '_', t)
    return t.strip('_')

def save_progress(processed_ids: set):
    with open(PROGRESS_PATH, 'w', encoding='utf-8') as f:
        json.dump(list(processed_ids), f, ensure_ascii=False)

def load_progress() -> set:
    if os.path.exists(PROGRESS_PATH):
        with open(PROGRESS_PATH, 'r', encoding='utf-8') as f:
            return set(json.load(f))
    return set()

def save_entries(entries: list):
    with open(OUTPUT_PATH, 'w', encoding='utf-8') as f:
        json.dump({"entries": entries}, f, ensure_ascii=False, indent=2)

def load_entries() -> list:
    if os.path.exists(OUTPUT_PATH):
        try:
            with open(OUTPUT_PATH, 'r', encoding='utf-8') as f:
                return json.load(f).get('entries', [])
        except Exception:
            pass
    return []

def call_groq(system_prompt: str, user_prompt: str) -> str | None:
    payload = {
        "model": MODEL,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user",   "content": user_prompt},
        ],
        "temperature": 0.0,
        "response_format": {"type": "json_object"},
    }
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json",
    }
    for attempt in range(8):
        try:
            resp = requests.post(GROQ_URL, headers=headers, json=payload, timeout=120)
            if resp.status_code == 200:
                return resp.json()['choices'][0]['message']['content']
            elif resp.status_code == 429:
                wait = min(120, 30 * (attempt + 1))
                print(f"  [Rate limit] Waiting {wait}s …")
                time.sleep(wait)
            else:
                print(f"  [HTTP {resp.status_code}] {resp.text[:200]}")
                time.sleep(15)
        except Exception as exc:
            print(f"  [Exception] {exc}")
            time.sleep(15)
    return None

# ─── PDF Parsing ──────────────────────────────────────────────────────────────

def extract_page_texts(pdf) -> list[tuple[int, str]]:
    """Return list of (page_number_1based, text) for pages in range."""
    pages = []
    for i in range(FIRST_PAGE, min(LAST_PAGE, len(pdf.pages))):
        text = pdf.pages[i].extract_text() or ''
        pages.append((i + 1, text.strip()))
    return pages

def is_exam_header(text: str) -> bool:
    """Heuristic: a page starts a new exam if its first line ends
    with its own name repeated on line 2 (the book's format)."""
    lines = [l.strip() for l in text.split('\n') if l.strip()]
    if len(lines) < 2:
        return False
    # Pattern: "NUM ExamName\nExamName" where NUM is a number between 1-300
    first = lines[0]
    match = re.match(r'^(\d{1,3})\s+(.+)$', first)
    if match:
        name_part = match.group(2).strip()
        # The second line or block starts with the exam name
        second_start = lines[1][:len(name_part)]
        if second_start.lower() == name_part.lower()[:len(second_start)]:
            return True
    return False

def get_exam_name_from_header(text: str) -> str:
    lines = [l.strip() for l in text.split('\n') if l.strip()]
    match = re.match(r'^\d{1,3}\s+(.+)$', lines[0])
    if match:
        return match.group(1).strip()
    return lines[0]

def group_pages_by_exam(pages: list[tuple[int, str]]) -> list[dict]:
    """Group consecutive pages belonging to the same exam."""
    exams = []
    current = None

    for page_num, text in pages:
        if not text:
            continue
        if is_exam_header(text):
            if current:
                exams.append(current)
            name = get_exam_name_from_header(text)
            current = {
                'name': name,
                'pages': [page_num],
                'text': text,
            }
        elif current:
            current['pages'].append(page_num)
            current['text'] += '\n\n' + text

    if current:
        exams.append(current)
    return exams

# ─── Groq Extraction ──────────────────────────────────────────────────────────

SYSTEM_PROMPT = """
You are a medical data extraction robot. Your ONLY job is to extract information from laboratory examination entries and output them as valid JSON.

CRITICAL RULES — READ CAREFULLY:
1. COPY TEXT VERBATIM from the source. Do NOT rephrase, summarize, translate, or improve.
2. Preserve all French medical terminology exactly as written.
3. If a field is not present in the text, use an empty string "" or empty list [] — never invent content.
4. For normalValues, extract every value exactly as written (e.g., "< 6 mg/L", "3,5 à 5 mEq/L").
5. For increased/decreased, copy the exact bullet points or sentences from the source.
6. Never merge two separate exams. Extract only the ONE exam described in the text.
7. Derive the id by slugifying the name (lowercase, replace spaces/accents with underscores).

Output ONLY valid JSON in this exact schema:
{
  "id": "string (slugified name)",
  "name": "string (exact name from PDF)",
  "abbreviation": "string or null",
  "category": "string (e.g. Biochimie, Hématologie, Immunologie, Microbiologie, Endocrinologie, etc.)",
  "physiopathology": "string (verbatim from source, may be long)",
  "collectionPrecautions": "string (verbatim, or empty string if not mentioned)",
  "normalValues": [
    {
      "population": "string or null (e.g. Homme, Femme, Enfant)",
      "traditionalValue": "string (exact value with unit)",
      "siValue": "string or null (SI unit value if given)",
      "unit": "string or null"
    }
  ],
  "indications": ["string (verbatim)", ...],
  "interpretation": {
    "increased": ["string (verbatim cause/condition)", ...],
    "decreased": ["string (verbatim cause/condition)", ...],
    "clinicalSignificance": "string or null (any other interpretation text)"
  },
  "remarks": ["string (verbatim)", ...]
}
"""

def extract_entry(exam: dict) -> dict | None:
    user_prompt = f"""Extract the laboratory exam entry from the following PDF text.
Exam name: {exam['name']}
Source pages: {exam['pages']}

--- PDF TEXT START ---
{exam['text'][:8000]}
--- PDF TEXT END ---

Return the complete JSON for this single exam entry."""

    raw = call_groq(SYSTEM_PROMPT, user_prompt)
    if not raw:
        return None
    try:
        data = json.loads(raw)
        # Ensure id matches slugified name
        if 'id' not in data or not data['id']:
            data['id'] = slugify(exam['name'])
        return data
    except json.JSONDecodeError as e:
        print(f"  [JSON parse error] {e}")
        # Try to find JSON in response
        match = re.search(r'\{.*\}', raw, re.DOTALL)
        if match:
            try:
                return json.loads(match.group(0))
            except Exception:
                pass
        return None

# ─── Main ─────────────────────────────────────────────────────────────────────

def main():
    print(f"📚 Opening PDF: {PDF_PATH}")
    if not os.path.exists(PDF_PATH):
        print("❌ PDF not found!")
        return

    with pdfplumber.open(PDF_PATH) as pdf:
        print(f"📄 Total pages: {len(pdf.pages)}")
        print(f"🔍 Scanning pages {FIRST_PAGE+1}–{LAST_PAGE} for exam entries …")
        pages = extract_page_texts(pdf)

    print("🗂  Grouping pages by exam …")
    exams = group_pages_by_exam(pages)
    print(f"✅ Found {len(exams)} exam entries in PDF")

    # Load prior state
    all_entries = load_entries()
    processed_ids = load_progress()
    existing_ids = {e['id'] for e in all_entries}
    processed_ids = processed_ids | existing_ids

    print(f"⏭  Already processed: {len(processed_ids)} entries")
    remaining = [e for e in exams if slugify(e['name']) not in processed_ids]
    print(f"⏳ Remaining: {len(remaining)} entries\n")

    for i, exam in enumerate(remaining):
        eid = slugify(exam['name'])
        pages_str = f"p.{exam['pages'][0]}–{exam['pages'][-1]}" if len(exam['pages']) > 1 else f"p.{exam['pages'][0]}"
        print(f"[{i+1}/{len(remaining)}] Extracting: {exam['name']} ({pages_str})")

        entry = extract_entry(exam)
        if entry:
            # Make sure no duplicate id
            entry['id'] = eid
            all_entries.append(entry)
            processed_ids.add(eid)
            save_entries(all_entries)
            save_progress(processed_ids)
            print(f"  ✓ Saved ({len(all_entries)} total)")
        else:
            print(f"  ✗ Failed to extract — skipping")

        # Small polite delay between calls
        if i < len(remaining) - 1:
            time.sleep(2)

    print(f"\n🎉 Done! {len(all_entries)} entries saved to {OUTPUT_PATH}")

if __name__ == '__main__':
    main()
