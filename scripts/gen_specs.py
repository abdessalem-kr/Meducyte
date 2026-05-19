import json

specialties_med = [
    "ANESTHESIE REANIMATION",
    "ANESTHESIE REANIMATION PEDIATRIQUE",
    "BIOPHYSIQUE MEDICALE",
    "CARDIOLOGIE",
    "DERMATOLOGIE ET VENEREOLOGIE",
    "DIABETOLOGIE ENDOCRINOLOGIE ET MALADIES METABOLIQUES",
    "EPIDEMIOLOGIE ET MEDECINE PREVENTIVE",
    "HEPATO-GASTRO-ENTEROLOGIE",
    "HEMATOLOGIE",
    "GYNECOLOGIE-OBSTETRIQUE",
    "INFECTIOLOGIE",
    "MEDECINE INTERNE",
    "MEDECINE LEGALE - DROIT MEDICAL ET ETHIQUE",
    "MEDECINE NUCLEAIRE ET IMAGERIE MOLECULAIRE",
    "MEDECINE DU SPORT",
    "MEDECINE DU TRAVAIL",
    "MEDECINE PHYSIQUE ET READAPTATION",
    "NEUROLOGIE",
    "NEPHROLOGIE",
    "ONCOLOGIE MEDICALE",
    "OPHTALMOLOGIE",
    "ORL",
    "PEDIATRIE",
    "PSYCHIATRIE",
    "PEDOPSYCHIATRIE",
    "PNEUMO-PHTISIOLOGIE",
    "RADIOTHERAPIE ONCOLOGIE",
    "RHUMATOLOGIE",
    "REANIMATION MEDICALE"
]

specialties_chir = [
    "CHIRURGIE GENERALE",
    "CHIRURGIE CARDIAQUE",
    "CHIRURGIE MAXILLO-FACIALE",
    "CHIRURGIE NEUROLOGIQUE",
    "CHIRURGIE ORTHOPEDIQUE ET TRAUMATOLOGIE",
    "CHIRURGIE PEDIATRIQUE",
    "CHIRURGIE THORACIQUE",
    "CHIRURGIE UROLOGIQUE",
    "CHIRURGIE VASCULAIRE",
    "CHIRURGIE PLASTIQUE RECONSTRUCTRICE ESTHETIQUE ET DE BRULOLOGIE"
]

all_specialties = specialties_med + specialties_chir

def titlize(s):
    # Capitalize first letter of each word except small ones, but simplistic
    words = s.lower().split()
    return " ".join(w.capitalize() for w in words)

def standardize(s):
    # remove hyphens and spaces
    return s.lower().replace(" ", "").replace("-", "")

enum_vals = []
config_vals = []
config_names = []

for s in all_specialties:
    title = titlize(s)
    enum_name = standardize(title)
    
    # We already have cardiology and neurology specific, handle them
    if enum_name == "cardiologie":
        enum_name = "cardiology"
        title = "Cardiologie"
    elif enum_name == "neurologie":
        enum_name = "neurology"
        title = "Neurologie"
        
    if enum_name not in ["cardiology", "neurology"]:
        enum_vals.append(enum_name)
    
        config_text = f'''
  static const {enum_name} = SpecialtyFormConfig(
    specialty: MedicalSpecialty.{enum_name},
    title: '{title}',
    icon: Iconsax.health,  // Generic icon
    commonSymptoms: [
      'Fever',
      'Cough',
      'Shortness of breath',
      'Fatigue',
      'Headache',
      'Chest Pain',
      'Nausea',
      'Vomiting',
      'Diarrhea',
      'Abdominal Pain',
      'Dizziness',
      'Chills',
    ],
    examFields: [
      ExamFieldConfig(
        key: 'general',
        label: 'General',
        normalText: 'Well-appearing, in no acute distress.',
      ),
      ExamFieldConfig(
        key: 'cardiovascular',
        label: 'Cardiovascular',
        normalText: 'Regular rate and rhythm, normal S1/S2, no murmurs.',
      ),
      ExamFieldConfig(
        key: 'respiratory',
        label: 'Respiratory',
        normalText:
            'Clear to auscultation bilaterally, no wheezes, rales, or rhonchi.',
      ),
      ExamFieldConfig(
        key: 'abdominal',
        label: 'Abdominal',
        normalText: 'Soft, non-tender, non-distended, normal bowel sounds.',
      ),
      ExamFieldConfig(
        key: 'neurological',
        label: 'Neurological',
        normalText:
            'Alert and oriented x3, cranial nerves II-XII intact, normal strength and sensation.',
      ),
    ],
  );
'''
        config_vals.append(config_text)
        config_names.append(enum_name)

# Make enum string
all_enums = ["general", "cardiology", "neurology"] + enum_vals
enum_str = "enum MedicalSpecialty { " + ", ".join(all_enums) + " }"

# Add back cardiology and neurology and general to config_names
all_config_names = ["general", "cardiology", "neurology"] + config_names
all_list_str = "static const List<SpecialtyFormConfig> all = [\n    " + ",\n    ".join(all_config_names) + "\n  ];"

with open("output.txt", "w") as f:
    f.write(enum_str + "\n\n")
    for cv in config_vals:
        f.write(cv + "\n")
    f.write(all_list_str + "\n")

print("Done")
