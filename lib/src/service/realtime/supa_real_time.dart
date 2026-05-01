import 'package:supa_helper/src/service/realtime/supa_real_time_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupaRealTime {

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
  }) ;

  /// Removes the subscription for [channelName].
  void unsubscribe(String channelName);
  /// Removes all active subscriptions.
  void unsubscribeAll()  ;
  /// Returns `true` if [channelName] is currently subscribed.
  bool isSubscribed(String channelName) ;

  /// Returns the number of active subscriptions.
  int get activeChannelsCount ;

  /// Disposes all active subscriptions. Call this when the service is no longer needed.
  void dispose();
}