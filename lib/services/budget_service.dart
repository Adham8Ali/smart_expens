import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_expens/core/constants/app_constants.dart';
import 'package:smart_expens/core/errors/app_exception.dart';

/// Handles Firestore operations for the user's monthly budget.
///
/// Budget is stored as a field on the user document:
///   users/{uid} → { monthlyBudget: double, budgetUpdatedAt: Timestamp }
class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(AppConstants.usersCollection).doc(uid);

  AppException _mapFirebase(FirebaseException e, String op) {
    debugPrint(' BudgetService[$op] code=${e.code} msg=${e.message}');
    final code = AppException.codeFromFirestore(e.code);
    return AppException(
      message: AppException.messageFor(code),
      code: code,
      cause: e,
    );
  }

  /// Saves the monthly budget for [uid].
  ///
  /// Uses `update` with merge semantics so other user fields are preserved.
  Future<void> saveBudget(String uid, double budget) async {
    try {
      debugPrint(' BudgetService.saveBudget → uid=$uid budget=$budget');
      await _userDoc(uid).update({
        'monthlyBudget': budget,
        'budgetUpdatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint(' BudgetService.saveBudget done');
    } on FirebaseException catch (e) {
      throw _mapFirebase(e, 'saveBudget');
    } catch (e) {
      debugPrint(' BudgetService.saveBudget unexpected: $e');
      throw AppException(
        message: AppException.messageFor(AppErrorCode.unknown),
        code: AppErrorCode.unknown,
        cause: e,
      );
    }
  }

  /// Real-time stream of the user's monthly budget.
  ///
  /// Emits `null` if the field is missing (user never set a budget).
  Stream<double?> budgetStream(String uid) {
    debugPrint('BudgetService.budgetStream → uid=$uid');
    return _userDoc(uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          final data = doc.data();
          if (data == null) return null;
          return (data['monthlyBudget'] as num?)?.toDouble();
        })
        .handleError((Object error) {
          if (error is FirebaseException) {
            throw _mapFirebase(error, 'budgetStream');
          }
          throw AppException(
            message: AppException.messageFor(AppErrorCode.unknown),
            code: AppErrorCode.unknown,
            cause: error,
          );
        });
  }
}
