import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_expens/model/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  /// Create a new user document in Firestore
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .set(user.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error creating user: $e');
    }
  }

  /// Get user data by UID
  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_usersCollection).doc(uid).get();
      
      if (!doc.exists) {
        return null;
      }
      
      return UserModel.fromDocument(doc);
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching user: $e');
    }
  }

  /// Update user data
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .update(user.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error updating user: $e');
    }
  }

  /// Update specific user fields
  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update(fields);
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error updating user fields: $e');
    }
  }

  /// Delete user document
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).delete();
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error deleting user: $e');
    }
  }

  /// Check if user exists in Firestore
  Future<bool> userExists(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_usersCollection).doc(uid).get();
      return doc.exists;
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error checking user existence: $e');
    }
  }

  /// Stream of user data by UID (real-time updates)
  Stream<UserModel?> userStream(String uid) {
    return _firestore
        .collection(_usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromDocument(doc);
    });
  }

  /// Get all users (admin use only - be careful with large datasets)
  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_usersCollection).get();
      return snapshot.docs
          .map((doc) => UserModel.fromDocument(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching all users: $e');
    }
  }
}
