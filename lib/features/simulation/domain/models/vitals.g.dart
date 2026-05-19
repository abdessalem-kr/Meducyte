// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vitals.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VitalsImpl _$$VitalsImplFromJson(Map<String, dynamic> json) => _$VitalsImpl(
  heartRate: (json['heart_rate'] as num).toInt(),
  bloodPressure: json['blood_pressure'] as String,
  temperature: (json['temperature'] as num).toDouble(),
  spo2: (json['spo2'] as num).toInt(),
  respiratoryRate: (json['respiratory_rate'] as num).toInt(),
);

Map<String, dynamic> _$$VitalsImplToJson(_$VitalsImpl instance) =>
    <String, dynamic>{
      'heart_rate': instance.heartRate,
      'blood_pressure': instance.bloodPressure,
      'temperature': instance.temperature,
      'spo2': instance.spo2,
      'respiratory_rate': instance.respiratoryRate,
    };
