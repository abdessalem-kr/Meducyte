import 'package:freezed_annotation/freezed_annotation.dart';

part 'sim_case_summary.freezed.dart';
part 'sim_case_summary.g.dart';

@freezed
class SimCaseSummary with _$SimCaseSummary {
  const factory SimCaseSummary({
    @JsonKey(name: 'pathology_id') required String pathologyId,
    @JsonKey(name: 'module_name') required String moduleName,
    required String summary,
    @JsonKey(name: 'target_pathology') required String targetPathology,
  }) = _SimCaseSummary;

  factory SimCaseSummary.fromJson(Map<String, dynamic> json) =>
      _$SimCaseSummaryFromJson(json);
}
