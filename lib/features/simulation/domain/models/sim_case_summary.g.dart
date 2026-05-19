// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sim_case_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SimCaseSummaryImpl _$$SimCaseSummaryImplFromJson(Map<String, dynamic> json) =>
    _$SimCaseSummaryImpl(
      pathologyId: json['pathology_id'] as String,
      moduleName: json['module_name'] as String,
      summary: json['summary'] as String,
      targetPathology: json['target_pathology'] as String,
    );

Map<String, dynamic> _$$SimCaseSummaryImplToJson(
  _$SimCaseSummaryImpl instance,
) => <String, dynamic>{
  'pathology_id': instance.pathologyId,
  'module_name': instance.moduleName,
  'summary': instance.summary,
  'target_pathology': instance.targetPathology,
};
