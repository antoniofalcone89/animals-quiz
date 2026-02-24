import 'package:flutter/foundation.dart';

import 'answer_result.dart';
import 'buy_hint_result.dart';
import 'level.dart';
import 'reveal_letter_result.dart';
import '../config/env.dart';
import '../repositories/quiz_repository.dart';

class ScoringConfig {
  /// Points awarded when the answer is correct with no hints or letter reveals.
  final int pointsNoHints;

  /// Points for 1 hint or 1 letter revealed.
  final int pointsOneAssist;

  /// Points for 2 assists (hints + letters combined).
  final int pointsTwoAssists;

  /// Points for 3+ assists.
  final int pointsManyAssists;

  /// Points when the answer was revealed via ad.
  final int pointsAdRevealed;

  const ScoringConfig({
    this.pointsNoHints = 20,
    this.pointsOneAssist = 15,
    this.pointsTwoAssists = 10,
    this.pointsManyAssists = 5,
    this.pointsAdRevealed = 3,
  });

  int compute({
    required int hintsUsed,
    required int lettersUsed,
    required bool adRevealed,
  }) {
    if (adRevealed) return pointsAdRevealed;
    final total = hintsUsed + lettersUsed;
    if (total == 0) return pointsNoHints;
    if (total == 1) return pointsOneAssist;
    if (total == 2) return pointsTwoAssists;
    return pointsManyAssists;
  }
}

class GameState extends ChangeNotifier {
  static const List<int> hintCosts = [5, 10, 20];
  static const int letterRevealCost = 30;
  static const int maxLetterReveals = 3;
  static const ScoringConfig scoring = ScoringConfig();

  final QuizRepository _quizRepository;

  String _username = 'Guest';
  int _totalCoins = 0;
  int _totalPoints = 0;
  final Map<int, List<bool>> _levelProgress = {};
  final Map<int, List<int>> _hintsProgress = {};
  final Map<int, List<int>> _lettersProgress = {};
  List<Level> _levels = [];
  bool _isLoading = false;
  bool _isStatsLoading = true;
  String? _error;

  GameState({required QuizRepository quizRepository})
    : _quizRepository = quizRepository;

  String get username => _username;
  int get totalCoins => _totalCoins;
  int get totalPoints => _totalPoints;
  Map<int, List<bool>> get levelProgress => _levelProgress;
  Map<int, List<int>> get hintsProgress => _hintsProgress;
  List<Level> get levels => _levels;
  bool get isLoading => _isLoading;
  bool get isStatsLoading => _isStatsLoading;
  String? get error => _error;

  void setUsername(String name) {
    _username = name.isEmpty ? 'Guest' : name;
    notifyListeners();
  }

  void setTotalCoins(int coins) {
    _totalCoins = coins;
    notifyListeners();
  }

  void setTotalPoints(int points) {
    _totalPoints = points;
    notifyListeners();
  }

  void setInitialStats({required int coins, required int points}) {
    _totalCoins = coins;
    _totalPoints = points;
    _isStatsLoading = false;
    notifyListeners();
  }

  void initLevel(int levelId, int animalCount) {
    if (!_levelProgress.containsKey(levelId)) {
      _levelProgress[levelId] = List.filled(animalCount, false);
    }
    if (!_hintsProgress.containsKey(levelId)) {
      _hintsProgress[levelId] = List.filled(animalCount, 0);
    }
    if (!_lettersProgress.containsKey(levelId)) {
      _lettersProgress[levelId] = List.filled(animalCount, 0);
    }
  }

