import '../models/auth_result.dart';
import '../models/user.dart';

abstract class AuthRepository {
  Future<AuthResult> login({required String email, required String password});

  Future<AuthResult> loginWithGoogle({required String idToken});

  Future<AuthResult> register({
    required String email,
    required String password,
    required String username,
  });

  Future<User> getCurrentUser();

  Future<void> logout();

  bool get isLoggedIn;

  String? get currentToken;
}
