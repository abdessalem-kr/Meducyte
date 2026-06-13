import 'package:meducyte_app/export.dart';
import 'package:intl/intl.dart';
import 'package:meducyte_app/core/network/dio_client.dart';
import 'package:meducyte_app/shared/providers/network_provider.dart';
import 'package:meducyte_app/features/productive_bay/domain/repositories/productivity_repository.dart';
import 'package:meducyte_app/features/productive_bay/domain/models/pomodoro_settings.dart';

class ApiProductivityRepository implements ProductivityRepository {
  final DioClient _client;

  ApiProductivityRepository(this._client);

  String? _formatDateTime(DateTime? date) {
    if (date == null) return null;
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date.toUtc());
  }

  @override
  Future<List<TodoItem>> getTodoItems() async {
    const String query = r'''
 query GetTodoItems{
   todoItems{
     id
     title
     priority
     deadline
     is_completed
     module_id
     estimated_pomodoros
     completed_pomodoros
     created_at
     subtasks{
       id
       title
       is_completed
       }
     }
   }
 ''';

    final response = await _client.post('/graphql', data: {'query': query});

    if (response.data['errors'] != null) {
      throw Exception(response.data['errors'][0]['message']);
    }

    final data = response.data['data']?['todoItems'];
    if (data == null) return [];

    final List<dynamic> list = data;
    return list.map((json) => TodoItem.fromJson(json)).toList();
  }

  @override
  Future<TodoItem> createTodo({
    required String title,
    TodoPriority? priority,
    DateTime? deadline,
    String? moduleId,
    int? estimatedPomodoros,
    List<SubTask>? subtasks,
  }) async {
    const String mutation = r'''
 mutation CreateTodo($title:String!, $priority:String, $deadline:DateTime, $module_id:String, $estimated_pomodoros:Int, $subtasks: [SubTaskInput]) {
   createTodo(title: $title,priority: $priority,deadline: $deadline,module_id: $module_id,estimated_pomodoros: $estimated_pomodoros,subtasks: $subtasks) {
     id
     title
     priority
     deadline
     module_id
     estimated_pomodoros
     created_at
     subtasks{
       id
       title
       is_completed
       }
     }
   }
 ''';

    debugPrint("DEBUG: createTodo sending POST to /graphql with variables: title=$title, priority=$priority");
    final response = await _client.post(
      '/graphql',
      data: {
        'query': mutation,
        'variables': {
          'title': title,
          'priority': priority?.name,
          'deadline': _formatDateTime(deadline),
          'module_id': moduleId,
          'estimated_pomodoros': estimatedPomodoros,
          'subtasks': subtasks?.map((s) => s.toApiJson()).toList(),
        },
      },
    );
    debugPrint("DEBUG: createTodo response status code: ${response.statusCode}");
    debugPrint("DEBUG: createTodo response data: ${response.data}");

    if (response.data['errors'] != null) {
      debugPrint("DEBUG: createTodo error returned: ${response.data['errors']}");
      throw Exception(response.data['errors'][0]['message']);
    }

    final data = response.data['data']?['createTodo'];
    if (data == null) {
      debugPrint("DEBUG: createTodo response data was null");
      throw Exception('Failed to create task');
    }

    debugPrint("DEBUG: createTodo parsed TodoItem: $data");
    return TodoItem.fromJson(data);
  }

  @override
  Future<TodoItem> updateTodo({
    required String id,
    String? title,
    TodoPriority? priority,
    DateTime? deadline,
    bool? isCompleted,
    int? completedPomodoros,
    int? estimatedPomodoros,
    List<SubTask>? subtasks,
  }) async {
    final List<String> varDecls = ['\$id: ID!'];
    final List<String> argsList = ['id: \$id'];
    final Map<String, dynamic> variables = {'id': id};

    if (title != null) {
      varDecls.add('\$title: String');
      argsList.add('title: \$title');
      variables['title'] = title;
    }
    if (priority != null) {
      varDecls.add('\$priority: String');
      argsList.add('priority: \$priority');
      variables['priority'] = priority.name;
    }
    if (deadline != null) {
      varDecls.add('\$deadline: DateTime');
      argsList.add('deadline: \$deadline');
      variables['deadline'] = _formatDateTime(deadline);
    }
    if (isCompleted != null) {
      varDecls.add('\$is_completed: Boolean');
      argsList.add('is_completed: \$is_completed');
      variables['is_completed'] = isCompleted;
    }
    if (completedPomodoros != null) {
      varDecls.add('\$completed_pomodoros: Int');
      argsList.add('completed_pomodoros: \$completed_pomodoros');
      variables['completed_pomodoros'] = completedPomodoros;
    }
    if (estimatedPomodoros != null) {
      varDecls.add('\$estimated_pomodoros: Int');
      argsList.add('estimated_pomodoros: \$estimated_pomodoros');
      variables['estimated_pomodoros'] = estimatedPomodoros;
    }
    if (subtasks != null) {
      varDecls.add('\$subtasks: [SubTaskInput]');
      argsList.add('subtasks: \$subtasks');
      variables['subtasks'] = subtasks.map((s) => s.toApiJson()).toList();
    }

    final String mutation =
        '''
 mutation UpdateTodo(${varDecls.join(', ')}) {
   updateTodo(${argsList.join(', ')}) {
     id
     title
     priority
     deadline
     is_completed
     module_id
     estimated_pomodoros
     completed_pomodoros
     created_at
     subtasks {
       id
       title
       is_completed
     }
   }
 }
''';

    final response = await _client.post(
      '/graphql',
      data: {'query': mutation, 'variables': variables},
    );

    if (response.data['errors'] != null) {
      throw Exception(response.data['errors'][0]['message']);
    }

    final data = response.data['data']?['updateTodo'];
    if (data == null) throw Exception('Failed to update task');

    return TodoItem.fromJson(data);
  }

  @override
  Future<void> deleteTodo(String id) async {
    const String mutation = r'''
 mutation DeleteTodo($id:ID!) {
   deleteTodo(id: $id) {
     id
     }
   }
 ''';

    await _client.post(
      '/graphql',
      data: {
        'query': mutation,
        'variables': {'id': id},
      },
    );
  }

  @override
  Future<List<ExamEvent>> getExams() async {
    try {
      const String query = r'''
   query GetExamEvents{
     examEvents{
       id
       title
       date
       }
     }
   ''';

      final response = await _client.post('/graphql', data: {'query': query});
      if (response.data['errors'] != null) {
        throw Exception(response.data['errors'][0]['message']);
      }
      final List<dynamic>? data = response.data['data']?['examEvents'];
      if (data == null) return [];
      return data.map((json) => ExamEvent.fromJson(json)).toList();
    } catch (e) {
      debugPrint("ApiProductivityRepository.getExams error: $e");
      rethrow;
    }
  }

  @override
  Future<ExamEvent> createExam({
    required String title,
    required DateTime date,
  }) async {
    try {
      const String mutation = r'''
   mutation CreateExam($title:String!, $date:DateTime!) {
     createExam(title: $title,date: $date) {
       id
       title
       date
       }
     }
   ''';

      final response = await _client.post(
        '/graphql',
        data: {
          'query': mutation,
          'variables': {'title': title, 'date': _formatDateTime(date)},
        },
      );

      if (response.data['errors'] != null) {
        throw Exception(response.data['errors'][0]['message']);
      }

      final data = response.data['data']?['createExam'];
      if (data == null) {
        throw Exception("Failed to create exam:response data is null");
      }
      return ExamEvent.fromJson(data);
    } catch (e) {
      debugPrint("ApiProductivityRepository.createExam error: $e");
      rethrow;
    }
  }

  @override
  Future<ExamEvent> updateExam({
    required String id,
    String? title,
    DateTime? date,
  }) async {
    try {
      const String mutation = r'''
   mutation UpdateExam($id:ID!, $title:String, $date:DateTime) {
     updateExam(id: $id,title: $title,date: $date) {
       id
       title
       date
       }
     }
   ''';

      final response = await _client.post(
        '/graphql',
        data: {
          'query': mutation,
          'variables': {
            'id': id,
            'title': title,
            'date': _formatDateTime(date),
          },
        },
      );

      if (response.data['errors'] != null) {
        throw Exception(response.data['errors'][0]['message']);
      }

      final data = response.data['data']?['updateExam'];
      if (data == null) {
        throw Exception("Failed to update exam:response data is null");
      }
      return ExamEvent.fromJson(data);
    } catch (e) {
      debugPrint("ApiProductivityRepository.updateExam error: $e");
      rethrow;
    }
  }

  @override
  Future<void> deleteExam(String id) async {
    try {
      const String mutation = r'''
   mutation DeleteExam($id:ID!) {
     deleteExam(id: $id) {
       id
       }
     }
   ''';

      final response = await _client.post(
        '/graphql',
        data: {
          'query': mutation,
          'variables': {'id': id},
        },
      );

      if (response.data['errors'] != null) {
        throw Exception(response.data['errors'][0]['message']);
      }
    } catch (e) {
      debugPrint("ApiProductivityRepository.deleteExam error: $e");
      rethrow;
    }
  }

  @override
  Future<void> logPomodoro({
    required String type,
    required int durationMinutes,
    required DateTime startedAt,
    String? status,
    String? todoItemId,
  }) async {
    const String mutation = r'''
 mutation LogPomodoro($type:String!, $duration_minutes:Int!, $started_at:DateTime!, $status:String, $todo_item_id:ID) {
   logPomodoroSession(type: $type,duration_minutes: $duration_minutes,started_at: $started_at,status: $status,todo_item_id: $todo_item_id) {
     id
     }
   }
 ''';

    await _client.post(
      '/graphql',
      data: {
        'query': mutation,
        'variables': {
          'type': type,
          'duration_minutes': durationMinutes,
          'started_at': _formatDateTime(startedAt),
          'status': status,
          'todo_item_id': todoItemId,
        },
      },
    );
  }

  @override
  Future<StudyStats> getStats() async {
    const String query = r'''
 query GetStats{
   productiveBayStats{
     focus_hours_today
     focus_hours_week
     completed_tasks_today
     current_streak
     pomodoros_completed_today
     short_breaks_completed_today
     long_breaks_completed_today
     }
   }
 ''';

    final response = await _client.post('/graphql', data: {'query': query});

    final stats = response.data['data']['productiveBayStats'];
    return StudyStats(
      currentStreak: stats['current_streak'] as int,
      totalHours: (stats['focus_hours_today'] as num)
          .toInt(), //Approximation for UI
      completedPomodorosToday: stats['pomodoros_completed_today'] as int,
      completedShortBreaksToday: stats['short_breaks_completed_today'] as int,
      completedLongBreaksToday: stats['long_breaks_completed_today'] as int,
      totalPomodorosGoal: 8, //Could be dynamic
      moduleScores: {}, //Not implemented on backend yet
    );
  }

  @override
  Future<PomodoroSettings> getUserSettings() async {
    const String query = r'''
 query GetUserSettings{
   userSettings{
     pomodoro_work_duration
     pomodoro_short_break
     pomodoro_long_break
     pomodoro_sessions_until_long_break
     }
   }
 ''';

    final response = await _client.post('/graphql', data: {'query': query});
    final settings = response.data['data']['userSettings'];

    return PomodoroSettings(
      workDuration: settings['pomodoro_work_duration'] as int,
      shortBreakDuration: settings['pomodoro_short_break'] as int,
      longBreakDuration: settings['pomodoro_long_break'] as int,
      sessionsUntilLongBreak:
          settings['pomodoro_sessions_until_long_break'] as int,
    );
  }

  @override
  Future<PomodoroSettings> updatePomodoroSettings({
    int? workDuration,
    int? shortBreak,
    int? longBreak,
    int? sessionsUntilLong,
  }) async {
    const String mutation = r'''
 mutation UpdatePomodoroSettings($work:Int, $short:Int, $long:Int, $sessions:Int) {
   updatePomodoroSettings(work_duration: $work,short_break: $short,long_break: $long,sessions_until_long: $sessions) {
     pomodoro_work_duration
     pomodoro_short_break
     pomodoro_long_break
     pomodoro_sessions_until_long_break
     }
   }
 ''';

    final response = await _client.post(
      '/graphql',
      data: {
        'query': mutation,
        'variables': {
          'work': workDuration,
          'short': shortBreak,
          'long': longBreak,
          'sessions': sessionsUntilLong,
        },
      },
    );

    final settings = response.data['data']['updatePomodoroSettings'];
    return PomodoroSettings(
      workDuration: settings['pomodoro_work_duration'] as int,
      shortBreakDuration: settings['pomodoro_short_break'] as int,
      longBreakDuration: settings['pomodoro_long_break'] as int,
      sessionsUntilLongBreak:
          settings['pomodoro_sessions_until_long_break'] as int,
    );
  }
}

final productivityRepositoryProvider = Provider<ProductivityRepository>((ref) {
  final client = ref.watch(dioClientProvider);
  return ApiProductivityRepository(client);
});
