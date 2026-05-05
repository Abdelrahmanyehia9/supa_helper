import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supa_helper/src/errors/handle_error.dart';

class RetryOption {
  final int retryAttempts;
  const RetryOption({required this.retryAttempts});
  void _log(String message) {
    if (kDebugMode) debugPrint('[Retry-Option] $message');
  }
  Future<T> withRetry<T>(
      Future<T> Function() request, {
        int? retries,
      }) async
  {
    int attempt = 0;
    final maxAttempts = retries ?? retryAttempts;
    const maxDelay = 30;
    while (true) {
      try {
        if (attempt > 0) _log('🔁 Attempt $attempt / $maxAttempts');
        return await request();
      } catch (e) {
        if (attempt >= maxAttempts) {
          if(maxAttempts>0) _log('❌ Failed after $maxAttempts attempts → $e');
          e.handleError();
        }
        final delay = min(pow(2, attempt).toInt(), maxDelay);
        _log('⚠️ Attempt $attempt failed → retrying in ${delay}s | Error: $e');
        await Future.delayed(Duration(seconds: delay));
        attempt++;
      }
    }
  }
}
