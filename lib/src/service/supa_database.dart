// ignore_for_file: non_constant_identifier_names
import 'package:supabase_flutter/supabase_flutter.dart';
import '../errors/supa_exception.dart';

/// A helper class that simplifies CRUD database operations with Supabase.
final class SupaDatabase {
  final PostgrestClient _client;
  const SupaDatabase(this._client);

  /// Fetches multiple rows from [table].
  /// Use [filter] for filtering, ordering, or pagination.
  Future<List<Map<String, dynamic>>> GET({
    required String table,
    String? select,
    PostgrestFilterBuilder<PostgrestList> Function(
        PostgrestFilterBuilder<PostgrestList>,
        )? filter,
  }) async {
    try {
      final query = _client.from(table).select(select ?? "*");
      return List<Map<String, dynamic>>.from(
        await (filter != null ? filter(query) : query),
      );
    } on PostgrestException catch (e) {
      throw SupaDatabaseException(e.message);
    } catch (e) {
      throw SupaDatabaseException(e.toString());
    }
  }

  /// Fetches a single row from [table]. Returns `{}` if not found.
  Future<Map<String, dynamic>> GET_SINGLE({
    required String table,
    String? select,
    required PostgrestFilterBuilder<PostgrestList> Function(
        PostgrestFilterBuilder<PostgrestList>,
        ) filter,
  }) async {
    try {
      final query = _client.from(table).select(select ?? "*");
      return await filter(query).maybeSingle() ?? {};
    } on PostgrestException catch (e) {
      throw SupaDatabaseException(e.message);
    } catch (e) {
      throw SupaDatabaseException(e.toString());
    }
  }

  /// Inserts a single row into [table]. Returns the inserted row or `{}`.
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
    } on PostgrestException catch (e) {
      throw SupaDatabaseException(e.message);
    } catch (e) {
      throw SupaDatabaseException(e.toString());
    }
  }

  /// Inserts multiple rows into [table]. Returns the inserted rows.
  Future<List<Map<String, dynamic>>> INSERT_MANY({
    required String table,
    required List<Map<String, dynamic>> data,
    String? select,
  }) async {
    try {
      return await _client.from(table).insert(data).select(select ?? "*");
    } on PostgrestException catch (e) {
      throw SupaDatabaseException(e.message);
    } catch (e) {
      throw SupaDatabaseException(e.toString());
    }
  }

  /// Inserts or updates a row in [table] based on the primary key.
  Future<Map<String, dynamic>> UPSERT({
    required String table,
    required Map<String, dynamic> data,
    String? select,
  }) async {
    try {
      return await _client
          .from(table)
          .upsert(data)
          .select(select ?? "*")
          .maybeSingle() ??
          {};
    } on PostgrestException catch (e) {
      throw SupaDatabaseException(e.message);
    } catch (e) {
      throw SupaDatabaseException(e.toString());
    }
  }

  /// Updates rows in [table] where [column] equals [value].
  Future<Map<String, dynamic>> UPDATE({
    required String table,
    required Map<String, dynamic> data,
    required String column,
    required dynamic value,
    String? select,
  }) async {
    try {
      return await _client
          .from(table)
          .update(data)
          .eq(column, value)
          .select(select ?? "*")
          .maybeSingle() ??
          {};
    } on PostgrestException catch (e) {
      throw SupaDatabaseException(e.message);
    } catch (e) {
      throw SupaDatabaseException(e.toString());
    }
  }

  /// Deletes rows from [table] where [column] equals [value].
  Future<void> DELETE({
    required String table,
    required String column,
    required dynamic value,
  }) async {
    try {
      await _client.from(table).delete().eq(column, value);
    } on PostgrestException catch (e) {
      throw SupaDatabaseException(e.message);
    } catch (e) {
      throw SupaDatabaseException(e.toString());
    }
  }

  /// Calls a Postgres function [function] with optional [params].
  Future<dynamic> RPC({
    required String function,
    Map<String, dynamic>? params,
  }) async {
    try {
      return await _client.rpc(function, params: params);
    } on PostgrestException catch (e) {
      throw SupaDatabaseException(e.message);
    } catch (e) {
      throw SupaDatabaseException(e.toString());
    }
  }

  /// Returns the row count of [table]. Use [filter] to count specific rows.
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
    } on PostgrestException catch (e) {
      throw SupaDatabaseException(e.message);
    } catch (e) {
      throw SupaDatabaseException(e.toString());
    }
  }
}