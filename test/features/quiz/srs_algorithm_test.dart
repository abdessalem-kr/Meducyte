import 'package:flutter_test/flutter_test.dart';
import 'package:meducyte_app/features/quiz/data/repositories/srs_repository.dart';

void main() {
  group('SrsAlgorithm', () {
    test('New card - Good performance should give 10m interval', () {
      final result = SrsAlgorithm.calculate(
        repetitionCount: 0,
        intervalDays: 0,
        easeFactor: 2.5,
        performance: SrsPerformance.good,
      );

      expect(result.nextInterval.inMinutes, equals(10));
      expect(result.nextRepetitionCount, equals(1));
    });

    test(
      'Learning card (step 1) - Good performance should give 1d interval',
      () {
        final result = SrsAlgorithm.calculate(
          repetitionCount: 1,
          intervalDays: 0,
          easeFactor: 2.5,
          performance: SrsPerformance.good,
        );

        expect(result.nextInterval.inDays, equals(1));
        expect(result.nextRepetitionCount, equals(2));
      },
    );

    test(
      'New card - Easy performance should give 4d interval and graduate',
      () {
        final result = SrsAlgorithm.calculate(
          repetitionCount: 0,
          intervalDays: 0,
          easeFactor: 2.5,
          performance: SrsPerformance.easy,
        );

        expect(result.nextInterval.inDays, equals(4));
        expect(result.nextRepetitionCount, equals(2));
        expect(result.nextEaseFactor, greaterThan(2.5));
      },
    );

    test('Graduated card - Good performance should use ease factor', () {
      final result = SrsAlgorithm.calculate(
        repetitionCount: 2,
        intervalDays: 1,
        easeFactor: 2.5,
        performance: SrsPerformance.good,
      );

      expect(
        result.nextInterval.inDays,
        equals(3),
      ); // 1 * 2.5 = 2.5 -> ceil = 3
      expect(result.nextRepetitionCount, equals(2));
    });

    test('Graduated card - Again performance should reset to learning', () {
      final result = SrsAlgorithm.calculate(
        repetitionCount: 5,
        intervalDays: 10,
        easeFactor: 2.5,
        performance: SrsPerformance.again,
      );

      expect(result.nextInterval.inMinutes, equals(1));
      expect(result.nextRepetitionCount, equals(0));
      expect(result.nextEaseFactor, equals(2.3)); // 2.5 - 0.2
    });

    test(
      'Graduated card - Hard performance should increase interval slightly',
      () {
        final result = SrsAlgorithm.calculate(
          repetitionCount: 2,
          intervalDays: 3,
          easeFactor: 2.5,
          performance: SrsPerformance.hard,
        );

        expect(
          result.nextInterval.inDays,
          equals(4),
        ); // 3 * 1.2 = 3.6 -> ceil = 4
        expect(result.nextEaseFactor, equals(2.35)); // 2.5 - 0.15
      },
    );
  });
}
