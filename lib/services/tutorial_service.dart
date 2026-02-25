import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  static const _key = 'tutorial_quiz_seen';

  static Future<bool> hasSeenTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> markTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  /// Temporary: reset the tutorial flag for testing.
  static Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
