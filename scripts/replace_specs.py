import os

header = """import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

{enum_str}

class ExamFieldConfig {
  final String key;
  final String label;
  final String normalText;

  const ExamFieldConfig({
    required this.key,
    required this.label,
    required this.normalText,
  });
}

class SpecialtyFormConfig {
  final MedicalSpecialty specialty;
  final String title;
  final IconData icon;
  final List<String> commonSymptoms;
  final List<ExamFieldConfig> examFields;

  const SpecialtyFormConfig({
    required this.specialty,
    required this.title,
    required this.icon,
    required this.commonSymptoms,
    required this.examFields,
  });
}

class SpecialtyConfigs {
"""

cardiology_str = """  static const cardiology = SpecialtyFormConfig(
    specialty: MedicalSpecialty.cardiology,
    title: 'Cardiology',
    icon: Iconsax.heart,
    commonSymptoms: [
      'Chest Pain',
      'Palpitations',
      'Shortness of breath (Dyspnea)',
      'Orthopnea',
      'Paroxysmal Nocturnal Dyspnea',
      'Syncope',
      'Dizziness',
      'Peripheral Edema',
      'Fatigue',
    ],
    examFields: [
      ExamFieldConfig(
        key: 'general',
        label: 'General Appearance',
        normalText: 'Alert, no respiratory distress, normal body habitus.',
      ),
      ExamFieldConfig(
        key: 'jvp',
        label: 'Jugular Venous Pressure',
        normalText: 'JVP non-elevated, normal waveform.',
      ),
      ExamFieldConfig(
        key: 'heart_sounds',
        label: 'Heart Sounds',
        normalText: 'Normal S1, S2. No S3, S4, or murmurs. No rubs or gallops.',
      ),
      ExamFieldConfig(
        key: 'pulses',
        label: 'Peripheral Pulses',
        normalText: '2+ symmetric in radials and dorsalis pedis bilaterally.',
      ),
      ExamFieldConfig(
        key: 'edema',
        label: 'Extremities / Edema',
        normalText: 'Warm, well-perfused. No peripheral edema.',
      ),
      ExamFieldConfig(
        key: 'ecg',
        label: 'ECG Findings (Optional)',
        normalText: 'Normal Sinus Rhythm, normal axis, no ST-T wave changes.',
      ),
    ],
  );
"""

neurology_str = """  static const neurology = SpecialtyFormConfig(
    specialty: MedicalSpecialty.neurology,
    title: 'Neurology',
    icon: Iconsax.activity,
    commonSymptoms: [
      'Headache',
      'Dizziness / Vertigo',
      'Weakness',
      'Numbness / Tingling',
      'Seizures',
      'Memory loss',
      'Speech difficulty',
      'Tremor',
      'Visual disturbance',
      'Loss of consciousness',
    ],
    examFields: [
      ExamFieldConfig(
        key: 'general',
        label: 'General Appearance',
        normalText: 'Awake, alert, comfortable.',
      ),
      ExamFieldConfig(
        key: 'mental_status',
        label: 'Mental Status',
        normalText:
            'Oriented to person, place, and time. Normal attention, language, and memory.',
      ),
      ExamFieldConfig(
        key: 'cranial_nerves',
        label: 'Cranial Nerves',
        normalText: 'CN II-XII intact and symmetric bilaterally.',
      ),
      ExamFieldConfig(
        key: 'motor',
        label: 'Motor System',
        normalText:
            'Normal muscle tone and bulk. Strength 5/5 in all extremities.',
      ),
      ExamFieldConfig(
        key: 'sensory',
        label: 'Sensory System',
        normalText:
            'Intact to light touch, pinprick, temperature, and vibration globally.',
      ),
      ExamFieldConfig(
        key: 'reflexes',
        label: 'Reflexes',
        normalText:
            '2+ symmetric throughout. Plantar responses flexor bilaterally.',
      ),
      ExamFieldConfig(
        key: 'coordination',
        label: 'Coordination / Gait',
        normalText:
            'Normal finger-to-nose and heel-to-shin. Normal gait and tandem walk.',
      ),
    ],
  );
"""

footer = "}\n"

with open('output.txt', 'r') as f:
    text = f.read()

enum_part = text.split('\n\n')[0]
configs_part = "\n\n".join(text.split('\n\n')[1:-1])
list_part = text.split('\n')[-2]

full_file = (header.replace('{enum_str}', enum_part) +
            configs_part + "\n" +
            cardiology_str + "\n" +
            neurology_str + "\n" +
            list_part + "\n" + footer)

with open('lib/features/observation/data/models/specialty_config.dart', 'w') as f:
    f.write(full_file)
