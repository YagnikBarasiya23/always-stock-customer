import '../../../../config/api/api_services.dart';
import '../../../../config/constants/url_constants.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/paged_result.dart';
import '../models/inventory_transaction_model.dart';
import '../models/stock_change_result_model.dart';

abstract class InventoryRepository {
  /// POST /inventory/add-stock → { product, transaction }.
  /// [type] may be [TransactionType.add] (default) or [TransactionType.returned].
  static Future<StockChangeResultModel> addStock({
    required String productId,
    required double quantity,
    String? reason,
    TransactionType? type,
  }) async {
    final result = await ApiServices.post(
      UrlConstants.inventoryAddStock,
      data: {
        'productId': productId,
        'quantity': quantity,
        'reason': ?reason,
        'type': ?type?.value,
      },
    );
    return StockChangeResultModel.fromJson(AppUtils.parseMap(result.data));
  }

  /// POST /inventory/remove-stock → { product, transaction }.
  /// [type] may be [TransactionType.remove] (default) or [TransactionType.damaged].
  static Future<StockChangeResultModel> removeStock({
    required String productId,
    required double quantity,
    String? reason,
    TransactionType? type,
  }) async {
    final result = await ApiServices.post(
      UrlConstants.inventoryRemoveStock,
      data: {
        'productId': productId,
        'quantity': quantity,
        'reason': ?reason,
        'type': ?type?.value,
      },
    );
    return StockChangeResultModel.fromJson(AppUtils.parseMap(result.data));
  }

  /// POST /inventory/adjust-stock → { product, transaction }. [reason] is required.
  static Future<StockChangeResultModel> adjustStock({
    required String productId,
    required double newStock,
    required String reason,
  }) async {
    final result = await ApiServices.post(
      UrlConstants.inventoryAdjustStock,
      data: {'productId': productId, 'newStock': newStock, 'reason': reason},
    );
    return StockChangeResultModel.fromJson(AppUtils.parseMap(result.data));
  }

  /// POST /inventory/history → { transactions } + meta.
  static Future<PagedResult<InventoryTransactionModel>> history({
    int page = 1,
    int limit = 20,
    String? productId,
    TransactionType? type,
    DateTime? from,
    DateTime? to,
  }) async {
    final result = await ApiServices.post(
      UrlConstants.inventoryHistory,
      data: {
        'page': page,
        'limit': limit,
        'productId': ?productId,
        'type': ?type?.value,
        'from': ?from?.toIso8601String(),
        'to': ?to?.toIso8601String(),
      },
    );
    return PagedResult.from(result, 'transactions', InventoryTransactionModel.fromJson);
  }
}
