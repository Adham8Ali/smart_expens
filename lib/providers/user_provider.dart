import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_expens/models/user_model.dart';
import 'package:smart_expens/models/user_input.dart';
import 'package:smart_expens/services/auth_service.dart';
import 'package:smart_expens/services/firestore_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _currentUser;
  User? _authUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

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

  /// Initialize authentication state listener (only once)
  void _initializeAuthListener() {
    if (_isInitialized) {
      print(
        '⚠️ UserProvider already initialized, skipping duplicate initialization',
      );
      return;
    }

    _isInitialized = true;
    print('🔵 Initializing UserProvider auth listener');

    _authService.authStateChanges().listen(
      (User? user) async {
        print('🔔 Auth state changed: user = ${user?.uid ?? "null"}');
        _authUser = user;

        if (user != null) {
          // User logged in
          await _fetchUserData(user.uid);
        } else {
          // User logged out
          print(' User logged out, clearing current user');
          _currentUser = null;
          _errorMessage = null;
        }

        notifyListeners();
      },
      onError: (error) {
        print(' Error in auth state listener: $error');
        _errorMessage = 'Authentication error: $error';
        notifyListeners();
      },
    );
  }

  /// Fetch user data from Firestore
  Future<void> _fetchUserData(String uid) async {
    try {
      _errorMessage = null;
      print('🔵 Fetching user data for UID: $uid');

      UserModel? user = await _firestoreService.getUser(uid);

      if (user == null) {
        // User not found in Firestore, but auth user exists
        // This shouldn't happen if signup worked correctly
        print(' User data not found in Firestore for UID: $uid');
        _currentUser = null;
        _errorMessage = 'User profile not found. Please try signing up again.';
      } else {
        print(' User data fetched successfully: ${user.name}');
        _currentUser = user;
      }
    } on FirebaseException catch (e) {
      print(' Firebase error fetching user data: ${e.code} - ${e.message}');
      _errorMessage = 'Firestore error: ${e.message}';
      _currentUser = null;
    } catch (e) {
      print(' Unexpected error fetching user data: $e');
      _errorMessage = 'Failed to load user profile: $e';
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

      print('🔵 Starting signup process for: $email');

      final user = UserInput(
        fullName: fullName.trim(),
        email: email.trim(),
        password: password.trim(),
      );

      final authUser = await _authService.signUp(user);
      print('✅ Signup successful for: ${authUser.uid}');

      // ✅ Explicitly fetch Firestore data right after sign-up
      // so that _currentUser is populated before navigation
      await _fetchUserData(authUser.uid);
      _authUser = authUser;
    } on FirebaseException catch (e) {
      print('🔴 Firebase error during signup: ${e.code}');
      _errorMessage = e.message ?? 'Signup failed';
      rethrow;
    } catch (e) {
      print('🔴 Error during signup: $e');
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

      print('🔵 Starting login process for: $email');

      final authUser = await _authService.login(email.trim(), password.trim());
      print('✅ Login successful for: ${authUser.uid}');

      _authUser = authUser;

      // ✅ Fetch user data after successful authentication
      // The auth listener will also fire, but this ensures _currentUser is set immediately
      await _fetchUserData(authUser.uid);
    } on FirebaseException catch (e) {
      print('🔴 Firebase error during login: ${e.code}');
      _errorMessage = e.message ?? 'Login failed';
      _authUser = null;
      rethrow;
    } catch (e) {
      print('🔴 Error during login: $e');
      _errorMessage = e.toString();
      _authUser = null;
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

      print('🔵 Starting sign out');

      await _authService.signOut();

      _currentUser = null;
      _authUser = null;
      _errorMessage = null;

      print('✅ Sign out successful');
    } catch (e) {
      print('🔴 Error during sign out: $e');
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

      print('🔵 Sending password reset email to: $email');

      await _authService.resetPassword(email.trim());

      print('✅ Password reset email sent');
    } catch (e) {
      print('🔴 Error during password reset: $e');
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

      print('🔵 Updating profile for user: ${_authUser!.uid}');

      await _authService.updateProfile(
        uid: _authUser!.uid,
        displayName: displayName,
        photoURL: photoURL,
      );

      // Refresh user data
      await _fetchUserData(_authUser!.uid);

      print('✅ Profile updated successfully');
    } catch (e) {
      print('🔴 Error updating profile: $e');
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user email
  Future<void> updateEmail(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (_authUser == null) {
        throw Exception('No authenticated user');
      }

      print('🔵 Updating email for user: ${_authUser!.uid}');

      await _authService.updateEmail(uid: _authUser!.uid, email: email);

      await _fetchUserData(_authUser!.uid);

      print('✅ Email updated successfully');
    } catch (e) {
      print('🔴 Error updating email: $e');
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (_authUser == null) {
        throw Exception('No authenticated user');
      }

      print('🔵 Updating password for user: ${_authUser!.uid}');

      await _authService.updatePassword(newPassword: newPassword);

      print('✅ Password updated successfully');
    } catch (e) {
      print('🔴 Error updating password: $e');
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
      print('🔵 Refreshing user data for: ${_authUser!.uid}');
      await _fetchUserData(_authUser!.uid);
    }
  }

  /// Set the user's monthly budget (persist to Firestore)
  Future<void> setMonthlyBudget(double budget) async {
    if (_authUser == null) throw Exception('No authenticated user');
    try {
      _isLoading = true;
      notifyListeners();

      await _firestoreService.updateUserFields(_authUser!.uid, {
        'monthlyBudget': budget,
      });

      // Update local model optimistically
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(monthlyBudget: budget);
      }
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Force refresh of auth state
  Future<void> refreshAuthState() async {
    try {
      print('🔵 Refreshing auth state');
      await _authService.refreshCurrentUser();
      if (_authUser != null) {
        await _fetchUserData(_authUser!.uid);
      }
    } catch (e) {
      print('⚠️ Error refreshing auth state: $e');
    }
  }
}
