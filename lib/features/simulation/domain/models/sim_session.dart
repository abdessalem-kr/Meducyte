import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meducyte_app/features/simulation/domain/models/patient_case.dart';
import 'package:meducyte_app/features/simulation/domain/models/sim_message.dart';

part 'sim_session.freezed.dart';
part 'sim_session.g.dart';

enum SimulationDifficulty { junior, resident, consultant }

enum SimulationSetting { emergencyRoom, outpatientClinic, intensiveCare }

enum PatientPersonality { calm, anxious, aggressive, stoic, nonCompliant }

@freezed
class SimSession with _$SimSession {
  const factory SimSession({
    required String id,
    required PatientCase patientCase,
    required List<SimMessage> messages,
    @Default(SimulationDifficulty.junior) SimulationDifficulty difficulty,
    @Default(SimulationSetting.emergencyRoom) SimulationSetting setting,
    @Default(false) bool isFinished,
    @Default(false) bool isTyping,
    String? userDiagnosis,
    int? score,
    String? feedback,
  }) = _SimSession;

  factory SimSession.fromJson(Map<String, dynamic> json) =>
      _$SimSessionFromJson(json);
}
