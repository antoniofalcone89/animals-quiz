import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'config/env.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/service_locator.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Env.isMock) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (e) {
      // On iOS, Firebase auto-initializes via GoogleService-Info.plist before
      // Dart starts, so a duplicate-app error here is expected and safe to ignore.
      if (e.code != 'duplicate-app') {
        debugPrint('Firebase init error: $e');
      }
    } catch (e) {
      debugPrint('Firebase init error: $e');
    }
    if (kIsWeb) {
      try {
        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
      } catch (e) {
        debugPrint('Firebase persistence error: $e');
      }
    }
  }

  ServiceLocator.instance.initialize();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('it'), Locale('en')],
      path: 'translations',
      fallbackLocale: const Locale('it'),
      startLocale: const Locale('it'),
      saveLocale: false,
      child: const AnimalQuizApp(),
    ),
  );
}

class AnimalQuizApp extends StatelessWidget {
  const AnimalQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = EasyLocalization.of(context);
    return MaterialApp(
      title: 'Animal Quiz Academy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      localizationsDelegates: localization?.delegates,
      supportedLocales:
          localization?.supportedLocales ?? const [Locale('it'), Locale('en')],
      locale: localization?.locale,
      home: const SplashScreen(),
    );
  }
}