  Future<void> loadLevels() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _levels = await _quizRepository.getLevels();
      for (final level in _levels) {
        initLevel(level.id, level.animals.length);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadProgress() async {
    _isStatsLoading = true;
    notifyListeners();
    try {
      final progress = await _quizRepository.getUserProgress();
      _levelProgress.addAll(progress);
      final hints = await _quizRepository.getHintsProgress();
      _hintsProgress.addAll(hints);
      final letters = await _quizRepository.getLettersProgress();
      _lettersProgress.addAll(letters);
      _totalCoins = await _quizRepository.getUserCoins();
      _totalPoints = await _quizRepository.getUserPoints();
      _isStatsLoading = false;
      notifyListeners();
    } catch (e) {
      _isStatsLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<AnswerResult> submitAnswer(
    int levelId,
    int animalIndex,
    String answer, {
    bool adRevealed = false,
  }) async {
    final result = await _quizRepository.submitAnswer(
      levelId: levelId,
      animalIndex: animalIndex,
      answer: answer,
      adRevealed: adRevealed,
    );

    if (result.correct) {
      _totalCoins = result.totalCoins;
      _totalPoints += result.pointsAwarded;
      if (_levelProgress.containsKey(levelId)) {
        _levelProgress[levelId]![animalIndex] = true;
      }
      notifyListeners();
    }

    return result;
  }

  Future<BuyHintResult?> buyHint(int levelId, int animalIndex) async {
    final currentHints = getHintsRevealed(levelId, animalIndex);
    if (currentHints >= hintCosts.length) return null;
    if (_totalCoins < hintCosts[currentHints]) return null;

    try {
      final result = await _quizRepository.buyHint(
        levelId: levelId,
        animalIndex: animalIndex,
      );
      _totalCoins = result.totalCoins;
      _hintsProgress.putIfAbsent(
        levelId,
        () => List.filled(
          levels.firstWhere((l) => l.id == levelId).animals.length,
          0,
        ),
      );
      _hintsProgress[levelId]![animalIndex] = result.hintsRevealed;
      notifyListeners();
      return result;
    } catch (e) {
      return null;
    }
  }

  Future<RevealLetterResult?> buyLetterReveal(
    int levelId,
    int animalIndex,
  ) async {
    final currentLetters = getLettersRevealed(levelId, animalIndex);
    if (currentLetters >= maxLetterReveals) return null;
    if (_totalCoins < letterRevealCost) return null;

    try {
      final result = await _quizRepository.revealLetter(
        levelId: levelId,
        animalIndex: animalIndex,
      );
      _totalCoins = result.totalCoins;
      _lettersProgress.putIfAbsent(
        levelId,
        () => List.filled(
          levels.firstWhere((l) => l.id == levelId).animals.length,
          0,
        ),
      );
      _lettersProgress[levelId]![animalIndex] = result.lettersRevealed;
      notifyListeners();
      return result;
    } catch (e) {
      return null;
    }
  }

  int getLettersRevealed(int levelId, int animalIndex) {
    return _lettersProgress[levelId]?[animalIndex] ?? 0;
  }

  /// Returns deterministic letter positions to reveal based on count.
  /// Positions are evenly distributed: 1st→middle, 2nd→1/3, 3rd→2/3.
  List<int> getRevealedPositions(
    int levelId,
    int animalIndex,
    String animalName,
  ) {
    final count = getLettersRevealed(levelId, animalIndex);
    if (count <= 0) return [];

    final letters = animalName.replaceAll(' ', '');
    final len = letters.length;
    if (len == 0) return [];

    // Compute positions in letter-only space (excluding spaces)
    final positions = <int>[];
    if (count >= 1) positions.add(len ~/ 2); // middle
    if (count >= 2) positions.add(len ~/ 3); // 1/3
    if (count >= 3) positions.add((len * 2) ~/ 3); // 2/3

    // Convert letter-only indices to full-name indices (accounting for spaces)
    final result = <int>[];
    for (final letterIdx in positions) {
      int letterCount = 0;
      for (int i = 0; i < animalName.length; i++) {
        if (animalName[i] != ' ') {
          if (letterCount == letterIdx) {
            result.add(i);
            break;
          }
          letterCount++;
        }
      }
    }

    return result;
  }

  int getHintsRevealed(int levelId, int animalIndex) {
    return _hintsProgress[levelId]?[animalIndex] ?? 0;
  }

  bool isAnimalGuessed(int levelId, int animalIndex) {
    return _levelProgress[levelId]?[animalIndex] ?? false;
  }

  double getLevelProgress(int levelId) {
    final progress = _levelProgress[levelId];
    if (progress == null || progress.isEmpty) return 0.0;
    return progress.where((g) => g).length / progress.length;
  }

  int getLevelCorrectCount(int levelId) {
    final progress = _levelProgress[levelId];
    if (progress == null) return 0;
    return progress.where((g) => g).length;
  }

  bool isLevelUnlocked(int levelId) {
    // Debug mode: unlock all levels
    if (Env.debugUnlockAll) return true;

    if (levelId <= 1) return true;
    return getLevelProgress(levelId - 1) >= 0.8;
  }
}
