import '../../data/quiz_data.dart';
import '../../models/answer_result.dart';
import '../../models/buy_hint_result.dart';
import '../../models/game_state.dart';
import '../../models/level.dart';
import '../../models/reveal_letter_result.dart';
import '../../models/user.dart';
import '../../utils/string_similarity.dart';
import '../quiz_repository.dart';

class MockQuizRepository implements QuizRepository {
  final Map<int, List<bool>> _progress = {};
  final Map<int, List<int>> _hints = {};
  final Map<int, List<int>> _letters = {};
  int _coins = 0;
  int _points = 0;
  int _currentStreak = 0;
  DateTime? _lastActivityDate;

  @override
  Future<List<Level>> getLevels() async {
    return quizLevels;
  }

  @override
  Future<Level> getLevelDetail(int levelId) async {
    return quizLevels.firstWhere((l) => l.id == levelId);
  }

  @override
  Future<AnswerResult> submitAnswer({
    required int levelId,
    required int animalIndex,
    required String answer,
    bool adRevealed = false,
  }) async {
    final level = quizLevels.firstWhere((l) => l.id == levelId);
    final animal = level.animals[animalIndex];
    final correct = isFuzzyMatch(answer, animal.name);

    int coinsAwarded = 0;
    int pointsAwarded = 0;
    int streakBonusCoins = 0;
    if (correct) {
      _progress.putIfAbsent(
        levelId,
        () => List.filled(level.animals.length, false),
      );
      _progress[levelId]![animalIndex] = true;
      final hints = _hints[levelId]?[animalIndex] ?? 0;
      final letters = _letters[levelId]?[animalIndex] ?? 0;
      pointsAwarded = GameState.scoring.compute(
        hintsUsed: hints,
        lettersUsed: letters,
        adRevealed: adRevealed,
      );
      _points += pointsAwarded;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final previous = _lastActivityDate;
      final isFirstAnswerToday =
          previous == null ||
          DateTime(previous.year, previous.month, previous.day) != today;

      if (previous == null) {
        _currentStreak = 1;
      } else {
        final prevDay = DateTime(previous.year, previous.month, previous.day);
        final days = today.difference(prevDay).inDays;
        if (days == 0) {
          // Keep streak unchanged: already counted today.
        } else if (days == 1) {
          _currentStreak += 1;
        } else {
          _currentStreak = 1;
        }
      }

      _lastActivityDate = today;

      if (isFirstAnswerToday) {
        streakBonusCoins = (_currentStreak * 2).clamp(0, 20);
      }

      coinsAwarded = 10 + streakBonusCoins;
      _coins += coinsAwarded;
    }

    return AnswerResult(
      correct: correct,
      coinsAwarded: coinsAwarded,
      totalCoins: _coins,
      pointsAwarded: pointsAwarded,
      correctAnswer: animal.name,
      currentStreak: _currentStreak,
      lastActivityDate: _lastActivityDate,
      streakBonusCoins: streakBonusCoins,
    );
  }

  /// Dev-only: simulate that today hasn't been played yet so the next
  /// correct answer triggers the streak bonus.
  @override
  void resetStreakDateForDebug() {
    _lastActivityDate = null;
  }

  @override
  Future<Map<int, List<bool>>> getUserProgress() async {
    return Map.unmodifiable(_progress);
  }

  @override
  Future<Map<int, List<int>>> getHintsProgress() async {
    return Map.unmodifiable(_hints);
  }

  @override
  Future<Map<int, List<int>>> getLettersProgress() async {
    return Map.unmodifiable(_letters);
  }

  @override
  Future<int> getUserCoins() async {
    return _coins;
  }

  @override
  Future<int> getUserPoints() async {
    return _points;
  }

  @override
  Future<User?> getCurrentUserStats() async {
    return User(
      id: 'mock-user',
      username: 'Mock User',
      email: 'mock@example.com',
      totalCoins: _coins,
      totalPoints: _points,
      currentStreak: _currentStreak,
      lastActivityDate: _lastActivityDate,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<BuyHintResult> buyHint({
    required int levelId,
    required int animalIndex,
  }) async {
    final level = quizLevels.firstWhere((l) => l.id == levelId);
    _hints.putIfAbsent(levelId, () => List.filled(level.animals.length, 0));
    final currentHints = _hints[levelId]![animalIndex];

    if (currentHints >= 3) {
      throw Exception('max_hints_reached');
    }

    final cost = GameState.hintCosts[currentHints];
    if (_coins < cost) {
      throw Exception('insufficient_coins');
    }

    _coins -= cost;
    _hints[levelId]![animalIndex] = currentHints + 1;

    return BuyHintResult(
      totalCoins: _coins,
      hintsRevealed: _hints[levelId]![animalIndex],
    );
  }

  @override
  Future<RevealLetterResult> revealLetter({
    required int levelId,
    required int animalIndex,
  }) async {
    final level = quizLevels.firstWhere((l) => l.id == levelId);
    _letters.putIfAbsent(levelId, () => List.filled(level.animals.length, 0));
    final currentLetters = _letters[levelId]![animalIndex];

    if (currentLetters >= GameState.maxLetterReveals) {
      throw Exception('max_letters_reached');
    }

    if (_coins < GameState.letterRevealCost) {
      throw Exception('insufficient_coins');
    }

    _coins -= GameState.letterRevealCost;
    _letters[levelId]![animalIndex] = currentLetters + 1;

    return RevealLetterResult(
      totalCoins: _coins,
      lettersRevealed: _letters[levelId]![animalIndex],
    );
  }
}
