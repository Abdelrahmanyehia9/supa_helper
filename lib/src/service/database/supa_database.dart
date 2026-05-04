import 'package:supa_helper/src/models/supa_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore_for_file: non_constant_identifier_names

/// A helper class that simplifies CRUD database operations with Supabase.
abstract class SupaDatabase {
  /// Fetches multiple rows from [table].
  /// Use [filter] for filtering, ordering, or pagination.
  Future<List<Map<String, dynamic>>> GET({
    required String table,
    String? select,

    PostgrestFilterBuilder<PostgrestList> Function(
        PostgrestFilterBuilder<PostgrestList>,
        )? filter,
    int? retryAttempt,
  });

  /// Fetches a single row from [table]. Returns `{}` if not found.
  Future<Map<String, dynamic>> GET_SINGLE({
    required String table,
    String? select,
    required PostgrestTransformBuilder<PostgrestList> Function(
        PostgrestFilterBuilder<PostgrestList>,
        ) filter,
    int? retryAttempt,
  });

  /// Fetches a paginated list of rows from [table].
  Future<SupaPage> GET_PAGINATED({
    required String table,
    required int page,
    int perPage = 20,
    String? select,
    PostgrestTransformBuilder<PostgrestList> Function(
        PostgrestFilterBuilder<PostgrestList>,
        )? filter,
    int? retryAttempt,
  });

  /// Deletes multiple rows from [table] by their IDs.
  ///
  /// Example:
  /// ```dart
  /// await db.DELETE_MANY(
  ///   table: 'orders',
  ///   ids: ['1', '2', '3'],
  /// );
  /// ```
  Future<void> DELETE_MANY({
    required String table,
    required List<String> ids,
    String idColumn = 'id',
    int? retryAttempt,
  });

  /// Returns true if a row exists in [table] matching the [filter].
  ///
  /// Example:
  /// ```dart
  /// final exists = await db.EXISTS(
  ///   table: 'users',
  ///   filter: (q) => q.eq('email', 'test@test.com'),
  /// );
  /// ```
  Future<bool> EXISTS({
    required String table,
    required PostgrestFilterBuilder<PostgrestList> Function(
        PostgrestFilterBuilder<PostgrestList>,
        ) filter,
    int? retryAttempt,
  });

  /// Inserts a single row into [table]. Returns the inserted row or `{}`.
  Future<Map<String, dynamic>> INSERT({
    required String table,
    required Map<String, dynamic> data,
    String? select,
    int? retryAttempt,
  });

  /// Inserts multiple rows into [table]. Returns the inserted rows.
  Future<List<Map<String, dynamic>>> INSERT_MANY({
    required String table,
    required List<Map<String, dynamic>> data,
    String? select,
    int? retryAttempt,
  });

  /// Inserts or updates a row in [table] based on the primary key.
  Future<Map<String, dynamic>> UPSERT({
    required String table,
    required Map<String, dynamic> data,
    String? select,
    String idColumn = 'id',
    required String idValue,
    int? retryAttempt,
  });

  /// Updates rows in [table] where [idColumn] equals [idValue].
  Future<Map<String, dynamic>> UPDATE({
    required String table,
    required Map<String, dynamic> data,
    String? select,
    String idColumn = 'id',
    required String idValue,
    int? retryAttempt,
  });

  /// Deletes rows from [table] using a custom filter.
  Future<void> DELETE({
    required String table,
    required PostgrestFilterBuilder<PostgrestList> Function(
        PostgrestTransformBuilder<void>,
        ) filter,
    int? retryAttempt,
  });

  /// Calls a Postgres function [function] with optional [params].
  Future<dynamic> RPC({
    required String function,
    Map<String, dynamic>? params,
    int? retryAttempt,
  });

  /// Returns the row count of [table]. Use [filter] to count specific rows.
  Future<int> COUNT({
    required String table,
    CountOption countOption = CountOption.exact,
    PostgrestFilterBuilder<int> Function(
        PostgrestFilterBuilder<int>,
        )? filter,
    int? retryAttempt,
  });
}