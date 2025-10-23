import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_memorizer/features/auth/presentation/pages/login_page.dart';
import 'package:quran_memorizer/features/auth/presentation/pages/register_page.dart';
import 'package:quran_memorizer/features/home/presentation/pages/home_page.dart';
import 'package:quran_memorizer/features/learning/presentation/pages/learning_page.dart';
import 'package:quran_memorizer/features/progress/presentation/pages/progress_page.dart';
import 'package:quran_memorizer/features/settings/presentation/pages/settings_page.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String learning = '/learning';
  static const String progress = '/progress';
  static const String settings = '/settings';

  final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      // Authentication routes
      GoRoute(
        path: login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterPage(),
      ),

      // Main app routes
      GoRoute(
        path: home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: learning,
        builder: (context, state) => const LearningPage(),
      ),
      GoRoute(
        path: progress,
        builder: (context, state) => const ProgressPage(),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}
