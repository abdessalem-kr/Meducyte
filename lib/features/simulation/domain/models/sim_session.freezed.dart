// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sim_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SimSession _$SimSessionFromJson(Map<String, dynamic> json) {
  return _SimSession.fromJson(json);
}

/// @nodoc
mixin _$SimSession {
  String get id => throw _privateConstructorUsedError;
  PatientCase get patientCase => throw _privateConstructorUsedError;
  List<SimMessage> get messages => throw _privateConstructorUsedError;
  SimulationDifficulty get difficulty => throw _privateConstructorUsedError;
  SimulationSetting get setting => throw _privateConstructorUsedError;
  bool get isFinished => throw _privateConstructorUsedError;
  bool get isTyping => throw _privateConstructorUsedError;
  String? get userDiagnosis => throw _privateConstructorUsedError;
  int? get score => throw _privateConstructorUsedError;
  String? get feedback => throw _privateConstructorUsedError;

  /// Serializes this SimSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SimSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SimSessionCopyWith<SimSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SimSessionCopyWith<$Res> {
  factory $SimSessionCopyWith(
    SimSession value,
    $Res Function(SimSession) then,
  ) = _$SimSessionCopyWithImpl<$Res, SimSession>;
  @useResult
  $Res call({
    String id,
    PatientCase patientCase,
    List<SimMessage> messages,
    SimulationDifficulty difficulty,
    SimulationSetting setting,
    bool isFinished,
    bool isTyping,
    String? userDiagnosis,
    int? score,
    String? feedback,
  });

  $PatientCaseCopyWith<$Res> get patientCase;
}

