import 'package:supabase_flutter/supabase_flutter.dart';

import 'service/authentication/supa_auth.dart';
import 'service/database/supa_database.dart';
import 'service/realtime/supa_real_time.dart';
import 'service/storage/supa_storage.dart';

/// Main entry point for Supabase helper package.
/// Singleton wrapper around Supabase services.
///
/// Usage:
/// ```dart
/// await Supa.instance.init(
///   url: 'YOUR_URL',
///   anonKey: 'YOUR_ANON_KEY',
/// );
///
/// await Supa.instance.auth.signIn(...);
/// final data = await Supa.instance.database.GET;
/// ```
Supa get  supa => Supa.instance;
class Supa {
  Supa._();
  /// Global singleton instance.
  static final Supa instance = Supa._();
  bool _initialized = false;
  /// Initialize Supabase once at app startup.
  Future<void> init({
    required String url,
    required String anonKey,
    Map<String, String>? headers,
    RealtimeClientOptions realtimeClientOptions =
    const RealtimeClientOptions(),
    PostgrestClientOptions postgrestOptions =
    const PostgrestClientOptions(),
    StorageClientOptions storageOptions =
    const StorageClientOptions(),
    FlutterAuthClientOptions authOptions =
    const FlutterAuthClientOptions(),
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

  /// Ensure package initialized before using services.
  void _ensureInitialized() {
    if (!_initialized || !Supabase.instance.isInitialized) {
      throw Exception(
        'Supa is not initialized.\n'
            'Call supa.init(...) before using any service.',
      );
    }
  }

  /// Raw Supabase client.
  SupabaseClient get client {
    _ensureInitialized();
    return Supabase.instance.client;
  }

  // =========================
  // Lazy Services
  // =========================
  SupaAuth? _auth;
  SupaDatabase? _database;
  SupaStorage? _storage;
  SupaRealTime? _realtime;

  /// Authentication service.
  SupaAuth get auth {
    _ensureInitialized();
    return _auth ??= SupaAuth(client.auth);
  }
  /// Database service.
  SupaDatabase get database {
    _ensureInitialized();
    return _database ??= SupaDatabase(client.rest);
  }
  /// Storage service.
  SupaStorage get storage {
    _ensureInitialized();
    return _storage ??= SupaStorage(client.storage);
  }
  /// Realtime service.
  SupaRealTime get realtime {
    _ensureInitialized();
    return _realtime ??= SupaRealTime(client.realtime);
  }

  /// Reset cached services (optional).
  /// Useful for logout / testing.
  void reset() {
    _auth = null;
    _database = null;
    _storage = null;
    _realtime = null;
  }
}