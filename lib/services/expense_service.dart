import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_expens/core/constants/app_constants.dart';
import 'package:smart_expens/core/errors/app_exception.dart';
import 'package:smart_expens/models/expense_model.dart';

/// Handles all Firestore CRUD operations for user expenses.
///
/// Firestore path:  users/{uid}/expenses/{expenseId}
///
/// All methods throw [AppException] on failure so callers receive typed,
/// user-friendly errors instead of raw Firebase strings.
class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Private helpers ───────────────────────────────────────────────────────

  /// Returns the typed expenses sub-collection reference for [uid].
  CollectionReference<Map<String, dynamic>> _col(String uid) => _firestore
      .collection(AppConstants.usersCollection)
      .doc(uid)
      .collection(AppConstants.expensesCollection);

  /// Converts a [FirebaseException] into a typed [AppException] and logs it.
  AppException _mapFirebase(FirebaseException e, String operation) {
    debugPrint(' ExpenseService[$operation] code=${e.code} msg=${e.message}');
    final code = AppException.codeFromFirestore(e.code);
    return AppException(
      message: AppException.messageFor(code),
      code: code,
      cause: e,
    );
  }

  // ─── Write ────────────────────────────────────────────────────────────────

  /// Adds a new expense for [uid] and returns the Firestore-generated document ID.
  ///
  /// The [ExpenseModel.id] field inside the stored document is set to match
  /// the generated ID so documents are self-contained on reads.
  Future<String> addExpense({
    required String uid,
    required double amount,
    required String categoryId,
    required DateTime date,
    String? note,
  }) async {
    try {
      debugPrint(
        ' ExpenseService.addExpense → uid=$uid '
        'amount=$amount categoryId=$categoryId',
      );

      final docRef = _col(uid).doc(); // auto-generate ID
      final expense = ExpenseModel(
        id: docRef.id,
        uid: uid,
        amount: amount,
        categoryId: categoryId,
        date: date,
        note: note,
        createdAt: DateTime.now(),
      );

      await docRef.set(expense.toMap());
      debugPrint(' ExpenseService.addExpense done → id=${docRef.id}');
      return docRef.id;
    } on FirebaseException catch (e) {
      throw _mapFirebase(e, 'addExpense');
    } catch (e) {
      debugPrint(' ExpenseService.addExpense unexpected: $e');
      throw AppException(
        message: AppException.messageFor(AppErrorCode.unknown),
        code: AppErrorCode.unknown,
        cause: e,
      );
    }
  }

  /// Merges [fields] into an existing expense document. Only provided fields
  /// are overwritten — unrelated fields are preserved.
  Future<void> updateExpense({
    required String uid,
    required String expenseId,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? note,
  }) async {
    try {
      final fields = <String, dynamic>{};
      if (amount != null) fields['amount'] = amount;
      if (categoryId != null) fields['categoryId'] = categoryId;
      if (date != null) fields['date'] = Timestamp.fromDate(date);
      if (note != null) fields['note'] = note;

      if (fields.isEmpty) {
        debugPrint('  ExpenseService.updateExpense: nothing to update.');
        return;
      }

      debugPrint(
        'ExpenseService.updateExpense → uid=$uid id=$expenseId '
        'fields=${fields.keys.toList()}',
      );
      await _col(uid).doc(expenseId).update(fields);
      debugPrint(' ExpenseService.updateExpense done → id=$expenseId');
    } on FirebaseException catch (e) {
      throw _mapFirebase(e, 'updateExpense');
    } catch (e) {
      debugPrint(' ExpenseService.updateExpense unexpected: $e');
      throw AppException(
        message: AppException.messageFor(AppErrorCode.unknown),
        code: AppErrorCode.unknown,
        cause: e,
      );
    }
  }

  /// Permanently deletes expense [expenseId] for [uid].
  Future<void> deleteExpense({
    required String uid,
    required String expenseId,
  }) async {
    try {
      debugPrint(' ExpenseService.deleteExpense → uid=$uid id=$expenseId');
      await _col(uid).doc(expenseId).delete();
      debugPrint(' ExpenseService.deleteExpense done → id=$expenseId');
    } on FirebaseException catch (e) {
      throw _mapFirebase(e, 'deleteExpense');
    } catch (e) {
      debugPrint(' ExpenseService.deleteExpense unexpected: $e');
      throw AppException(
        message: AppException.messageFor(AppErrorCode.unknown),
        code: AppErrorCode.unknown,
        cause: e,
      );
    }
  }

  // ─── Read ─────────────────────────────────────────────────────────────────

  /// One-time fetch of all expenses for [uid], newest first.
  Future<List<ExpenseModel>> getAllExpenses(String uid) async {
    try {
      debugPrint('📖 ExpenseService.getAllExpenses → uid=$uid');
      final snapshot = await _col(uid).orderBy('date', descending: true).get();
      final list = snapshot.docs
          .map((d) => ExpenseModel.fromMap(d.data()))
          .toList();
      debugPrint(' ExpenseService.getAllExpenses → ${list.length} docs');
      return list;
    } on FirebaseException catch (e) {
      throw _mapFirebase(e, 'getAllExpenses');
    } catch (e) {
      debugPrint(' ExpenseService.getAllExpenses unexpected: $e');
      throw AppException(
        message: AppException.messageFor(AppErrorCode.unknown),
        code: AppErrorCode.unknown,
        cause: e,
      );
    }
  }

  /// Real-time stream of all expenses for [uid], ordered by date descending.
  ///
  /// Errors from Firestore (e.g. permission-denied) are re-emitted as
  /// [AppException] so the provider can display a typed error message.
  Stream<List<ExpenseModel>> expensesStream(String uid) {
    debugPrint('ExpenseService.expensesStream → uid=$uid');
    return _col(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => ExpenseModel.fromMap(d.data())).toList(),
        )
        .handleError((Object error) {
          if (error is FirebaseException) {
            throw _mapFirebase(error, 'expensesStream');
          }
          throw AppException(
            message: AppException.messageFor(AppErrorCode.unknown),
            code: AppErrorCode.unknown,
            cause: error,
          );
        });
  }

  /// Real-time stream of expenses for [uid] filtered to a specific [month].
  Stream<List<ExpenseModel>> expensesStreamForMonth({
    required String uid,
    required DateTime month,
  }) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(
      month.year,
      month.month + 1,
      1,
    ).subtract(const Duration(milliseconds: 1));

    debugPrint(
      '👂 ExpenseService.expensesStreamForMonth → uid=$uid '
      '${start.toIso8601String()} → ${end.toIso8601String()}',
    );

    return _col(uid)
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
          isLessThanOrEqualTo: Timestamp.fromDate(end),
        )
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => ExpenseModel.fromMap(d.data())).toList(),
        )
        .handleError((Object error) {
          if (error is FirebaseException) {
            throw _mapFirebase(error, 'expensesStreamForMonth');
          }
          throw AppException(
            message: AppException.messageFor(AppErrorCode.unknown),
            code: AppErrorCode.unknown,
            cause: error,
          );
        });
  }
}
