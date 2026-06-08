import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:smart_expens/core/errors/app_exception.dart';
import 'package:smart_expens/services/budget_service.dart';

/// Manages the user's monthly budget state with real-time Firestore streaming.
///
/// Listens to budget changes on the user document so the UI always
/// reflects the latest value — even if it was changed from another device.
class BudgetProvider with ChangeNotifier {
  final BudgetService _service = BudgetService();

  StreamSubscription<double?>? _subscription;
  String? _activeUid;

  // ─── State ──────────────────────────────────────────────────────────────────

  double _monthlyBudget = 0.0;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  // ─── Getters ────────────────────────────────────────────────────────────────

  double get monthlyBudget => _monthlyBudget;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool get hasBudget => _monthlyBudget > 0;

  // ─── Stream subscription ──────────────────────────────────────────────────

  /// Starts listening to real-time budget updates for [uid].
  void startListening(String uid) {
    if (uid.isEmpty) {
      debugPrint('⚠️  BudgetProvider.startListening: uid is empty, abort.');
      return;
    }

    // Prevent duplicate subscriptions for the same user
    if (_activeUid == uid && _subscription != null) {
      debugPrint('ℹ  BudgetProvider: already subscribed to uid=$uid');
      return;
    }

    _subscription?.cancel();
    _activeUid = uid;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    debugPrint(' BudgetProvider.startListening → uid=$uid');

    _subscription = _service
        .budgetStream(uid)
        .listen(
          (budget) {
            _monthlyBudget = budget ?? 0.0;
            _isLoading = false;
            _errorMessage = null;
            debugPrint('BudgetProvider: budget=$_monthlyBudget');
            notifyListeners();
          },
          onError: (Object error) {
            _isLoading = false;
            if (error is AppException) {
              _errorMessage = error.message;
              debugPrint(
                '  BudgetProvider stream error [${error.code.name}]: '
                '${error.message}',
              );
            } else {
              _errorMessage = AppException.messageFor(AppErrorCode.unknown);
              debugPrint('  BudgetProvider stream unexpected error: $error');
            }
            notifyListeners();
          },
          cancelOnError: false,
        );
  }

  /// Cancels the stream and clears budget state.
  void stopListening() {
    debugPrint(' BudgetProvider.stopListening');
    _subscription?.cancel();
    _subscription = null;
    _activeUid = null;
    _monthlyBudget = 0.0;
    _isLoading = false;
    _isSaving = false;
    _errorMessage = null;
    notifyListeners();
  }

  // ─── Write ──────────────────────────────────────────────────────────────────

  /// Saves a new monthly budget. Returns `true` on success.
  Future<bool> saveBudget(String uid, double budget) async {
    if (uid.isEmpty) {
      _errorMessage = 'You must be signed in to save a budget.';
      notifyListeners();
      return false;
    }

    try {
      _isSaving = true;
      _errorMessage = null;
      notifyListeners();

      await _service.saveBudget(uid, budget);

      // The stream will automatically update _monthlyBudget
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      debugPrint('BudgetProvider.saveBudget [${e.code.name}]: $e');
      return false;
    } catch (e) {
      _errorMessage = AppException.messageFor(AppErrorCode.unknown);
      debugPrint(' BudgetProvider.saveBudget unexpected: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Clears the current error state.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ─── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
