import 'api_response_handler.dart';
import 'app_utils.dart';

/// A typed page of items plus the pagination info from the response envelope.
class PagedResult<T> {
  final List<T> items;
  final Pagination? pagination;

  const PagedResult({this.items = const [], this.pagination});

  /// Builds a page from an [ApiResult] whose data holds the list under [key].
  /// Falls back to a raw list payload or an `items` key.
  factory PagedResult.from(ApiResult result, String key, T Function(Map<String, dynamic>) fromJson) {
    return PagedResult(
      items: itemsOf(result.data, key, fromJson),
      pagination: result.pagination,
    );
  }

  static List<E> itemsOf<E>(dynamic data, String key, E Function(Map<String, dynamic>) fromJson) {
    if (data is List) return AppUtils.parseObjectList(data, fromJson);
    final map = AppUtils.parseMap(data);
    return AppUtils.parseObjectList(map[key] ?? map['items'], fromJson);
  }
}
