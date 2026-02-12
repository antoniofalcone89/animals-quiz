import '../../models/auth_result.dart';
import '../../models/user.dart';
import '../../services/api_client.dart';
import '../auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  final ApiClient _client;
  User? _currentUser;
  String? _token;

  ApiAuthRepository(this._client);

  @override
  Future<AuthResult> login({required String email, required String password}) async {
    final json = await _client.post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    final result = AuthResult.fromJson(json);
    _currentUser = result.user;
    _token = result.token;
    _client.setToken(_token);
    return result;
  }

  @override
  Future<AuthResult> loginWithGoogle({required String idToken}) async {
    final json = await _client.post('/auth/google', body: {
      'idToken': idToken,
    });
    final result = AuthResult.fromJson(json);
    _currentUser = result.user;
    _token = result.token;
    _client.setToken(_token);
    return result;
  }

  @override
  Future<AuthResult> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final json = await _client.post('/auth/register', body: {
      'email': email,
      'password': password,
      'username': username,
    });
    final result = AuthResult.fromJson(json);
    _currentUser = result.user;
    _token = result.token;
    _client.setToken(_token);
    return result;
  }

  @override
  Future<User> getCurrentUser() async {
    final json = await _client.get('/auth/me');
    _currentUser = User.fromJson(json);
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _client.setToken(null);
  }

  @override
  bool get isLoggedIn => _token != null;

  @override
  String? get currentToken => _token;
}
