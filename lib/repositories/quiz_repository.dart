import '../models/answer_result.dart';
import '../models/buy_hint_result.dart';
import '../models/level.dart';

abstract class QuizRepository {
  Future<List<Level>> getLevels();

  Future<Level> getLevelDetail(int levelId);

  Future<AnswerResult> submitAnswer({
    required int levelId,
    required int animalIndex,
    required String answer,
  });

  Future<Map<int, List<bool>>> getUserProgress();

  Future<Map<int, List<int>>> getHintsProgress();

  Future<int> getUserCoins();

  Future<BuyHintResult> buyHint({
    required int levelId,
    required int animalIndex,
  });
}
