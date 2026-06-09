import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_expens/models/user_input.dart';
import 'package:smart_expens/models/user_model.dart';
import 'package:smart_expens/services/firebase_auth.dart';
import 'package:smart_expens/services/firestore_service.dart';

/// Combined AuthService that integrates Firebase Auth and Firestore
/// This is a higher-level service that provides a clean interface for authentication operations
class AuthService {
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  /// Sign up with email and password and automatically create Firestore document
  Future<User> signUp(UserInput user) async {
    final authUser = await _firebaseAuthService.signUpWithEmailAndPassword(
      user,
    );
    if (authUser == null) {
      throw Exception('Failed to create user account');
    }
    return authUser;
  }

  /// Login with email and password
  Future<User> login(String email, String password) async {
    final authUser = await _firebaseAuthService.loginWithEmailAndPassword(
      email,
      password,
    );
    if (authUser == null) {
      throw Exception('Failed to login');
    }
    return authUser;
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _firebaseAuthService.signOut();
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await _firebaseAuthService.resetPassword(email);
  }

  /// Get current authenticated user
  User? getCurrentUser() {
    return _firebaseAuthService.getCurrentUser();
  }

  /// Stream of authentication state changes
  Stream<User?> authStateChanges() {
    return _firebaseAuthService.authStateChanges();
  }

  /// Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    return await _firestoreService.getUser(uid);
  }

  /// Update user profile in both Auth and Firestore
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? photoURL,
  }) async {
    // Update Firebase Auth profile
    await _firebaseAuthService.updateUserProfile(
      displayName: displayName,
      photoURL: photoURL,
    );

    // Update Firestore document
      if (displayName != null || photoURL != null) {
        final Map<String, dynamic> updates = {};
        if (displayName != null) updates['name'] = displayName;
        if (photoURL != null) updates['profileImage'] = photoURL;

        await _firestoreService.updateUserFields(uid, updates);
      }
  }

  /// Update user email in Auth and Firestore
  Future<void> updateEmail({required String uid, required String email}) async {
    await _firebaseAuthService.updateUserEmail(newEmail: email);

    // Update Firestore document
    await _firestoreService.updateUserFields(uid, {
      'email': email.trim().toLowerCase(),
    });
  }

  /// Update password in Auth
  Future<void> updatePassword({required String newPassword}) async {
    await _firebaseAuthService.updateUserPassword(newPassword: newPassword);
  }

  /// Check if user is logged in
  bool get isSignedIn => _firebaseAuthService.getCurrentUser() != null;

  /// Get current user's UID
  String? get currentUid => _firebaseAuthService.getCurrentUser()?.uid;

  /// Force refresh of current user
  Future<void> refreshCurrentUser() async {
    await _firebaseAuthService.refreshCurrentUser();
  }
}
