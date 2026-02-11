import 'package:flutter/foundation.dart';

class GameState extends ChangeNotifier {
  String _username = 'Guest';
  int _totalCoins = 0;
  final Map<int, List<bool>> _levelProgress = {};

  String get username => _username;
  int get totalCoins => _totalCoins;
  Map<int, List<bool>> get levelProgress => _levelProgress;

  void setUsername(String name) {
    _username = name.isEmpty ? 'Guest' : name;
    notifyListeners();
  }

  void addCoins(int amount) {
    _totalCoins += amount;
    notifyListeners();
  }

  void initLevel(int levelId, int animalCount) {
    if (!_levelProgress.containsKey(levelId)) {
      _levelProgress[levelId] = List.filled(animalCount, false);
    }
  }

  void markAnimalCorrect(int levelId, int animalIndex) {
    if (_levelProgress.containsKey(levelId)) {
      _levelProgress[levelId]![animalIndex] = true;
      notifyListeners();
    }
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
}
