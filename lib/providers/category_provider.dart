import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_expens/models/category_model.dart';
import 'package:smart_expens/services/category_service.dart';

/// Manages category state and stream lifecycle for the authenticated user.
///
/// Listens to real-time Firestore updates for user's custom categories.
/// Properly handles stream cancellation during auth transitions.
class CategoryProvider with ChangeNotifier {
  CategoryProvider() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      _onAuthStateChanged,
    );
  }

  final CategoryService _service = CategoryService();

  /// Subscription to FirebaseAuth state changes — drives stream lifecycle.
  StreamSubscription<User?>? _authSubscription;

  /// Active Firestore stream subscription. Stored so it can be cancelled.
  StreamSubscription<List<CategoryModel>>? _subscription;

  /// UID currently subscribed to — used to detect uid changes.
  String? _activeUid;

  // ─── Auth callback ───────────────────────────────────────────────────────

  /// Called whenever auth state changes (login / logout / token refresh).
  void _onAuthStateChanged(User? user) {
    if (user != null && user.uid.isNotEmpty) {
      if (_activeUid != user.uid) {
        debugPrint('🔑 CategoryProvider: auth changed → uid=${user.uid}');
        startListening(user.uid);
      }
    } else {
      debugPrint('🔑 CategoryProvider: auth changed → signed out');
      stopListening();
    }
  }

  // ─── State ────────────────────────────────────────────────────────────────

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ─── Getters ──────────────────────────────────────────────────────────────

  List<CategoryModel> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Start listening to user's custom categories.
  ///
  /// If [uid] differs from current [_activeUid], the old subscription
  /// is cancelled first to prevent orphaned listeners.
  void startListening(String uid) {
    // ── Guard: abort if uid is empty ───────────────────────────────────────
    if (uid.isEmpty) {
      debugPrint('  CategoryProvider.startListening: uid is empty, abort.');
      return;
    }

    // ── Cancel old subscription if uid changed ─────────────────────────────
    if (_activeUid != uid) {
      debugPrint(
        ' CategoryProvider: uid changed from $_activeUid to $uid, '
        'cancelling old subscription',
      );
      _subscription?.cancel();
      _subscription = null;
    }

    // ── Prevent duplicate subscriptions ────────────────────────────────────
    if (_activeUid == uid && _subscription != null) {
      debugPrint('ℹ  CategoryProvider: already subscribed to uid=$uid');
      return;
    }

    _activeUid = uid;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    debugPrint('CategoryProvider.startListening → uid=$uid');

    _subscription = _service
        .getUserCategoriesStream(uid)
        .listen(
          (categories) {
            _categories = categories;
            _isLoading = false;
            _errorMessage = null;
            debugPrint(
              'CategoryProvider: received ${categories.length} categories.',
            );
            notifyListeners();
          },
          onError: (Object error) {
            _isLoading = false;
            _errorMessage = error.toString();
            debugPrint(' CategoryProvider stream error: $error');
            notifyListeners();
          },
          cancelOnError: false,
        );
  }

  /// Cancels the stream and clears all category state.
  ///
  /// Call this on user sign-out so no stale data remains in memory.
  void stopListening() {
    debugPrint(' CategoryProvider.stopListening');
    _subscription?.cancel();
    _subscription = null;
    _activeUid = null;
    _categories = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
