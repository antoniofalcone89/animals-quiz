class AnswerResult {
  final bool correct;
  final int coinsAwarded;
  final int totalCoins;
  final int pointsAwarded;
  final String? correctAnswer;
  final int? currentStreak;
  final DateTime? lastActivityDate;
  final int streakBonusCoins;
  final double comboMultiplier;

  const AnswerResult({
    required this.correct,
    required this.coinsAwarded,
    required this.totalCoins,
    this.pointsAwarded = 0,
    this.correctAnswer,
    this.currentStreak,
    this.lastActivityDate,
    this.streakBonusCoins = 0,
    this.comboMultiplier = 1.0,
  });

  factory AnswerResult.fromJson(Map<String, dynamic> json) {
    final lastActivityRaw =
        json['lastActivityDate'] ?? json['last_activity_date'];

    return AnswerResult(
      correct: json['correct'] as bool,
      coinsAwarded: json['coinsAwarded'] as int,
      totalCoins: json['totalCoins'] as int,
      pointsAwarded: json['pointsAwarded'] as int? ?? 0,
      correctAnswer: json['correctAnswer'] as String?,
      currentStreak:
          json['currentStreak'] as int? ?? json['current_streak'] as int?,
      lastActivityDate: lastActivityRaw is String && lastActivityRaw.isNotEmpty
          ? DateTime.tryParse(lastActivityRaw)
          : null,
      streakBonusCoins: (json['streakBonusCoins'] as int?) ?? 0,
      comboMultiplier: (json['comboMultiplier'] as num?)?.toDouble() ?? 1.0,
    );
  }
}
