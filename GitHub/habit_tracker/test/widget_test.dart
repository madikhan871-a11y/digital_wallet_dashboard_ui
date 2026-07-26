import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';



void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp() as Widget);
    expect(find.text('Habit Tracker'), findsOneWidget);
  });
}

class MyApp {
  const MyApp();
}