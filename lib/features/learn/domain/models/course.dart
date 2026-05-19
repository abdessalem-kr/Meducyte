import 'dart:convert';
import 'package:meducyte_app/export.dart';

class LearnModule extends Equatable {
  final String id;
  final String name;
  final String? description;
  final int year;
  final bool isFree;
  final String? parentId;
  final List<LearnModule>? children;
  final List<LearnLesson>? lessons;

  const LearnModule({
    required this.id,
    required this.name,
    this.description,
    required this.year,
    this.isFree = false,
    this.parentId,
    this.children,
    this.lessons,
  });

  factory LearnModule.fromJson(Map<String, dynamic> json) {
    return LearnModule(
      id: json['id'].toString(),
      name: json['name'] as String,
      description: json['description'] as String?,
      year: json['year'] as int? ?? 0,
      isFree: json['is_free'] == 1 || json['is_free'] == true,
      parentId:
          json['parent']?['id']?.toString() ?? json['parentId']?.toString(),
      children: json['children'] != null
          ? (json['children'] as List)
                .map((m) => LearnModule.fromJson(m as Map<String, dynamic>))
                .toList()
          : null,
      lessons: json['lessons'] != null
          ? (json['lessons'] as List)
                .map((l) => LearnLesson.fromJson(l as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'year': year,
      'is_free': isFree,
      'parent': parentId != null ? {'id': parentId} : null,
      'children': children?.map((m) => m.toJson()).toList(),
      'lessons': lessons?.map((l) => l.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    year,
    parentId,
    children,
    lessons,
  ];
}

class LearnLesson extends Equatable {
  final String id;
  final String moduleId;
  final String title;
  final int order;
  final bool isFree;
  final List<LearnParagraph>? paragraphs;
  final LearnModule? module;
  final bool isStudied;

  const LearnLesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.order,
    this.isFree = false,
    this.paragraphs,
    this.module,
    this.isStudied = false,
  });

  factory LearnLesson.fromJson(Map<String, dynamic> json) {
    return LearnLesson(
      id: json['id'].toString(),
      moduleId: json['moduleId']?.toString() ?? '',
      title: json['title'] as String,
      order: json['order'] as int? ?? 0,
      isFree: json['is_free'] == 1 || json['is_free'] == true,
      paragraphs: json['paragraphs'] != null
          ? (json['paragraphs'] as List)
                .map((p) => LearnParagraph.fromJson(p as Map<String, dynamic>))
                .toList()
          : null,
      module: json['module'] != null
          ? LearnModule.fromJson(json['module'] as Map<String, dynamic>)
          : null,
      isStudied:
          json['is_studied'] == 1 ||
          json['is_studied'] == true ||
          json['isStudied'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moduleId': moduleId,
      'title': title,
      'order': order,
      'is_free': isFree,
      'is_studied': isStudied,
    };
  }

  @override
  List<Object?> get props => [
    id,
    moduleId,
    title,
    order,
    paragraphs,
    isStudied,
  ];
}

class LearnParagraph extends Equatable {
  final String id;
  final String? title;
  final String lessonId;
  final String content;
  final int order;
  final bool hasQuiz;
  final ParagraphNote? myNote;
  final List<HighlightModel> highlights;

  const LearnParagraph({
    required this.id,
    this.title,
    required this.lessonId,
    required this.content,
    required this.order,
    this.hasQuiz = false,
    this.myNote,
    this.highlights = const [],
  });

  factory LearnParagraph.fromJson(Map<String, dynamic> json) {
    return LearnParagraph(
      id: json['id'].toString(),
      title: json['title'] as String?,
      lessonId: json['lessonId']?.toString() ?? '',
      content: json['content'] as String,
      order: json['order'] as int? ?? 0,
      hasQuiz: json['has_quiz'] == 1 || json['has_quiz'] == true,
      myNote: json['my_note'] != null
          ? ParagraphNote.fromJson(json['my_note'] as Map<String, dynamic>)
          : null,
      highlights: () {
        final data = json['my_highlights'];
        if (data == null) return const <HighlightModel>[];

        List list;
        if (data is String) {
          try {
            list = jsonDecode(data) as List;
          } catch (e) {
            debugPrint('DEBUG: Error decoding my_highlights string: $e');
            return const <HighlightModel>[];
          }
        } else if (data is List) {
          list = data;
        } else {
          return const <HighlightModel>[];
        }

        return list
            .map((h) => HighlightModel.fromJson(h as Map<String, dynamic>))
            .toList();
      }(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    lessonId,
    content,
    order,
    hasQuiz,
    myNote,
    highlights,
  ];
}

class ParagraphNote extends Equatable {
  final String id;
  final String? text;
  final String? googleDriveFileId;
  final String? googleDriveWebViewLink;
  final String? thumbnailUrl;

  const ParagraphNote({
    required this.id,
    this.text,
    this.googleDriveFileId,
    this.googleDriveWebViewLink,
    this.thumbnailUrl,
  });

  factory ParagraphNote.fromJson(Map<String, dynamic> json) {
    return ParagraphNote(
      id: json['id'].toString(),
      text: json['text'] as String?,
      googleDriveFileId: json['google_drive_file_id'] as String?,
      googleDriveWebViewLink: json['google_drive_web_view_link'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    text,
    googleDriveFileId,
    googleDriveWebViewLink,
    thumbnailUrl,
  ];
}

// Deprecated models for compatibility during transition (if needed)
// These can be removed once the refactor is complete.
class CourseSummary {
  final String id;
  final String title;
  final String specialty;
  final int? itemNumber;
  final double progress;

  CourseSummary({
    required this.id,
    required this.title,
    required this.specialty,
    this.itemNumber,
    this.progress = 0.0,
  });
}
