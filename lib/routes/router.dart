import 'package:flutter/material.dart';
import 'package:lipht/features/auth/screens/login_screen.dart';
import 'package:lipht/features/auth/screens/signup_screen.dart';
import 'package:lipht/presentation/screens/main_layout.dart';
import 'package:lipht/features/settings/screens/settings_screen.dart';
import 'package:lipht/features/build/screens/build_program_screen.dart';
import 'package:lipht/routes/routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract arguments if passed
    final args = settings.arguments;

    switch (settings.name) {
      // Authentication routes
      case Routes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case Routes.register:
        return MaterialPageRoute(builder: (_) => SignupScreen());

      // Main app container - this holds the tab navigation
      case Routes.main:
        return MaterialPageRoute(builder: (_) => MainLayout());

      // Settings route (accessible from all tabs)
      case Routes.settings:
        return MaterialPageRoute(builder: (_) => SettingsScreen());

      // These routes are not directly navigated to - they're handled by the tab controller
      // Instead they'll just go to MainLayout which manages the tabs
      case Routes.home:
        return MaterialPageRoute(
            builder: (_) => const MainLayout(currentIndex: 0));
      case Routes.build:
        return MaterialPageRoute(
            builder: (_) => const MainLayout(currentIndex: 1));
      case Routes.fuel:
        return MaterialPageRoute(
            builder: (_) => const MainLayout(currentIndex: 2));
      case Routes.sleep:
        return MaterialPageRoute(
            builder: (_) => const MainLayout(currentIndex: 3));
      case Routes.friends:
        return MaterialPageRoute(
            builder: (_) => const MainLayout(currentIndex: 4));

      /// Tab-specific detail screens
      case Routes.buildProgram:
        return MaterialPageRoute(
          builder: (_) => MainLayout(
            currentIndex: 1,
            child: BuildProgramScreen(),
          ),
        );
      default:
        return _errorRoute('No route defined for ${settings.name}');
    }
  }

  // Helper for error routes
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text('Navigation Error')),
        body: Center(child: Text(message)),
      ),
    );
  }
}
