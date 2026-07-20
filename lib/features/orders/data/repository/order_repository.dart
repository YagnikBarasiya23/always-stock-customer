/// PROVISIONAL: backend not implemented; request/response shapes are a
/// pragmatic guess based on UrlConstants.orderItems.
library;

import '../../../../config/api/api_services.dart';
import '../../../../config/constants/url_constants.dart';
import '../../../../core/utils/paged_result.dart';
import '../models/order_item_model.dart';

abstract class OrderRepository {
  /// POST /order-items/list → { orderItems } + meta.
  static Future<PagedResult<OrderItemModel>> listOrderItems({
    int page = 1,
    int limit = 20,
    String? orderId,
  }) async {
    final result = await ApiServices.post(
      UrlConstants.orderItems,
      data: {
        'page': page,
        'limit': limit,
        'orderId': ?orderId,
      },
    );
    return PagedResult.from(result, 'orderItems', OrderItemModel.fromJson);
  }
}
