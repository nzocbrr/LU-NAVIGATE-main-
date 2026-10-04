import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lu_navigate/screens/schedule/schedule_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('a fresh schedule starts empty until a form is imported',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ScheduleScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Import your registration form to add classes'),
        findsOneWidget);
    expect(
      find.text('No classes listed in your registration form for this day.'),
      findsOneWidget,
    );
    expect(find.text('Software Engineering 1'), findsNothing);
  });
}