/// @nodoc
class _$SimSessionCopyWithImpl<$Res, $Val extends SimSession>
    implements $SimSessionCopyWith<$Res> {
  _$SimSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SimSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientCase = null,
    Object? messages = null,
    Object? difficulty = null,
    Object? setting = null,
    Object? isFinished = null,
    Object? isTyping = null,
    Object? userDiagnosis = freezed,
    Object? score = freezed,
    Object? feedback = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            patientCase: null == patientCase
                ? _value.patientCase
                : patientCase // ignore: cast_nullable_to_non_nullable
                      as PatientCase,
            messages: null == messages
                ? _value.messages
                : messages // ignore: cast_nullable_to_non_nullable
                      as List<SimMessage>,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as SimulationDifficulty,
            setting: null == setting
                ? _value.setting
                : setting // ignore: cast_nullable_to_non_nullable
                      as SimulationSetting,
            isFinished: null == isFinished
                ? _value.isFinished
                : isFinished // ignore: cast_nullable_to_non_nullable
                      as bool,
            isTyping: null == isTyping
                ? _value.isTyping
                : isTyping // ignore: cast_nullable_to_non_nullable
                      as bool,
            userDiagnosis: freezed == userDiagnosis
                ? _value.userDiagnosis
                : userDiagnosis // ignore: cast_nullable_to_non_nullable
                      as String?,
            score: freezed == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int?,
            feedback: freezed == feedback
                ? _value.feedback
                : feedback // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of SimSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PatientCaseCopyWith<$Res> get patientCase {
    return $PatientCaseCopyWith<$Res>(_value.patientCase, (value) {
      return _then(_value.copyWith(patientCase: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SimSessionImplCopyWith<$Res>
    implements $SimSessionCopyWith<$Res> {
  factory _$$SimSessionImplCopyWith(
    _$SimSessionImpl value,
    $Res Function(_$SimSessionImpl) then,
  ) = __$$SimSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    PatientCase patientCase,
    List<SimMessage> messages,
    SimulationDifficulty difficulty,
    SimulationSetting setting,
    bool isFinished,
    bool isTyping,
    String? userDiagnosis,
    int? score,
    String? feedback,
  });

  @override
  $PatientCaseCopyWith<$Res> get patientCase;
}

/// @nodoc
class __$$SimSessionImplCopyWithImpl<$Res>
    extends _$SimSessionCopyWithImpl<$Res, _$SimSessionImpl>
    implements _$$SimSessionImplCopyWith<$Res> {
  __$$SimSessionImplCopyWithImpl(
    _$SimSessionImpl _value,
    $Res Function(_$SimSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SimSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientCase = null,
    Object? messages = null,
    Object? difficulty = null,
    Object? setting = null,
    Object? isFinished = null,
    Object? isTyping = null,
    Object? userDiagnosis = freezed,
    Object? score = freezed,
    Object? feedback = freezed,
  }) {
    return _then(
      _$SimSessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        patientCase: null == patientCase
            ? _value.patientCase
            : patientCase // ignore: cast_nullable_to_non_nullable
                  as PatientCase,
        messages: null == messages
            ? _value._messages
            : messages // ignore: cast_nullable_to_non_nullable
                  as List<SimMessage>,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as SimulationDifficulty,
        setting: null == setting
            ? _value.setting
            : setting // ignore: cast_nullable_to_non_nullable
                  as SimulationSetting,
        isFinished: null == isFinished
            ? _value.isFinished
            : isFinished // ignore: cast_nullable_to_non_nullable
                  as bool,
        isTyping: null == isTyping
            ? _value.isTyping
            : isTyping // ignore: cast_nullable_to_non_nullable
                  as bool,
        userDiagnosis: freezed == userDiagnosis
            ? _value.userDiagnosis
            : userDiagnosis // ignore: cast_nullable_to_non_nullable
                  as String?,
        score: freezed == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int?,
        feedback: freezed == feedback
            ? _value.feedback
            : feedback // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SimSessionImpl implements _SimSession {
  const _$SimSessionImpl({
    required this.id,
    required this.patientCase,
    required final List<SimMessage> messages,
    this.difficulty = SimulationDifficulty.junior,
    this.setting = SimulationSetting.emergencyRoom,
    this.isFinished = false,
    this.isTyping = false,
    this.userDiagnosis,
    this.score,
    this.feedback,
  }) : _messages = messages;

  factory _$SimSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SimSessionImplFromJson(json);

  @override
  final String id;
  @override
  final PatientCase patientCase;
  final List<SimMessage> _messages;
  @override
  List<SimMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  @JsonKey()
  final SimulationDifficulty difficulty;
  @override
  @JsonKey()
  final SimulationSetting setting;
  @override
  @JsonKey()
  final bool isFinished;
  @override
  @JsonKey()
  final bool isTyping;
  @override
  final String? userDiagnosis;
  @override
  final int? score;
  @override
  final String? feedback;

  @override
  String toString() {
    return 'SimSession(id: $id, patientCase: $patientCase, messages: $messages, difficulty: $difficulty, setting: $setting, isFinished: $isFinished, isTyping: $isTyping, userDiagnosis: $userDiagnosis, score: $score, feedback: $feedback)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientCase, patientCase) ||
                other.patientCase == patientCase) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.setting, setting) || other.setting == setting) &&
            (identical(other.isFinished, isFinished) ||
                other.isFinished == isFinished) &&
            (identical(other.isTyping, isTyping) ||
                other.isTyping == isTyping) &&
            (identical(other.userDiagnosis, userDiagnosis) ||
                other.userDiagnosis == userDiagnosis) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.feedback, feedback) ||
                other.feedback == feedback));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    patientCase,
    const DeepCollectionEquality().hash(_messages),
    difficulty,
    setting,
    isFinished,
    isTyping,
    userDiagnosis,
    score,
    feedback,
  );

  /// Create a copy of SimSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SimSessionImplCopyWith<_$SimSessionImpl> get copyWith =>
      __$$SimSessionImplCopyWithImpl<_$SimSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SimSessionImplToJson(this);
  }
}

abstract class _SimSession implements SimSession {
  const factory _SimSession({
    required final String id,
    required final PatientCase patientCase,
    required final List<SimMessage> messages,
    final SimulationDifficulty difficulty,
    final SimulationSetting setting,
    final bool isFinished,
    final bool isTyping,
    final String? userDiagnosis,
    final int? score,
    final String? feedback,
  }) = _$SimSessionImpl;

  factory _SimSession.fromJson(Map<String, dynamic> json) =
      _$SimSessionImpl.fromJson;

  @override
  String get id;
  @override
  PatientCase get patientCase;
  @override
  List<SimMessage> get messages;
  @override
  SimulationDifficulty get difficulty;
  @override
  SimulationSetting get setting;
  @override
  bool get isFinished;
  @override
  bool get isTyping;
  @override
  String? get userDiagnosis;
  @override
  int? get score;
  @override
  String? get feedback;

  /// Create a copy of SimSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SimSessionImplCopyWith<_$SimSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
