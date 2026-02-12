class LeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final int totalCoins;
  final int levelsCompleted;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.totalCoins,
    required this.levelsCompleted,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int,
      userId: json['userId'] as String,
      username: json['username'] as String,
      totalCoins: json['totalCoins'] as int,
      levelsCompleted: json['levelsCompleted'] as int,
    );
  }
}
