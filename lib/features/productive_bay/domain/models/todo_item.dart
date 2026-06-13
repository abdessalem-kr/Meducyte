import 'package:equatable/equatable.dart';

enum TodoPriority { urgent, exam, optional }

class SubTask extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;

  const SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  SubTask copyWith({String? id, String? title, bool? isCompleted}) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'].toString(),
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'is_completed': isCompleted,
  };

  /// Used for GraphQL payloads. Omits `id` so the backend correctly
  /// treats every subtask as new on createTodo, and relies on the
  /// numeric-id check in updateTodo only for entries with real DB ids.
  Map<String, dynamic> toApiJson() => {
    'title': title,
    'is_completed': isCompleted,
  };

  @override
  List<Object?> get props => [id, title, isCompleted];
}

class TodoItem extends Equatable {
  final String id;
  final String? moduleId;
  final String title;
  final bool isCompleted;
  final TodoPriority priority;
  final DateTime? deadline;
  final List<String> tags;
  final List<SubTask> subtasks;
  final int estimatedPomodoros;
  final int completedPomodoros;
  final DateTime createdAt;

  const TodoItem({
    required this.id,
    this.moduleId,
    required this.title,
    this.isCompleted = false,
    this.priority = TodoPriority.optional,
    this.deadline,
    this.tags = const [],
    this.subtasks = const [],
    this.estimatedPomodoros = 1,
    this.completedPomodoros = 0,
    required this.createdAt,
  });

  TodoItem copyWith({
    String? id,
    String? moduleId,
    String? title,
    bool? isCompleted,
    TodoPriority? priority,
    DateTime? deadline,
    List<String>? tags,
    List<SubTask>? subtasks,
    int? estimatedPomodoros,
    int? completedPomodoros,
    DateTime? createdAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      tags: tags ?? this.tags,
      subtasks: subtasks ?? this.subtasks,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'].toString(),
      moduleId: json['module_id']?.toString(),
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      priority: TodoPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TodoPriority.optional,
      ),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      subtasks:
          (json['subtasks'] as List<dynamic>?)
              ?.map((e) => SubTask.fromJson(e))
              .toList() ??
          [],
      estimatedPomodoros: json['estimated_pomodoros'] as int? ?? 1,
      completedPomodoros: json['completed_pomodoros'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'module_id': moduleId,
    'title': title,
    'is_completed': isCompleted,
    'priority': priority.name,
    'deadline': deadline?.toIso8601String(),
    'tags': tags,
    'subtasks': subtasks.map((e) => e.toJson()).toList(),
    'estimated_pomodoros': estimatedPomodoros,
    'completed_pomodoros': completedPomodoros,
    'created_at': createdAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    moduleId,
    title,
    isCompleted,
    priority,
    deadline,
    tags,
    subtasks,
    estimatedPomodoros,
    completedPomodoros,
    createdAt,
  ];
}
