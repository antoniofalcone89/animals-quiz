import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../repositories/api/api_auth_repository.dart';
import '../repositories/api/api_leaderboard_repository.dart';
import '../repositories/api/api_quiz_repository.dart';
import '../repositories/auth_repository.dart';
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

    final useMock = dotenv.env['USE_MOCK']?.toLowerCase() == 'true';

    if (useMock) {
      authRepository = MockAuthRepository();
      quizRepository = MockQuizRepository();
      leaderboardRepository = MockLeaderboardRepository();
    } else {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.example.com/api/v1';
      final client = ApiClient(baseUrl: baseUrl);
      authRepository = ApiAuthRepository(client);
      quizRepository = ApiQuizRepository(client);
      leaderboardRepository = ApiLeaderboardRepository(client);
    }

    _initialized = true;
  }
}
