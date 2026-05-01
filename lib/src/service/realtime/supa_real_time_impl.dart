import 'package:supa_helper/src/errors/handle_error.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supa_real_time.dart';

typedef RealtimeCallback = void Function(PostgresChangePayload payload);

final class SupaRealTimeImpl implements SupaRealTime {
  final Map<String, RealtimeChannel> _channels = {};
  final RealtimeClient _client;
  SupaRealTimeImpl(this._client);

  @override
  void subscribeToTable({
    required String channelName,
    required String schema,
    required String table,
    required RealtimeCallback callback,
    PostgresChangeEvent event = PostgresChangeEvent.all,
    PostgresChangeFilter? filter,
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

      });

      _channels[channelName] = channel;
    } catch (e) {
       e.handleError() ;
    }
  }

  @override
  void unsubscribe(String channelName) {
    try {
      final channel = _channels.remove(channelName);
      if (channel != null) _client.removeChannel(channel);
    } catch (e) {
       e.handleError() ;
    }
  }

  @override
  void unsubscribeAll() {
    try {
      for (var channel in _channels.values) {
        _client.removeChannel(channel);
      }
      _channels.clear();
    } catch (e) {
       e.handleError() ;
    }
  }
  @override
  bool isSubscribed(String channelName) => _channels.containsKey(channelName);
  @override
  int get activeChannelsCount => _channels.length;
  @override
  void dispose() => unsubscribeAll();
}