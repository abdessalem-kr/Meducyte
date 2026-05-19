import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/pomodoro_settings.dart';
import 'package:meducyte_app/features/productive_bay/data/repositories/api_productivity_repository.dart';

class PomodoroSettingsNotifier
    extends StateNotifier<AsyncValue<PomodoroSettings>> {
  PomodoroSettingsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadSettings();
  }

  final Ref ref;

  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(productivityRepositoryProvider);
      final settings = await repo.getUserSettings();
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateSettings({
    int? workDuration,
    int? shortBreak,
    int? longBreak,
    int? sessionsUntilLong,
  }) async {
    try {
      final repo = ref.read(productivityRepositoryProvider);
      final updated = await repo.updatePomodoroSettings(
        workDuration: workDuration,
        shortBreak: shortBreak,
        longBreak: longBreak,
        sessionsUntilLong: sessionsUntilLong,
      );
      state = AsyncValue.data(updated);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final pomodoroSettingsProvider =
    StateNotifierProvider<
      PomodoroSettingsNotifier,
      AsyncValue<PomodoroSettings>
    >((ref) {
      return PomodoroSettingsNotifier(ref);
    });
