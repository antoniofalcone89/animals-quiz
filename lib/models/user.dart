class User {
  final String id;
  final String username;
  final String email;
  final int totalCoins;
  final int totalPoints;
  final int currentStreak;
  final DateTime? lastActivityDate;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.totalCoins,
    required this.totalPoints,
    this.currentStreak = 0,
    this.lastActivityDate,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final lastActivityRaw =
        json['lastActivityDate'] ?? json['last_activity_date'];

    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      totalCoins: json['totalCoins'] as int,
      totalPoints: json['totalPoints'] as int? ?? json['score'] as int? ?? 0,
      currentStreak:
          json['currentStreak'] as int? ?? json['current_streak'] as int? ?? 0,
      lastActivityDate: lastActivityRaw is String && lastActivityRaw.isNotEmpty
          ? DateTime.tryParse(lastActivityRaw)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'totalCoins': totalCoins,
      'totalPoints': totalPoints,
      'currentStreak': currentStreak,
      'lastActivityDate': lastActivityDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
