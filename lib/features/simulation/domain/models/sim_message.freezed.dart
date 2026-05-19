// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sim_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SimMessage _$SimMessageFromJson(Map<String, dynamic> json) {
  return _SimMessage.fromJson(json);
}

/// @nodoc
mixin _$SimMessage {
  @JsonKey(fromJson: _idToString)
  String get id => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_from_user')
  bool get isFromUser => throw _privateConstructorUsedError;
  DateTime? get timestamp => throw _privateConstructorUsedError;
  ClinicalMedia? get media => throw _privateConstructorUsedError;
  @JsonKey(name: 'raw_result')
  String? get rawResult => throw _privateConstructorUsedError;
  String? get interpretation => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_revealed')
  bool get isRevealed => throw _privateConstructorUsedError;

  /// Serializes this SimMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SimMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SimMessageCopyWith<SimMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SimMessageCopyWith<$Res> {
  factory $SimMessageCopyWith(
    SimMessage value,
    $Res Function(SimMessage) then,
  ) = _$SimMessageCopyWithImpl<$Res, SimMessage>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _idToString) String id,
    String text,
    @JsonKey(name: 'is_from_user') bool isFromUser,
    DateTime? timestamp,
    ClinicalMedia? media,
    @JsonKey(name: 'raw_result') String? rawResult,
    String? interpretation,
    @JsonKey(name: 'is_revealed') bool isRevealed,
  });

  $ClinicalMediaCopyWith<$Res>? get media;
}

