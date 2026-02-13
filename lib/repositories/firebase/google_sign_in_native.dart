import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

/// Native implementation using the google_sign_in package.
Future<fb.OAuthCredential?> getNativeGoogleCredential() async {
  final googleUser = await GoogleSignIn().signIn();
  if (googleUser == null) return null; // user cancelled
  final googleAuth = await googleUser.authentication;
  return fb.GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
}

Future<void> nativeGoogleSignOut() async {
  await GoogleSignIn().signOut();
}
