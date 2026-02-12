import '../../models/leaderboard_entry.dart';
import '../leaderboard_repository.dart';

class MockLeaderboardRepository implements LeaderboardRepository {
  static const _mockEntries = [
    LeaderboardEntry(rank: 1, userId: 'u1', username: 'AnimalMaster', totalCoins: 980, levelsCompleted: 6),
    LeaderboardEntry(rank: 2, userId: 'u2', username: 'WildExplorer', totalCoins: 870, levelsCompleted: 5),
    LeaderboardEntry(rank: 3, userId: 'u3', username: 'NatureLover', totalCoins: 750, levelsCompleted: 5),
    LeaderboardEntry(rank: 4, userId: 'u4', username: 'ZooKeeper42', totalCoins: 640, levelsCompleted: 4),
    LeaderboardEntry(rank: 5, userId: 'u5', username: 'SafariKing', totalCoins: 530, levelsCompleted: 4),
    LeaderboardEntry(rank: 6, userId: 'u6', username: 'BirdWatcher', totalCoins: 420, levelsCompleted: 3),
    LeaderboardEntry(rank: 7, userId: 'u7', username: 'OceanFan', totalCoins: 350, levelsCompleted: 3),
    LeaderboardEntry(rank: 8, userId: 'u8', username: 'BugHunter', totalCoins: 280, levelsCompleted: 2),
    LeaderboardEntry(rank: 9, userId: 'u9', username: 'ForestRanger', totalCoins: 190, levelsCompleted: 2),
    LeaderboardEntry(rank: 10, userId: 'u10', username: 'ReefDiver', totalCoins: 100, levelsCompleted: 1),
  ];

  @override
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 50, int offset = 0}) async {
    final end = (offset + limit).clamp(0, _mockEntries.length);
    if (offset >= _mockEntries.length) return [];
    return _mockEntries.sublist(offset, end);
  }
}
