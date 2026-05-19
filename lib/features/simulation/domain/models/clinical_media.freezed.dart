// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinical_media.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ClinicalMedia _$ClinicalMediaFromJson(Map<String, dynamic> json) {
  return _ClinicalMedia.fromJson(json);
}

/// @nodoc
mixin _$ClinicalMedia {
  String get url => throw _privateConstructorUsedError;
  MediaType get type => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;

  /// Serializes this ClinicalMedia to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClinicalMedia
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClinicalMediaCopyWith<ClinicalMedia> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClinicalMediaCopyWith<$Res> {
  factory $ClinicalMediaCopyWith(
    ClinicalMedia value,
    $Res Function(ClinicalMedia) then,
  ) = _$ClinicalMediaCopyWithImpl<$Res, ClinicalMedia>;
  @useResult
  $Res call({String url, MediaType type, String? title});
}

/// @nodoc
class _$ClinicalMediaCopyWithImpl<$Res, $Val extends ClinicalMedia>
    implements $ClinicalMediaCopyWith<$Res> {
  _$ClinicalMediaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClinicalMedia
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? type = null,
    Object? title = freezed,
  }) {
    return _then(
      _value.copyWith(
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as MediaType,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ClinicalMediaImplCopyWith<$Res>
    implements $ClinicalMediaCopyWith<$Res> {
  factory _$$ClinicalMediaImplCopyWith(
    _$ClinicalMediaImpl value,
    $Res Function(_$ClinicalMediaImpl) then,
  ) = __$$ClinicalMediaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String url, MediaType type, String? title});
}

/// @nodoc
class __$$ClinicalMediaImplCopyWithImpl<$Res>
    extends _$ClinicalMediaCopyWithImpl<$Res, _$ClinicalMediaImpl>
    implements _$$ClinicalMediaImplCopyWith<$Res> {
  __$$ClinicalMediaImplCopyWithImpl(
    _$ClinicalMediaImpl _value,
    $Res Function(_$ClinicalMediaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ClinicalMedia
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? type = null,
    Object? title = freezed,
  }) {
    return _then(
      _$ClinicalMediaImpl(
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as MediaType,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ClinicalMediaImpl implements _ClinicalMedia {
  const _$ClinicalMediaImpl({
    required this.url,
    required this.type,
    this.title,
  });

  factory _$ClinicalMediaImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClinicalMediaImplFromJson(json);

  @override
  final String url;
  @override
  final MediaType type;
  @override
  final String? title;

  @override
  String toString() {
    return 'ClinicalMedia(url: $url, type: $type, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClinicalMediaImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, url, type, title);

  /// Create a copy of ClinicalMedia
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClinicalMediaImplCopyWith<_$ClinicalMediaImpl> get copyWith =>
      __$$ClinicalMediaImplCopyWithImpl<_$ClinicalMediaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClinicalMediaImplToJson(this);
  }
}

abstract class _ClinicalMedia implements ClinicalMedia {
  const factory _ClinicalMedia({
    required final String url,
    required final MediaType type,
    final String? title,
  }) = _$ClinicalMediaImpl;

  factory _ClinicalMedia.fromJson(Map<String, dynamic> json) =
      _$ClinicalMediaImpl.fromJson;

  @override
  String get url;
  @override
  MediaType get type;
  @override
  String? get title;

  /// Create a copy of ClinicalMedia
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClinicalMediaImplCopyWith<_$ClinicalMediaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
