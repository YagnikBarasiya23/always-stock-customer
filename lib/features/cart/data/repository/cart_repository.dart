/// PROVISIONAL: backend not implemented; request/response shapes are a
/// pragmatic guess based on the UrlConstants cart endpoints. All four
/// endpoints are assumed to return the full cart.
library;

import '../../../../config/api/api_services.dart';
import '../../../../config/constants/url_constants.dart';
import '../../../../core/utils/app_utils.dart';
import '../models/cart_model.dart';

abstract class CartRepository {
  /// POST /cart/detail → cart.
  static Future<CartModel> detail() async {
    final result = await ApiServices.post(UrlConstants.cartDetail, data: {});
    return _cartFrom(result.data);
  }

  /// POST /cart/add-item → updated cart.
  static Future<CartModel> addItem({
    required String productId,
    String? variantId,
    int quantity = 1,
  }) async {
    final result = await ApiServices.post(
      UrlConstants.cartAddItem,
      data: {
        'productId': productId,
        'variantId': ?variantId,
        'quantity': quantity,
      },
    );
    return _cartFrom(result.data);
  }

  /// POST /cart/update-item-quantity → updated cart.
  static Future<CartModel> updateItemQuantity({
    required String itemId,
    required int quantity,
  }) async {
    final result = await ApiServices.post(
      UrlConstants.cartUpdateItemQuantity,
      data: {'itemId': itemId, 'quantity': quantity},
    );
    return _cartFrom(result.data);
  }

  /// POST /cart/remove-item → updated cart.
  static Future<CartModel> removeItem({required String itemId}) async {
    final result = await ApiServices.post(UrlConstants.cartRemoveItem, data: {'itemId': itemId});
    return _cartFrom(result.data);
  }

  static CartModel _cartFrom(dynamic data) {
    final map = AppUtils.parseMap(data);
    return CartModel.fromJson(
      map['cart'] is Map<String, dynamic> ? map['cart'] as Map<String, dynamic> : map,
    );
  }
}
