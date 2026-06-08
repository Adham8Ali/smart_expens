import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_expens/core/errors/app_exception.dart';
import 'package:smart_expens/models/expense_model.dart';
import 'package:smart_expens/services/expense_service.dart';

/// Manages expense state for the authenticated user.
///
/// Listens to a real-time Firestore stream so the UI always reflects the
/// latest data. The subscription is properly cancelled on sign-out and
/// on [dispose] to prevent memory leaks and orphaned listeners.
class ExpenseProvider with ChangeNotifier {
  final ExpenseService _service = ExpenseService();

  /// Active Firestore stream subscription. Stored so it can be cancelled.
  StreamSubscription<List<ExpenseModel>>? _subscription;

  /// UID currently subscribed to — used to reconnect after stream errors.
  String? _activeUid;

  // ─── State ────────────────────────────────────────────────────────────────

  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  AppErrorCode? _errorCode;

  // ─── Getters ──────────────────────────────────────────────────────────────

  List<ExpenseModel> get expenses => List.unmodifiable(_expenses);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  /// Typed error code — lets the UI react differently to permission-denied
  /// vs network errors vs unknown errors.
  AppErrorCode? get errorCode => _errorCode;

  /// True when the error is a permission / auth problem.
  bool get isPermissionError =>
      _errorCode == AppErrorCode.permissionDenied ||
      _errorCode == AppErrorCode.unauthenticated;

  /// Total amount of all loaded expenses.
  double get totalAmount => _expenses.fold(0.0, (sum, e) => sum + e.amount);

  /// Expenses grouped by [categoryId].
  Map<String, List<ExpenseModel>> get byCategory {
    final map = <String, List<ExpenseModel>>{};
    for (final e in _expenses) {
      map.putIfAbsent(e.categoryId, () => []).add(e);
    }
    return map;
  }

