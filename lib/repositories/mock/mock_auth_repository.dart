import '../../models/user.dart';
import '../auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  bool _signedIn = false;
  bool _isAnonymous = false;
  User? _currentUser;

  @override
  Future<bool> signInWithGoogle() async {
    _signedIn = true;
    return true;
  }

  @override
  Future<void> signInAnonymously() async {
    _signedIn = true;
    _isAnonymous = true;
  }

  @override
  Future<void> signOut() async {
    _signedIn = false;
    _currentUser = null;
  }

  @override
  Future<User> registerProfile(String username) async {
    _currentUser = User(
      id: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      email: 'mock@example.com',
      totalCoins: 0,
      totalPoints: 0,
      currentStreak: 0,
      lastActivityDate: null,
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  @override
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<String?> getIdToken() async {
    return _signedIn ? 'mock-token' : null;
  }

  @override
  bool get isSignedIn => _signedIn;

  @override
  String? get displayName => _signedIn ? 'Mock User' : null;

  @override
  String? get photoUrl => null;

  @override
  bool get isAnonymous => _isAnonymous;

  @override
  Future<bool> linkWithGoogle() async {
    if (!_isAnonymous) return false;
    _isAnonymous = false;
    return true;
  }

  @override
  Future<void> linkWithEmailPassword(String email, String password) async {
    if (!_isAnonymous) return;
    _isAnonymous = false;
  }
}
