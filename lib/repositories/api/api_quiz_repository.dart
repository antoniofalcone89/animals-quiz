import '../../models/answer_result.dart';
import '../../models/level.dart';
import '../../services/api_client.dart';
import '../quiz_repository.dart';

class ApiQuizRepository implements QuizRepository {
  final ApiClient _client;

  ApiQuizRepository(this._client);

  @override
  Future<List<Level>> getLevels() async {
    final json = await _client.get('/levels');
    final list = json['levels'] as List<dynamic>;
    return list.map((l) => Level.fromJson(l as Map<String, dynamic>)).toList();
  }

  @override
  Future<Level> getLevelDetail(int levelId) async {
    final json = await _client.get('/levels/$levelId');
    return Level.fromJson(json);
  }

  @override
  Future<AnswerResult> submitAnswer({
    required int levelId,
    required int animalIndex,
    required String answer,
  }) async {
    final json = await _client.post('/quiz/answer', body: {
      'levelId': levelId,
      'animalIndex': animalIndex,
      'answer': answer,
    });
    return AnswerResult.fromJson(json);
  }

  @override
  Future<Map<int, List<bool>>> getUserProgress() async {
    final json = await _client.get('/users/me/progress');
    final levels = json['levels'] as Map<String, dynamic>;
    return levels.map((key, value) {
      final animals = value as List<dynamic>;
      final boolList = animals.map((a) {
        if (a is bool) return a;
        return (a as Map<String, dynamic>)['guessed'] as bool;
      }).toList();
      return MapEntry(int.parse(key), boolList);
    });
  }

  @override
  Future<int> getUserCoins() async {
    final json = await _client.get('/users/me/coins');
    return json['totalCoins'] as int;
  }
}
