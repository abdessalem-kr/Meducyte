import json
import os

path = '/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/assets/data/medicalcul_master_data.json'
if os.path.exists(path):
    print("medicalcul_master_data.json exists!")
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    print("Top-level keys:", list(data.keys()))
    for k, v in data.items():
        if isinstance(v, list):
            print(f"  Key '{k}' is a list of length {len(v)}")
            if len(v) > 0:
                print(f"    Sample item keys in '{k}':", list(v[0].keys()) if isinstance(v[0], dict) else type(v[0]))
        else:
            print(f"  Key '{k}' is a {type(v)}")
