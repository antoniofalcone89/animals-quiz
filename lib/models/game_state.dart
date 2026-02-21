import 'package:flutter/foundation.dart';

import 'answer_result.dart';
import 'buy_hint_result.dart';
import 'level.dart';
import '../config/env.dart';
import '../repositories/quiz_repository.dart';

class GameState extends ChangeNotifier {
  static const List<int> hintCosts = [5, 10, 20];

  final QuizRepository _quizRepository;

  String _username = 'Guest';
  int _totalCoins = 0;
  final Map<int, List<bool>> _levelProgress = {};
  final Map<int, List<int>> _hintsProgress = {};
  List<Level> _levels = [];
  bool _isLoading = false;
  String? _error;

  GameState({required QuizRepository quizRepository})
    : _quizRepository = quizRepository;

  String get username => _username;
  int get totalCoins => _totalCoins;
  Map<int, List<bool>> get levelProgress => _levelProgress;
  Map<int, List<int>> get hintsProgress => _hintsProgress;
  List<Level> get levels => _levels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setUsername(String name) {
    _username = name.isEmpty ? 'Guest' : name;
    notifyListeners();
  }

  void initLevel(int levelId, int animalCount) {
    if (!_levelProgress.containsKey(levelId)) {
      _levelProgress[levelId] = List.filled(animalCount, false);
    }
    if (!_hintsProgress.containsKey(levelId)) {
      _hintsProgress[levelId] = List.filled(animalCount, 0);
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
    try {
      final progress = await _quizRepository.getUserProgress();
      _levelProgress.addAll(progress);
      final hints = await _quizRepository.getHintsProgress();
      _hintsProgress.addAll(hints);
      _totalCoins = await _quizRepository.getUserCoins();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<AnswerResult> submitAnswer(
    int levelId,
    int animalIndex,
    String answer,
  ) async {
    final result = await _quizRepository.submitAnswer(
      levelId: levelId,
      animalIndex: animalIndex,
      answer: answer,
    );

    if (result.correct) {
      _totalCoins = result.totalCoins;
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
