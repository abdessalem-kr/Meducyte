import 'package:freezed_annotation/freezed_annotation.dart';

part 'vitals.freezed.dart';
part 'vitals.g.dart';

@freezed
class Vitals with _$Vitals {
  const factory Vitals({
    @JsonKey(name: 'heart_rate') required int heartRate,
    @JsonKey(name: 'blood_pressure') required String bloodPressure,
    required double temperature,
    required int spo2,
    @JsonKey(name: 'respiratory_rate') required int respiratoryRate,
  }) = _Vitals;

  factory Vitals.fromJson(Map<String, dynamic> json) => _$VitalsFromJson(json);
}
