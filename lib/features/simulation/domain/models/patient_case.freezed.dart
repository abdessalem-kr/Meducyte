// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient_case.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PatientCase _$PatientCaseFromJson(Map<String, dynamic> json) {
  return _PatientCase.fromJson(json);
}

/// @nodoc
mixin _$PatientCase {
  @JsonKey(fromJson: _idToString)
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get age => throw _privateConstructorUsedError;
  String get gender => throw _privateConstructorUsedError;
  @JsonKey(name: 'main_complaint')
  String get mainComplaint => throw _privateConstructorUsedError;
  String get occupation => throw _privateConstructorUsedError;
  @JsonKey(name: 'medical_history')
  String get medicalHistory => throw _privateConstructorUsedError;
  String get personality => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_pathology')
  String get targetPathology => throw _privateConstructorUsedError;
  @JsonKey(name: 'secret_details')
  String get secretDetails => throw _privateConstructorUsedError;
  @JsonKey(name: 'expected_findings')
  List<String> get expectedFindings => throw _privateConstructorUsedError;
  @JsonKey(name: 'initial_vitals')
  Vitals? get initialVitals => throw _privateConstructorUsedError;
  @JsonKey(name: 'physical_exam_results')
  Map<String, String> get physicalExamResults =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'lab_results')
  Map<String, String> get labResults => throw _privateConstructorUsedError;
  @JsonKey(name: 'media_findings')
  Map<String, ClinicalMedia> get mediaFindings =>
      throw _privateConstructorUsedError;

  /// Serializes this PatientCase to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PatientCase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PatientCaseCopyWith<PatientCase> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatientCaseCopyWith<$Res> {
  factory $PatientCaseCopyWith(
    PatientCase value,
    $Res Function(PatientCase) then,
  ) = _$PatientCaseCopyWithImpl<$Res, PatientCase>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _idToString) String id,
    String name,
    int age,
    String gender,
    @JsonKey(name: 'main_complaint') String mainComplaint,
    String occupation,
    @JsonKey(name: 'medical_history') String medicalHistory,
    String personality,
    @JsonKey(name: 'target_pathology') String targetPathology,
    @JsonKey(name: 'secret_details') String secretDetails,
    @JsonKey(name: 'expected_findings') List<String> expectedFindings,
    @JsonKey(name: 'initial_vitals') Vitals? initialVitals,
    @JsonKey(name: 'physical_exam_results')
    Map<String, String> physicalExamResults,
    @JsonKey(name: 'lab_results') Map<String, String> labResults,
    @JsonKey(name: 'media_findings') Map<String, ClinicalMedia> mediaFindings,
  });

  $VitalsCopyWith<$Res>? get initialVitals;
}

