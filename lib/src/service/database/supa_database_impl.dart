// ignore_for_file: non_constant_identifier_names
import 'package:supa_helper/src/models/supa_page.dart';
import 'package:supa_helper/src/service/database/supa_database.dart';
import 'package:supa_helper/src/helpers/retry_option.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class SupaDatabaseImpl implements SupaDatabase {
  final PostgrestClient _client;
  final RetryOption retryOption;

  const SupaDatabaseImpl(this._client, {required this.retryOption});

  @override
  Future<List<Map<String, dynamic>>> GET({
    required String table,
    String? select,
    PostgrestTransformBuilder<PostgrestList> Function(
        PostgrestFilterBuilder<PostgrestList>,
        )? filter,
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<List<Map<String, dynamic>>>(
      retries: retryAttempt,
          () async {
        final query = _client.from(table).select(select ?? '*');
        return List<Map<String, dynamic>>.from(
          await (filter != null ? filter(query) : query),
        );
      },
    );
  }

  @override
  Future<Map<String, dynamic>> GET_SINGLE({
    required String table,
    String? select,
    required PostgrestTransformBuilder<PostgrestList> Function(
        PostgrestFilterBuilder<PostgrestList>,
        ) filter,
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<Map<String, dynamic>>(
      retries: retryAttempt,
          () async {
        final query = _client.from(table).select(select ?? '*');
        return await filter(query).maybeSingle() ?? {};
      },
    );
  }

  @override
  Future<SupaPage> GET_PAGINATED({
    required String table,
    required int page,
    int perPage = 20,
    String? select,
    PostgrestTransformBuilder<PostgrestList> Function(
        PostgrestFilterBuilder<PostgrestList>,
        )? filter,
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<SupaPage>(
      retries: retryAttempt,
          () async {
        final from = (page - 1) * perPage;
        final to = from + perPage - 1;
        final query = _client.from(table).select(select ?? '*');
        final filtered = filter != null ? filter(query) : query;
        final response = await filtered.range(from, to).count(CountOption.exact);
        final int totalCount = response.count;
        final data = (response.data as List?)
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList() ??
            [];
        return SupaPage(
          data: data,
          totalCount: totalCount,
          hasMore: to < totalCount - 1,
          currentPage: page,
          perPage: perPage,
        );
      },
    );
  }

  @override
  Future<Map<String, dynamic>> INSERT({
    required String table,
    required Map<String, dynamic> data,
    String? select,
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<Map<String, dynamic>>(
      retries: retryAttempt,
          () async {
        return await _client
            .from(table)
            .insert(data)
            .select(select ?? '*')
            .maybeSingle() ??
            {};
      },
    );
  }

  @override
  Future<List<Map<String, dynamic>>> INSERT_MANY({
    required String table,
    required List<Map<String, dynamic>> data,
    String? select,
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<List<Map<String, dynamic>>>(
      retries: retryAttempt,
          () async {
        return await _client.from(table).insert(data).select(select ?? '*');
      },
    );
  }

  @override
  Future<Map<String, dynamic>> UPDATE({
    required String table,
    required Map<String, dynamic> data,
    String? select,
    String idColumn = 'id',
    required String idValue,
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<Map<String, dynamic>>(
      retries: retryAttempt,
          () async {
        return await _client
            .from(table)
            .update(data)
            .eq(idColumn, idValue)
            .select(select ?? '*')
            .maybeSingle() ??
            {};
      },
    );
  }

  @override
  Future<Map<String, dynamic>> UPSERT({
    required String table,
    required Map<String, dynamic> data,
    String? select,
    String idColumn = 'id',
    required String idValue,
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<Map<String, dynamic>>(
      retries: retryAttempt,
          () async {
        return await _client
            .from(table)
            .upsert(data)
            .eq(idColumn, idValue)
            .select(select ?? '*')
            .maybeSingle() ??
            {};
      },
    );
  }

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
        final response = await filter(query).limit(1).count(CountOption.exact);
        return response.count > 0;
      },
    );
  }

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
}