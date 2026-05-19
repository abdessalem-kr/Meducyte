import 'package:equatable/equatable.dart';

class Paragraph extends Equatable {
  final String id;
  final String lessonId;
  final String content;
  final int orderIndex;
  final ParagraphType type;

  const Paragraph({
    required this.id,
    required this.lessonId,
    required this.content,
    required this.orderIndex,
    this.type = ParagraphType.text,
  });

  Paragraph copyWith({
    String? id,
    String? lessonId,
    String? content,
    int? orderIndex,
    ParagraphType? type,
  }) {
    return Paragraph(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      content: content ?? this.content,
      orderIndex: orderIndex ?? this.orderIndex,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [id, lessonId, content, orderIndex, type];
}

enum ParagraphType { text, image, code, quote, warning }
