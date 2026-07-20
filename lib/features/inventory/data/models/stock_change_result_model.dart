import '../../../../core/utils/app_utils.dart';
import '../../../products/data/models/product_model.dart';
import 'inventory_transaction_model.dart';

/// Response of `/inventory/add-stock`, `/inventory/remove-stock` and
/// `/inventory/adjust-stock`: `{ product, transaction }`.
class StockChangeResultModel {
  final ProductModel product;
  final InventoryTransactionModel transaction;

  const StockChangeResultModel({required this.product, required this.transaction});

  factory StockChangeResultModel.fromJson(Map<String, dynamic> json) {
    return StockChangeResultModel(
      product: ProductModel.fromJson(AppUtils.parseMap(json['product'])),
      transaction: InventoryTransactionModel.fromJson(AppUtils.parseMap(json['transaction'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'transaction': transaction.toJson(),
    };
  }
}
