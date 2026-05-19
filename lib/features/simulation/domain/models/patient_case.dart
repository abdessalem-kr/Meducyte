import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meducyte_app/features/simulation/domain/models/vitals.dart';
import 'package:meducyte_app/features/simulation/domain/models/clinical_media.dart';

part 'patient_case.freezed.dart';
part 'patient_case.g.dart';

@freezed
class PatientCase with _$PatientCase {
  const factory PatientCase({
    @JsonKey(fromJson: _idToString) required String id,
    required String name,
    required int age,
    required String gender,
    @JsonKey(name: 'main_complaint') required String mainComplaint,
    required String occupation,
    @JsonKey(name: 'medical_history') required String medicalHistory,
    required String personality,
    @JsonKey(name: 'target_pathology') required String targetPathology,
    @JsonKey(name: 'secret_details') required String secretDetails,
    @JsonKey(name: 'expected_findings') required List<String> expectedFindings,
    @JsonKey(name: 'initial_vitals') Vitals? initialVitals,
    @JsonKey(name: 'physical_exam_results') @Default({}) Map<String, String> physicalExamResults,
    @JsonKey(name: 'lab_results') @Default({}) Map<String, String> labResults,
    @JsonKey(name: 'media_findings') @Default({}) Map<String, ClinicalMedia> mediaFindings,
  }) = _PatientCase;

  factory PatientCase.fromJson(Map<String, dynamic> json) =>
      _$PatientCaseFromJson(json);
}

String _idToString(dynamic id) => id?.toString() ?? "";
