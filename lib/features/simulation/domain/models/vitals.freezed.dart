// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vitals.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Vitals _$VitalsFromJson(Map<String, dynamic> json) {
  return _Vitals.fromJson(json);
}

/// @nodoc
mixin _$Vitals {
  @JsonKey(name: 'heart_rate')
  int get heartRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'blood_pressure')
  String get bloodPressure => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  int get spo2 => throw _privateConstructorUsedError;
  @JsonKey(name: 'respiratory_rate')
  int get respiratoryRate => throw _privateConstructorUsedError;

  /// Serializes this Vitals to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Vitals
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VitalsCopyWith<Vitals> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VitalsCopyWith<$Res> {
  factory $VitalsCopyWith(Vitals value, $Res Function(Vitals) then) =
      _$VitalsCopyWithImpl<$Res, Vitals>;
  @useResult
  $Res call({
    @JsonKey(name: 'heart_rate') int heartRate,
    @JsonKey(name: 'blood_pressure') String bloodPressure,
    double temperature,
    int spo2,
    @JsonKey(name: 'respiratory_rate') int respiratoryRate,
  });
}

/// @nodoc
class _$VitalsCopyWithImpl<$Res, $Val extends Vitals>
    implements $VitalsCopyWith<$Res> {
  _$VitalsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Vitals
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? heartRate = null,
    Object? bloodPressure = null,
    Object? temperature = null,
    Object? spo2 = null,
    Object? respiratoryRate = null,
  }) {
    return _then(
      _value.copyWith(
            heartRate: null == heartRate
                ? _value.heartRate
                : heartRate // ignore: cast_nullable_to_non_nullable
                      as int,
            bloodPressure: null == bloodPressure
                ? _value.bloodPressure
                : bloodPressure // ignore: cast_nullable_to_non_nullable
                      as String,
            temperature: null == temperature
                ? _value.temperature
                : temperature // ignore: cast_nullable_to_non_nullable
                      as double,
            spo2: null == spo2
                ? _value.spo2
                : spo2 // ignore: cast_nullable_to_non_nullable
                      as int,
            respiratoryRate: null == respiratoryRate
                ? _value.respiratoryRate
                : respiratoryRate // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VitalsImplCopyWith<$Res> implements $VitalsCopyWith<$Res> {
  factory _$$VitalsImplCopyWith(
    _$VitalsImpl value,
    $Res Function(_$VitalsImpl) then,
  ) = __$$VitalsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'heart_rate') int heartRate,
    @JsonKey(name: 'blood_pressure') String bloodPressure,
    double temperature,
    int spo2,
    @JsonKey(name: 'respiratory_rate') int respiratoryRate,
  });
}

/// @nodoc
class __$$VitalsImplCopyWithImpl<$Res>
    extends _$VitalsCopyWithImpl<$Res, _$VitalsImpl>
    implements _$$VitalsImplCopyWith<$Res> {
  __$$VitalsImplCopyWithImpl(
    _$VitalsImpl _value,
    $Res Function(_$VitalsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Vitals
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? heartRate = null,
    Object? bloodPressure = null,
    Object? temperature = null,
    Object? spo2 = null,
    Object? respiratoryRate = null,
  }) {
    return _then(
      _$VitalsImpl(
        heartRate: null == heartRate
            ? _value.heartRate
            : heartRate // ignore: cast_nullable_to_non_nullable
                  as int,
        bloodPressure: null == bloodPressure
            ? _value.bloodPressure
            : bloodPressure // ignore: cast_nullable_to_non_nullable
                  as String,
        temperature: null == temperature
            ? _value.temperature
            : temperature // ignore: cast_nullable_to_non_nullable
                  as double,
        spo2: null == spo2
            ? _value.spo2
            : spo2 // ignore: cast_nullable_to_non_nullable
                  as int,
        respiratoryRate: null == respiratoryRate
            ? _value.respiratoryRate
            : respiratoryRate // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VitalsImpl implements _Vitals {
  const _$VitalsImpl({
    @JsonKey(name: 'heart_rate') required this.heartRate,
    @JsonKey(name: 'blood_pressure') required this.bloodPressure,
    required this.temperature,
    required this.spo2,
    @JsonKey(name: 'respiratory_rate') required this.respiratoryRate,
  });

  factory _$VitalsImpl.fromJson(Map<String, dynamic> json) =>
      _$$VitalsImplFromJson(json);

  @override
  @JsonKey(name: 'heart_rate')
  final int heartRate;
  @override
  @JsonKey(name: 'blood_pressure')
  final String bloodPressure;
  @override
  final double temperature;
  @override
  final int spo2;
  @override
  @JsonKey(name: 'respiratory_rate')
  final int respiratoryRate;

  @override
  String toString() {
    return 'Vitals(heartRate: $heartRate, bloodPressure: $bloodPressure, temperature: $temperature, spo2: $spo2, respiratoryRate: $respiratoryRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VitalsImpl &&
            (identical(other.heartRate, heartRate) ||
                other.heartRate == heartRate) &&
            (identical(other.bloodPressure, bloodPressure) ||
                other.bloodPressure == bloodPressure) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.spo2, spo2) || other.spo2 == spo2) &&
            (identical(other.respiratoryRate, respiratoryRate) ||
                other.respiratoryRate == respiratoryRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    heartRate,
    bloodPressure,
    temperature,
    spo2,
    respiratoryRate,
  );

  /// Create a copy of Vitals
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VitalsImplCopyWith<_$VitalsImpl> get copyWith =>
      __$$VitalsImplCopyWithImpl<_$VitalsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VitalsImplToJson(this);
  }
}

abstract class _Vitals implements Vitals {
  const factory _Vitals({
    @JsonKey(name: 'heart_rate') required final int heartRate,
    @JsonKey(name: 'blood_pressure') required final String bloodPressure,
    required final double temperature,
    required final int spo2,
    @JsonKey(name: 'respiratory_rate') required final int respiratoryRate,
  }) = _$VitalsImpl;

  factory _Vitals.fromJson(Map<String, dynamic> json) = _$VitalsImpl.fromJson;

  @override
  @JsonKey(name: 'heart_rate')
  int get heartRate;
  @override
  @JsonKey(name: 'blood_pressure')
  String get bloodPressure;
  @override
  double get temperature;
  @override
  int get spo2;
  @override
  @JsonKey(name: 'respiratory_rate')
  int get respiratoryRate;

  /// Create a copy of Vitals
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VitalsImplCopyWith<_$VitalsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
