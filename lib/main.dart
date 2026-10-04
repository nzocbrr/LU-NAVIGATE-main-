import 'package:flutter/material.dart';
import 'dart:async';

import 'app_colors.dart';
import 'auth_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/announcements/announcements_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/schedule/schedule_screen.dart';
import 'theme_provider.dart';
import 'widgets/floating_bottom_navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LuNavigateApp());
}

class LuNavigateApp extends StatelessWidget {
  const LuNavigateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeProvider,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'LU Navigate',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryGreen,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: AppColors.background,
            cardColor: Colors.white,
            fontFamily: 'Roboto',
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryGreen,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: AppColors.darkBackground,
            cardColor: AppColors.cardDark,
            fontFamily: 'Roboto',
          ),
          home: const AppStartupGate(),
        );
      },
    );
  }
}

class AppStartupGate extends StatefulWidget {
  const AppStartupGate({super.key});

  @override
  State<AppStartupGate> createState() => _AppStartupGateState();
}

class _AppStartupGateState extends State<AppStartupGate> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) return const _SplashScreen();
    return ValueListenableBuilder<AppUser?>(
      valueListenable: authProvider,
      builder: (context, user, _) =>
          user == null ? const AuthScreen() : const MainNavigationShell(),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: AppColors.primaryGreen,
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'LU-Nav',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'LAGUNA UNIVERSITY',
              style: TextStyle(
                color: AppColors.lightGreen,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  static const _tabTransitionDuration = Duration(milliseconds: 240);
  int _currentIndex = 0;

  final _screens = const <Widget>[
    MapScreen(),
    ScheduleScreen(),
    AnnouncementsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + 16;
    return Scaffold(
      body: Stack(
        children: [
          for (var index = 0; index < _screens.length; index++)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: index != _currentIndex,
                child: ExcludeSemantics(
                  excluding: index != _currentIndex,
                  child: AnimatedOpacity(
                    key: ValueKey('tab-opacity-$index'),
                    opacity: index == _currentIndex ? 1 : 0,
                    duration: _tabTransitionDuration,
                    curve: Curves.easeInOut,
                    child: AnimatedSlide(
                      offset: index == _currentIndex
                          ? Offset.zero
                          : Offset(index < _currentIndex ? -0.035 : 0.035, 0),
                      duration: _tabTransitionDuration,
                      curve: Curves.easeInOutCubic,
                      child: _screens[index],
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 20,
            right: 20,
            bottom: bottom,
            child: FloatingBottomNavigation(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ),
        ],
      ),
    );
  }
}