/// @nodoc
class _$PatientCaseCopyWithImpl<$Res, $Val extends PatientCase>
    implements $PatientCaseCopyWith<$Res> {
  _$PatientCaseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PatientCase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? age = null,
    Object? gender = null,
    Object? mainComplaint = null,
    Object? occupation = null,
    Object? medicalHistory = null,
    Object? personality = null,
    Object? targetPathology = null,
    Object? secretDetails = null,
    Object? expectedFindings = null,
    Object? initialVitals = freezed,
    Object? physicalExamResults = null,
    Object? labResults = null,
    Object? mediaFindings = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            age: null == age
                ? _value.age
                : age // ignore: cast_nullable_to_non_nullable
                      as int,
            gender: null == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String,
            mainComplaint: null == mainComplaint
                ? _value.mainComplaint
                : mainComplaint // ignore: cast_nullable_to_non_nullable
                      as String,
            occupation: null == occupation
                ? _value.occupation
                : occupation // ignore: cast_nullable_to_non_nullable
                      as String,
            medicalHistory: null == medicalHistory
                ? _value.medicalHistory
                : medicalHistory // ignore: cast_nullable_to_non_nullable
                      as String,
            personality: null == personality
                ? _value.personality
                : personality // ignore: cast_nullable_to_non_nullable
                      as String,
            targetPathology: null == targetPathology
                ? _value.targetPathology
                : targetPathology // ignore: cast_nullable_to_non_nullable
                      as String,
            secretDetails: null == secretDetails
                ? _value.secretDetails
                : secretDetails // ignore: cast_nullable_to_non_nullable
                      as String,
            expectedFindings: null == expectedFindings
                ? _value.expectedFindings
                : expectedFindings // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            initialVitals: freezed == initialVitals
                ? _value.initialVitals
                : initialVitals // ignore: cast_nullable_to_non_nullable
                      as Vitals?,
            physicalExamResults: null == physicalExamResults
                ? _value.physicalExamResults
                : physicalExamResults // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            labResults: null == labResults
                ? _value.labResults
                : labResults // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            mediaFindings: null == mediaFindings
                ? _value.mediaFindings
                : mediaFindings // ignore: cast_nullable_to_non_nullable
                      as Map<String, ClinicalMedia>,
          )
          as $Val,
    );
  }

  /// Create a copy of PatientCase
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VitalsCopyWith<$Res>? get initialVitals {
    if (_value.initialVitals == null) {
      return null;
    }

    return $VitalsCopyWith<$Res>(_value.initialVitals!, (value) {
      return _then(_value.copyWith(initialVitals: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PatientCaseImplCopyWith<$Res>
    implements $PatientCaseCopyWith<$Res> {
  factory _$$PatientCaseImplCopyWith(
    _$PatientCaseImpl value,
    $Res Function(_$PatientCaseImpl) then,
  ) = __$$PatientCaseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _idToString) String id,
    String name,
    int age,
    String gender,
    @JsonKey(name: 'main_complaint') String mainComplaint,
    String occupation,
    @JsonKey(name: 'medical_history') String medicalHistory,
    String personality,
    @JsonKey(name: 'target_pathology') String targetPathology,
    @JsonKey(name: 'secret_details') String secretDetails,
    @JsonKey(name: 'expected_findings') List<String> expectedFindings,
    @JsonKey(name: 'initial_vitals') Vitals? initialVitals,
    @JsonKey(name: 'physical_exam_results')
    Map<String, String> physicalExamResults,
    @JsonKey(name: 'lab_results') Map<String, String> labResults,
    @JsonKey(name: 'media_findings') Map<String, ClinicalMedia> mediaFindings,
  });

  @override
  $VitalsCopyWith<$Res>? get initialVitals;
}

/// @nodoc
class __$$PatientCaseImplCopyWithImpl<$Res>
    extends _$PatientCaseCopyWithImpl<$Res, _$PatientCaseImpl>
    implements _$$PatientCaseImplCopyWith<$Res> {
  __$$PatientCaseImplCopyWithImpl(
    _$PatientCaseImpl _value,
    $Res Function(_$PatientCaseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PatientCase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? age = null,
    Object? gender = null,
    Object? mainComplaint = null,
    Object? occupation = null,
    Object? medicalHistory = null,
    Object? personality = null,
    Object? targetPathology = null,
    Object? secretDetails = null,
    Object? expectedFindings = null,
    Object? initialVitals = freezed,
    Object? physicalExamResults = null,
    Object? labResults = null,
    Object? mediaFindings = null,
  }) {
    return _then(
      _$PatientCaseImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        age: null == age
            ? _value.age
            : age // ignore: cast_nullable_to_non_nullable
                  as int,
        gender: null == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String,
        mainComplaint: null == mainComplaint
            ? _value.mainComplaint
            : mainComplaint // ignore: cast_nullable_to_non_nullable
                  as String,
        occupation: null == occupation
            ? _value.occupation
            : occupation // ignore: cast_nullable_to_non_nullable
                  as String,
        medicalHistory: null == medicalHistory
            ? _value.medicalHistory
            : medicalHistory // ignore: cast_nullable_to_non_nullable
                  as String,
        personality: null == personality
            ? _value.personality
            : personality // ignore: cast_nullable_to_non_nullable
                  as String,
        targetPathology: null == targetPathology
            ? _value.targetPathology
            : targetPathology // ignore: cast_nullable_to_non_nullable
                  as String,
        secretDetails: null == secretDetails
            ? _value.secretDetails
            : secretDetails // ignore: cast_nullable_to_non_nullable
                  as String,
        expectedFindings: null == expectedFindings
            ? _value._expectedFindings
            : expectedFindings // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        initialVitals: freezed == initialVitals
            ? _value.initialVitals
            : initialVitals // ignore: cast_nullable_to_non_nullable
                  as Vitals?,
        physicalExamResults: null == physicalExamResults
            ? _value._physicalExamResults
            : physicalExamResults // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        labResults: null == labResults
            ? _value._labResults
            : labResults // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        mediaFindings: null == mediaFindings
            ? _value._mediaFindings
            : mediaFindings // ignore: cast_nullable_to_non_nullable
                  as Map<String, ClinicalMedia>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PatientCaseImpl implements _PatientCase {
  const _$PatientCaseImpl({
    @JsonKey(fromJson: _idToString) required this.id,
    required this.name,
    required this.age,
    required this.gender,
    @JsonKey(name: 'main_complaint') required this.mainComplaint,
    required this.occupation,
    @JsonKey(name: 'medical_history') required this.medicalHistory,
    required this.personality,
    @JsonKey(name: 'target_pathology') required this.targetPathology,
    @JsonKey(name: 'secret_details') required this.secretDetails,
    @JsonKey(name: 'expected_findings')
    required final List<String> expectedFindings,
    @JsonKey(name: 'initial_vitals') this.initialVitals,
    @JsonKey(name: 'physical_exam_results')
    final Map<String, String> physicalExamResults = const {},
    @JsonKey(name: 'lab_results')
    final Map<String, String> labResults = const {},
    @JsonKey(name: 'media_findings')
    final Map<String, ClinicalMedia> mediaFindings = const {},
  }) : _expectedFindings = expectedFindings,
       _physicalExamResults = physicalExamResults,
       _labResults = labResults,
       _mediaFindings = mediaFindings;

  factory _$PatientCaseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PatientCaseImplFromJson(json);

  @override
  @JsonKey(fromJson: _idToString)
  final String id;
  @override
  final String name;
  @override
  final int age;
  @override
  final String gender;
  @override
  @JsonKey(name: 'main_complaint')
  final String mainComplaint;
  @override
  final String occupation;
  @override
  @JsonKey(name: 'medical_history')
  final String medicalHistory;
  @override
  final String personality;
  @override
  @JsonKey(name: 'target_pathology')
  final String targetPathology;
  @override
  @JsonKey(name: 'secret_details')
  final String secretDetails;
  final List<String> _expectedFindings;
  @override
  @JsonKey(name: 'expected_findings')
  List<String> get expectedFindings {
    if (_expectedFindings is EqualUnmodifiableListView)
      return _expectedFindings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_expectedFindings);
  }

  @override
  @JsonKey(name: 'initial_vitals')
  final Vitals? initialVitals;
  final Map<String, String> _physicalExamResults;
  @override
  @JsonKey(name: 'physical_exam_results')
  Map<String, String> get physicalExamResults {
    if (_physicalExamResults is EqualUnmodifiableMapView)
      return _physicalExamResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_physicalExamResults);
  }

  final Map<String, String> _labResults;
  @override
  @JsonKey(name: 'lab_results')
  Map<String, String> get labResults {
    if (_labResults is EqualUnmodifiableMapView) return _labResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_labResults);
  }

  final Map<String, ClinicalMedia> _mediaFindings;
  @override
  @JsonKey(name: 'media_findings')
  Map<String, ClinicalMedia> get mediaFindings {
    if (_mediaFindings is EqualUnmodifiableMapView) return _mediaFindings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_mediaFindings);
  }

  @override
  String toString() {
    return 'PatientCase(id: $id, name: $name, age: $age, gender: $gender, mainComplaint: $mainComplaint, occupation: $occupation, medicalHistory: $medicalHistory, personality: $personality, targetPathology: $targetPathology, secretDetails: $secretDetails, expectedFindings: $expectedFindings, initialVitals: $initialVitals, physicalExamResults: $physicalExamResults, labResults: $labResults, mediaFindings: $mediaFindings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatientCaseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.mainComplaint, mainComplaint) ||
                other.mainComplaint == mainComplaint) &&
            (identical(other.occupation, occupation) ||
                other.occupation == occupation) &&
            (identical(other.medicalHistory, medicalHistory) ||
                other.medicalHistory == medicalHistory) &&
            (identical(other.personality, personality) ||
                other.personality == personality) &&
            (identical(other.targetPathology, targetPathology) ||
                other.targetPathology == targetPathology) &&
            (identical(other.secretDetails, secretDetails) ||
                other.secretDetails == secretDetails) &&
            const DeepCollectionEquality().equals(
              other._expectedFindings,
              _expectedFindings,
            ) &&
            (identical(other.initialVitals, initialVitals) ||
                other.initialVitals == initialVitals) &&
            const DeepCollectionEquality().equals(
              other._physicalExamResults,
              _physicalExamResults,
            ) &&
            const DeepCollectionEquality().equals(
              other._labResults,
              _labResults,
            ) &&
            const DeepCollectionEquality().equals(
              other._mediaFindings,
              _mediaFindings,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    age,
    gender,
    mainComplaint,
    occupation,
    medicalHistory,
    personality,
    targetPathology,
    secretDetails,
    const DeepCollectionEquality().hash(_expectedFindings),
    initialVitals,
    const DeepCollectionEquality().hash(_physicalExamResults),
    const DeepCollectionEquality().hash(_labResults),
    const DeepCollectionEquality().hash(_mediaFindings),
  );

  /// Create a copy of PatientCase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PatientCaseImplCopyWith<_$PatientCaseImpl> get copyWith =>
      __$$PatientCaseImplCopyWithImpl<_$PatientCaseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PatientCaseImplToJson(this);
  }
}

