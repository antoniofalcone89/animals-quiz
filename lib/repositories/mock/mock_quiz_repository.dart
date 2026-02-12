import 'package:easy_localization/easy_localization.dart';

import '../../data/quiz_data.dart';
import '../../models/answer_result.dart';
import '../../models/level.dart';
import '../quiz_repository.dart';

class MockQuizRepository implements QuizRepository {
  final Map<int, List<bool>> _progress = {};
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
    final correctName = animal.translationKey.tr().toLowerCase();
    final correct = answer.trim().toLowerCase() == correctName;

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
      correctAnswer: correct ? null : animal.translationKey.tr(),
    );
  }

  @override
  Future<Map<int, List<bool>>> getUserProgress() async {
    return Map.unmodifiable(_progress);
  }

  @override
  Future<int> getUserCoins() async {
    return _coins;
  }
}
