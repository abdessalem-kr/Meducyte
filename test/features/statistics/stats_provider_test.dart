import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:meducyte_app/core/network/dio_client.dart';
import 'package:meducyte_app/features/statistics/data/providers/stats_provider.dart';
import 'package:meducyte_app/features/statistics/domain/models/stats_models.dart';

// Fake DioClient for intercepting stats API calls
class FakeStatsDioClient extends Fake implements DioClient {
  int postCallCount = 0;
  Map<String, dynamic>? nextResponse;
  bool shouldThrow = false;
  String? queryReceived;

  @override
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    postCallCount++;
    if (data is Map && data.containsKey('query')) {
      queryReceived = data['query'] as String;
    }
    
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'Network connection failure',
        type: DioExceptionType.connectionTimeout,
      );
    }

    return Response(
      requestOptions: RequestOptions(path: path),
      data: nextResponse ?? {'data': {}},
      statusCode: 200,
    );
  }
}

void main() {
  group('StatsRepository and userStatsProvider Tests', () {
    late FakeStatsDioClient fakeDio;
    late StatsRepository repository;

    setUp(() {
      fakeDio = FakeStatsDioClient();
      repository = StatsRepository(fakeDio);
    });

    test('getUserStats successfully fetches and parses remote stats with camelCase keys', () async {
      final mockResponse = {
        'data': {
          'myStats': {
            'overallAccuracy': 0.85,
            'quizzesCompleted': 12,
            'questionsAnswered': 120,
            'questionsAnsweredToday': 15,
            'studyStreak': 5,
            'specialtyAccuracy': {
              'Cardiology': 0.90,
              'Neurology': 0.80,
            },
            'performanceTrend': [0.70, 0.75, 0.80, 0.85],
          }
        }
      };

      fakeDio.nextResponse = mockResponse;

      final stats = await repository.getUserStats();

      expect(fakeDio.postCallCount, 1);
      expect(fakeDio.queryReceived, contains('myStats'));
      expect(fakeDio.queryReceived, contains('overallAccuracy'));

      expect(stats.overallAccuracy, 0.85);
      expect(stats.quizzesCompleted, 12);
      expect(stats.questionsAnswered, 120);
      expect(stats.questionsAnsweredToday, 15);
      expect(stats.studyStreak, 5);
      expect(stats.specialtyAccuracy['Cardiology'], 0.90);
      expect(stats.specialtyAccuracy['Neurology'], 0.80);
      expect(stats.performanceTrend.length, 4);
      expect(stats.performanceTrend[3].accuracy, 0.85);
    });

    test('getUserStats successfully parses remote stats with snake_case keys as fallback', () async {
      final mockResponse = {
        'data': {
          'myStats': {
            'overall_accuracy': 0.75,
            'quizzes_completed': 8,
            'questions_answered': 80,
            'questions_answered_today': 10,
            'study_streak': 3,
            'specialty_accuracy': {
              'Pulmonology': 0.70,
            },
            'performance_trend': [0.60, 0.75],
          }
        }
      };

      fakeDio.nextResponse = mockResponse;

      final stats = await repository.getUserStats();

      expect(stats.overallAccuracy, 0.75);
      expect(stats.quizzesCompleted, 8);
      expect(stats.questionsAnswered, 80);
      expect(stats.questionsAnsweredToday, 10);
      expect(stats.studyStreak, 3);
      expect(stats.specialtyAccuracy['Pulmonology'], 0.70);
      expect(stats.performanceTrend.length, 2);
      expect(stats.performanceTrend[1].accuracy, 0.75);
    });

    test('getUserStats returns empty stats when response contains null myStats', () async {
      final mockResponse = {
        'data': {
          'myStats': null,
        }
      };

      fakeDio.nextResponse = mockResponse;

      final stats = await repository.getUserStats();

      expect(stats.overallAccuracy, 0.0);
      expect(stats.quizzesCompleted, 0);
      expect(stats.questionsAnswered, 0);
      expect(stats.studyStreak, 0);
      expect(stats.specialtyAccuracy, isEmpty);
      expect(stats.performanceTrend, isEmpty);
    });

    test('getUserStats throws exception when GraphQL error is returned', () async {
      final mockResponse = {
        'errors': [
          {'message': 'Unauthorized access to statistics'}
        ]
      };

      fakeDio.nextResponse = mockResponse;

      expect(
        () => repository.getUserStats(),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('GraphQL error: Unauthorized access to statistics'))),
      );
    });

    test('getUserStats throws exception when connection/network failure occurs', () async {
      fakeDio.shouldThrow = true;

      expect(
        () => repository.getUserStats(),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Failed to load statistics'))),
      );
    });

    test('userStatsProvider propagates data from StatsRepository correctly', () async {
      final mockResponse = {
        'data': {
          'myStats': {
            'overallAccuracy': 0.95,
            'quizzesCompleted': 20,
            'questionsAnswered': 200,
            'questionsAnsweredToday': 25,
            'studyStreak': 10,
            'specialtyAccuracy': {},
            'performanceTrend': [],
          }
        }
      };

      fakeDio.nextResponse = mockResponse;

      final container = ProviderContainer(
        overrides: [
          statsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final statsFuture = container.read(userStatsProvider.future);
      expect(statsFuture, isA<Future<UserStats>>());

      final stats = await statsFuture;
      expect(stats.overallAccuracy, 0.95);
      expect(stats.quizzesCompleted, 20);
      expect(stats.questionsAnswered, 200);
      expect(stats.questionsAnsweredToday, 25);
      expect(stats.studyStreak, 10);
    });
  });
}
