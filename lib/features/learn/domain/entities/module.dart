//lib/features/learn/domain/entities/module.dart
import 'package:equatable/equatable.dart';

class Module extends Equatable {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final int lessonCount;
  final int completedLessons;
  final bool isLocked;

  const Module({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.lessonCount,
    this.completedLessons = 0,
    this.isLocked = false,
  });

  double get progress => lessonCount > 0 ? completedLessons / lessonCount : 0;

  Module copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    int? lessonCount,
    int? completedLessons,
    bool? isLocked,
  }) {
    return Module(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      lessonCount: lessonCount ?? this.lessonCount,
      completedLessons: completedLessons ?? this.completedLessons,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    thumbnailUrl,
    lessonCount,
    completedLessons,
    isLocked,
  ];
}
