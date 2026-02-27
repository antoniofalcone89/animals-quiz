import '../../models/leaderboard_entry.dart';
import '../../services/api_client.dart';
import '../leaderboard_repository.dart';

class ApiLeaderboardRepository implements LeaderboardRepository {
  final ApiClient _client;

  ApiLeaderboardRepository(this._client);

  @override
  Future<List<LeaderboardEntry>> getLeaderboard({
    int limit = 50,
    int offset = 0,
  }) async {
    final json = await _client.get('/leaderboard?limit=$limit&offset=$offset');
    final list =
        (json['leaderboard'] as List<dynamic>?) ??
        (json['entries'] as List<dynamic>? ?? const []);
    return list
        .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<LeaderboardEntry>> getDailyChallengeLeaderboard({
    String date = 'today',
    int limit = 50,
    int offset = 0,
  }) async {
    final json = await _client.get(
      '/challenge/leaderboard?date=$date&limit=$limit&offset=$offset',
    );
    final list =
        (json['leaderboard'] as List<dynamic>?) ??
        (json['entries'] as List<dynamic>? ?? const []);
    return list
        .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