  /// Total spending for the current calendar month only.
  double get currentMonthSpending {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Per-category spending totals for the current month.
  ///
  /// Used by the analysis API to build the request payload.
  Map<String, double> get spendingByCategory {
    final now = DateTime.now();
    final map = <String, double>{};
    for (final e in _expenses) {
      if (e.date.year == now.year && e.date.month == now.month) {
        map[e.categoryId] = (map[e.categoryId] ?? 0.0) + e.amount;
      }
    }
    return map;
  }

  // ─── Stream subscription ──────────────────────────────────────────────────

  /// Starts listening to real-time expense updates for [uid].
  ///
  /// Any existing subscription is cancelled first, preventing duplicate
  /// listeners on hot-reload or repeated auth-state changes.
  void startListening(String uid) =>
      _startListeningInternal(uid, silent: false);

  /// Internal implementation that separates first-start (shows spinner) from
  /// silent reconnects (keeps existing data visible while reconnecting).
  void _startListeningInternal(String uid, {required bool silent}) {
    // ── Guard: abort if uid is empty ───────────────────────────────────────
    if (uid.isEmpty) {
      debugPrint(' ExpenseProvider.startListening: uid is empty, abort.');
      return;
    }

    // ── Cancel any orphaned subscription before creating a new one ─────────
    _subscription?.cancel();
    _subscription = null;
    _activeUid = uid;

    // Only show a loading spinner on the very first subscription.
    // During silent reconnects we keep whatever data is already in _expenses
    // so the table stays visible instead of flashing a spinner.
    if (!silent) {
      _isLoading = true;
    }
    _errorMessage = null;
    _errorCode = null;
    notifyListeners();

    debugPrint(
      ' ExpenseProvider.startListening → uid=$uid${silent ? " (reconnect)" : ""}',
    );

    _subscription = _service
        .expensesStream(uid)
        .listen(
          (expenses) {
            _expenses = expenses;
            _isLoading = false;
            _errorMessage = null;
            _errorCode = null;
            debugPrint(
              'ExpenseProvider: received ${expenses.length} expenses.',
            );
            notifyListeners();
          },
          onError: (Object error) {
            _isLoading = false;

            if (error is AppException) {
              _errorMessage = error.message;
              _errorCode = error.code;
              debugPrint(
                '  ExpenseProvider stream error [${error.code.name}]: '
                '${error.message}',
              );
            } else {
              _errorMessage = AppException.messageFor(AppErrorCode.unknown);
              _errorCode = AppErrorCode.unknown;
              debugPrint('  ExpenseProvider stream unexpected error: $error');
            }

            notifyListeners();

            // Firestore watch streams can close with INTERNAL errors; reconnect
            // silently so the existing expense list stays visible.
            final activeUid = _activeUid;
            if (activeUid != null && activeUid.isNotEmpty) {
              Future.delayed(const Duration(seconds: 2), () {
                if (_activeUid == activeUid) {
                  debugPrint(
                    '🔄 ExpenseProvider: reconnecting stream for uid=$activeUid',
                  );
                  _startListeningInternal(activeUid, silent: true);
                }
              });
            }
          },
          cancelOnError: false,
        );
  }

  /// Cancels the stream and clears all local expense state.
  ///
  /// Call this on user sign-out so no stale data remains in memory.
  void stopListening() {
    debugPrint(' ExpenseProvider.stopListening');
    _subscription?.cancel();
    _subscription = null;
    _activeUid = null;
    _expenses = [];
    _isLoading = false;
    _errorMessage = null;
    _errorCode = null;
    notifyListeners();
  }

  // ─── Write actions ────────────────────────────────────────────────────────

  /// Adds a new expense. Returns `true` on success, `false` on failure.
  ///
  /// Validates that [uid] is not empty before calling Firestore —
  /// this is a client-side guard that surfaces auth issues early.
  Future<bool> addExpense({
    required String uid,
    required double amount,
    required String categoryId,
    required DateTime date,
    String? note,
  }) async {
    // ── Auth guard ──────────────────────────────────────────────────────────
    if (uid.isEmpty) {
      _errorMessage = AppException.messageFor(AppErrorCode.unauthenticated);
      _errorCode = AppErrorCode.unauthenticated;
      debugPrint(' ExpenseProvider.addExpense: uid is empty.');
      notifyListeners();
      return false;
    }

    // ── Verify FirebaseAuth still has a current user ────────────────────────
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.uid != uid) {
      _errorMessage = AppException.messageFor(AppErrorCode.unauthenticated);
      _errorCode = AppErrorCode.unauthenticated;
      debugPrint(
        'ExpenseProvider.addExpense: FirebaseAuth.currentUser mismatch. '
        'currentUser=${currentUser?.uid} requested=$uid',
      );
      notifyListeners();
      return false;
    }

    try {
      _isSubmitting = true;
      _errorMessage = null;
      _errorCode = null;
      notifyListeners();

      await _service.addExpense(
        uid: uid,
        amount: amount,
        categoryId: categoryId,
        date: date,
        note: note,
      );

      // The real-time stream updates _expenses automatically.
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _errorCode = e.code;
      debugPrint('ExpenseProvider.addExpense [${e.code.name}]: $e');
      return false;
    } catch (e) {
      _errorMessage = AppException.messageFor(AppErrorCode.unknown);
      _errorCode = AppErrorCode.unknown;
      debugPrint(' ExpenseProvider.addExpense unexpected: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Updates an existing expense. Returns `true` on success.
  Future<bool> updateExpense(
    ExpenseModel copyWith, {
    required String uid,
    required String expenseId,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? note,
  }) async {
    try {
      _isSubmitting = true;
      _errorMessage = null;
      _errorCode = null;
      notifyListeners();

      await _service.updateExpense(
        uid: uid,
        expenseId: expenseId,
        amount: amount,
        categoryId: categoryId,
        date: date,
        note: note,
      );
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _errorCode = e.code;
      debugPrint(' ExpenseProvider.updateExpense [${e.code.name}]: $e');
      return false;
    } catch (e) {
      _errorMessage = AppException.messageFor(AppErrorCode.unknown);
      _errorCode = AppErrorCode.unknown;
      debugPrint('ExpenseProvider.updateExpense unexpected: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Deletes an expense. Returns `true` on success.
  Future<bool> deleteExpense(
    String id, {
    required String uid,
    required String expenseId,
  }) async {
    try {
      _isSubmitting = true;
      _errorMessage = null;
      _errorCode = null;
      notifyListeners();

      await _service.deleteExpense(uid: uid, expenseId: expenseId);
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _errorCode = e.code;
      debugPrint(' ExpenseProvider.deleteExpense [${e.code.name}]: $e');
      return false;
    } catch (e) {
      _errorMessage = AppException.messageFor(AppErrorCode.unknown);
      _errorCode = AppErrorCode.unknown;
      debugPrint(' ExpenseProvider.deleteExpense unexpected: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Clears the current error state.
  void clearError() {
    _errorMessage = null;
    _errorCode = null;
    notifyListeners();
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
