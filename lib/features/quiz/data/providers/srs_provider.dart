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
  final quizRepo = ref.watch(quizRepositoryProvider);
  final user = ref.watch(authControllerProvider).value;
  final is1to6YearUser = user != null && user.year >= 1 && user.year <= 6;

  if (is1to6YearUser) {
    return (db.select(db.questionReviews)
          ..where((t) => t.nextReview.isSmallerOrEqual(Variable(DateTime.now()))))
        .watch()
        .asyncMap((reviews) async {
          if (reviews.isEmpty) return 0;
          try {
            final ids = reviews.map((r) => r.questionId).toList();
            final questions = await quizRepo.getQuestionsByIds(ids);
            final filtered = questions.where((q) => q.year == user.year).toList();
            return filtered.length;
          } catch (_) {
            return 0;
          }
        });
  }

  return (db.select(db.questionReviews)
        ..where((t) => t.nextReview.isSmallerOrEqual(Variable(DateTime.now()))))
      .watch()
      .map((reviews) => reviews.length);
});

final srsStatsProvider = StreamProvider<Map<String, int>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final quizRepo = ref.watch(quizRepositoryProvider);
  final user = ref.watch(authControllerProvider).value;
  final is1to6YearUser = user != null && user.year >= 1 && user.year <= 6;

  if (is1to6YearUser) {
    return db.select(db.questionReviews).watch().asyncMap((reviews) async {
      if (reviews.isEmpty) {
        return {
          'due': 0,
          'learning': 0,
          'mastered': 0,
          'total': 0,
        };
      }
      try {
        final ids = reviews.map((r) => r.questionId).toList();
        final questions = await quizRepo.getQuestionsByIds(ids);
        final allowedIds = questions.where((q) => q.year == user.year).map((q) => q.id).toSet();

        int due = 0;
        int learning = 0;
        int mastered = 0;
        int total = 0;
        final now = DateTime.now();

        for (var r in reviews) {
          if (!allowedIds.contains(r.questionId)) continue;
          total++;
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
      } catch (_) {
        return {
          'due': 0,
          'learning': 0,
          'mastered': 0,
          'total': 0,
        };
      }
    });
  }

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
