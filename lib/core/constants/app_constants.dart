/// Central location for all Firestore collection/document path strings.
///
/// Using constants prevents typos and makes renaming a one-line change.
class AppConstants {
  AppConstants._(); // prevent instantiation

  // ── Firestore collection paths ──────────────────────────────────────────────
  static const String usersCollection = 'users';
  static const String expensesCollection = 'expenses';
  static const String categoriesCollection = 'categories';
}
