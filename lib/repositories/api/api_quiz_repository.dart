import '../../models/answer_result.dart';
import '../../models/buy_hint_result.dart';
import '../../models/level.dart';
import '../../models/reveal_letter_result.dart';
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
    bool adRevealed = false,
  }) async {
    final json = await _client.post(
      '/quiz/answer',
      body: {
        'levelId': levelId,
        'animalIndex': animalIndex,
        'answer': answer,
        if (adRevealed) 'adRevealed': true,
      },
    );
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
  Future<Map<int, List<int>>> getHintsProgress() async {
    final json = await _client.get('/users/me/progress');
    final levels = json['levels'] as Map<String, dynamic>;
    return levels.map((key, value) {
      final animals = value as List<dynamic>;
      final hintsList = animals.map((a) {
        if (a is bool) return 0;
        return (a as Map<String, dynamic>)['hintsRevealed'] as int? ?? 0;
      }).toList();
      return MapEntry(int.parse(key), hintsList);
    });
  }

  @override
  Future<int> getUserCoins() async {
    final json = await _client.get('/users/me/coins');
    return json['totalCoins'] as int;
  }

  @override
  Future<int> getUserPoints() async {
    final json = await _client.get('/auth/me');
    return json['totalPoints'] as int? ?? json['score'] as int? ?? 0;
  }

  @override
  Future<BuyHintResult> buyHint({
    required int levelId,
    required int animalIndex,
  }) async {
    final json = await _client.post(
      '/quiz/buy-hint',
      body: {'levelId': levelId, 'animalIndex': animalIndex},
    );
    return BuyHintResult.fromJson(json);
  }

  @override
  Future<Map<int, List<int>>> getLettersProgress() async {
    final json = await _client.get('/users/me/progress');
    final levels = json['levels'] as Map<String, dynamic>;
    return levels.map((key, value) {
      final animals = value as List<dynamic>;
      final lettersList = animals.map((a) {
        if (a is bool) return 0;
        return (a as Map<String, dynamic>)['lettersRevealed'] as int? ?? 0;
      }).toList();
      return MapEntry(int.parse(key), lettersList);
    });
  }

  @override
  Future<RevealLetterResult> revealLetter({
    required int levelId,
    required int animalIndex,
  }) async {
    final json = await _client.post(
      '/quiz/reveal-letter',
      body: {'levelId': levelId, 'animalIndex': animalIndex},
    );
    return RevealLetterResult.fromJson(json);
  }
}
