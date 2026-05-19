// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sim_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SimMessageImpl _$$SimMessageImplFromJson(Map<String, dynamic> json) =>
    _$SimMessageImpl(
      id: _idToString(json['id']),
      text: json['text'] as String,
      isFromUser: json['is_from_user'] as bool,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      media: json['media'] == null
          ? null
          : ClinicalMedia.fromJson(json['media'] as Map<String, dynamic>),
      rawResult: json['raw_result'] as String?,
      interpretation: json['interpretation'] as String?,
      isRevealed: json['is_revealed'] as bool? ?? false,
    );

Map<String, dynamic> _$$SimMessageImplToJson(_$SimMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'is_from_user': instance.isFromUser,
      'timestamp': instance.timestamp?.toIso8601String(),
      'media': instance.media,
      'raw_result': instance.rawResult,
      'interpretation': instance.interpretation,
      'is_revealed': instance.isRevealed,
    };
