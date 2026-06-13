import 'package:flutter_test/flutter_test.dart';
import 'package:meducyte_app/features/simulation/domain/models/simulation_models.dart';
import 'package:meducyte_app/features/simulation/data/repositories/simulation_repository.dart';
import 'package:meducyte_app/features/simulation/presentation/providers/simulation_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FakeSimulationRepository implements SimulationRepository {
  @override
  Future<SimSession> startSession({
    required String pathologyId,
    required SimulationDifficulty difficulty,
    required SimulationSetting setting,
  }) async {
    const mockCase = PatientCase(
      id: 'case_001',
      name: 'John Doe',
      age: 58,
      gender: 'M',
      mainComplaint: 'Chest pain and shortness of breath',
      occupation: 'Taxi Driver',
      medicalHistory: 'Hypertension, Smoker (20 years)',
      personality: 'Anxious',
      targetPathology: 'Acute Myocardial Infarction',
      secretDetails: 'The pain radiates to the left jaw and arm.',
      expectedFindings: ['ST-segment elevation', 'Troponin elevation'],
      initialVitals: Vitals(
        heartRate: 105,
        bloodPressure: '150/95',
        temperature: 37,
        spo2: 94,
        respiratoryRate: 22,
      ),
      physicalExamResults: {},
      labResults: {},
      mediaFindings: {},
    );

    return SimSession(
      id: 'session_123',
      patientCase: mockCase,
      difficulty: difficulty,
      setting: setting,
      messages: [
        SimMessage(
          id: 'msg_000',
          text: 'Patient John Doe admitted to emergency room.',
          isFromUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  @override
  Future<SimMessage> sendMessage(String sessionId, String text) async {
    return SimMessage(
      id: 'msg_ai_${DateTime.now().millisecondsSinceEpoch}',
      text: 'Response from AI',
      isFromUser: false,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<Map<String, dynamic>> performAction(
    String sessionId,
    String type,
    String name,
  ) async {
    return {
      'result': 'Action result',
      'finding': 'Action finding',
    };
  }

  @override
  Future<Map<String, dynamic>> submitDiagnosis(
    String sessionId,
    String diagnosis,
  ) async {
    return {
      'score': 85,
      'feedback': 'Good job',
    };
  }

  @override
  Future<List<SimCaseSummary>> getCases() async {
    return [
      const SimCaseSummary(
        pathologyId: 'case_001',
        moduleName: 'Cardiology',
        summary: 'John Doe Case',
        targetPathology: 'Acute Myocardial Infarction',
      ),
    ];
  }
}

void main() {
  group('SimSessionNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          simulationRepositoryProvider.overrideWithValue(
            FakeSimulationRepository(),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state is loading', () {
      expect(
        container.read(simSessionProvider),
        const AsyncValue<SimSession>.loading(),
      );
    });

    test('startNewSession sets the session correctly', () async {
      await container.read(simSessionProvider.notifier).startNewSession(
        pathologyId: 'case_001',
        difficulty: SimulationDifficulty.junior,
        setting: SimulationSetting.emergencyRoom,
      );

      final state = container.read(simSessionProvider);
      expect(state.value?.patientCase.name, 'John Doe');
      expect(state.value?.messages.length, 1); // Briefing message
    });

    test('sendMessage adds user and AI messages', () async {
      await container.read(simSessionProvider.notifier).startNewSession(
        pathologyId: 'case_001',
        difficulty: SimulationDifficulty.junior,
        setting: SimulationSetting.emergencyRoom,
      );

      await container.read(simSessionProvider.notifier).sendMessage('Hello');

      final state = container.read(simSessionProvider);
      expect(state.value?.messages.length, 3); // Briefing + User + AI
      expect(state.value?.messages[1].isFromUser, true);
      expect(state.value?.messages[2].isFromUser, false);
    });

    test('submitDiagnosis finishes the session with score', () async {
      await container.read(simSessionProvider.notifier).startNewSession(
        pathologyId: 'case_001',
        difficulty: SimulationDifficulty.junior,
        setting: SimulationSetting.emergencyRoom,
      );

      await container
          .read(simSessionProvider.notifier)
          .submitDiagnosis('Acute Myocardial Infarction');

      final state = container.read(simSessionProvider);
      expect(state.value?.isFinished, true);
      expect(state.value?.score != null, true);
    });
  });
}
