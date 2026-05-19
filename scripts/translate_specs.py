import json

translations = {
    "spec_general": {"en": "General Practice", "fr": "Médecine Générale"},
    "spec_cardiology": {"en": "Cardiology", "fr": "Cardiologie"},
    "spec_neurology": {"en": "Neurology", "fr": "Neurologie"},
    "spec_anesthesiereanimation": {"en": "Anesthesia and Recovery", "fr": "Anesthésie Réanimation"},
    "spec_anesthesiereanimationpediatrique": {"en": "Pediatric Anesthesia", "fr": "Anesthésie Réanimation Pédiatrique"},
    "spec_biophysiquemedicale": {"en": "Medical Biophysics", "fr": "Biophysique Médicale"},
    "spec_dermatologieetvenereologie": {"en": "Dermatology and Venereology", "fr": "Dermatologie et Vénéréologie"},
    "spec_diabetologieendocrinologieetmaladiesmetaboliques": {"en": "Endocrinology, Diabetes, and Metabolism", "fr": "Diabétologie Endocrinologie et Maladies Métaboliques"},
    "spec_epidemiologieetmedecinepreventive": {"en": "Epidemiology and Preventive Medicine", "fr": "Épidémiologie et Médecine Préventive"},
    "spec_hepatogastroenterologie": {"en": "Hepato-Gastroenterology", "fr": "Hépato-Gastro-Entérologie"},
    "spec_hematologie": {"en": "Hematology", "fr": "Hématologie"},
    "spec_gynecologieobstetrique": {"en": "Gynecology and Obstetrics", "fr": "Gynécologie-Obstétrique"},
    "spec_infectiologie": {"en": "Infectious Diseases", "fr": "Infectiologie"},
    "spec_medecineinterne": {"en": "Internal Medicine", "fr": "Médecine Interne"},
    "spec_medecinelegaledroitmedicaletethique": {"en": "Legal Medicine and Medical Ethics", "fr": "Médecine Légale - Droit Médical et Éthique"},
    "spec_medecinenucleaireetimageriemoleculaire": {"en": "Nuclear Medicine and Molecular Imaging", "fr": "Médecine Nucléaire et Imagerie Moléculaire"},
    "spec_medecinedusport": {"en": "Sports Medicine", "fr": "Médecine du Sport"},
    "spec_medecinedutravail": {"en": "Occupational Medicine", "fr": "Médecine du Travail"},
    "spec_medecinephysiqueetreadaptation": {"en": "Physical Medicine and Rehabilitation", "fr": "Médecine Physique et Réadaptation"},
    "spec_nephrologie": {"en": "Nephrology", "fr": "Néphrologie"},
    "spec_oncologiemedicale": {"en": "Medical Oncology", "fr": "Oncologie Médicale"},
    "spec_ophtalmologie": {"en": "Ophthalmology", "fr": "Ophtalmologie"},
    "spec_orl": {"en": "ENT (Otolaryngology)", "fr": "ORL"},
    "spec_pediatrie": {"en": "Pediatrics", "fr": "Pédiatrie"},
    "spec_psychiatrie": {"en": "Psychiatry", "fr": "Psychiatrie"},
    "spec_pedopsychiatrie": {"en": "Child Psychiatry", "fr": "Pédopsychiatrie"},
    "spec_pneumophtisiologie": {"en": "Pulmonology and Phthisiology", "fr": "Pneumo-Phtisiologie"},
    "spec_radiotherapieoncologie": {"en": "Radiation Oncology", "fr": "Radiothérapie Oncologie"},
    "spec_rhumatologie": {"en": "Rheumatology", "fr": "Rhumatologie"},
    "spec_reanimationmedicale": {"en": "Medical Intensive Care", "fr": "Réanimation Médicale"},
    "spec_chirurgiegenerale": {"en": "General Surgery", "fr": "Chirurgie Générale"},
    "spec_chirurgiecardiaque": {"en": "Cardiac Surgery", "fr": "Chirurgie Cardiaque"},
    "spec_chirurgiemaxillofaciale": {"en": "Maxillofacial Surgery", "fr": "Chirurgie Maxillo-Faciale"},
    "spec_chirurgieneurologique": {"en": "Neurosurgery", "fr": "Chirurgie Neurologique"},
    "spec_chirurgieorthopediqueettraumatologie": {"en": "Orthopedic Surgery and Traumatology", "fr": "Chirurgie Orthopédique et Traumatologie"},
    "spec_chirurgiepediatrique": {"en": "Pediatric Surgery", "fr": "Chirurgie Pédiatrique"},
    "spec_chirurgiethoracique": {"en": "Thoracic Surgery", "fr": "Chirurgie Thoracique"},
    "spec_chirurgieurologique": {"en": "Urological Surgery", "fr": "Chirurgie Urologique"},
    "spec_chirurgievasculaire": {"en": "Vascular Surgery", "fr": "Chirurgie Vasculaire"},
    "spec_chirurgieplastiquereconstructriceesthetiqueetdebrulologie": {"en": "Plastic, Reconstructive, and Aesthetic Surgery", "fr": "Chirurgie Plastique, Reconstructrice, Esthétique et Brûlologie"},
    "selectSpecialty": {"en": "Select Specialty", "fr": "Choisir une spécialité"},
    "chooseTemplateDescription": {"en": "Choose a template tailored to your medical specialty for faster reporting.", "fr": "Choisissez un modèle adapté à votre spécialité pour des rapports plus rapides."}
}

en_path = "lib/l10n/arb/intl_en.arb"
fr_path = "lib/l10n/arb/intl_fr.arb"

def update_arb(path, lang):
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    for key, val in translations.items():
        data[key] = val[lang]
        
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

update_arb(en_path, "en")
update_arb(fr_path, "fr")
print("Updated ARB files successfully.")

dart_code = """import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meducyte_app/features/observation/data/models/specialty_config.dart';

extension MedicalSpecialtyLocalization on MedicalSpecialty {
  String localizedName(BuildContext context) {
    switch (this) {
"""
for spec_key in translations.keys():
    if spec_key.startswith("spec_"):
        enum_val = spec_key.split("spec_")[1]
        dart_code += f"      case MedicalSpecialty.{enum_val}:\n"
        dart_code += f"        return AppLocalizations.of(context)!.{spec_key};\n"
dart_code += """    }
  }
}
"""
with open('lib/features/observation/data/models/specialty_localization.dart', 'w') as f:
    f.write(dart_code)
print("Generated Dart extension.")
