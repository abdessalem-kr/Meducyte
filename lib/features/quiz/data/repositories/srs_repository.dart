import 'package:meducyte_app/core/database/app_database.dart';
import 'package:meducyte_app/export.dart';
import 'package:drift/drift.dart';

enum SrsPerformance { again, hard, good, easy }

class SrsReviewResult {
  final Duration nextInterval;
  final int nextRepetitionCount;
  final double nextEaseFactor;

  SrsReviewResult({
    required this.nextInterval,
    required this.nextRepetitionCount,
    required this.nextEaseFactor,
  });
}

class SrsAlgorithm {
  static SrsReviewResult calculate({
    required int repetitionCount,
    required int intervalDays,
    required double easeFactor,
    required SrsPerformance performance,
  }) {
    Duration nextInterval;
    int nextRepetitionCount = repetitionCount;
    double nextEaseFactor = easeFactor;

    if (repetitionCount < 2) {
      // Learning phase
      switch (performance) {
        case SrsPerformance.again:
          nextInterval = const Duration(minutes: 1);
          nextRepetitionCount = 0;
          break;
        case SrsPerformance.hard:
          nextInterval = const Duration(minutes: 5);
          break;
        case SrsPerformance.good:
          if (repetitionCount == 0) {
            nextInterval = const Duration(minutes: 10);
            nextRepetitionCount = 1;
          } else {
            nextInterval = const Duration(days: 1);
            nextRepetitionCount = 2;
          }
          break;
        case SrsPerformance.easy:
          nextInterval = const Duration(days: 4);
          nextRepetitionCount = 2;
          nextEaseFactor = (easeFactor + 0.15).clamp(1.3, 5.0);
          break;
      }
    } else {
      // Graduated phase
      int currentInterval = intervalDays == 0 ? 1 : intervalDays;

      switch (performance) {
        case SrsPerformance.again:
          nextInterval = const Duration(minutes: 1);
          nextRepetitionCount = 0;
          nextEaseFactor = (easeFactor - 0.2).clamp(1.3, 2.5);
          break;
        case SrsPerformance.hard:
          nextInterval = Duration(days: (currentInterval * 1.2).ceil());
          nextEaseFactor = (easeFactor - 0.15).clamp(1.3, 2.5);
          break;
        case SrsPerformance.good:
          nextInterval = Duration(days: (currentInterval * easeFactor).ceil());
          break;
        case SrsPerformance.easy:
          nextInterval = Duration(
            days: (currentInterval * easeFactor * 1.3).ceil(),
          );
          nextEaseFactor = (easeFactor + 0.15).clamp(1.3, 5.0);
          break;
      }
    }

    return SrsReviewResult(
      nextInterval: nextInterval,
      nextRepetitionCount: nextRepetitionCount,
      nextEaseFactor: nextEaseFactor,
    );
  }
}

class SrsRepository {
  final AppDatabase _db;
  final QuizRepository? _quizRepository;

  SrsRepository(this._db, [this._quizRepository]);

