/// Base exception for all `supa_helper` errors.
sealed class SupaException implements Exception {
  final String message;
  final String? statusCode;
  final Object? rawError ;
  const SupaException({required this.message , this.statusCode, this.rawError});
  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when an authentication operation fails.
final class SupaAuthException extends SupaException {
  final String? code;
  const SupaAuthException({required super.message, this.code , super.statusCode, super.rawError});
}

/// Thrown when a database operation fails.
final class SupaDatabaseException extends SupaException {
  final String? hint ;
  const SupaDatabaseException({required super.message, this.hint, super.rawError, super.statusCode});
}

/// Thrown when a storage operation fails.
final class SupaStorageException extends SupaException {
  const SupaStorageException({required super.message, super.rawError, super.statusCode});
}

/// Thrown when a realtime subscription operation fails.
final class SupaRealtimeException extends SupaException {
  const SupaRealtimeException({required super.message, super.rawError, super.statusCode});
}

final class SupaUnExpectedException extends SupaException {
  const SupaUnExpectedException(Object error) : super(message: 'An unexpected error occurred', rawError: error);
}