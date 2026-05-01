import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../errors/supa_exception.dart';

/// Callback triggered when a Postgres change event occurs.
typedef RealtimeCallback = void Function(PostgresChangePayload payload);

/// Manages Supabase Realtime subscriptions for Postgres changes.
final class SupaRealTime {
  final Map<String, RealtimeChannel> _channels = {};
  final RealtimeClient _client;
  SupaRealTime(this._client);

  /// Subscribes to changes on a Postgres [table].
  /// If a channel with [channelName] already exists, it will be replaced.
  /// Use [filter] to listen to specific rows only.
  ///
  /// Throws [SupaRealtimeException] if the subscription fails.
  void subscribeToTable({
    required String channelName,
    required String schema,
    required String table,
    required RealtimeCallback callback,
    PostgresChangeEvent event = PostgresChangeEvent.all,
    PostgresChangeFilter? filter,
    void Function(SupaRealtimeException)? onError,
  }) {
    try {
      if (_channels.containsKey(channelName)) unsubscribe(channelName);

      final channel = _client
          .channel(channelName)
          .onPostgresChanges(
        event: event,
        schema: schema,
        table: table,
        filter: filter,
        callback: callback,
      )
          .subscribe((status, error) {
        if (error != null) {
          final exception = SupaRealtimeException(error.toString());
          debugPrint('[$channelName] error: $error');
          onError?.call(exception);
        }
      });

      _channels[channelName] = channel;
    } catch (e) {
      throw SupaRealtimeException(e.toString());
    }
  }

  /// Removes the subscription for [channelName].
  void unsubscribe(String channelName) {
    try {
      final channel = _channels.remove(channelName);
      if (channel != null) _client.removeChannel(channel);
    } catch (e) {
      throw SupaRealtimeException(e.toString());
    }
  }

  /// Removes all active subscriptions.
  void unsubscribeAll() {
    try {
      for (var channel in _channels.values) {
        _client.removeChannel(channel);
      }
      _channels.clear();
    } catch (e) {
      throw SupaRealtimeException(e.toString());
    }
  }

  /// Returns `true` if [channelName] is currently subscribed.
  bool isSubscribed(String channelName) => _channels.containsKey(channelName);

  /// Returns the number of active subscriptions.
  int get activeChannelsCount => _channels.length;

  /// Disposes all active subscriptions. Call this when the service is no longer needed.
  void dispose() => unsubscribeAll();
}