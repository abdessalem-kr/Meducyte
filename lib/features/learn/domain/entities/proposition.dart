import 'package:equatable/equatable.dart';

class Proposition extends Equatable {
  final String id;
  final String text;
  final bool isCorrect;
  final String? feedback;

  const Proposition({
    required this.id,
    required this.text,
    required this.isCorrect,
    this.feedback,
  });

  Proposition copyWith({
    String? id,
    String? text,
    bool? isCorrect,
    String? feedback,
  }) {
    return Proposition(
      id: id ?? this.id,
      text: text ?? this.text,
      isCorrect: isCorrect ?? this.isCorrect,
      feedback: feedback ?? this.feedback,
    );
  }

  @override
  List<Object?> get props => [id, text, isCorrect, feedback];
}
