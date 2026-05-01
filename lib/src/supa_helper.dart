// ignore_for_file: always_use_package_imports

import 'package:supabase_flutter/supabase_flutter.dart';
import 'service/authentication/supa_auth_impl.dart';
import 'service/database/supa_database_impl.dart';
import 'service/realtime/supa_real_time_impl.dart';
import 'service/storage/supa_storage_impl.dart';

/// Main entry point for Supabase helper package.
/// Singleton wrapper around Supabase services.
///
/// Usage:
/// ```dart
/// await SupaHelper.instance.init(
///   url: 'YOUR_URL',
///   anonKey: 'YOUR_ANON_KEY',
/// );
///
/// await SupaHelper.instance.auth.signIn(...);
/// final data = await SupaHelper.instance.database.GET;
/// ```
class SupaHelper {
  SupaHelper._();

  /// Global singleton instance.
  static final SupaHelper instance = SupaHelper._();
  bool _initialized = false;

  SupaAuthImpl? _auth;
  SupaDatabaseImpl? _database;
  SupaStorageImpl? _storage;
  SupaRealTimeImpl? _realtime;

  /// Initialize Supabase once at app startup.
  Future<void> init({
    required String url,
    required String anonKey,
    Map<String, String>? headers,
    RealtimeClientOptions realtimeClientOptions = const RealtimeClientOptions(),
    PostgrestClientOptions postgrestOptions = const PostgrestClientOptions(),
    StorageClientOptions storageOptions = const StorageClientOptions(),
    FlutterAuthClientOptions authOptions = const FlutterAuthClientOptions(),
    Future<String?> Function()? accessToken,
    bool? debug,
  }) async {
    if (_initialized) return;
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      headers: headers,
      realtimeClientOptions: realtimeClientOptions,
      postgrestOptions: postgrestOptions,
      storageOptions: storageOptions,
      authOptions: authOptions,
      accessToken: accessToken,
      debug: debug,
    );
    _initialized = true;
  }
  /// Raw Supabase client.
  SupabaseClient get client => Supabase.instance.client;
  /// Authentication service.
  SupaAuthImpl get auth => _auth??  SupaAuthImpl(client.auth);
  /// Database service.
  SupaDatabaseImpl get database => _database ??  SupaDatabaseImpl(client.rest);
  /// Storage service.
  SupaStorageImpl get storage => _storage ??  SupaStorageImpl(client.storage);
  /// Realtime service.
  SupaRealTimeImpl get realtime => _realtime ?? SupaRealTimeImpl(client.realtime) ;
  /// Reset all cached services and allow re-initialization.
  void reset() {
    _auth = null;
    _database = null;
    _storage = null;
    _realtime = null;
    _initialized = false;
  }
}