abstract class _PatientCase implements PatientCase {
  const factory _PatientCase({
    @JsonKey(fromJson: _idToString) required final String id,
    required final String name,
    required final int age,
    required final String gender,
    @JsonKey(name: 'main_complaint') required final String mainComplaint,
    required final String occupation,
    @JsonKey(name: 'medical_history') required final String medicalHistory,
    required final String personality,
    @JsonKey(name: 'target_pathology') required final String targetPathology,
    @JsonKey(name: 'secret_details') required final String secretDetails,
    @JsonKey(name: 'expected_findings')
    required final List<String> expectedFindings,
    @JsonKey(name: 'initial_vitals') final Vitals? initialVitals,
    @JsonKey(name: 'physical_exam_results')
    final Map<String, String> physicalExamResults,
    @JsonKey(name: 'lab_results') final Map<String, String> labResults,
    @JsonKey(name: 'media_findings')
    final Map<String, ClinicalMedia> mediaFindings,
  }) = _$PatientCaseImpl;

  factory _PatientCase.fromJson(Map<String, dynamic> json) =
      _$PatientCaseImpl.fromJson;

  @override
  @JsonKey(fromJson: _idToString)
  String get id;
  @override
  String get name;
  @override
  int get age;
  @override
  String get gender;
  @override
  @JsonKey(name: 'main_complaint')
  String get mainComplaint;
  @override
  String get occupation;
  @override
  @JsonKey(name: 'medical_history')
  String get medicalHistory;
  @override
  String get personality;
  @override
  @JsonKey(name: 'target_pathology')
  String get targetPathology;
  @override
  @JsonKey(name: 'secret_details')
  String get secretDetails;
  @override
  @JsonKey(name: 'expected_findings')
  List<String> get expectedFindings;
  @override
  @JsonKey(name: 'initial_vitals')
  Vitals? get initialVitals;
  @override
  @JsonKey(name: 'physical_exam_results')
  Map<String, String> get physicalExamResults;
  @override
  @JsonKey(name: 'lab_results')
  Map<String, String> get labResults;
  @override
  @JsonKey(name: 'media_findings')
  Map<String, ClinicalMedia> get mediaFindings;

  /// Create a copy of PatientCase
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PatientCaseImplCopyWith<_$PatientCaseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
