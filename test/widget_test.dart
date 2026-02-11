import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_quiz_academy/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('it'), Locale('en')],
        path: 'translations',
        fallbackLocale: const Locale('it'),
        startLocale: const Locale('it'),
        saveLocale: false,
        child: const AnimalQuizApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Animal Quiz Academy'), findsNothing);
  });
}
