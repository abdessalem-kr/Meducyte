//meducyte_app/lib/features/drugs/domain/models/drug_models.dart

enum InteractionSeverity { none, minor, moderate, severe }

class Drug {
  final String id;
  final String name;
  final String genericName;
  final String drugClass; //For"Form-Lab"or other display info
  final String? therapeuticClass; //e.g., "Antalgiques"
  final String? category; //e.g., "Gastro-Entérologie"
  final List<String> indications;
  final List<String> contraindications;
  final String dosage;
  final String sideEffects;
  final String mechanismOfAction;

  Drug({
    required this.id,
    required this.name,
    required this.genericName,
    required this.drugClass,
    this.therapeuticClass,
    this.category,
    required this.indications,
    required this.contraindications,
    required this.dosage,
    required this.sideEffects,
    required this.mechanismOfAction,
  });

  bool get isFree {
    final lowerName = name.toLowerCase();
    final lowerGeneric = genericName.toLowerCase();
    return lowerName.contains('paracetamol') ||
        lowerName.contains('aspirin') ||
        lowerName.contains('aspirine') ||
        lowerName.contains('ibuprofen') ||
        lowerName.contains('ibuprofène') ||
        lowerName.contains('amoxicillin') ||
        lowerName.contains('amoxicilline') ||
        lowerGeneric.contains('paracetamol') ||
        lowerGeneric.contains('aspirin');
  }

  factory Drug.fromJson(Map<String, dynamic> json) {
    String normalize(dynamic value) {
      if (value == null) return '';
      if (value is List) return value.join('. ');
      return value.toString();
    }

    return Drug(
      id: json['id'] as String,
      name: json['name'] as String,
      genericName: json['generic_name'] as String,
      drugClass: json['drug_class'] as String,
      therapeuticClass: json['therapeutic_class'] as String?,
      category: json['category'] as String?,
      indications: json['indications'] is List
          ? List<String>.from(json['indications'] as List)
          : [],
      contraindications: json['contraindications'] is List
          ? List<String>.from(json['contraindications'] as List)
          : [],
      dosage: normalize(json['dosage']),
      sideEffects: normalize(json['side_effects']),
      mechanismOfAction: normalize(json['mechanism_of_action']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'generic_name': genericName,
      'drug_class': drugClass,
      'therapeutic_class': therapeuticClass,
      'category': category,
      'indications': indications,
      'contraindications': contraindications,
      'dosage': dosage,
      'side_effects': sideEffects,
      'mechanism_of_action': mechanismOfAction,
    };
  }
}

class DrugInteraction {
  final String drugId1;
  final String drugId2;
  final InteractionSeverity severity;
  final String description;
  final String management;

  DrugInteraction({
    required this.drugId1,
    required this.drugId2,
    required this.severity,
    required this.description,
    required this.management,
  });

  factory DrugInteraction.fromJson(Map<String, dynamic> json) {
    return DrugInteraction(
      drugId1: json['drug_id_1'] as String,
      drugId2: json['drug_id_2'] as String,
      severity: InteractionSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => InteractionSeverity.none,
      ),
      description: json['description'] as String,
      management: json['management'] as String,
    );
  }
}
