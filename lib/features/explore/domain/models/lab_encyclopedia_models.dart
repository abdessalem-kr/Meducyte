class LabEntry {
  final String id;
  final String name;
  final String? abbreviation;
  final String category;
  final String introduction;
  final String collectionPrecautions;
  final List<LabNormalValue> normalValues;
  final String clinique;
  final List<String>? remarks;

  const LabEntry({
    required this.id,
    required this.name,
    this.abbreviation,
    required this.category,
    required this.introduction,
    required this.collectionPrecautions,
    required this.normalValues,
    required this.clinique,
    this.remarks,
  });

  factory LabEntry.fromJson(Map<String, dynamic> json) {
    return LabEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      abbreviation: json['abbreviation'] as String?,
      category: json['category'] as String? ?? 'Général',
      introduction:
          json['introduction'] as String? ??
          json['physiopathology'] as String? ??
          '',
      collectionPrecautions:
          json['collectionPrecautions'] as String? ?? 'Non précisé',
      normalValues:
          (json['normalValues'] as List<dynamic>?)
              ?.map((e) => LabNormalValue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      clinique: json['clinique'] as String? ?? '',
      remarks: (json['remarks'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}

class LabNormalValue {
  final String? population;
  final String traditionalValue;
  final String? siValue;
  final String? unit;

  const LabNormalValue({
    this.population,
    required this.traditionalValue,
    this.siValue,
    this.unit,
  });

  factory LabNormalValue.fromJson(Map<String, dynamic> json) {
    return LabNormalValue(
      population: json['population'] as String?,
      traditionalValue: json['traditionalValue'] as String? ?? '',
      siValue: json['siValue'] as String?,
      unit: json['unit'] as String?,
    );
  }
}
