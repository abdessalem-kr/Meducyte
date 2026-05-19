class QuizNoteEntry {
  final int questionId;
  final String questionText;
  final String? highlightText;
  final String note;
  final String? lessonTitle;
  final String? moduleName;
  final int? year;
  final DateTime createdAt;
  final bool isGlobal;
  final int? clinicalCaseId;
  final String? clinicalCaseTitle;

  QuizNoteEntry({
    required this.questionId,
    required this.questionText,
    this.highlightText,
    required this.note,
    this.lessonTitle,
    this.moduleName,
    this.year,
    required this.createdAt,
    this.isGlobal = false,
    this.clinicalCaseId,
    this.clinicalCaseTitle,
  });

  QuizNoteEntry copyWith({
    int? questionId,
    String? questionText,
    String? highlightText,
    String? note,
    String? lessonTitle,
    String? moduleName,
    int? year,
    DateTime? createdAt,
    bool? isGlobal,
    int? clinicalCaseId,
    String? clinicalCaseTitle,
  }) {
    return QuizNoteEntry(
      questionId: questionId ?? this.questionId,
      questionText: questionText ?? this.questionText,
      highlightText: highlightText ?? this.highlightText,
      note: note ?? this.note,
      lessonTitle: lessonTitle ?? this.lessonTitle,
      moduleName: moduleName ?? this.moduleName,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
      isGlobal: isGlobal ?? this.isGlobal,
      clinicalCaseId: clinicalCaseId ?? this.clinicalCaseId,
      clinicalCaseTitle: clinicalCaseTitle ?? this.clinicalCaseTitle,
    );
  }
}
