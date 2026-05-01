import 'package:supabase_flutter/supabase_flutter.dart';
// ignore_for_file: non_constant_identifier_names
/// A helper class that simplifies CRUD database operations with Supabase.
abstract class SupaDatabase{
  /// Fetches multiple rows from [table].
  /// Use [filter] for filtering, ordering, or pagination.
  Future<List<Map<String, dynamic>>> GET({
    required String table,
    String? select,
    PostgrestFilterBuilder<PostgrestList> Function(
        PostgrestFilterBuilder<PostgrestList>,
        )? filter,
  }) ;
  /// Fetches a single row from [table]. Returns `{}` if not found.
  Future<Map<String, dynamic>> GET_SINGLE({
    required String table,
    String? select,
    required PostgrestTransformBuilder<PostgrestList> Function(PostgrestFilterBuilder<PostgrestList>) filter
  })  ;
  /// Inserts a single row into [table]. Returns the inserted row or `{}`.
  Future<Map<String, dynamic>> INSERT({
    required String table,
    required Map<String, dynamic> data,
    String? select,
  }) ;
  /// Inserts multiple rows into [table]. Returns the inserted rows.
  Future<List<Map<String, dynamic>>> INSERT_MANY({
    required String table,
    required List<Map<String, dynamic>> data,
    String? select,
  })  ;
  /// Inserts or updates a row in [table] based on the primary key.
  Future<Map<String, dynamic>> UPSERT({
    required String table,
    required Map<String, dynamic> data,
    String? select,
    String idColumn = 'id',
    required String idValue,
  })  ;
  /// Updates rows in [table] where [column] equals [value].
  Future<Map<String, dynamic>> UPDATE({
    required String table,
    required Map<String, dynamic> data,
    String? select,
    String idColumn = 'id',
    required String idValue,
  })  ;
  /// Deletes rows from [table] where [column] equals [value].
  Future<void> DELETE({
    required String table,
    required PostgrestFilterBuilder<PostgrestList> Function(
        PostgrestTransformBuilder<void>,
        ) filter,
  }) ;
  /// Calls a Postgres function [function] with optional [params].
  Future<dynamic> RPC({
    required String function,
    Map<String, dynamic>? params,
  }) ;
  /// Returns the row count of [table]. Use [filter] to count specific rows.
  Future<int> COUNT({
    required String table,
    CountOption countOption = CountOption.exact,
    PostgrestFilterBuilder<int> Function(
        PostgrestFilterBuilder<int>,
        )? filter,
  })  ;
}