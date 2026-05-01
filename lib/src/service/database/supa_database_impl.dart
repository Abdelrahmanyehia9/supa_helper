// ignore_for_file: non_constant_identifier_names
import 'package:supa_helper/src/errors/handle_error.dart';
import 'package:supa_helper/src/service/database/supa_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
final class SupaDatabaseImpl implements SupaDatabase {
  final PostgrestClient _client;
  const SupaDatabaseImpl(this._client);
  @override
  Future<List<Map<String, dynamic>>> GET({
    required String table,
    String? select,
    PostgrestTransformBuilder<PostgrestList> Function(PostgrestFilterBuilder<PostgrestList>)? filter
  }) async
  {
    try {
      final query = _client.from(table).select(select ?? "*");
      return List<Map<String, dynamic>>.from(
        await (filter != null ? filter(query) : query),
      );
    }  catch (e) {
       e.handleError() ;
    }
  }
  @override
  Future<Map<String, dynamic>> GET_SINGLE({
    required String table,
    String? select,
    required PostgrestTransformBuilder<PostgrestList> Function(PostgrestFilterBuilder<PostgrestList>) filter
  }) async
  {
    try {
      final query = _client.from(table).select(select ?? "*");
      return await filter(query).maybeSingle() ?? {};
    }
    catch (e) {
       e.handleError() ;
    }
  }
  @override
  Future<Map<String, dynamic>> INSERT({
    required String table,
    required Map<String, dynamic> data,
    String? select,
  }) async {
    try {
      return await _client
          .from(table)
          .insert(data)
          .select(select ?? "*")
          .maybeSingle() ??
          {};
    } catch (e) {
       e.handleError() ;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> INSERT_MANY({
    required String table,
    required List<Map<String, dynamic>> data,
    String? select,
  }) async
  {
    try {
      return await _client.from(table).insert(data).select(select ?? "*");
    }  catch (e) {
       e.handleError() ;
    }
  }

  @override
  Future<Map<String, dynamic>> UPDATE({
    required String table,
    required Map<String, dynamic> data,
    String? select,
    String idColumn = 'id',
    required String idValue,
  }) async {
    try {
      final query = _client.from(table).update(data).eq(idColumn, idValue).select(select ?? "*");
      return await query.maybeSingle() ?? {};
    }
      catch (e) {
       e.handleError() ;
    }
  }
  @override
  Future<Map<String, dynamic>> UPSERT({
    required String table,
    required Map<String, dynamic> data,
    String? select,
    String idColumn = 'id',
    required String idValue,
  }) async {
    try {
      final query = _client.from(table).upsert(data).eq(idColumn, idValue).select(select ?? "*");
      return await query.maybeSingle() ?? {};
    }
      catch (e) {
       e.handleError() ;
    }
  }

  @override
  Future<void> DELETE({
    required String table,
    required PostgrestFilterBuilder<void> Function(
        PostgrestFilterBuilder<void>,
        ) filter,
  }) async {
    try {
      final query = _client.from(table).delete();
      await filter(query);
    }
       catch (e) {
       e.handleError();
    }
  }

  @override
  Future<dynamic> RPC({
    required String function,
    Map<String, dynamic>? params,
  }) async {
    try {
      return await _client.rpc(function, params: params);
    } catch (e) {
       e.handleError();
    }
  }

  @override
  Future<int> COUNT({
    required String table,
    CountOption countOption = CountOption.exact,
    PostgrestFilterBuilder<int> Function(
        PostgrestFilterBuilder<int>,
        )? filter,
  }) async {
    try {
      final query = _client.from(table).count(countOption);
      return filter != null ? await filter(query) : await query;
    } catch (e) {
       e.handleError() ;
    }
  }
}