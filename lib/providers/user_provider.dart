import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_expens/model/user_model.dart';
import 'package:smart_expens/model/user_input.dart';
import 'package:smart_expens/services/auth_service.dart';
import 'package:smart_expens/services/firestore_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _currentUser;
  User? _authUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  User? get authUser => _authUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authUser != null && _currentUser != null;
  String? get currentUid => _authUser?.uid;

  UserProvider() {
    _initializeAuthListener();
  }

  /// Initialize authentication state listener
  void _initializeAuthListener() {
    _authService.authStateChanges().listen((User? user) async {
      _authUser = user;
      if (user != null) {
        await _fetchUserData(user.uid);
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  /// Fetch user data from Firestore
  Future<void> _fetchUserData(String uid) async {
    try {
      _errorMessage = null;

      UserModel? user = await _firestoreService.getUser(uid);
      _currentUser = user;

      if (user == null) {
        _errorMessage = 'User data not found in Firestore';
      }
    } catch (e) {
      _errorMessage = e.toString();
      _currentUser = null;
    } finally {
      notifyListeners();
    }
  }

  /// Sign up new user
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = UserInput(
        fullName: fullName,
        email: email,
        password: password,
      );

      final authUser = await _authService.signUp(user);

      // ✅ Explicitly fetch Firestore data right after sign-up so that
      // _currentUser is populated before the caller navigates to home.
      // The auth-state listener will also fire, but _fetchUserData guards
      // against duplicate calls by being idempotent.
      await _fetchUserData(authUser.uid);
      _authUser = authUser;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login user
  Future<void> login({required String email, required String password}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.login(email, password);

      // User data will be fetched automatically by the auth listener
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();

      _currentUser = null;
      _authUser = null;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.resetPassword(email);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (_authUser == null) {
        throw Exception('No authenticated user');
      }

      await _authService.updateProfile(
        uid: _authUser!.uid,
        displayName: displayName,
        photoURL: photoURL,
      );

      // Refresh user data
      await _fetchUserData(_authUser!.uid);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh user data from Firestore
  Future<void> refreshUserData() async {
    if (_authUser != null) {
      await _fetchUserData(_authUser!.uid);
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
