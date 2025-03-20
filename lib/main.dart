import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:lipht/core/services/auth_service.dart';
import 'package:lipht/providers/auth_provider.dart';
import 'package:lipht/providers/app_state_provider.dart';
import 'package:lipht/routes/router.dart';
import 'package:lipht/features/auth/screens/login_screen.dart';
import 'package:lipht/features/home/screens/home_screen.dart';
import 'package:lipht/presentation/screens/main_layout.dart';
import 'package:lipht/presentation/widgets/no_transitions_builder.dart';
import 'package:lipht/features/fuel/screens/fuel_screen.dart';

// Global navigator key for app-wide navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(
          create: (context) {
            final provider = AuthProvider(AuthService());
            // Initialize the auth state listener right when provider is created
            provider.initAuthStateListener();
            return provider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Set the navigator key
      title: 'LIPHT Fitness',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: NoTransitionsBuilder(),
            TargetPlatform.iOS: NoTransitionsBuilder(),
          },
        ),
      ),
      // Use home with consumer pattern to react to auth changes
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // This will rebuild when auth state changes
          print("Auth state in MyApp: ${authProvider.isAuthenticated}");
          return AuthStateRedirector();
        },
      ),
      onGenerateRoute: AppRouter.generateRoute,
      // Don't set initialRoute when using home
    );
  }
}

// Auth state redirector component
class AuthStateRedirector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    debugPrint("Auth state in redirector: ${authProvider.isAuthenticated}");

    // Instead of using microtask, directly return the appropriate screen
    if (authProvider.isAuthenticated) {
      return MainLayout();
    } else {
      return LoginScreen();
    }
  }
}
