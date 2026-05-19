import 'package:meducyte_app/features/learn/domain/models/course.dart';

enum QuizCorrectionMode { allOrNothing, partial }

class ClinicalCase {
  final int id;
  final String text;
  final String? title;
  final String? myHighlights;
  final ParagraphNote? myNote;

  ClinicalCase({
    required this.id,
    required this.text,
    this.title,
    this.myHighlights,
    this.myNote,
  });

  factory ClinicalCase.fromJson(Map<String, dynamic> json) {
    return ClinicalCase(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      text: json['text'] as String,
      title: json['title'] as String?,
      myHighlights: json['my_highlights']?.toString(),
      myNote: json['my_note'] != null
          ? ParagraphNote.fromJson(json['my_note'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'title': title,
    'my_highlights': myHighlights,
    'my_note': myNote?.toString(), //Simple serialization for note
  };
}

class Question {
  final int id;
  final int? paragraphId;
  final int? lessonId;
  final String text;
  final String? sourceExam;
  final List<String> tags;
  final int? estimatedTime;
  final List<Proposition> propositions;
  final String? lessonTitle;
  final String? moduleName;
  final int? year;
  final List<QuestionComment> comments;
  final String? myHighlights; //JSON string from backend
  final bool isSaved;
  final ClinicalCase? clinicalCase;

  Question({
    required this.id,
    this.paragraphId,
    this.lessonId,
    required this.text,
    this.sourceExam,
    this.tags = const [],
    this.estimatedTime,
    required this.propositions,
    this.lessonTitle,
    this.moduleName,
    this.year,
    this.comments = const [],
    this.myHighlights,
    this.isSaved = false,
    this.clinicalCase,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      paragraphId: (json['paragraphId'] ?? json['paragraph_id']) != null
          ? int.tryParse(
              (json['paragraphId'] ?? json['paragraph_id']).toString(),
            )
          : null,
      lessonId: (json['lessonId'] ?? json['lesson_id']) != null
          ? int.tryParse((json['lessonId'] ?? json['lesson_id']).toString())
          : null,
      text: json['text'] as String,
      sourceExam: (json['sourceExam'] ?? json['source_exam']) as String?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : const [],
      estimatedTime: (json['estimatedTime'] ?? json['estimated_time']) as int?,
      propositions: (json['propositions'] as List)
          .map((p) => Proposition.fromJson(p as Map<String, dynamic>))
          .toList(),
      lessonTitle: (json['lessonTitle'] ?? json['lesson']?['title']) as String?,
      moduleName:
          (json['moduleName'] ?? json['lesson']?['module']?['name']) as String?,
      year: (json['year'] ?? json['lesson']?['module']?['year']) as int?,
      comments: json['comments'] != null
          ? (json['comments'] as List)
                .map((c) => QuestionComment.fromJson(c as Map<String, dynamic>))
                .toList()
          : const [],
      myHighlights: json['my_highlights']?.toString(),
      isSaved:
          json['saved_by_user'] == 1 ||
          json['saved_by_user'] == true ||
          json['savedByUser'] == true,
      clinicalCase: json['clinicalCase'] != null
          ? ClinicalCase.fromJson(json['clinicalCase'] as Map<String, dynamic>)
          : null,
    );
  }

  ///Returns whether a specific proposition is correct for this question.
  bool forValidation(int propositionId) {
    try {
      final prop = propositions.firstWhere((p) => p.id == propositionId);
      return prop.isCorrect;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'paragraph_id': paragraphId,
    'lesson_id': lessonId,
    'text': text,
    'source_exam': sourceExam,
    'tags': tags,
    'estimated_time': estimatedTime,
    'propositions': propositions.map((p) => p.toJson()).toList(),
    'lesson': lessonTitle != null ? {'title': lessonTitle} : null,
    'module': moduleName != null ? {'name': moduleName, 'year': year} : null,
    'comments': comments.map((c) => c.toJson()).toList(),
    'my_highlights': myHighlights,
    'saved_by_user': isSaved,
    'clinicalCase': clinicalCase?.toJson(),
  };

  Question copyWith({
    int? id,
    int? paragraphId,
    int? lessonId,
    String? text,
    String? sourceExam,
    List<String>? tags,
    int? estimatedTime,
    List<Proposition>? propositions,
    String? lessonTitle,
    String? moduleName,
    int? year,
    List<QuestionComment>? comments,
    String? myHighlights,
    bool? isSaved,
  }) {
    return Question(
      id: id ?? this.id,
      paragraphId: paragraphId ?? this.paragraphId,
      lessonId: lessonId ?? this.lessonId,
      text: text ?? this.text,
      sourceExam: sourceExam ?? this.sourceExam,
      tags: tags ?? this.tags,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      propositions: propositions ?? this.propositions,
      lessonTitle: lessonTitle ?? this.lessonTitle,
      moduleName: moduleName ?? this.moduleName,
      year: year ?? this.year,
      comments: comments ?? this.comments,
      myHighlights: myHighlights ?? this.myHighlights,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

class Proposition {
  final int id;
  final int questionId;
  final String label;
  final String text;
  final bool isCorrect;
  final int order;

  Proposition({
    required this.id,
    required this.questionId,
    required this.label,
    required this.text,
    required this.isCorrect,
    required this.order,
  });

  factory Proposition.fromJson(Map<String, dynamic> json) {
    return Proposition(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      questionId: (json['questionId'] ?? json['question_id']) != null
          ? int.parse((json['questionId'] ?? json['question_id']).toString())
          : 0,
      label: json['label'] as String,
      text: json['text'] as String,
      isCorrect:
          json['is_correct'] == 1 ||
          json['is_correct'] == true ||
          json['isCorrect'] == true,
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question_id': questionId,
    'label': label,
    'text': text,
    'is_correct': isCorrect ? 1 : 0,
    'order': order,
  };
}

class QuizSession {
  final String id;
  final List<Question> questions;
  final DateTime startTime;
  final Map<String, dynamic> filters;
  int currentQuestionIndex;
  Map<int, Set<int>> userAnswers; //questionId->set of propositionIds
  final QuizCorrectionMode correctionMode;
  bool isCompleted;

  QuizSession({
    required this.id,
    required this.questions,
    required this.startTime,
    required this.filters,
    this.currentQuestionIndex = 0,
    Map<int, Set<int>>? userAnswers,
    this.correctionMode = QuizCorrectionMode.allOrNothing,
    this.isCompleted = false,
  }) : userAnswers = userAnswers ?? {};

  factory QuizSession.fromJson(Map<String, dynamic> json) {
    final Map<int, Set<int>> loadedAnswers = {};
    if (json['user_answers'] != null) {
      final answersMap = json['user_answers'] as Map<String, dynamic>;
      answersMap.forEach((qIdStr, propIds) {
        final qId = int.parse(qIdStr);
        final propsList = propIds as List;
        loadedAnswers[qId] = propsList.map((id) => id as int).toSet();
      });
    }

    return QuizSession(
      id: json['id'] as String,
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList(),
      startTime: DateTime.parse(json['start_time'] as String),
      filters: json['filters'] as Map<String, dynamic>,
      currentQuestionIndex: json['current_question_index'] as int? ?? 0,
      userAnswers: loadedAnswers,
      isCompleted: json['is_completed'] as bool? ?? false,
      correctionMode: json['correction_mode'] != null
          ? QuizCorrectionMode.values.firstWhere(
              (e) => e.name == json['correction_mode'],
              orElse: () => QuizCorrectionMode.allOrNothing,
            )
          : QuizCorrectionMode.allOrNothing,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> encodedAnswers = {};
    userAnswers.forEach((qId, props) {
      encodedAnswers[qId.toString()] = props.toList();
    });

    return {
      'id': id,
      'questions': questions.map((q) => q.toJson()).toList(),
      'start_time': startTime.toIso8601String(),
      'filters': filters,
      'current_question_index': currentQuestionIndex,
      'user_answers': encodedAnswers,
      'is_completed': isCompleted,
      'correction_mode': correctionMode.name,
    };
  }

  AnswerResult validateAnswer(int questionId) {
    try {
      final question = questions.firstWhere((q) => q.id == questionId);
      final selectedPropIds = userAnswers[questionId] ?? {};

      final correctPropIds = question.propositions
          .where((p) => p.isCorrect)
          .map((p) => p.id)
          .toSet();

      if (correctionMode == QuizCorrectionMode.allOrNothing) {
        final bool isCorrect =
            selectedPropIds.length == correctPropIds.length &&
            selectedPropIds.containsAll(correctPropIds);
        return AnswerResult(
          isCorrect: isCorrect,
          score: isCorrect ? 1.0 : 0.0,
          correctPropositionId: correctPropIds.isNotEmpty
              ? correctPropIds.first
              : null,
        );
      } else {
        //Simple Ratio scoring: (correct selected) / (total correct)
        final correctlySelectedCount = selectedPropIds
            .where((id) => correctPropIds.contains(id))
            .length;
        final totalCorrectCount = correctPropIds.length;

        double score = totalCorrectCount > 0
            ? correctlySelectedCount / totalCorrectCount
            : 0.0;

        return AnswerResult(
          isCorrect: score > 0,
          score: score,
          correctPropositionId: correctPropIds.isNotEmpty
              ? correctPropIds.first
              : null,
        );
      }
    } catch (_) {
      return AnswerResult(isCorrect: false, score: 0.0);
    }
  }
}

class AnswerResult {
  final bool isCorrect;
  final double score;
  final int? correctPropositionId;
  final String? explanation;

  AnswerResult({
    required this.isCorrect,
    this.score = 0.0,
    this.correctPropositionId,
    this.explanation,
  });
}

class QuestionComment {
  final String id;
  final String author;
  final String text;
  final bool isEdited;
  final DateTime createdAt;
  final String? parentId;
  final int upvotes;
  final int downvotes;
  final int? myVote;
  final bool isMine;
  final List<QuestionComment> replies;

  QuestionComment({
    required this.id,
    required this.author,
    required this.text,
    this.isEdited = false,
    required this.createdAt,
    this.parentId,
    this.upvotes = 0,
    this.downvotes = 0,
    this.myVote,
    this.isMine = false,
    this.replies = const [],
  });

  factory QuestionComment.fromJson(Map<String, dynamic> json) {
    return QuestionComment(
      id: json['id'].toString(),
      author: json['user']?['name'] as String? ?? 'Anonyme',
      text: json['text'] as String,
      isEdited: json['is_edited'] == 1 || json['is_edited'] == true,
      createdAt: DateTime.parse(json['created_at'] as String),
      parentId: json['parent_id']?.toString(),
      upvotes: json['upvotes'] as int? ?? 0,
      downvotes: json['downvotes'] as int? ?? 0,
      myVote: json['my_vote'] as int?,
      isMine: json['is_mine'] == 1 || json['is_mine'] == true,
      replies: json['replies'] != null
          ? (json['replies'] as List)
                .map((r) => QuestionComment.fromJson(r as Map<String, dynamic>))
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author,
    'text': text,
    'is_edited': isEdited,
    'created_at': createdAt.toIso8601String(),
    'parent_id': parentId,
    'upvotes': upvotes,
    'downvotes': downvotes,
    'my_vote': myVote,
    'is_mine': isMine,
    'replies': replies.map((r) => r.toJson()).toList(),
  };

  QuestionComment copyWith({
    String? id,
    String? author,
    String? text,
    bool? isEdited,
    DateTime? createdAt,
    String? parentId,
    int? upvotes,
    int? downvotes,
    int? myVote,
    bool? isMine,
    List<QuestionComment>? replies,
  }) {
    return QuestionComment(
      id: id ?? this.id,
      author: author ?? this.author,
      text: text ?? this.text,
      isEdited: isEdited ?? this.isEdited,
      createdAt: createdAt ?? this.createdAt,
      parentId: parentId ?? this.parentId,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      myVote: myVote ?? this.myVote,
      isMine: isMine ?? this.isMine,
      replies: replies ?? this.replies,
    );
  }
}

class QuestionFolder {
  final int id;
  final String name;
  final String? color;
  final int userId;

  QuestionFolder({
    required this.id,
    required this.name,
    this.color,
    required this.userId,
  });

  factory QuestionFolder.fromJson(Map<String, dynamic> json) {
    return QuestionFolder(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      name: json['name'] as String,
      color: json['color'] as String?,
      userId: json['user_id'] != null
          ? (json['user_id'] is int
                ? json['user_id'] as int
                : int.parse(json['user_id'].toString()))
          : 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'user_id': userId,
  };

  QuestionFolder copyWith({int? id, String? name, String? color, int? userId}) {
    return QuestionFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      userId: userId ?? this.userId,
    );
  }
}

class SavedQuestion {
  final int id;
  final int userId;
  final int questionId;
  final int? folderId;
  final Question? question;
  final DateTime createdAt;

  SavedQuestion({
    required this.id,
    required this.userId,
    required this.questionId,
    this.folderId,
    this.question,
    required this.createdAt,
  });

  factory SavedQuestion.fromJson(Map<String, dynamic> json) {
    return SavedQuestion(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      userId: (json['user_id'] ?? json['userId']) != null
          ? ((json['user_id'] ?? json['userId']) is int
                ? (json['user_id'] ?? json['userId']) as int
                : int.parse((json['user_id'] ?? json['userId']).toString()))
          : 0,
      questionId: (json['question_id'] ?? json['questionId']) != null
          ? ((json['question_id'] ?? json['questionId']) is int
                ? (json['question_id'] ?? json['questionId']) as int
                : int.parse(
                    (json['question_id'] ?? json['questionId']).toString(),
                  ))
          : 0,
      folderId: (json['folder_id'] ?? json['folderId']) != null
          ? ((json['folder_id'] ?? json['folderId']) is int
                ? (json['folder_id'] ?? json['folderId']) as int
                : int.parse((json['folder_id'] ?? json['folderId']).toString()))
          : null,
      question: json['question'] != null
          ? Question.fromJson(json['question'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'question_id': questionId,
    'folder_id': folderId,
    'question': question?.toJson(),
    'created_at': createdAt.toIso8601String(),
  };
}
