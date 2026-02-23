class AnswerResult {
  final bool correct;
  final int coinsAwarded;
  final int totalCoins;
  final int pointsAwarded;
  final String? correctAnswer;

  const AnswerResult({
    required this.correct,
    required this.coinsAwarded,
    required this.totalCoins,
    this.pointsAwarded = 0,
    this.correctAnswer,
  });

  factory AnswerResult.fromJson(Map<String, dynamic> json) {
    return AnswerResult(
      correct: json['correct'] as bool,
      coinsAwarded: json['coinsAwarded'] as int,
      totalCoins: json['totalCoins'] as int,
      pointsAwarded: json['pointsAwarded'] as int? ?? 0,
      correctAnswer: json['correctAnswer'] as String?,
    );
  }
}
