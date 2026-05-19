import 'dart:convert';
import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/quiz/domain/models/quiz_note_entry.dart';

final quizNotesProvider = FutureProvider<List<QuizNoteEntry>>((ref) async {
  final savedQuestions = await ref.watch(mySavedQuestionsProvider.future);
  final List<QuizNoteEntry> allNotes = [];

  final Set<int> processedClinicalCaseIds = {};

  for (final saved in savedQuestions) {
    final question = saved.question;
    if (question == null) continue;

    //1.Process Question Highlights
    if (question.myHighlights != null) {
      _parseHighlightsJson(
        question.myHighlights!,
        question,
        allNotes,
        isClinicalCase: false,
      );
    }

    //2.Process Clinical Case(Only once per case)
    final clinicalCaseId = question.clinicalCase?.id;
    if (clinicalCaseId != null &&
        !processedClinicalCaseIds.contains(clinicalCaseId)) {
      processedClinicalCaseIds.add(clinicalCaseId);

      //Process Clinical Case Highlights
      if (question.clinicalCase?.myHighlights != null) {
        _parseHighlightsJson(
          question.clinicalCase!.myHighlights!,
          question,
          allNotes,
          isClinicalCase: true,
        );
      }

      //Process Clinical Case Global Note
      if (question.clinicalCase?.myNote?.text != null &&
          question.clinicalCase!.myNote!.text!.isNotEmpty) {
        allNotes.add(
          QuizNoteEntry(
            questionId: question.id,
            questionText: question.text,
            note: question.clinicalCase!.myNote!.text!,
            lessonTitle: question.lessonTitle,
            moduleName: question.moduleName,
            year: question.year,
            createdAt: saved.createdAt,
            isGlobal: true,
            clinicalCaseId: clinicalCaseId,
            clinicalCaseTitle: question.clinicalCase?.title,
          ),
        );
      }
    }
  }

  //Sort by date descending
  allNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return allNotes;
});

void _parseHighlightsJson(
  String jsonStr,
  Question question,
  List<QuizNoteEntry> target, {
  required bool isClinicalCase,
}) {
  try {
    final decoded = json.decode(jsonStr);
    if (decoded is Map<String, dynamic>) {
      //Global question note
      if (!isClinicalCase && decoded.containsKey('global_question_note')) {
        final noteText = decoded['global_question_note'] as String?;
        if (noteText != null && noteText.isNotEmpty) {
          target.add(
            QuizNoteEntry(
              questionId: question.id,
              questionText: question.text,
              note: noteText,
              lessonTitle: question.lessonTitle,
              moduleName: question.moduleName,
              year: question.year,
              createdAt:
                  DateTime.now(), //Fallback as global notes don't have separate timestamp in JSON yet
              isGlobal: true,
            ),
          );
        }
      }

      //Individual highlights
      decoded.forEach((key, value) {
        if (value is List) {
          for (final hJson in value) {
            final highlight = HighlightModel.fromJson(
              hJson as Map<String, dynamic>,
            );
            if (highlight.note != null && highlight.note!.isNotEmpty) {
              target.add(
                QuizNoteEntry(
                  questionId: question.id,
                  questionText: question.text,
                  highlightText: highlight.text,
                  note: highlight.note!,
                  lessonTitle: question.lessonTitle,
                  moduleName: question.moduleName,
                  year: question.year,
                  createdAt: highlight.createdAt,
                  isGlobal: false,
                  clinicalCaseId: isClinicalCase
                      ? question.clinicalCase?.id
                      : null,
                  clinicalCaseTitle: isClinicalCase
                      ? question.clinicalCase?.title
                      : null,
                ),
              );
            }
          }
        }
      });
    }
  } catch (_) {
    //Handle parsing error silently in production
  }
}
