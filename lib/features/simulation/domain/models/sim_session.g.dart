// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sim_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SimSessionImpl _$$SimSessionImplFromJson(Map<String, dynamic> json) =>
    _$SimSessionImpl(
      id: json['id'] as String,
      patientCase: PatientCase.fromJson(
        json['patientCase'] as Map<String, dynamic>,
      ),
      messages: (json['messages'] as List<dynamic>)
          .map((e) => SimMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      difficulty:
          $enumDecodeNullable(
            _$SimulationDifficultyEnumMap,
            json['difficulty'],
          ) ??
          SimulationDifficulty.junior,
      setting:
          $enumDecodeNullable(_$SimulationSettingEnumMap, json['setting']) ??
          SimulationSetting.emergencyRoom,
      isFinished: json['isFinished'] as bool? ?? false,
      isTyping: json['isTyping'] as bool? ?? false,
      userDiagnosis: json['userDiagnosis'] as String?,
      score: (json['score'] as num?)?.toInt(),
      feedback: json['feedback'] as String?,
    );

Map<String, dynamic> _$$SimSessionImplToJson(_$SimSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientCase': instance.patientCase,
      'messages': instance.messages,
      'difficulty': _$SimulationDifficultyEnumMap[instance.difficulty]!,
      'setting': _$SimulationSettingEnumMap[instance.setting]!,
      'isFinished': instance.isFinished,
      'isTyping': instance.isTyping,
      'userDiagnosis': instance.userDiagnosis,
      'score': instance.score,
      'feedback': instance.feedback,
    };

const _$SimulationDifficultyEnumMap = {
  SimulationDifficulty.junior: 'junior',
  SimulationDifficulty.resident: 'resident',
  SimulationDifficulty.consultant: 'consultant',
};

const _$SimulationSettingEnumMap = {
  SimulationSetting.emergencyRoom: 'emergencyRoom',
  SimulationSetting.outpatientClinic: 'outpatientClinic',
  SimulationSetting.intensiveCare: 'intensiveCare',
};
