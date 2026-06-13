import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/simulation/domain/models/simulation_models.dart';
import 'package:meducyte_app/core/network/dio_client.dart';
import 'package:meducyte_app/shared/providers/network_provider.dart';

abstract class SimulationRepository {
  Future<SimSession> startSession({
    required String pathologyId,
    required SimulationDifficulty difficulty,
    required SimulationSetting setting,
  });
  Future<SimMessage> sendMessage(String sessionId, String text);
  Future<Map<String, dynamic>> performAction(
    String sessionId,
    String type,
    String name,
  );
  Future<Map<String, dynamic>> submitDiagnosis(
    String sessionId,
    String diagnosis,
  );
  Future<List<SimCaseSummary>> getCases();
}

class ApiSimulationRepository implements SimulationRepository {
  final DioClient _client;
  ApiSimulationRepository(this._client);

  @override
  Future<SimSession> startSession({
    required String pathologyId,
    required SimulationDifficulty difficulty,
    required SimulationSetting setting,
  }) async {
    try {
      final response = await _client.post(
        '/api/simulation/start',
        data: {
          'pathology_id': pathologyId,
          'difficulty': difficulty.name,
          'setting': setting.name,
        },
      );
      return SimSession.fromJson(response.data);
    } catch (e) {
      debugPrint("SimulationRepository: Error in startSession: $e");
      if (e is DioException) {
        debugPrint("Status Code: ${e.response?.statusCode}");
        debugPrint("Data: ${e.response?.data}");
        debugPrint("Path: ${e.requestOptions.path}");
      }
      rethrow;
    }
  }

  @override
  Future<SimMessage> sendMessage(String sessionId, String text) async {
    try {
      final response = await _client.post(
        '/api/simulation/chat',
        data: {'session_id': sessionId, 'message': text},
      );
      return SimMessage.fromJson(response.data);
    } catch (e) {
      debugPrint("SimulationRepository: Error in sendMessage: $e");
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> performAction(
    String sessionId,
    String type,
    String name,
  ) async {
    try {
      final response = await _client.post(
        '/api/simulation/action',
        data: {'session_id': sessionId, 'type': type, 'name': name},
      );
      return response.data;
    } catch (e) {
      debugPrint("SimulationRepository: Error in performAction: $e");
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> submitDiagnosis(
    String sessionId,
    String diagnosis,
  ) async {
    try {
      final response = await _client.post(
        '/api/simulation/evaluate',
        data: {'session_id': sessionId, 'diagnosis': diagnosis},
      );
      return response.data;
    } catch (e) {
      debugPrint("SimulationRepository: Error in submitDiagnosis: $e");
      rethrow;
    }
  }

  @override
  Future<List<SimCaseSummary>> getCases() async {
    try {
      final response = await _client.get('/api/simulation/cases');
      return (response.data as List)
          .map((e) => SimCaseSummary.fromJson(e))
          .toList();
    } catch (e) {
      debugPrint("SimulationRepository: Error in getCases: $e");
      if (e is DioException) {
        debugPrint("Status Code: ${e.response?.statusCode}");
        debugPrint("Data: ${e.response?.data}");
        debugPrint("Path: ${e.requestOptions.path}");
      }
      rethrow;
    }
  }
}

final simulationRepositoryProvider = Provider<SimulationRepository>((ref) {
  final client = ref.watch(dioClientProvider);
  return ApiSimulationRepository(client);
});
