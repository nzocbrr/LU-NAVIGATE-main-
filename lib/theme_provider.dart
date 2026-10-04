import 'package:flutter/material.dart';

class ThemeProvider extends ValueNotifier<ThemeMode> {
  ThemeProvider() : super(ThemeMode.light);

  bool get isDark => value == ThemeMode.dark;

  void toggle() {
    value = isDark ? ThemeMode.light : ThemeMode.dark;
  }
}

final themeProvider = ThemeProvider();
