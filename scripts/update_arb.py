import json
import os

def update_arb(file_path, new_keys):
    with open(file_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    
    data.update(new_keys)
    
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Updated {file_path}")

en_path = "/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/lib/l10n/arb/intl_en.arb"
fr_path = "/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/lib/l10n/arb/intl_fr.arb"

new_keys_en = {
    "labNormalValues": "Normal Values",
    "searchParameter": "Search parameter...",
    "unitSI": "SI Unit",
    "unitTrad": "Trad. Unit",
    "paramReference": "Reference Sheet"
}

new_keys_fr = {
    "labNormalValues": "Valeurs Normales",
    "searchParameter": "Rechercher un paramètre...",
    "unitSI": "Unité SI",
    "unitTrad": "Unité Trad.",
    "paramReference": "Feuille de Référence"
}

update_arb(en_path, new_keys_en)
update_arb(fr_path, new_keys_fr)
