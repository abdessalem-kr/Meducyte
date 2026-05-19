import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meducyte_app/features/simulation/domain/models/clinical_media.dart';

part 'sim_message.freezed.dart';
part 'sim_message.g.dart';

@freezed
class SimMessage with _$SimMessage {
  const factory SimMessage({
    @JsonKey(fromJson: _idToString) required String id,
    required String text,
    @JsonKey(name: 'is_from_user') required bool isFromUser,
    @Default(null) DateTime? timestamp,
    ClinicalMedia? media,
    @JsonKey(name: 'raw_result') String? rawResult,
    String? interpretation,
    @JsonKey(name: 'is_revealed') @Default(false) bool isRevealed,
  }) = _SimMessage;

  factory SimMessage.fromJson(Map<String, dynamic> json) =>
      _$SimMessageFromJson(json);
}

String _idToString(dynamic id) => id?.toString() ?? "";
