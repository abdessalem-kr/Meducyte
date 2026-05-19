// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sim_case_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SimCaseSummary _$SimCaseSummaryFromJson(Map<String, dynamic> json) {
  return _SimCaseSummary.fromJson(json);
}

/// @nodoc
mixin _$SimCaseSummary {
  @JsonKey(name: 'pathology_id')
  String get pathologyId => throw _privateConstructorUsedError;
  @JsonKey(name: 'module_name')
  String get moduleName => throw _privateConstructorUsedError;
  String get summary => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_pathology')
  String get targetPathology => throw _privateConstructorUsedError;

  /// Serializes this SimCaseSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SimCaseSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SimCaseSummaryCopyWith<SimCaseSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SimCaseSummaryCopyWith<$Res> {
  factory $SimCaseSummaryCopyWith(
    SimCaseSummary value,
    $Res Function(SimCaseSummary) then,
  ) = _$SimCaseSummaryCopyWithImpl<$Res, SimCaseSummary>;
  @useResult
  $Res call({
    @JsonKey(name: 'pathology_id') String pathologyId,
    @JsonKey(name: 'module_name') String moduleName,
    String summary,
    @JsonKey(name: 'target_pathology') String targetPathology,
  });
}

/// @nodoc
class _$SimCaseSummaryCopyWithImpl<$Res, $Val extends SimCaseSummary>
    implements $SimCaseSummaryCopyWith<$Res> {
  _$SimCaseSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SimCaseSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pathologyId = null,
    Object? moduleName = null,
    Object? summary = null,
    Object? targetPathology = null,
  }) {
    return _then(
      _value.copyWith(
            pathologyId: null == pathologyId
                ? _value.pathologyId
                : pathologyId // ignore: cast_nullable_to_non_nullable
                      as String,
            moduleName: null == moduleName
                ? _value.moduleName
                : moduleName // ignore: cast_nullable_to_non_nullable
                      as String,
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as String,
            targetPathology: null == targetPathology
                ? _value.targetPathology
                : targetPathology // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SimCaseSummaryImplCopyWith<$Res>
    implements $SimCaseSummaryCopyWith<$Res> {
  factory _$$SimCaseSummaryImplCopyWith(
    _$SimCaseSummaryImpl value,
    $Res Function(_$SimCaseSummaryImpl) then,
  ) = __$$SimCaseSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'pathology_id') String pathologyId,
    @JsonKey(name: 'module_name') String moduleName,
    String summary,
    @JsonKey(name: 'target_pathology') String targetPathology,
  });
}

/// @nodoc
class __$$SimCaseSummaryImplCopyWithImpl<$Res>
    extends _$SimCaseSummaryCopyWithImpl<$Res, _$SimCaseSummaryImpl>
    implements _$$SimCaseSummaryImplCopyWith<$Res> {
  __$$SimCaseSummaryImplCopyWithImpl(
    _$SimCaseSummaryImpl _value,
    $Res Function(_$SimCaseSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SimCaseSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pathologyId = null,
    Object? moduleName = null,
    Object? summary = null,
    Object? targetPathology = null,
  }) {
    return _then(
      _$SimCaseSummaryImpl(
        pathologyId: null == pathologyId
            ? _value.pathologyId
            : pathologyId // ignore: cast_nullable_to_non_nullable
                  as String,
        moduleName: null == moduleName
            ? _value.moduleName
            : moduleName // ignore: cast_nullable_to_non_nullable
                  as String,
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as String,
        targetPathology: null == targetPathology
            ? _value.targetPathology
            : targetPathology // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SimCaseSummaryImpl implements _SimCaseSummary {
  const _$SimCaseSummaryImpl({
    @JsonKey(name: 'pathology_id') required this.pathologyId,
    @JsonKey(name: 'module_name') required this.moduleName,
    required this.summary,
    @JsonKey(name: 'target_pathology') required this.targetPathology,
  });

  factory _$SimCaseSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SimCaseSummaryImplFromJson(json);

  @override
  @JsonKey(name: 'pathology_id')
  final String pathologyId;
  @override
  @JsonKey(name: 'module_name')
  final String moduleName;
  @override
  final String summary;
  @override
  @JsonKey(name: 'target_pathology')
  final String targetPathology;

  @override
  String toString() {
    return 'SimCaseSummary(pathologyId: $pathologyId, moduleName: $moduleName, summary: $summary, targetPathology: $targetPathology)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimCaseSummaryImpl &&
            (identical(other.pathologyId, pathologyId) ||
                other.pathologyId == pathologyId) &&
            (identical(other.moduleName, moduleName) ||
                other.moduleName == moduleName) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.targetPathology, targetPathology) ||
                other.targetPathology == targetPathology));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    pathologyId,
    moduleName,
    summary,
    targetPathology,
  );

  /// Create a copy of SimCaseSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SimCaseSummaryImplCopyWith<_$SimCaseSummaryImpl> get copyWith =>
      __$$SimCaseSummaryImplCopyWithImpl<_$SimCaseSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SimCaseSummaryImplToJson(this);
  }
}

abstract class _SimCaseSummary implements SimCaseSummary {
  const factory _SimCaseSummary({
    @JsonKey(name: 'pathology_id') required final String pathologyId,
    @JsonKey(name: 'module_name') required final String moduleName,
    required final String summary,
    @JsonKey(name: 'target_pathology') required final String targetPathology,
  }) = _$SimCaseSummaryImpl;

  factory _SimCaseSummary.fromJson(Map<String, dynamic> json) =
      _$SimCaseSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'pathology_id')
  String get pathologyId;
  @override
  @JsonKey(name: 'module_name')
  String get moduleName;
  @override
  String get summary;
  @override
  @JsonKey(name: 'target_pathology')
  String get targetPathology;

  /// Create a copy of SimCaseSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SimCaseSummaryImplCopyWith<_$SimCaseSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
