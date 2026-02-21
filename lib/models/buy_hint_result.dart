class BuyHintResult {
  final int totalCoins;
  final int hintsRevealed;

  const BuyHintResult({
    required this.totalCoins,
    required this.hintsRevealed,
  });

  factory BuyHintResult.fromJson(Map<String, dynamic> json) {
    return BuyHintResult(
      totalCoins: json['totalCoins'] as int,
      hintsRevealed: json['hintsRevealed'] as int,
    );
  }
}
