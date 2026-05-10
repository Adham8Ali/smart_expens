import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_expens/model/user_input.dart';
import 'package:smart_expens/model/user_model.dart';
import 'package:smart_expens/services/firestore_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Sign up with email and password
  Future<User?> signUpWithEmailAndPassword(UserInput user) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      // Update user profile with full name
      await credential.user?.updateDisplayName(user.fullName);
      await credential.user?.reload();

      // Create Firestore document for the user
      if (credential.user != null) {
        final userModel = UserModel(
          uid: credential.user!.uid,
          name: user.fullName,
          email: user.email,
          image: credential.user?.photoURL,
          createdAt: DateTime.now(),
        );

        await _firestoreService.createUser(userModel);
      }

      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('Password is too weak (at least 6 characters)');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Email already in use');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email address');
      }
      throw Exception(e.message ?? 'Error during registration');
    } catch (e) {
      throw Exception('خطأ غير متوقع: $e');
    }
  }

  // Login with email and password
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('User not found');
      } else if (e.code == 'wrong-password') {
        throw Exception('Invalid password');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email address');
      } else if (e.code == 'user-disabled') {
        throw Exception('This account has been disabled');
      }
      throw Exception(e.message ?? 'Error during login');
    } catch (e) {
      throw Exception('خطأ غير متوقع: $e');
    }
  }

  // Password reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('User not found');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email address');
      }
      throw Exception(e.message ?? 'Error during password reset');
    } catch (e) {
      throw Exception('خطأ غير متوقع: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error during logout: $e');
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user is logged in
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }
        await user.reload();
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }
}
