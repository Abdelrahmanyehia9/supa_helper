// ignore_for_file: non_constant_identifier_names
import 'package:supa_helper/src/models/supa_page.dart';
import 'package:supa_helper/src/service/database/supa_database.dart';
import 'package:supa_helper/src/helpers/retry_option.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class SupaDatabaseImpl implements SupaDatabase {
  final PostgrestClient _client;
  final RetryOption retryOption;

  const SupaDatabaseImpl(this._client, {required this.retryOption});

  // ─── helpers ────────────────────────────────────────────────

  List<T> _mapList<T>(
      List<Map<String, dynamic>> result,
      T Function(Map<String, dynamic>)? mapper,
      )
  {
    if (mapper != null) {
      return result.map(mapper).toList();
    }
    if (T==dynamic||T == Map<String, dynamic>) {
      return result.cast<T>();
    }
    throw ArgumentError('Mapper is required for type $T');
  }

  T _mapSingle<T>(
      Map<String, dynamic> result,
      T Function(Map<String, dynamic>)? mapper,
      ) {
    if (mapper != null) {
      return mapper(result);
    }
    if (T== dynamic || T == Map<String, dynamic>) {
      return result as T;
    }
    throw ArgumentError('Mapper is required for type $T');
  }

  // ─── GET ────────────────────────────────────────────────────
@override
  Future<List<T>> GET<T>({
    required String table,
    String? select,
    T Function(Map<String, dynamic>)? mapper,
    PostgrestTransformBuilder<PostgrestList> Function(
        PostgrestFilterBuilder<PostgrestList>,
        )? filter,
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<List<T>>(
      retries: retryAttempt,
          () async {
        final query = _client.from(table).select(select ?? '*');
        final result = await (filter != null ? filter(query) : query);
        return _mapList<T>(result, mapper);
      },
    );
  }

  // ─── GET_SINGLE ─────────────────────────────────────────────

  @override
  Future<T> GET_SINGLE<T>({
    required String table,
    String? select,
    required PostgrestTransformBuilder<PostgrestList> Function(
        PostgrestFilterBuilder<PostgrestList>,
        ) filter,
    T Function(Map<String, dynamic>)? mapper,
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<T>(
      retries: retryAttempt,
          () async {
        final query = _client.from(table).select(select ?? '*');
        final result = await filter(query).maybeSingle() ?? {};
        return _mapSingle<T>(result, mapper);
      },
    );
  }

  // ─── GET_PAGINATED ──────────────────────────────────────────

  @override
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
  }) async {
    return retryOption.withRetry<SupaPage<T>>(
      retries: retryAttempt,
          () async {
        final from = (page - 1) * perPage;
        final to = from + perPage - 1;
        final query = _client.from(table).select(select ?? '*');
        final filtered = filter != null ? filter(query) : query;
        final response =
        await filtered.range(from, to).count(CountOption.exact);
        final int totalCount = response.count;
        final rawList = (response.data as List?)
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList() ??
            [];
        return SupaPage<T>(
          data: _mapList<T>(rawList, mapper),
          totalCount: totalCount,
          hasMore: to < totalCount - 1,
          currentPage: page,
          perPage: perPage,
        );
      },
    );
  }

  // ─── INSERT ─────────────────────────────────────────────────

  @override
  Future<T> INSERT<T>({
    required String table,
    required Map<String, dynamic> data,
    String? select,
    T Function(Map<String, dynamic>)? mapper,
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<T>(
      retries: retryAttempt,
          () async {
        final result = await _client
            .from(table)
            .insert(data)
            .select(select ?? '*')
            .maybeSingle() ??
            {};
        return _mapSingle<T>(result, mapper);
      },
    );
  }

  // ─── INSERT_MANY ────────────────────────────────────────────

  @override
  Future<List<T>> INSERT_MANY<T>({
    required String table,
    required List<Map<String, dynamic>> data,
    String? select,
    T Function(Map<String, dynamic>)? mapper,
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<List<T>>(
      retries: retryAttempt,
          () async {
        final result =
        await _client.from(table).insert(data).select(select ?? '*');
        return _mapList<T>(result, mapper);
      },
    );
  }

  // ─── UPDATE ─────────────────────────────────────────────────

  @override
  Future<T> UPDATE<T>({
    required String table,
    required Map<String, dynamic> data,
    String? select,
    String idColumn = 'id',
    required String idValue,
    T Function(Map<String, dynamic>)? mapper,
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<T>(
      retries: retryAttempt,
          () async {
        final result = await _client
            .from(table)
            .update(data)
            .eq(idColumn, idValue)
            .select(select ?? '*')
            .maybeSingle() ??
            {};
        return _mapSingle<T>(result, mapper);
      },
    );
  }

  // ─── UPSERT ─────────────────────────────────────────────────

  @override
  Future<T> UPSERT<T>({
    required String table,
    required Map<String, dynamic> data,
    String? select,
    String idColumn = 'id',
    required String idValue,
    T Function(Map<String, dynamic>)? mapper,
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<T>(
      retries: retryAttempt,
          () async {
        final result = await _client
            .from(table)
            .upsert(data)
            .eq(idColumn, idValue)
            .select(select ?? '*')
            .maybeSingle() ??
            {};
        return _mapSingle<T>(result, mapper);
      },
    );
  }

  // ─── DELETE ─────────────────────────────────────────────────

  @override
  Future<void> DELETE({
    required String table,
    required PostgrestFilterBuilder<void> Function(
        PostgrestFilterBuilder<void>,
        ) filter,
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<void>(
      retries: retryAttempt,
          () async {
        final query = _client.from(table).delete();
        await filter(query);
      },
    );
  }

  // ─── DELETE_MANY ────────────────────────────────────────────

  @override
  Future<void> DELETE_MANY({
    required String table,
    required List<String> ids,
    String idColumn = 'id',
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<void>(
      retries: retryAttempt,
          () async {
        await _client.from(table).delete().inFilter(idColumn, ids);
      },
    );
  }

  // ─── EXISTS ─────────────────────────────────────────────────

  @override
  Future<bool> EXISTS({
    required String table,
    required PostgrestFilterBuilder<PostgrestList> Function(
        PostgrestFilterBuilder<PostgrestList>,
        ) filter,
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<bool>(
      retries: retryAttempt,
          () async {
        final query = _client.from(table).select();
        final response =
        await filter(query).limit(1).count(CountOption.exact);
        return response.count > 0;
      },
    );
  }

  // ─── COUNT ──────────────────────────────────────────────────

  @override
  Future<int> COUNT({
    required String table,
    CountOption countOption = CountOption.exact,
    PostgrestFilterBuilder<int> Function(
        PostgrestFilterBuilder<int>,
        )? filter,
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<int>(
      retries: retryAttempt,
          () async {
        final query = _client.from(table).count(countOption);
        return filter != null ? await filter(query) : await query;
      },
    );
  }

  // ─── RPC ────────────────────────────────────────────────────

  @override
  Future<dynamic> RPC({
    required String function,
    Map<String, dynamic>? params,
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<dynamic>(
      retries: retryAttempt,
          () async {
        return await _client.rpc(function, params: params);
      },
    );
  }
}