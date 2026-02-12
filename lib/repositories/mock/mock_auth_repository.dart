import '../../models/auth_result.dart';
import '../../models/user.dart';
import '../auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  User? _currentUser;
  String? _token;

  @override
  Future<AuthResult> login({required String email, required String password}) async {
    _currentUser = User(
      id: 'mock-user-1',
      username: email.split('@').first,
      email: email,
      totalCoins: 0,
      createdAt: DateTime.now(),
    );
    _token = 'mock-token-${DateTime.now().millisecondsSinceEpoch}';
    return AuthResult(user: _currentUser!, token: _token!);
  }

  @override
  Future<AuthResult> loginWithGoogle({required String idToken}) async {
    _currentUser = User(
      id: 'mock-google-user-1',
      username: 'Player',
      email: 'player@gmail.com',
      totalCoins: 0,
      createdAt: DateTime.now(),
    );
    _token = 'mock-google-token-${DateTime.now().millisecondsSinceEpoch}';
    return AuthResult(user: _currentUser!, token: _token!);
  }

  @override
  Future<AuthResult> register({
    required String email,
    required String password,
    required String username,
  }) async {
    _currentUser = User(
      id: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      email: email,
      totalCoins: 0,
      createdAt: DateTime.now(),
    );
    _token = 'mock-token-${DateTime.now().millisecondsSinceEpoch}';
    return AuthResult(user: _currentUser!, token: _token!);
  }

  @override
  Future<User> getCurrentUser() async {
    if (_currentUser == null) throw Exception('Not logged in');
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
  }

  @override
  bool get isLoggedIn => _currentUser != null;

  @override
  String? get currentToken => _token;
}
