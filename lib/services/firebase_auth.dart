import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_expens/models/user_input.dart';
import 'package:smart_expens/models/user_model.dart';
import 'package:smart_expens/services/firestore_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email.trim());
  }

  /// Normalize credentials (trim and lowercase email)
  String _normalizeEmail(String email) => email.trim().toLowerCase();

  /// Sign up with email and password
  Future<User?> signUpWithEmailAndPassword(UserInput user) async {
    try {
      final normalizedEmail = _normalizeEmail(user.email);
      final trimmedPassword = user.password.trim();

      // Validate email format
      if (!_isValidEmail(normalizedEmail)) {
        throw Exception('Invalid email address format');
      }

      // Validate password strength
      if (trimmedPassword.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: trimmedPassword,
      );

      final authUser = credential.user;
      if (authUser == null) {
        throw Exception('Failed to create user account');
      }

      // Update user profile with full name
      try {
        await authUser.updateDisplayName(user.fullName.trim());
        await authUser.reload();
      } catch (e) {
        print('⚠️ Warning: Failed to update display name: $e');
        // Don't fail signup if display name update fails
      }

      // Create Firestore document for the user
      try {
        final userModel = UserModel(
          uid: authUser.uid,
          name: user.fullName.trim(),
          email: normalizedEmail,
          image: authUser.photoURL,
          createdAt: DateTime.now(),
        );

        await _firestoreService.createUser(userModel);
      } catch (e) {
        // ❌ CRITICAL: If Firestore fails, delete the auth user
        print('❌ ERROR: Firestore creation failed: $e');
        try {
          await authUser.delete();
        } catch (deleteError) {
          print('❌ ERROR: Failed to rollback auth user: $deleteError');
        }
        throw Exception('Failed to create user profile. Please try again.');
      }

      return authUser;
    } on FirebaseAuthException catch (e) {
      print(
        '🔴 Firebase Auth Exception during signup: ${e.code} - ${e.message}',
      );

      if (e.code == 'weak-password') {
        throw Exception('Password is too weak (at least 6 characters)');
      } else if (e.code == 'email-already-in-use') {
        throw Exception(
          'Email already registered. Please login or use a different email.',
        );
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email address format');
      } else if (e.code == 'operation-not-allowed') {
        throw Exception('Email/password signup is disabled');
      }
      throw Exception(e.message ?? 'Registration failed. Please try again.');
    } catch (e) {
      print('🔴 Unexpected error during signup: $e');
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Login with email and password
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      final trimmedPassword = password.trim();

      // Validate inputs
      if (normalizedEmail.isEmpty) {
        throw Exception('Email cannot be empty');
      }
      if (trimmedPassword.isEmpty) {
        throw Exception('Password cannot be empty');
      }
      if (!_isValidEmail(normalizedEmail)) {
        throw Exception('Invalid email address format');
      }

      print('🔵 Attempting login with email: $normalizedEmail');

      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: trimmedPassword,
      );

      final authUser = credential.user;
      if (authUser == null) {
        throw Exception('Failed to login. User not found.');
      }

      print('✅ Login successful for user: ${authUser.uid}');
      return authUser;
    } on FirebaseAuthException catch (e) {
      print(
        '🔴 Firebase Auth Exception during login: ${e.code} - ${e.message}',
      );

      if (e.code == 'user-not-found') {
        throw Exception(
          'No account found with this email. Please sign up first.',
        );
      } else if (e.code == 'wrong-password') {
        throw Exception('Incorrect password. Please try again.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email address format');
      } else if (e.code == 'user-disabled') {
        throw Exception('This account has been disabled');
      } else if (e.code == 'invalid-credential') {
        throw Exception('Invalid email or password');
      }

      // Catch-all for credential errors
      throw Exception(
        e.message ?? 'Login failed. Please check your email and password.',
      );
    } catch (e) {
      print('🔴 Unexpected error during login: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Password reset
  Future<void> resetPassword(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);

      if (!_isValidEmail(normalizedEmail)) {
        throw Exception('Invalid email address format');
      }

      await _auth.sendPasswordResetEmail(email: normalizedEmail);
    } on FirebaseAuthException catch (e) {
      print('🔴 Firebase Auth Exception during password reset: ${e.code}');

      if (e.code == 'user-not-found') {
        throw Exception('No account found with this email');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email address format');
      }
      throw Exception(e.message ?? 'Failed to send password reset email');
    } catch (e) {
      print('🔴 Unexpected error during password reset: $e');
      throw Exception('Failed to send password reset: ${e.toString()}');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      print('🔵 Signing out user');
      await _auth.signOut();
      print('✅ Sign out successful');
    } catch (e) {
      print('🔴 Error during logout: $e');
      throw Exception('Error during logout: $e');
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Check if user is logged in
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        if (displayName != null) {
          await user.updateDisplayName(displayName.trim());
        }
        if (photoURL != null && photoURL.isNotEmpty) {
          await user.updatePhotoURL(photoURL);
        }
        await user.reload();
      } else {
        throw Exception('No authenticated user found');
      }
    } catch (e) {
      print('🔴 Error updating profile: $e');
      throw Exception('Error updating profile: $e');
    }
  }

  /// Force refresh of current user
  Future<void> refreshCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        print('✅ Current user refreshed');
      }
    } catch (e) {
      print('⚠️ Error refreshing current user: $e');
    }
  }
}
