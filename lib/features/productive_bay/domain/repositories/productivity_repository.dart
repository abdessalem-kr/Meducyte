import 'package:meducyte_app/features/productive_bay/domain/models/productive_bay_models.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/todo_item.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/pomodoro_settings.dart';

abstract class ProductivityRepository {
  Future<List<TodoItem>> getTodoItems();
  Future<TodoItem> createTodo({
    required String title,
    TodoPriority? priority,
    DateTime? deadline,
    String? moduleId,
    int? estimatedPomodoros,
    List<SubTask>? subtasks,
  });
  Future<TodoItem> updateTodo({
    required String id,
    String? title,
    TodoPriority? priority,
    DateTime? deadline,
    bool? isCompleted,
    int? completedPomodoros,
    int? estimatedPomodoros,
    List<SubTask>? subtasks,
  });
  Future<void> deleteTodo(String id);
  Future<List<ExamEvent>> getExams();
  Future<ExamEvent> createExam({required String title, required DateTime date});
  Future<ExamEvent> updateExam({
    required String id,
    String? title,
    DateTime? date,
  });
  Future<void> deleteExam(String id);
  Future<void> logPomodoro({
    required String type,
    required int durationMinutes,
    required DateTime startedAt,
    String? status,
    String? todoItemId,
  });
  Future<StudyStats> getStats();
  Future<PomodoroSettings> getUserSettings();
  Future<PomodoroSettings> updatePomodoroSettings({
    int? workDuration,
    int? shortBreak,
    int? longBreak,
    int? sessionsUntilLong,
  });
}
