import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_quiz_academy/main.dart';
import 'package:animal_quiz_academy/services/service_locator.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    dotenv.testLoad(fileInput: 'USE_MOCK=true\nAPI_BASE_URL=https://api.example.com/api/v1');
    ServiceLocator.instance.initialize();

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
