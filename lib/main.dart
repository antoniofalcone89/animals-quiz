import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      supportedLocales: localization?.supportedLocales ?? const [Locale('it'), Locale('en')],
      locale: localization?.locale,
      home: const SplashScreen(),
    );
  }
}
