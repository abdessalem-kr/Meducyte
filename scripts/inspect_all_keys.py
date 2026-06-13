import json

with open('/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/assets/data/medicalcul_ultimate_master.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

keys = set()
for item in data:
    keys.update(item.keys())

print("Unique keys in master JSON:", list(keys))
