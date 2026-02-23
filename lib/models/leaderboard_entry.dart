class LeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final int totalPoints;
  final int levelsCompleted;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.totalPoints,
    required this.levelsCompleted,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int,
      userId: json['userId'] as String,
      username: json['username'] as String,
      totalPoints: json['totalPoints'] as int,
      levelsCompleted: json['levelsCompleted'] as int,
    );
  }
}
