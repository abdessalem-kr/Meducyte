class CalculatorCategory {
  final String id;
  final String name;
  final List<MedicalCalculatorMetadata> calculators;

  CalculatorCategory({
    required this.id,
    required this.name,
    required this.calculators,
  });

  factory CalculatorCategory.fromJson(Map<String, dynamic> json) {
    return CalculatorCategory(
      id: json['id'],
      name: json['name'],
      calculators: (json['calculators'] as List)
          .map((c) => MedicalCalculatorMetadata.fromJson(c))
          .toList(),
    );
  }
}

class MedicalCalculatorMetadata {
  final String id;
  final String name;
  final String descriptionEn;
  final String descriptionFr;
  final String url;
  final CalculatorEngineSchema? schema;

  MedicalCalculatorMetadata({
    required this.id,
    required this.name,
    required this.descriptionEn,
    required this.descriptionFr,
    required this.url,
    this.schema,
  });

  factory MedicalCalculatorMetadata.fromJson(Map<String, dynamic> json) {
    return MedicalCalculatorMetadata(
      id: json['id'],
      name: json['name'],
      descriptionEn: json['description_en'] ?? json['description'] ?? '',
      descriptionFr: json['description_fr'] ?? json['description'] ?? '',
      url: json['url'],
      schema: json['schema'] != null
          ? CalculatorEngineSchema.fromJson(json['schema'])
          : null,
    );
  }

  String localizedDescription(String lang) {
    if (lang == 'fr') return descriptionFr;
    return descriptionEn;
  }
}

class CalculatorEngineSchema {
  final List<CalculatorCriterion> criteria;
  final List<ScoreInterpretation> interpretations;
  final String? interpretationText;

  CalculatorEngineSchema({
    required this.criteria,
    required this.interpretations,
    this.interpretationText,
  });

  factory CalculatorEngineSchema.fromJson(Map<String, dynamic> json) {
    return CalculatorEngineSchema(
      criteria: (json['criteria'] as List)
          .map((c) => CalculatorCriterion.fromJson(c))
          .toList(),
      interpretations: (json['interpretations'] as List)
          .map((i) => ScoreInterpretation.fromJson(i))
          .toList(),
      interpretationText: json['interpretation_text'],
    );
  }
}

class CalculatorCriterion {
  final String label;
  final String type; // 'checkbox', 'radio', 'numeric'
  final double? points; //for checkbox
  final List<CriterionOption>? options; //for radio
  final String? unit; //for numeric
  final double? defaultValue; //for numeric
  final String? value; //for static

  CalculatorCriterion({
    required this.label,
    required this.type,
    this.points,
    this.options,
    this.unit,
    this.defaultValue,
    this.value,
  });

  factory CalculatorCriterion.fromJson(Map<String, dynamic> json) {
    return CalculatorCriterion(
      label: json['label'],
      type: json['type'],
      points: json['points']?.toDouble(),
      unit: json['unit'],
      defaultValue: json['default_value']?.toDouble(),
      value: json['value'],
      options: json['options'] != null
          ? (json['options'] as List)
                .map((o) => CriterionOption.fromJson(o))
                .toList()
          : null,
    );
  }
}

class CriterionOption {
  final String label;
  final double points;

  CriterionOption({required this.label, required this.points});

  factory CriterionOption.fromJson(Map<String, dynamic> json) {
    return CriterionOption(
      label: json['label'],
      points: json['points'].toDouble(),
    );
  }
}

class ScoreInterpretation {
  final double min;
  final double max;
  final String label;
  final String? color;

  ScoreInterpretation({
    required this.min,
    required this.max,
    required this.label,
    this.color,
  });

  factory ScoreInterpretation.fromJson(Map<String, dynamic> json) {
    return ScoreInterpretation(
      min: json['min'].toDouble(),
      max: json['max'].toDouble(),
      label: json['label'],
      color: json['color'],
    );
  }
}
