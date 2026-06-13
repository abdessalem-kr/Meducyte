#!/usr/bin/env python3
"""
regenerate_calculator_schemas.py

Iterates through all static-only medical calculators in the app JSON,
fetches their medicalcul.free.fr page, then asks Groq (Llama 3.3-70b)
to reconstruct a real interactive schema and patches it back.

Usage:
    python3 scripts/regenerate_calculator_schemas.py

Environment:
    GROQ_API_KEY or hardcoded key below
"""

import json
import os
import re
import sys
import time
import requests

# ── Config ──────────────────────────────────────────────────────────────────
GROQ_API_KEY = "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"
GROQ_URL     = "https://api.groq.com/openai/v1/chat/completions"
MODEL_NAME   = "llama-3.3-70b-versatile"
MAX_TOKENS   = 2000
TEMPERATURE  = 0.15

DATA_FILE    = "assets/data/medical_calculators.json"
BACKUP_FILE  = "assets/data/medical_calculators.backup.json"
DELAY_SEC    = 1.5      # polite pause between requests

HEADERS_GROQ = {
    "Authorization": f"Bearer {GROQ_API_KEY}",
    "Content-Type": "application/json",
}
HEADERS_WEB = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/120.0.0.0 Safari/537.36"
    ),
    "Accept-Language": "fr-FR,fr;q=0.9,en;q=0.8",
}

# ── Helpers ──────────────────────────────────────────────────────────────────

def fetch_html(url: str, timeout: int = 3) -> str | None:
    """Download the HTML of a medicalcul page and strip scripts/styles."""
    if not url:
        return None
    try:
        r = requests.get(url, headers=HEADERS_WEB, timeout=timeout)
        r.raise_for_status()
        html = r.text
        html = re.sub(r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>', '', html, flags=re.IGNORECASE)
        html = re.sub(r'<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>',   '', html, flags=re.IGNORECASE)
        # Collapse excessive whitespace
        html = re.sub(r'\n{3,}', '\n\n', html)
        if len(html) > 12_000:
            html = html[:12_000]
        return html
    except Exception as e:
        print(f"  ⚠️  Could not fetch {url}: {e}")
        return None


SYSTEM_PROMPT = """You are a clinical informatics expert. Given a medical calculator's name, description, and optionally its raw HTML page, generate a complete interactive schema in JSON.

Rules:
- 'criteria' is a list of scoring inputs. Each has:
  * 'label' (string)
  * 'type': 'radio', 'checkbox', or 'numeric'
  * For radio: 'options' array – each option has 'label' (string) and 'points' (number)
  * For checkbox: 'points' (number) added when checked
  * For numeric: 'unit' (string) and 'default_value' (number)
- 'interpretations' is a list of scoring bands: 'min', 'max', 'label', 'color' (green/orange/red)
- 'interpretation_text' is a 1-3 sentence clinical summary
- Do NOT invent criteria – base them on the actual clinical definition of the score
- Return ONLY a raw JSON object, no markdown, no code fences.
"""


def build_user_message(name: str, description: str, html: str | None) -> str:
    parts = [f"Calculator: {name}", f"Description: {description}"]
    if html:
        parts.append("\nPage HTML (stripped):\n" + html)
    else:
        parts.append("\n(No page content – use medical literature for this score)")
    return "\n".join(parts)


def call_groq(user_msg: str) -> dict | None:
    payload = {
        "model": MODEL_NAME,
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user",   "content": user_msg},
        ],
        "temperature": TEMPERATURE,
        "max_tokens": MAX_TOKENS,
    }
    try:
        r = requests.post(GROQ_URL, headers=HEADERS_GROQ, json=payload, timeout=60)
        r.raise_for_status()
        content = r.json()["choices"][0]["message"]["content"].strip()
        # Strip markdown code fences if model ignores instruction
        content = re.sub(r'^```json\s*|^```\s*|```$', '', content, flags=re.MULTILINE).strip()
        return json.loads(content)
    except Exception as e:
        print(f"  ❌  Groq error: {e}")
        return None


def is_interactive(schema: dict) -> bool:
    """Return True if the schema has at least one non-static criterion."""
    criteria = schema.get("criteria", [])
    return any(c.get("type") != "static" for c in criteria)


# ── Main ─────────────────────────────────────────────────────────────────────

def main():
    # Load data
    with open(DATA_FILE, encoding="utf-8") as f:
        data: list = json.load(f)

    # Backup
    if not os.path.exists(BACKUP_FILE):
        with open(BACKUP_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"📂  Backup saved → {BACKUP_FILE}")

    # Identify targets
    targets = []
    for cat in data:
        for calc in cat["calculators"]:
            schema = calc.get("schema")
            if schema is None or not is_interactive(schema):
                # Only skip if already ai_audited to avoid re-hitting the API
                if (schema or {}).get("ai_audited") and (schema or {}).get("source_grounded"):
                    continue
                targets.append((cat, calc))

    print(f"\n🔍  {len(targets)} calculators need real schemas.\n")

    success = 0
    failed  = []

    for i, (cat, calc) in enumerate(targets, 1):
        name = calc["name"]
        url  = calc.get("url", "")
        desc_fr = calc.get("description_fr", "")
        desc_en = calc.get("description_en", "")
        description = desc_fr or desc_en

        print(f"[{i}/{len(targets)}] {name}")

        # Fetch page
        html = fetch_html(url)
        if html:
            print(f"  📄  Fetched {len(html)} chars from {url}")
        else:
            print(f"  ⚠️  Using knowledge only (no HTML)")

        user_msg = build_user_message(name, description, html)
        schema   = call_groq(user_msg)

        if schema and "criteria" in schema and len(schema["criteria"]) > 0 and is_interactive(schema):
            schema["ai_audited"]       = True
            schema["source_grounded"]  = bool(html)
            calc["schema"]             = schema
            print(f"  ✅  Schema generated: {len(schema['criteria'])} criteria, {len(schema.get('interpretations',[]))} ranges")
            success += 1
        else:
            print(f"  ❌  Schema generation failed or not interactive")
            failed.append(name)

        # Save incrementally every 10 to preserve progress
        if i % 10 == 0:
            _save(data)
            print(f"  💾  Progress saved ({i} processed)")

        time.sleep(DELAY_SEC)

    # Final save
    _save(data)
    print(f"\n✅  Done! {success}/{len(targets)} schemas generated.")
    if failed:
        print(f"❌  Failed ({len(failed)}):")
        for n in failed:
            print(f"   - {n}")


def _save(data):
    with open(DATA_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


if __name__ == "__main__":
    main()
