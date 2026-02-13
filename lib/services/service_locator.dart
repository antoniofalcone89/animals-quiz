import 'package:firebase_auth/firebase_auth.dart';

import '../config/env.dart';
import '../repositories/api/api_leaderboard_repository.dart';
import '../repositories/api/api_quiz_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/firebase/firebase_auth_repository.dart';
import '../repositories/leaderboard_repository.dart';
import '../repositories/mock/mock_auth_repository.dart';
import '../repositories/mock/mock_leaderboard_repository.dart';
import '../repositories/mock/mock_quiz_repository.dart';
import '../repositories/quiz_repository.dart';
import 'api_client.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._();
  static ServiceLocator get instance => _instance;

  late final AuthRepository authRepository;
  late final QuizRepository quizRepository;
  late final LeaderboardRepository leaderboardRepository;

  bool _initialized = false;

  ServiceLocator._();

  void initialize() {
    if (_initialized) return;

    if (Env.isMock) {
      authRepository = MockAuthRepository();
      quizRepository = MockQuizRepository();
      leaderboardRepository = MockLeaderboardRepository();
    } else {
      final client = ApiClient(baseUrl: Env.apiUrl);
      client.setTokenProvider(
        () async => FirebaseAuth.instance.currentUser?.getIdToken(),
      );
      authRepository = FirebaseAuthRepository(client);
      quizRepository = ApiQuizRepository(client);
      leaderboardRepository = ApiLeaderboardRepository(client);
    }

    _initialized = true;
  }

  /// For tests — always uses mock repositories, skips Firebase.
  void initializeForTest() {
    if (_initialized) return;

    authRepository = MockAuthRepository();
    quizRepository = MockQuizRepository();
    leaderboardRepository = MockLeaderboardRepository();

    _initialized = true;
  }
}
