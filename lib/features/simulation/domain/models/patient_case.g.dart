// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_case.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PatientCaseImpl _$$PatientCaseImplFromJson(Map<String, dynamic> json) =>
    _$PatientCaseImpl(
      id: _idToString(json['id']),
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      gender: json['gender'] as String,
      mainComplaint: json['main_complaint'] as String,
      occupation: json['occupation'] as String,
      medicalHistory: json['medical_history'] as String,
      personality: json['personality'] as String,
      targetPathology: json['target_pathology'] as String,
      secretDetails: json['secret_details'] as String,
      expectedFindings: (json['expected_findings'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      initialVitals: json['initial_vitals'] == null
          ? null
          : Vitals.fromJson(json['initial_vitals'] as Map<String, dynamic>),
      physicalExamResults:
          (json['physical_exam_results'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      labResults:
          (json['lab_results'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      mediaFindings:
          (json['media_findings'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, ClinicalMedia.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
    );

Map<String, dynamic> _$$PatientCaseImplToJson(_$PatientCaseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'age': instance.age,
      'gender': instance.gender,
      'main_complaint': instance.mainComplaint,
      'occupation': instance.occupation,
      'medical_history': instance.medicalHistory,
      'personality': instance.personality,
      'target_pathology': instance.targetPathology,
      'secret_details': instance.secretDetails,
      'expected_findings': instance.expectedFindings,
      'initial_vitals': instance.initialVitals,
      'physical_exam_results': instance.physicalExamResults,
      'lab_results': instance.labResults,
      'media_findings': instance.mediaFindings,
    };
