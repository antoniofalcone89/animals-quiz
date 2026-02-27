import '../models/leaderboard_entry.dart';

abstract class LeaderboardRepository {
  Future<List<LeaderboardEntry>> getLeaderboard({
    int limit = 50,
    int offset = 0,
  });

  Future<List<LeaderboardEntry>> getDailyChallengeLeaderboard({
    String date = 'today',
    int limit = 50,
    int offset = 0,
  });
}
