class User {
  final String id;
  final String username;
  final String email;
  final int totalCoins;
  final int totalPoints;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.totalCoins,
    required this.totalPoints,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      totalCoins: json['totalCoins'] as int,
      totalPoints: json['totalPoints'] as int? ?? 0,
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
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
