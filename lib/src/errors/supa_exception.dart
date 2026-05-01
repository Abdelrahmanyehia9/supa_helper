/// Base exception for all `supa_helper` errors.
sealed class SupaException implements Exception {
  final String message;
  const SupaException(this.message);
  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when an authentication operation fails.
final class SupaAuthException extends SupaException {
  const SupaAuthException(super.message);
}

/// Thrown when a database operation fails.
final class SupaDatabaseException extends SupaException {
  const SupaDatabaseException(super.message);
}

/// Thrown when a storage operation fails.
final class SupaStorageException extends SupaException {
  const SupaStorageException(super.message);
}

/// Thrown when a realtime subscription operation fails.
final class SupaRealtimeException extends SupaException {
  const SupaRealtimeException(super.message);
}