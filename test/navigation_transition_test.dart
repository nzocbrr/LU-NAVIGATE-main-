import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lu_navigate/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('tab changes animate between screens', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const MaterialApp(home: MainNavigationShell()),
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<AnimatedOpacity>(find.byKey(const ValueKey('tab-opacity-0')))
          .opacity,
      1,
    );

    await tester.tap(find.text('Schedule'));
    await tester.pump();

    expect(
      tester
          .widget<AnimatedOpacity>(find.byKey(const ValueKey('tab-opacity-0')))
          .opacity,
      lessThan(1),
    );
    expect(
      tester
          .widget<AnimatedOpacity>(find.byKey(const ValueKey('tab-opacity-1')))
          .opacity,
      greaterThan(0),
    );

    await tester.pumpAndSettle();
    expect(
      tester
          .widget<AnimatedOpacity>(find.byKey(const ValueKey('tab-opacity-1')))
          .opacity,
      1,
    );
  });
}
