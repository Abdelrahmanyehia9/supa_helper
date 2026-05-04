// ignore_for_file: always_use_package_imports
import 'package:supa_helper/src/models/options.dart';
import 'package:supa_helper/src/helpers/retry_option.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'service/authentication/supa_auth_impl.dart';
import 'service/database/supa_database_impl.dart';
import 'service/realtime/supa_real_time_impl.dart';
import 'service/storage/supa_storage_impl.dart';

class SupaHelper {
  SupaHelper._();

  static final SupaHelper instance = SupaHelper._();
  bool _initialized = false;

  SupaAuthImpl? _auth;
  SupaDatabaseImpl? _database;
  SupaStorageImpl? _storage;
  SupaRealTimeImpl? _realtime;

  PostgrestOptions _postgrestOptions = const PostgrestOptions();
  AuthOptions _authOptions = const AuthOptions();

  Future<void> init({
    required String url,
    required String anonKey,
    Map<String, String>? headers,
    PostgrestOptions postgrestOptions = const PostgrestOptions(),
    AuthOptions authOptions = const AuthOptions(),
    StorageOptions storageOptions = const StorageOptions(),
    RealtimeOptions realtimeOptions = const RealtimeOptions(),
    Future<String?> Function()? accessToken,
    bool? debug,
  }) async {
    if (_initialized) return;
    _postgrestOptions = postgrestOptions;
    _authOptions = authOptions;
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      headers: headers,
      postgrestOptions: postgrestOptions,
      authOptions: authOptions,
      storageOptions: storageOptions,
      realtimeClientOptions: realtimeOptions,
      accessToken: accessToken,
      debug: debug,
    );
    _initialized = true;
  }

  SupabaseClient get client {
    if (!_initialized) throw Exception('SupaHelper is not initialized');
    return Supabase.instance.client;
  }

  SupaAuthImpl get auth => _auth ??=
      SupaAuthImpl(client.auth, retryOption: RetryOption(retryAttempts: _authOptions.retryAttempts));

  SupaDatabaseImpl get database => _database ??=
      SupaDatabaseImpl(client.rest, retryOption: RetryOption(retryAttempts: _postgrestOptions.retryAttempts));

  SupaStorageImpl get storage => _storage ??=
      SupaStorageImpl(client.storage);

  SupaRealTimeImpl get realtime => _realtime ??= SupaRealTimeImpl(client.realtime,);

  void reset() {
    _auth = null;
    _database = null;
    _storage = null;
    _realtime = null;
    _initialized = false;
    _postgrestOptions = const PostgrestOptions();
    _authOptions = const AuthOptions();
  }

}