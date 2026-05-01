import 'package:supa_helper/src/errors/supa_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  const ErrorHandler._();
  static SupaException handleError(Object e) {
    if (e is SupaException) return e;
    if (e is AuthException) return SupaAuthException(message:e.message, code: e.code,statusCode: e.code, rawError: e );
    if (e is StorageException) return SupaStorageException(message: e.message,statusCode: e.statusCode, rawError: e );
    if (e is PostgrestException) return SupaDatabaseException(message: e.message,statusCode: e.code, rawError: e.details, hint:  e.hint );
    return SupaUnExpectedException(e);
  }}

extension ErrorExtension on Object {
  Never handleError() {
   throw ErrorHandler.handleError(this);
  }
}
