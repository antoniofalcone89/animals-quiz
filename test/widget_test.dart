import 'package:flutter_test/flutter_test.dart';
import 'package:animal_quiz_academy/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AnimalQuizApp());
    expect(find.text('Animal Quiz Academy'), findsNothing);
  });
}
