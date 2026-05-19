import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/shared/providers/database_provider.dart';
import 'package:drift/drift.dart';

final srsRepositoryProvider = Provider<SrsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final quizRepo = ref.watch(quizRepositoryProvider);
  return SrsRepository(db, quizRepo);
});

final dueQuestionsCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.questionReviews)
        ..where((t) => t.nextReview.isSmallerOrEqual(Variable(DateTime.now()))))
      .watch()
      .map((reviews) => reviews.length);
});

final srsStatsProvider = StreamProvider<Map<String, int>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.questionReviews).watch().map((reviews) {
    int due = 0;
    int learning = 0; //Box 1-2
    int mastered = 0; //Box 5
    int total = reviews.length;
    final now = DateTime.now();

    for (var r in reviews) {
      if (r.nextReview.isBefore(now) || r.nextReview.isAtSameMomentAs(now)) {
        due++;
      }
      if (r.box <= 2) {
        learning++;
      } else if (r.box == 5) {
        mastered++;
      }
    }

    return {
      'due': due,
      'learning': learning,
      'mastered': mastered,
      'total': total,
    };
  });
});

final questionInSrsProvider = StreamProvider.family<bool, int>((
  ref,
  questionId,
) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.questionReviews)
        ..where((t) => t.questionId.equals(questionId)))
      .watchSingleOrNull()
      .map((r) => r != null);
});
