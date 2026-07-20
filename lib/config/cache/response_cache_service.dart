import 'dart:convert';

import '../../core/utils/api_response_handler.dart';
import '../local/local_storage_services.dart';

class CachedResponse {
  final dynamic data;
  final Pagination? pagination;
  final DateTime cachedAt;

  const CachedResponse({this.data, this.pagination, required this.cachedAt});
}

abstract class ResponseCacheService {
  static const _prefix = '__resp_cache__:';

  static Future<void> put(String key, {dynamic data, Pagination? pagination}) async {
    final preferences = await LocalStorageServices.instance;
    final envelope = {
      'cachedAt': DateTime.now().millisecondsSinceEpoch,
      'data': data,
      'pagination': pagination == null ? null : _paginationToJson(pagination),
    };
    await preferences.setString('$_prefix$key', jsonEncode(envelope));
  }

  static Future<CachedResponse?> get(String key) async {
    final preferences = await LocalStorageServices.instance;
    final raw = preferences.getString('$_prefix$key');
    if (raw == null) return null;

    final envelope = jsonDecode(raw) as Map<String, dynamic>;
    final paginationJson = envelope['pagination'] as Map<String, dynamic>?;
    return CachedResponse(
      data: envelope['data'],
      pagination: paginationJson == null ? null : Pagination.fromJson(paginationJson),
      cachedAt: DateTime.fromMillisecondsSinceEpoch(envelope['cachedAt'] as int),
    );
  }

  static Future<void> evict(String key) async {
    final preferences = await LocalStorageServices.instance;
    await preferences.remove('$_prefix$key');
  }

  static Future<void> clearAll() async {
    final preferences = await LocalStorageServices.instance;
    final cacheKeys = preferences.getKeys().where((key) => key.startsWith(_prefix));
    for (final key in cacheKeys) {
      await preferences.remove(key);
    }
  }

  static Map<String, dynamic> _paginationToJson(Pagination pagination) => {
    'page': pagination.page,
    'limit': pagination.limit,
    'totalItems': pagination.totalItems,
    'totalPages': pagination.totalPages,
    'hasNextPage': pagination.hasNextPage,
    'hasPrevPage': pagination.hasPrevPage,
  };
}
