import 'package:equatable/equatable.dart';

class UserNote extends Equatable {
  final String id;
  final String userId;
  final String lessonId;
  final String paragraphId;
  final String highlightedText;
  final String note;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserNote({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.paragraphId,
    required this.highlightedText,
    required this.note,
    required this.createdAt,
    this.updatedAt,
  });

  UserNote copyWith({
    String? id,
    String? userId,
    String? lessonId,
    String? paragraphId,
    String? highlightedText,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserNote(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lessonId: lessonId ?? this.lessonId,
      paragraphId: paragraphId ?? this.paragraphId,
      highlightedText: highlightedText ?? this.highlightedText,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    lessonId,
    paragraphId,
    highlightedText,
    note,
    createdAt,
    updatedAt,
  ];
}
