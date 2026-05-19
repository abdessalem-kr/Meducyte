import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/notifications/application/services/notification_service.dart';
import 'package:meducyte_app/features/productive_bay/data/repositories/api_productivity_repository.dart';
import 'package:meducyte_app/features/productive_bay/domain/repositories/productivity_repository.dart';

class ExamNotifier extends StateNotifier<List<ExamEvent>> {
  final ProductivityRepository _repository;
  final Ref _ref;

  ExamNotifier(this._repository, this._ref) : super([]) {
    _loadExams();
  }

  Future<void> refresh() => _loadExams();

  Future<void> _loadExams() async {
    try {
      final exams = await _repository.getExams();
      if (mounted) state = exams;
    } catch (e) {
      debugPrint("Error loading exams: $e");
    }
  }

  Future<void> addOrUpdateExam(
    DateTime date,
    String title, {
    String? id,
  }) async {
    try {
      if (id != null) {
        final updated = await _repository.updateExam(
          id: id,
          title: title,
          date: date,
        );
        state = [
          for (final exam in state)
            if (exam.id == id) updated else exam,
        ];

        //Re-schedule notification
        _ref
            .read(notificationServiceProvider)
            .scheduleExamReminder(
              id: id,
              title: updated.title,
              examDate: updated.date,
            );
      } else {
        final created = await _repository.createExam(title: title, date: date);
        state = [...state, created];

        //Schedule notification
        _ref
            .read(notificationServiceProvider)
            .scheduleExamReminder(
              id: created.id,
              title: created.title,
              examDate: created.date,
            );
      }
    } catch (e) {
      debugPrint("Error adding/updating exam: $e");
    }
  }

  Future<void> removeExam(String id) async {
    try {
      await _repository.deleteExam(id);
      state = state.where((e) => e.id != id).toList();

      //Cancel notification
      _ref.read(notificationServiceProvider).cancelNotification(id);
    } catch (e) {
      debugPrint("Error removing exam: $e");
    }
  }
}

final examEventsProvider = StateNotifierProvider<ExamNotifier, List<ExamEvent>>(
  (ref) {
    final repository = ref.watch(productivityRepositoryProvider);
    return ExamNotifier(repository, ref);
  },
);
