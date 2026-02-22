import '../../data/quiz_data.dart';
import '../../models/answer_result.dart';
import '../../models/buy_hint_result.dart';
import '../../models/game_state.dart';
import '../../models/level.dart';
import '../../models/reveal_letter_result.dart';
import '../../utils/string_similarity.dart';
import '../quiz_repository.dart';

class MockQuizRepository implements QuizRepository {
  final Map<int, List<bool>> _progress = {};
  final Map<int, List<int>> _hints = {};
  final Map<int, List<int>> _letters = {};
  int _coins = 0;

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
  }) async {
    final level = quizLevels.firstWhere((l) => l.id == levelId);
    final animal = level.animals[animalIndex];
    final correct = isFuzzyMatch(answer, animal.name);

    int coinsAwarded = 0;
    if (correct) {
      coinsAwarded = 10;
      _coins += coinsAwarded;
      _progress.putIfAbsent(levelId, () => List.filled(level.animals.length, false));
      _progress[levelId]![animalIndex] = true;
    }

    return AnswerResult(
      correct: correct,
      coinsAwarded: coinsAwarded,
      totalCoins: _coins,
      correctAnswer: animal.name,
    );
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