  /// Represents an interval as a human-readable string
  static String formatInterval(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h';
    } else {
      return '${duration.inDays}d';
    }
  }

  /// Calculates the next review date and updates the database
  Future<void> recordReview(int questionId, SrsPerformance performance) async {
    final existingReview = await _db.getReviewByQuestionId(questionId);
    final now = DateTime.now();

    final result = SrsAlgorithm.calculate(
      repetitionCount: existingReview?.repetitionCount ?? 0,
      intervalDays: existingReview?.interval ?? 0,
      easeFactor: existingReview?.easeFactor ?? 2.5,
      performance: performance,
    );

    final nextReviewDate = now.add(result.nextInterval);

    await _db.upsertQuestionReview(
      QuestionReviewsCompanion(
        questionId: Value(questionId),
        box: Value(1),
        nextReview: Value(nextReviewDate),
        lastReview: Value(now),
        repetitionCount: Value(result.nextRepetitionCount),
        easeFactor: Value(result.nextEaseFactor),
        interval: Value(result.nextInterval.inDays),
      ),
    );

    // Sync to backend if repository is available
    if (_quizRepository != null) {
      try {
        await _quizRepository.syncSrsReview(
          questionId: questionId,
          interval: result.nextInterval.inDays,
          easeFactor: result.nextEaseFactor,
          repetitionCount: result.nextRepetitionCount,
          nextReview: nextReviewDate,
          lastReview: now,
        );
      } catch (e) {
        debugPrint('DEBUG: SrsRepository sync error: $e');
      }
    }
  }

  /// Predicted intervals for the UI
  Future<Map<SrsPerformance, String>> getPredictedIntervals(
    int questionId,
  ) async {
    final existingReview = await _db.getReviewByQuestionId(questionId);

    final Map<SrsPerformance, String> intervals = {};
    for (var perf in SrsPerformance.values) {
      final res = SrsAlgorithm.calculate(
        repetitionCount: existingReview?.repetitionCount ?? 0,
        intervalDays: existingReview?.interval ?? 0,
        easeFactor: existingReview?.easeFactor ?? 2.5,
        performance: perf,
      );
      intervals[perf] = formatInterval(res.nextInterval);
    }
    return intervals;
  }

  Future<void> addToSrs(int questionId) async {
    final existing = await _db.getReviewByQuestionId(questionId);
    if (existing != null) return;

    await _db.upsertQuestionReview(
      QuestionReviewsCompanion(
        questionId: Value(questionId),
        box: Value(1),
        nextReview: Value(DateTime.now()), // Due immediately
        repetitionCount: Value(0),
        easeFactor: Value(2.5),
        interval: Value(0),
      ),
    );
  }

  Future<List<DbQuestionReview>> getDueReviews() => _db.getDueQuestions();

  Future<void> removeFromSrs(int questionId) => _db.deleteReview(questionId);

  Future<List<DbQuestionReview>> getAllReviews() => _db.getAllReviews();

  Future<void> resetSrs() => _db.deleteAllReviews();

  /// Fetches all reviews from backend and merges them into local DB
  Future<void> syncAllWithBackend() async {
    if (_quizRepository == null) return;

    try {
      // 1. Fetch current local reviews
      final localReviews = await getAllReviews();
      final localMap = {for (var r in localReviews) r.questionId: r};

      // 2. Fetch all reviews from backend
      final remoteReviews = await _quizRepository.fetchAllReviews();

      for (final remote in remoteReviews) {
        final qId = int.parse(remote['questionId'].toString());
        final local = localMap[qId];

        // Conflict resolution: update local if remote is different or newer
        final nextReview = DateTime.parse(remote['nextReview'].toString());
        final lastReview = remote['lastReview'] != null
            ? DateTime.parse(remote['lastReview'].toString())
            : null;

        if (local == null ||
            (lastReview != null &&
                (local.lastReview == null ||
                    lastReview.isAfter(local.lastReview!)))) {
          await _db.upsertQuestionReview(
            QuestionReviewsCompanion(
              questionId: Value(qId),
              box: Value(1),
              nextReview: Value(nextReview),
              lastReview: Value(lastReview),
              repetitionCount: Value(remote['repetitionCount'] as int),
              easeFactor: Value((remote['easeFactor'] as num).toDouble()),
              interval: Value(remote['interval'] as int),
            ),
          );
        }

        // Remove from map to track what's local-only
        localMap.remove(qId);
      }

      // 3. Sync local-only reviews UP to backend
      for (final localOnly in localMap.values) {
        await _quizRepository.syncSrsReview(
          questionId: localOnly.questionId,
          interval: localOnly.interval,
          easeFactor: localOnly.easeFactor,
          repetitionCount: localOnly.repetitionCount,
          nextReview: localOnly.nextReview,
          lastReview: localOnly.lastReview,
        );
      }
    } catch (e) {
      debugPrint('SrsRepository syncAllWithBackend error: $e');
    }
  }
}
