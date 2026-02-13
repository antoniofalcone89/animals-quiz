import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDHwWyb8zEX27S8oCTzzfg9Yhuq0GGQX6k",
    authDomain: "animals-game-de9c0.firebaseapp.com",
    projectId: "animals-game-de9c0",
    storageBucket: "animals-game-de9c0.firebasestorage.app",
    messagingSenderId: "123269083042",
    appId: "1:123269083042:web:1bdd6b9ff9e771613f4cfb",
    measurementId: "G-67TZ2QPLB7",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDuctcqxTKnmXsRDTReadJW5LjF56TkfB4",
    appId: "1:123269083042:android:c7a3354da7f6ae633f4cfb",
    messagingSenderId: "123269083042",
    projectId: "animals-game-de9c0",
    storageBucket: "animals-game-de9c0.appspot.com",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyAqMRB5ObKbUnfBVPXx7Ees6LOR9w75cz8",
    appId: "1:123269083042:ios:81284e4dc4f560693f4cfb",
    messagingSenderId: "123269083042",
    projectId: "animals-game-de9c0",
    storageBucket: "animals-game-de9c0.appspot.com",
    iosBundleId: "com.animalquiz.animalQuizAcademy",
  );
}
