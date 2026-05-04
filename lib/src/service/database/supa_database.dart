import 'package:supa_helper/src/models/supa_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore_for_file: non_constant_identifier_names

/// A unified interface for all Supabase database operations.
///
/// Every method supports:
/// - **[mapper]** — converts raw `Map<String, dynamic>` into a typed model.
///   If omitted, `T` must be `Map<String, dynamic>`.
/// - **[retryAttempt]** — overrides the global retry count for this call only.
///
/// All methods throw [SupaDatabaseException] on failure.
abstract class SupaDatabase {
  /// Fetches all rows from [table] that match the optional [filter].
  ///
  /// - [select] — comma-separated columns to return. Defaults to `'*'`.
  /// - [filter] — chain `.eq()`, `.order()`, `.limit()`, etc.
  /// - [mapper] — maps each row to [T]. Required when `T` is not `Map<String, dynamic>`.
  ///
  /// ```dart
  /// // raw
  /// final rows = await db.GET(table: 'orders');
  ///
  /// // typed
  /// final orders = await db.GET<Order>(
  ///   table: 'orders',
  ///   filter: (q) => q.eq('status', 'pending').order('created_at'),
  ///   mapper: Order.fromJson,
  /// );
  /// ```
  Future<List<T>> GET<T>({
    required String table,
    String? select,
    T Function(Map<String, dynamic>)? mapper,
    PostgrestTransformBuilder<PostgrestList> Function(
        PostgrestFilterBuilder<PostgrestList>,
        )? filter,
    int? retryAttempt,
  });

  /// Fetches a single row from [table] matching the [filter].
  ///
  /// Returns `{}` (empty map) when no row is found.
  /// Use [mapper] to get a typed model instead of a raw map.
  ///
  /// ```dart
  /// // raw
  /// final row = await db.GET_SINGLE(
  ///   table: 'users',
  ///   filter: (q) => q.eq('id', '123'),
  /// );
  ///
  /// // typed
  /// final user = await db.GET_SINGLE<User>(
  ///   table: 'users',
  ///   filter: (q) => q.eq('id', '123'),
  ///   mapper: User.fromJson,
  /// );
  /// ```
  Future<T> GET_SINGLE<T>({
    required String table,
    String? select,
    required PostgrestTransformBuilder<PostgrestList> Function(
        PostgrestFilterBuilder<PostgrestList>,
        ) filter,
    T Function(Map<String, dynamic>)? mapper,
    int? retryAttempt,
  });

  /// Fetches a paginated slice of rows from [table].
  ///
  /// - [page] — 1-based page number.
  /// - [perPage] — number of rows per page. Defaults to `20`.
  ///
  /// Returns a [SupaPage<T>] containing:
  /// - `data` — the rows for this page.
  /// - `totalCount` — total number of matching rows.
  /// - `hasMore` — whether a next page exists.
  ///
  /// ```dart
  /// final page = await db.GET_PAGINATED<Order>(
  ///   table: 'orders',
  ///   page: 1,
  ///   perPage: 20,
  ///   mapper: Order.fromJson,
  /// );
  ///
  /// print(page.data);       // List<Order>
  /// print(page.totalCount); // 87
  /// print(page.hasMore);    // true
  /// ```
  Future<SupaPage<T>> GET_PAGINATED<T>({
    required String table,
    required int page,
    int perPage = 20,
    String? select,
    T Function(Map<String, dynamic>)? mapper,
    PostgrestTransformBuilder<PostgrestList> Function(
        PostgrestFilterBuilder<PostgrestList>,
        )? filter,
    int? retryAttempt,
  });

  /// Inserts a single row into [table] and returns the inserted row.
  ///
  /// Returns `{}` if the server returns no data.
  ///
  /// ```dart
  /// // raw
  /// final row = await db.INSERT(
  ///   table: 'users',
  ///   data: {'name': 'John', 'email': 'john@example.com'},
  /// );
  ///
  /// // typed
  /// final user = await db.INSERT<User>(
  ///   table: 'users',
  ///   data: {'name': 'John', 'email': 'john@example.com'},
  ///   mapper: User.fromJson,
  /// );
  /// ```
  Future<T> INSERT<T>({
    required String table,
    required Map<String, dynamic> data,
    String? select,
    T Function(Map<String, dynamic>)? mapper,
    int? retryAttempt,
  });

