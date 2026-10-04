import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lu_navigate/auth_provider.dart';
import 'package:lu_navigate/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('registration opens the app and profile uses account details',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    authProvider.logout();
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(authProvider.logout);

    await tester.pumpWidget(const LuNavigateApp());
    expect(find.text('LU-Nav'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to LU-Nav'), findsOneWidget);

    await tester.tap(find.text('Register').last);
    await tester.pumpAndSettle();
    expect(find.text('Create your account'), findsOneWidget);

    const values = [
      'Taylor Student',
      '123-4567',
      'taylor@example.edu',
      'campus123',
    ];
    for (var index = 0; index < values.length; index++) {
      final field = find.byType(TextFormField).at(index);
      await tester.ensureVisible(field);
      await tester.enterText(field, values[index]);
    }

    final courseDropdown = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(courseDropdown);
    await tester.tap(courseDropdown);
    await tester.pumpAndSettle();
    const selectedCourse =
        'Bachelor of Science in Mechanical Engineering (BSME)';
    await tester.tap(find.text(selectedCourse).last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Register'));
    await tester.tap(find.widgetWithText(FilledButton, 'Register'));
    await tester.pumpAndSettle();
    expect(find.text('Map'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Taylor Student'), findsOneWidget);
    expect(find.text('123-4567'), findsOneWidget);
    expect(find.text(selectedCourse), findsNWidgets(2));

    final logoutButton = find.widgetWithText(OutlinedButton, 'Log Out');
    await tester.ensureVisible(logoutButton);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Log Out'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to LU-Nav'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '123-4567');
    await tester.enterText(find.byType(TextFormField).at(1), 'campus123');
    await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
    await tester.pumpAndSettle();
    expect(find.text('Map'), findsOneWidget);
  });
}
