import 'package:equatable/equatable.dart';

class Lesson extends Equatable {
  final String id;
  final String moduleId;
  final String title;
  final int orderIndex;
  final bool isCompleted;
  final int durationMinutes;
  final DateTime? completedAt;

  const Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.orderIndex,
    this.isCompleted = false,
    required this.durationMinutes,
    this.completedAt,
  });

  Lesson copyWith({
    String? id,
    String? moduleId,
    String? title,
    int? orderIndex,
    bool? isCompleted,
    int? durationMinutes,
    DateTime? completedAt,
  }) {
    return Lesson(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      title: title ?? this.title,
      orderIndex: orderIndex ?? this.orderIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    moduleId,
    title,
    orderIndex,
    isCompleted,
    durationMinutes,
    completedAt,
  ];
}
