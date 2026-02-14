import '../models/user.dart';

abstract class AuthRepository {
  /// Sign in with Google. Returns false if the user cancelled.
  Future<bool> signInWithGoogle();

  /// Sign in anonymously (guest).
  Future<void> signInAnonymously();

  /// Sign out of Firebase and clear local state.
  Future<void> signOut();

  /// Register a profile on the backend. Returns the created User.
  Future<User> registerProfile(String username);

  /// Get the current user's profile from the backend, or null if not registered.
  Future<User?> getCurrentUser();

  /// Get a fresh Firebase ID token (or mock token).
  Future<String?> getIdToken();

  /// Whether the user is currently signed in.
  bool get isSignedIn;

  /// Display name from the auth provider (e.g. Google account name).
  String? get displayName;
}
