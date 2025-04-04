import 'package:flutter/foundation.dart';
import 'package:lipht/core/services/auth_service.dart';
import 'package:lipht/data/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lipht/main.dart';
import 'package:lipht/routes/routes.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authService);

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signInWithEmailAndPassword(email, password);
      _error = null;
      return true; // Return true on success
    } catch (e) {
      _error = e.toString();
      _user = null;
      return false; // Return false on failure
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? photoUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        photoUrl: photoUrl,
      );
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      _user = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint("Starting sign out process");
      await _authService.signOut();
      debugPrint("Firebase auth sign out complete");

      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.signOut();
        debugPrint("Google sign out complete");
      }

      _user = null;
      _error = null;
      debugPrint(
          "User set to null, authentication state is now: $isAuthenticated");

      // Use the global navigator key to navigate directly
      navigatorKey.currentState?.pushReplacementNamed(Routes.login);
      debugPrint("Navigation to login screen triggered");
    } catch (e) {
      debugPrint("Error signing out: $e");
      _error = "Error signing out: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint("Notified listeners after sign out");
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Pass the GoogleSignIn instance to the auth service
      _user = await _authService.signInWithGoogle(_googleSignIn);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithApple() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Placeholder for Apple Sign-In implementation for Apple App Store guidelines
      // Need to implement this in AuthService
      // _user = await _authService.signInWithApple();
      _error = "Apple Sign-In not implemented yet";
      _user = null;
    } catch (e) {
      _error = e.toString();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Initialize auth state listener
  void initAuthStateListener() {
    debugPrint("Setting up auth state listener");
    _authService.authStateChanges().listen((UserModel? userData) {
      debugPrint(
          "Auth state changed: user ${userData != null ? 'exists' : 'is null'}");
      _user = userData;
      notifyListeners();
    });
  }
}
