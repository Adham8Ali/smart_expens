/// Typed application exceptions with user-friendly messages.
///
/// Wrapping raw Firebase exceptions lets the UI layer display meaningful
/// messages without leaking Firebase internal codes or stack traces.
enum AppErrorCode {
  permissionDenied,
  unauthenticated,
  notFound,
  networkUnavailable,
  invalidData,
  unknown,
}

class AppException implements Exception {
  final String message;
  final AppErrorCode code;
  final Object? cause;

  const AppException({
    required this.message,
    required this.code,
    this.cause,
  });

  @override
  String toString() => 'AppException(${code.name}): $message';

  // ─── Mapping helpers ────────────────────────────────────────────────────────

  /// Maps a Firestore [FirebaseException.code] string to an [AppErrorCode].
  static AppErrorCode codeFromFirestore(String firestoreCode) {
    switch (firestoreCode) {
      case 'permission-denied':
        return AppErrorCode.permissionDenied;
      case 'unauthenticated':
        return AppErrorCode.unauthenticated;
      case 'not-found':
        return AppErrorCode.notFound;
      case 'unavailable':
        return AppErrorCode.networkUnavailable;
      default:
        return AppErrorCode.unknown;
    }
  }

  /// Returns a user-friendly message for [code].
  static String messageFor(AppErrorCode code) {
    switch (code) {
      case AppErrorCode.permissionDenied:
        return 'You do not have permission. Please log in and try again.';
      case AppErrorCode.unauthenticated:
        return 'You must be signed in to perform this action.';
      case AppErrorCode.notFound:
        return 'The requested data was not found.';
      case AppErrorCode.networkUnavailable:
        return 'Network unavailable. Check your connection and try again.';
      case AppErrorCode.invalidData:
        return 'Invalid data. Please check your input and try again.';
      case AppErrorCode.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
