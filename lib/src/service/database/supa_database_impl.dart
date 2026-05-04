// ignore_for_file: non_constant_identifier_names
import 'package:supa_helper/src/errors/handle_error.dart';
import 'package:supa_helper/src/models/supa_page.dart';
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
  /// Fetches a paginated list of rows from [table].
  ///
  /// [page] starts from 1.
  /// [perPage] defaults to 20 rows per page.
  /// Use [filter] to filter or order results.
  ///
  /// Example:
  /// ```dart
  /// final result = await db.GET_PAGINATED(
  ///   table: 'orders',
  ///   page: 1,
  ///   perPage: 20,
  ///   filter: (q) => q.eq('status', 'pending'),
  /// );
  /// print(result.hasMore); // true if there are more pages
  /// ```
  Future<SupaPage> GET_PAGINATED({
    required String table,
    required int page,
    int perPage = 20,
    String? select,
    PostgrestTransformBuilder<PostgrestList> Function(
        PostgrestFilterBuilder<PostgrestList>,
        )? filter,
  }) async {
    try {
      // calculate the range based on page number and perPage
      final from = (page - 1) * perPage;
      final to = from + perPage - 1;
      final query = _client.from(table).select(select ?? '*');
      // apply filter if provided, otherwise use the base query
      final filtered = filter != null ? filter(query) : query;
      // fetch the data with range and total count
      final response = await filtered.range(from, to).count(CountOption.exact);
      final int totalCount = response.count;
      final data = (response.data as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList() ??
          [];
      return SupaPage(
        data: data,
        totalCount: totalCount,
        // hasMore is true if the last row of this page is before the last row overall
        hasMore: to < totalCount - 1,
        currentPage: page,
        perPage: perPage,
      );
    } catch (e) {
      e.handleError();
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

// DELETE_MANY
  @override
  Future<void> DELETE_MANY({
    required String table,
    required List<String> ids,
    String idColumn = 'id',
  }) async {
    try {
      await _client.from(table).delete().inFilter(idColumn, ids);
    } catch (e) {
      e.handleError();
    }
  }

// EXISTS
  @override
  Future<bool> EXISTS({
    required String table,
    required PostgrestFilterBuilder<PostgrestList> Function(
        PostgrestFilterBuilder<PostgrestList>,
        ) filter,
  }) async {
    try {
      final query = _client.from(table).select();
      final response = await filter(query).limit(1).count(CountOption.exact);
      return response.count > 0;
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