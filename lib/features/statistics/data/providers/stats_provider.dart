import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/core/network/dio_client.dart';
import 'package:meducyte_app/shared/providers/network_provider.dart';
import 'package:meducyte_app/features/statistics/domain/models/stats_models.dart';

class StatsRepository {
  //ignore:unused_field
  final DioClient _client;

  StatsRepository(this._client);

  Future<UserStats> getUserStats() async {
    try {
      //In a real app,this would be:
      //final response=await _client.get('/stats/me');
      //return UserStats.fromJson(response.data);

      //For now,returning empty stats to show the UI without mock data
      await Future.delayed(const Duration(seconds: 1));
      return UserStats.empty();
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
