import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/core/network/dio_client.dart';
import 'package:meducyte_app/shared/providers/network_provider.dart';
import 'package:meducyte_app/features/statistics/domain/models/stats_models.dart';

class StatsRepository {
  //ignore:unused_field
  final DioClient _client;

  StatsRepository(this._client);

  Future<UserStats> getUserStats() async {
    const String query = r'''
      query GetMyStats {
        myStats {
          overallAccuracy
          quizzesCompleted
          questionsAnswered
          questionsAnsweredToday
          studyStreak
          specialtyAccuracy
          performanceTrend
        }
      }
    ''';
    try {
      final response = await _client.post('/graphql', data: {'query': query});
      final mapData = response.data as Map<String, dynamic>?;
      if (mapData == null) throw Exception('Response data is null');

      if (mapData['errors'] != null) {
        final errorMsg = mapData['errors'][0]['message'];
        throw Exception('GraphQL error: $errorMsg');
      }

      final data = mapData['data']?['myStats'];
      if (data == null) {
        return UserStats.empty();
      }

      return UserStats.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load statistics: $e');
    }
  }
}

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return StatsRepository(dioClient);
});

final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final repository = ref.watch(statsRepositoryProvider);
  return repository.getUserStats();
});
