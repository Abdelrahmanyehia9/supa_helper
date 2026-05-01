import 'package:supabase_flutter/supabase_flutter.dart';

import 'service/authentication/supa_auth.dart';
import 'service/supa_database.dart';
import 'service/supa_real_time.dart';
import 'service/supa_storage.dart';

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

  SupaAuth? _auth;
  SupaDatabase? _database;
  SupaStorage? _storage;
  SupaRealTime? _realtime;

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

  /// Ensure package is initialized before using services.
  void _ensureInitialized() {
    if (!_initialized) {
      throw Exception(
        'Supabase is not initialized.\n'
            'Call SupaHelper.instance.init(...) before using any service.',
      );
    }
  }

  T _getService<T>(T? cached, T Function() create) {
    _ensureInitialized();
    return cached ??= create();
  }

  /// Raw Supabase client.
  SupabaseClient get client {
    _ensureInitialized();
    return Supabase.instance.client;
  }

  /// Authentication service.
  SupaAuth get auth => _getService(_auth, () => SupaAuth(client.auth));
  /// Database service.
  SupaDatabase get database => _getService(_database, () => SupaDatabase(client.rest));
  /// Storage service.
  SupaStorage get storage => _getService(_storage, () => SupaStorage(client.storage));
  /// Realtime service.
  SupaRealTime get realtime => _getService(_realtime, () => SupaRealTime(client.realtime));
  /// Reset all cached services and allow re-initialization.
  void reset() {
    _auth = null;
    _database = null;
    _storage = null;
    _realtime = null;
    _initialized = false;
  }
}