  /// Inserts multiple rows into [table] and returns the inserted rows.
  ///
  /// ```dart
  /// final users = await db.INSERT_MANY<User>(
  ///   table: 'users',
  ///   data: [
  ///     {'name': 'Alice'},
  ///     {'name': 'Bob'},
  ///   ],
  ///   mapper: User.fromJson,
  /// );
  /// ```
  Future<List<T>> INSERT_MANY<T>({
    required String table,
    required List<Map<String, dynamic>> data,
    String? select,
    T Function(Map<String, dynamic>)? mapper,
    int? retryAttempt,
  });

  /// Updates the row in [table] where [idColumn] equals [idValue].
  ///
  /// Returns the updated row, or `{}` if nothing was updated.
  ///
  /// ```dart
  /// final user = await db.UPDATE<User>(
  ///   table: 'users',
  ///   idValue: '123',
  ///   data: {'name': 'John Updated'},
  ///   mapper: User.fromJson,
  /// );
  /// ```
  Future<T> UPDATE<T>({
    required String table,
    required Map<String, dynamic> data,
    String? select,
    String idColumn = 'id',
    required String idValue,
    T Function(Map<String, dynamic>)? mapper,
    int? retryAttempt,
  });

  /// Inserts or updates a row in [table] based on the primary key.
  ///
  /// If a row with [idValue] exists it is updated; otherwise a new row is inserted.
  /// Returns the resulting row, or `{}` if the server returns no data.
  ///
  /// ```dart
  /// final user = await db.UPSERT<User>(
  ///   table: 'users',
  ///   idValue: '123',
  ///   data: {'id': '123', 'name': 'John'},
  ///   mapper: User.fromJson,
  /// );
  /// ```
  Future<T> UPSERT<T>({
    required String table,
    required Map<String, dynamic> data,
    String? select,
    String idColumn = 'id',
    required String idValue,
    T Function(Map<String, dynamic>)? mapper,
    int? retryAttempt,
  });

  /// Deletes rows from [table] that match the [filter].
  ///
  /// ```dart
  /// await db.DELETE(
  ///   table: 'orders',
  ///   filter: (q) => q.eq('status', 'cancelled'),
  /// );
  /// ```
  Future<void> DELETE({
    required String table,
    required PostgrestFilterBuilder<void> Function(
        PostgrestFilterBuilder<void>,
        ) filter,
    int? retryAttempt,
  });

  /// Deletes multiple rows from [table] by their IDs.
  ///
  /// Uses an `IN` filter on [idColumn] (defaults to `'id'`).
  ///
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

  /// Returns `true` if at least one row in [table] matches the [filter].
  ///
  /// ```dart
  /// final taken = await db.EXISTS(
  ///   table: 'users',
  ///   filter: (q) => q.eq('email', 'john@example.com'),
  /// );
  /// ```
  Future<bool> EXISTS({
    required String table,
    required PostgrestFilterBuilder<PostgrestList> Function(
        PostgrestFilterBuilder<PostgrestList>,
        ) filter,
    int? retryAttempt,
  });

  /// Returns the number of rows in [table].
  ///
  /// Use [filter] to count only rows matching a condition.
  /// [countOption] defaults to [CountOption.exact].
  ///
  /// ```dart
  /// final total = await db.COUNT(table: 'users');
  ///
  /// final admins = await db.COUNT(
  ///   table: 'users',
  ///   filter: (q) => q.eq('role', 'admin'),
  /// );
  /// ```
  Future<int> COUNT({
    required String table,
    CountOption countOption = CountOption.exact,
    PostgrestFilterBuilder<int> Function(
        PostgrestFilterBuilder<int>,
        )? filter,
    int? retryAttempt,
  });

  /// Calls a Postgres function [function] with optional [params].
  ///
  /// Returns the raw response from Supabase — cast or map as needed.
  ///
  /// ```dart
  /// final result = await db.RPC(
  ///   function: 'get_user_stats',
  ///   params: {'user_id': '123'},
  /// );
  /// ```
  Future<dynamic> RPC({
    required String function,
    Map<String, dynamic>? params,
    int? retryAttempt,
  });
}