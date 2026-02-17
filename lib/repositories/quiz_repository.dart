import '../models/answer_result.dart';
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

  Future<int> getUserCoins();

  Future<int> spendCoins(int amount);
}
