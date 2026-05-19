import 'package:equatable/equatable.dart';
import 'package:meducyte_app/features/learn/domain/entities/proposition.dart';

class Question extends Equatable {
  final String id;
  final String lessonId;
  final String text;
  final QuestionType type;
  final List<Proposition> propositions;
  final String? explanation;
  final int? correctIndex; //for single-choice

  const Question({
    required this.id,
    required this.lessonId,
    required this.text,
    required this.type,
    required this.propositions,
    this.explanation,
    this.correctIndex,
  });

  Question copyWith({
    String? id,
    String? lessonId,
    String? text,
    QuestionType? type,
    List<Proposition>? propositions,
    String? explanation,
    int? correctIndex,
  }) {
    return Question(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      text: text ?? this.text,
      type: type ?? this.type,
      propositions: propositions ?? this.propositions,
      explanation: explanation ?? this.explanation,
      correctIndex: correctIndex ?? this.correctIndex,
    );
  }

  @override
  List<Object?> get props => [
    id,
    lessonId,
    text,
    type,
    propositions,
    explanation,
    correctIndex,
  ];
}

enum QuestionType { singleChoice, multipleChoice, trueFalse, open }
