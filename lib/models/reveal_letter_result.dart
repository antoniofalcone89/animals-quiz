class RevealLetterResult {
  final int totalCoins;
  final int lettersRevealed;

  const RevealLetterResult({
    required this.totalCoins,
    required this.lettersRevealed,
  });

  factory RevealLetterResult.fromJson(Map<String, dynamic> json) {
    return RevealLetterResult(
      totalCoins: json['totalCoins'] as int,
      lettersRevealed: json['lettersRevealed'] as int,
    );
  }
}
