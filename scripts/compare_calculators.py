import json

backup_path = '/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/assets/data/medical_calculators.backup.json'
with open(backup_path, 'r', encoding='utf-8') as f:
    backup_data = json.load(f)

print("Type of backup_data:", type(backup_data))
if isinstance(backup_data, list):
    print("Length of list:", len(backup_data))
    if len(backup_data) > 0:
        print("Keys of first item:", list(backup_data[0].keys()) if isinstance(backup_data[0], dict) else type(backup_data[0]))
elif isinstance(backup_data, dict):
    print("Keys of dict:", list(backup_data.keys()))
