import json
import os

input_path = "/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/assets/data/lab_normal_values.json"
output_path = "/Users/mac/Desktop/Mac/Projects/Utopia/meducyte_app/lib/features/explore/domain/models/lab_normal_values_data.dart"

def generate_dart():
    with open(input_path, "r", encoding="utf-8") as f:
        raw_data = json.load(f)

    entries = []
    current_category = "Biochimie sanguine"
    
    # Simple state machine to categorize and parse
    for row in raw_data:
        if not row or len(row) < 2:
            continue
            
        param = row[0]
        
        # Category headers (heuristics)
        if "Ionogramme" in param:
            current_category = "Ionogramme"
            continue
        if "Protéines sériques (électrophorèse)" in param:
            current_category = "Protéines (Electrophorèse)"
            continue
        if "Hématies" in param and "4,5 à 6" in str(row):
             current_category = "Hématologie (NFS)"
        if "Paramètre" in param:
            if "urinaire" in str(raw_data[raw_data.index(row)+1][0]).lower():
                current_category = "Biochimie urinaire"
            elif "LCR" in str(raw_data[raw_data.index(row)+1][0]) or "Cytologie" in str(raw_data[raw_data.index(row)+1][0]):
                current_category = "LCR"
            continue
        if "FSH" in param and "Hormonologie" not in current_category:
            current_category = "Hormonologie"

        # Skip sub-headers or empty rows
        if param.startswith("1)") or param.startswith("2)") or not any(row[1:]):
            continue

        # Map to object
        entry = {
            "parameter": param.replace("• ", "").strip(),
            "tradValue": row[1] if len(row) > 1 else "",
            "siValue": row[2] if len(row) > 2 else "",
            "category": current_category
        }
        
        # Special case for Hematology grid
        if len(row) > 3:
             entry["men"] = row[1]
             entry["women"] = row[2]
             entry["children"] = row[3]
             entry["neonates"] = row[4] if len(row) > 4 else ""
             entry["category"] = "Hématologie (Grille)"

        entries.append(entry)

    # Generate Dart code
    dart_code = """class LabNormalValueEntry {
  final String parameter;
  final String tradValue;
  final String siValue;
  final String category;
  final String? men;
  final String? women;
  final String? children;
  final String? neonates;

  const LabNormalValueEntry({
    required this.parameter,
    required this.tradValue,
    required this.siValue,
    required this.category,
    this.men,
    this.women,
    this.children,
    this.neonates,
  });
}

class LabNormalValuesData {
  static const List<LabNormalValueEntry> entries = [
"""
    for e in entries:
        dart_code += f"    LabNormalValueEntry(\n"
        dart_code += f"      parameter: r'{e['parameter']}',\n"
        dart_code += f"      tradValue: r'{e['tradValue']}',\n"
        dart_code += f"      siValue: r'{e['siValue']}',\n"
        dart_code += f"      category: r'{e['category']}',\n"
        if "men" in e:
            dart_code += f"      men: r'{e['men']}',\n"
            dart_code += f"      women: r'{e['women']}',\n"
            dart_code += f"      children: r'{e['children']}',\n"
            dart_code += f"      neonates: r'{e['neonates']}',\n"
        dart_code += f"    ),\n"
        
    dart_code += "  ];\n}\n"

    with open(output_path, "w", encoding="utf-8") as f:
        f.write(dart_code)
    print(f"Generated {len(entries)} entries to {output_path}")

if __name__ == "__main__":
    generate_dart()
