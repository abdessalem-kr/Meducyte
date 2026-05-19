// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'specialty_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamFieldConfig _$ExamFieldConfigFromJson(Map<String, dynamic> json) =>
    ExamFieldConfig(
      key: json['key'] as String,
      label: json['label'] as String,
      normalText: json['normalText'] as String,
      localizationKey: json['localizationKey'] as String?,
    );

Map<String, dynamic> _$ExamFieldConfigToJson(ExamFieldConfig instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'normalText': instance.normalText,
      'localizationKey': instance.localizationKey,
    };

ExaminationSubStep _$ExaminationSubStepFromJson(Map<String, dynamic> json) =>
    ExaminationSubStep(
      action: json['action'] as String,
      description: json['description'] as String?,
      interpretation: json['interpretation'] as String?,
    );

Map<String, dynamic> _$ExaminationSubStepToJson(ExaminationSubStep instance) =>
    <String, dynamic>{
      'action': instance.action,
      'description': instance.description,
      'interpretation': instance.interpretation,
    };

ExaminationStep _$ExaminationStepFromJson(Map<String, dynamic> json) =>
    ExaminationStep(
      title: json['title'] as String,
      steps: (json['steps'] as List<dynamic>)
          .map((e) => ExaminationSubStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      clinicalPearl: json['clinicalPearl'] as String?,
      relatedFieldKeys: (json['relatedFieldKeys'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ExaminationStepToJson(ExaminationStep instance) =>
    <String, dynamic>{
      'title': instance.title,
      'steps': instance.steps,
      'clinicalPearl': instance.clinicalPearl,
      'relatedFieldKeys': instance.relatedFieldKeys,
    };

DiagnosticScore _$DiagnosticScoreFromJson(Map<String, dynamic> json) =>
    DiagnosticScore(
      name: json['name'] as String,
      description: json['description'] as String,
      criteria: (json['criteria'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      interpretation: json['interpretation'] as String,
    );

Map<String, dynamic> _$DiagnosticScoreToJson(DiagnosticScore instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'criteria': instance.criteria,
      'interpretation': instance.interpretation,
    };

PathologyGuide _$PathologyGuideFromJson(Map<String, dynamic> json) =>
    PathologyGuide(
      name: json['name'] as String,
      description: json['description'] as String?,
      focusedExam: (json['focusedExam'] as List<dynamic>?)
          ?.map((e) => ExaminationStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      scores: (json['scores'] as List<dynamic>?)
          ?.map((e) => DiagnosticScore.fromJson(e as Map<String, dynamic>))
          .toList(),
      redFlags: (json['redFlags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      immediateManagement: (json['immediateManagement'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      differentialDiagnosis: (json['differentialDiagnosis'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PathologyGuideToJson(PathologyGuide instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'focusedExam': instance.focusedExam,
      'scores': instance.scores,
      'redFlags': instance.redFlags,
      'immediateManagement': instance.immediateManagement,
      'differentialDiagnosis': instance.differentialDiagnosis,
    };
