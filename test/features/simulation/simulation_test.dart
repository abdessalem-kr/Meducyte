import 'package:flutter_test/flutter_test.dart';
import 'package:meducyte_app/features/simulation/domain/models/simulation_models.dart';
import 'package:meducyte_app/features/simulation/presentation/providers/simulation_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('SimSessionNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
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
