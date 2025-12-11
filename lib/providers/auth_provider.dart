import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  late final AuthService _authService;

  /// Default constructor - uses real Firebase services
  AuthProvider() {
    _authService = AuthService();
  }

  /// Test constructor - allows injecting mock services
  @visibleForTesting
  AuthProvider.forTesting({required AuthService authService}) {
    _authService = authService;
  }

  AuthState _authState = AuthState.initial;
  User? _firebaseUser;
  UserModel? _currentUser;
  String? _errorMessage;

  // Getters
  AuthState get authState => _authState;
  User? get firebaseUser => _firebaseUser;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _authState == AuthState.loading;
  bool get isAuthenticated => _authState == AuthState.authenticated;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isUser => _currentUser?.role == 'user';

  // Initialize and check auth state
  Future<void> initialize() async {
    _authState = AuthState.loading;
    notifyListeners();

    try {
      _firebaseUser = _authService.currentUser;

      if (_firebaseUser != null) {
        // User is logged in, fetch their document
        _currentUser = await _authService.getUserDocument(_firebaseUser!.uid);
        _authState = AuthState.authenticated;
      } else {
        _authState = AuthState.unauthenticated;
      }
    } catch (e) {
      _authState = AuthState.unauthenticated;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    _authState = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signInWithEmail(email, password);
      _firebaseUser = credential.user;

      if (_firebaseUser != null) {
        _currentUser = await _authService.getUserDocument(_firebaseUser!.uid);
        _authState = AuthState.authenticated;
        notifyListeners();
        return true;
      }

      _authState = AuthState.error;
      _errorMessage = 'Failed to get user data';
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _authState = AuthState.error;
      _errorMessage = _getAuthErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _authState = AuthState.error;
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return false;
    }
  }

  // Sign up with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? department,
  }) async {
    _authState = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        department: department,
      );

      _firebaseUser = credential.user;

      if (_firebaseUser != null) {
        _currentUser = await _authService.getUserDocument(_firebaseUser!.uid);
        _authState = AuthState.authenticated;
        notifyListeners();
        return true;
      }

      _authState = AuthState.error;
      _errorMessage = 'Failed to create account';
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _authState = AuthState.error;
      _errorMessage = _getAuthErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _authState = AuthState.error;
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _authState = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signInWithGoogle();

      if (credential == null) {
        // User cancelled sign-in
        _authState = AuthState.unauthenticated;
        notifyListeners();
        return false;
      }

      _firebaseUser = credential.user;

      if (_firebaseUser != null) {
        _currentUser = await _authService.getUserDocument(_firebaseUser!.uid);
        _authState = AuthState.authenticated;
        notifyListeners();
        return true;
      }

      _authState = AuthState.error;
      _errorMessage = 'Failed to sign in with Google';
      notifyListeners();
      return false;
    } catch (e) {
      _authState = AuthState.error;
      _errorMessage = 'Google sign-in failed';
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _authState = AuthState.loading;
    notifyListeners();

    try {
      await _authService.signOut();
      _firebaseUser = null;
      _currentUser = null;
      _authState = AuthState.unauthenticated;
    } catch (e) {
      _errorMessage = 'Failed to sign out';
    }

    notifyListeners();
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    if (_firebaseUser != null) {
      _currentUser = await _authService.getUserDocument(_firebaseUser!.uid);
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get user-friendly error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'weak-password':
        return 'Password must be at least 6 characters';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'invalid-credential':
        return 'Invalid email or password';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}

