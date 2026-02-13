import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Web stub — GoogleSignIn is not used on web (we use signInWithPopup).
Future<fb.OAuthCredential?> getNativeGoogleCredential() async {
  throw UnsupportedError('Use signInWithPopup on web');
}

Future<void> nativeGoogleSignOut() async {
  // no-op on web
}
