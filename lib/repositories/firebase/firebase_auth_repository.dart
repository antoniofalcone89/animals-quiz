import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../models/user.dart';
import '../../services/api_client.dart';
import '../auth_repository.dart';
import 'google_sign_in_stub.dart'
    if (dart.library.io) 'google_sign_in_native.dart';

class FirebaseAuthRepository implements AuthRepository {
  final ApiClient _client;
  final fb.FirebaseAuth _firebaseAuth;

  FirebaseAuthRepository(this._client)
      : _firebaseAuth = fb.FirebaseAuth.instance;

  @override
  Future<bool> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = fb.GoogleAuthProvider();
        await _firebaseAuth.signInWithPopup(provider);
      } else {
        final credential = await getNativeGoogleCredential();
        if (credential == null) return false; // user cancelled
        await _firebaseAuth.signInWithCredential(credential);
      }
      return true;
    } on fb.FirebaseAuthException {
      rethrow;
    }
  }

  @override
  Future<void> signInAnonymously() async {
    await _firebaseAuth.signInAnonymously();
  }

  @override
  Future<void> signOut() async {
    if (!kIsWeb) {
      await nativeGoogleSignOut();
    }
    await _firebaseAuth.signOut();
  }

  @override
  Future<User> registerProfile(String username) async {
    try {
      final json = await _client.post('/auth/register', body: {
        'username': username,
      });
      return User.fromJson(json);
    } on ApiException catch (e) {
      if (e.code == 'profile_exists') {
        // Profile already exists — fetch and return it
        final existing = await getCurrentUser();
        if (existing != null) return existing;
      }
      rethrow;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    return _client.getOrNull('/auth/me').then(
      (json) => json != null ? User.fromJson(json) : null,
    );
  }

  @override
  Future<String?> getIdToken() async {
    return _firebaseAuth.currentUser?.getIdToken();
  }

  @override
  bool get isSignedIn => _firebaseAuth.currentUser != null;
}
