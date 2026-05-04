import 'package:supabase_flutter/supabase_flutter.dart';

class PostgrestOptions implements PostgrestClientOptions {
  final int retryAttempts;
  @override
  final String schema;
  const PostgrestOptions({this.retryAttempts = 0, this.schema = 'public'});
}

class AuthOptions extends FlutterAuthClientOptions {
  final int retryAttempts;
  const AuthOptions({
    this.retryAttempts = 0,
    super.authFlowType = AuthFlowType.pkce,
    super.autoRefreshToken = true,
    super.pkceAsyncStorage,
  });


}

class StorageOptions implements StorageClientOptions {
  @override
  final int retryAttempts;
  @override
  final bool useNewHostname;
  const StorageOptions({
    this.retryAttempts = 0,
    this.useNewHostname = false,
  });
}

class RealtimeOptions implements RealtimeClientOptions {
  @override
  final RealtimeLogLevel? logLevel;
  @override
  final Duration? timeout;
  @override
  final int? eventsPerSecond;
  @override
  final WebSocketTransport? transport;
  const RealtimeOptions({
    this.logLevel,
    this.timeout,
    this.transport,
    this.eventsPerSecond,
  });

}