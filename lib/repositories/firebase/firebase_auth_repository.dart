import 'dart:developer' as dev;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/user.dart' as app;
import '../../services/api_client.dart';
import '../auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn? _googleSignIn;
  final ApiClient _apiClient;

  FirebaseAuthRepository({
    required ApiClient apiClient,
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _apiClient = apiClient,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = kIsWeb ? null : (googleSignIn ?? GoogleSignIn());

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<bool> signInWithGoogle() async {
    if (kIsWeb) {
      return _signInWithGoogleWeb();
    }
    return _signInWithGoogleNative();
  }

  Future<bool> _signInWithGoogleWeb() async {
    dev.log('[FirebaseAuth] signInWithPopup starting...');
    final provider = GoogleAuthProvider();
    final result = await _firebaseAuth.signInWithPopup(provider);
    final user = result.user;
    dev.log('[FirebaseAuth] signInWithPopup complete — uid: ${user?.uid}, email: ${user?.email}, displayName: ${user?.displayName}');
    return true;
  }

  Future<bool> _signInWithGoogleNative() async {
    final googleUser = await _googleSignIn!.signIn();
    if (googleUser == null) return false; // user cancelled

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _firebaseAuth.signInWithCredential(credential);
    return true;
  }

  @override
  Future<void> signInAnonymously() async {
    await _firebaseAuth.signInAnonymously();
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn?.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<app.User> registerProfile({required String username}) async {
    final json = await _apiClient.post('/auth/register', body: {
      'username': username,
    });
    return app.User.fromJson(json);
  }

  @override
  Future<app.User?> getCurrentUser() async {
    try {
      final json = await _apiClient.get('/auth/me');
      return app.User.fromJson(json);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<String?> getIdToken() async {
    return _firebaseAuth.currentUser?.getIdToken();
  }

  @override
  bool get isSignedIn => _firebaseAuth.currentUser != null;
}