/// @nodoc
class _$SimMessageCopyWithImpl<$Res, $Val extends SimMessage>
    implements $SimMessageCopyWith<$Res> {
  _$SimMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SimMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? isFromUser = null,
    Object? timestamp = freezed,
    Object? media = freezed,
    Object? rawResult = freezed,
    Object? interpretation = freezed,
    Object? isRevealed = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            isFromUser: null == isFromUser
                ? _value.isFromUser
                : isFromUser // ignore: cast_nullable_to_non_nullable
                      as bool,
            timestamp: freezed == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            media: freezed == media
                ? _value.media
                : media // ignore: cast_nullable_to_non_nullable
                      as ClinicalMedia?,
            rawResult: freezed == rawResult
                ? _value.rawResult
                : rawResult // ignore: cast_nullable_to_non_nullable
                      as String?,
            interpretation: freezed == interpretation
                ? _value.interpretation
                : interpretation // ignore: cast_nullable_to_non_nullable
                      as String?,
            isRevealed: null == isRevealed
                ? _value.isRevealed
                : isRevealed // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of SimMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ClinicalMediaCopyWith<$Res>? get media {
    if (_value.media == null) {
      return null;
    }

    return $ClinicalMediaCopyWith<$Res>(_value.media!, (value) {
      return _then(_value.copyWith(media: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SimMessageImplCopyWith<$Res>
    implements $SimMessageCopyWith<$Res> {
  factory _$$SimMessageImplCopyWith(
    _$SimMessageImpl value,
    $Res Function(_$SimMessageImpl) then,
  ) = __$$SimMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _idToString) String id,
    String text,
    @JsonKey(name: 'is_from_user') bool isFromUser,
    DateTime? timestamp,
    ClinicalMedia? media,
    @JsonKey(name: 'raw_result') String? rawResult,
    String? interpretation,
    @JsonKey(name: 'is_revealed') bool isRevealed,
  });

  @override
  $ClinicalMediaCopyWith<$Res>? get media;
}

/// @nodoc
class __$$SimMessageImplCopyWithImpl<$Res>
    extends _$SimMessageCopyWithImpl<$Res, _$SimMessageImpl>
    implements _$$SimMessageImplCopyWith<$Res> {
  __$$SimMessageImplCopyWithImpl(
    _$SimMessageImpl _value,
    $Res Function(_$SimMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SimMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? isFromUser = null,
    Object? timestamp = freezed,
    Object? media = freezed,
    Object? rawResult = freezed,
    Object? interpretation = freezed,
    Object? isRevealed = null,
  }) {
    return _then(
      _$SimMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        isFromUser: null == isFromUser
            ? _value.isFromUser
            : isFromUser // ignore: cast_nullable_to_non_nullable
                  as bool,
        timestamp: freezed == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        media: freezed == media
            ? _value.media
            : media // ignore: cast_nullable_to_non_nullable
                  as ClinicalMedia?,
        rawResult: freezed == rawResult
            ? _value.rawResult
            : rawResult // ignore: cast_nullable_to_non_nullable
                  as String?,
        interpretation: freezed == interpretation
            ? _value.interpretation
            : interpretation // ignore: cast_nullable_to_non_nullable
                  as String?,
        isRevealed: null == isRevealed
            ? _value.isRevealed
            : isRevealed // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SimMessageImpl implements _SimMessage {
  const _$SimMessageImpl({
    @JsonKey(fromJson: _idToString) required this.id,
    required this.text,
    @JsonKey(name: 'is_from_user') required this.isFromUser,
    this.timestamp = null,
    this.media,
    @JsonKey(name: 'raw_result') this.rawResult,
    this.interpretation,
    @JsonKey(name: 'is_revealed') this.isRevealed = false,
  });

  factory _$SimMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$SimMessageImplFromJson(json);

  @override
  @JsonKey(fromJson: _idToString)
  final String id;
  @override
  final String text;
  @override
  @JsonKey(name: 'is_from_user')
  final bool isFromUser;
  @override
  @JsonKey()
  final DateTime? timestamp;
  @override
  final ClinicalMedia? media;
  @override
  @JsonKey(name: 'raw_result')
  final String? rawResult;
  @override
  final String? interpretation;
  @override
  @JsonKey(name: 'is_revealed')
  final bool isRevealed;

  @override
  String toString() {
    return 'SimMessage(id: $id, text: $text, isFromUser: $isFromUser, timestamp: $timestamp, media: $media, rawResult: $rawResult, interpretation: $interpretation, isRevealed: $isRevealed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.isFromUser, isFromUser) ||
                other.isFromUser == isFromUser) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.media, media) || other.media == media) &&
            (identical(other.rawResult, rawResult) ||
                other.rawResult == rawResult) &&
            (identical(other.interpretation, interpretation) ||
                other.interpretation == interpretation) &&
            (identical(other.isRevealed, isRevealed) ||
                other.isRevealed == isRevealed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    text,
    isFromUser,
    timestamp,
    media,
    rawResult,
    interpretation,
    isRevealed,
  );

  /// Create a copy of SimMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SimMessageImplCopyWith<_$SimMessageImpl> get copyWith =>
      __$$SimMessageImplCopyWithImpl<_$SimMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SimMessageImplToJson(this);
  }
}

abstract class _SimMessage implements SimMessage {
  const factory _SimMessage({
    @JsonKey(fromJson: _idToString) required final String id,
    required final String text,
    @JsonKey(name: 'is_from_user') required final bool isFromUser,
    final DateTime? timestamp,
    final ClinicalMedia? media,
    @JsonKey(name: 'raw_result') final String? rawResult,
    final String? interpretation,
    @JsonKey(name: 'is_revealed') final bool isRevealed,
  }) = _$SimMessageImpl;

  factory _SimMessage.fromJson(Map<String, dynamic> json) =
      _$SimMessageImpl.fromJson;

  @override
  @JsonKey(fromJson: _idToString)
  String get id;
  @override
  String get text;
  @override
  @JsonKey(name: 'is_from_user')
  bool get isFromUser;
  @override
  DateTime? get timestamp;
  @override
  ClinicalMedia? get media;
  @override
  @JsonKey(name: 'raw_result')
  String? get rawResult;
  @override
  String? get interpretation;
  @override
  @JsonKey(name: 'is_revealed')
  bool get isRevealed;

  /// Create a copy of SimMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SimMessageImplCopyWith<_$SimMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
