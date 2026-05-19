import json
from collections import Counter

JSON_FILE = "assets/data/algerian_drugs.json"

with open(JSON_FILE, 'r', encoding='utf-8') as f:
    drugs = json.load(f)

dcis = [drug['generic_name'].upper() for drug in drugs]
counts = Counter(dcis)

print(f"Total entries: {len(drugs)}")
print(f"Unique DCIs: {len(counts)}")
print("\nTop 50 DCIs by frequency:")
for dci, count in counts.most_common(50):
    print(f"{count}: {dci}")
