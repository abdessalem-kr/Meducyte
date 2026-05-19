// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_media.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClinicalMediaImpl _$$ClinicalMediaImplFromJson(Map<String, dynamic> json) =>
    _$ClinicalMediaImpl(
      url: json['url'] as String,
      type: $enumDecode(_$MediaTypeEnumMap, json['type']),
      title: json['title'] as String?,
    );

Map<String, dynamic> _$$ClinicalMediaImplToJson(_$ClinicalMediaImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'type': _$MediaTypeEnumMap[instance.type]!,
      'title': instance.title,
    };

const _$MediaTypeEnumMap = {
  MediaType.audio: 'audio',
  MediaType.image: 'image',
  MediaType.ecg: 'ecg',
};
