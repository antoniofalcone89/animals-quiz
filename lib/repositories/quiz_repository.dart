import '../models/answer_result.dart';
import '../models/buy_hint_result.dart';
import '../models/level.dart';
import '../models/reveal_letter_result.dart';

abstract class QuizRepository {
  Future<List<Level>> getLevels();

  Future<Level> getLevelDetail(int levelId);

  Future<AnswerResult> submitAnswer({
    required int levelId,
    required int animalIndex,
    required String answer,
    bool adRevealed = false,
  });

  Future<Map<int, List<bool>>> getUserProgress();

  Future<Map<int, List<int>>> getHintsProgress();

  Future<Map<int, List<int>>> getLettersProgress();

  Future<int> getUserCoins();

  Future<int> getUserPoints();

  Future<BuyHintResult> buyHint({
    required int levelId,
    required int animalIndex,
  });

  Future<RevealLetterResult> revealLetter({
    required int levelId,
    required int animalIndex,
  });
}
