/// PROVISIONAL: backend not implemented; field shapes are a pragmatic guess
/// based on UrlConstants.orderItems.
library;

import '../../../../core/utils/app_utils.dart';

enum OrderItemStatus {
  pending('pending'),
  confirmed('confirmed'),
  packed('packed'),
  outForDelivery('out_for_delivery'),
  delivered('delivered'),
  cancelled('cancelled'),
  unknown('unknown');

  const OrderItemStatus(this.value);

  final String value;

  static OrderItemStatus fromValue(String? value) =>
      values.firstWhere((e) => e.value == value, orElse: () => unknown);
}

class OrderItemModel {
  final String id;
  final String? orderId;
  final String productId;
  final String name;
  final String? imageUrl;
  final String unitLabel;
  final int quantity;
  final double price;
  final double lineTotal;
  final OrderItemStatus status;
  final DateTime? orderedAt;

  const OrderItemModel({
    required this.id,
    this.orderId,
    required this.productId,
    required this.name,
    this.imageUrl,
    this.unitLabel = '',
    this.quantity = 1,
    this.price = 0,
    this.lineTotal = 0,
    this.status = OrderItemStatus.pending,
    this.orderedAt,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: AppUtils.parseString(json['_id']) ?? '',
      orderId: AppUtils.parseString(json['orderId']),
      productId: AppUtils.parseString(json['productId']) ?? '',
      name: AppUtils.parseString(json['name']) ?? '',
      imageUrl: AppUtils.parseString(json['imageUrl']),
      unitLabel: AppUtils.parseString(json['unitLabel']) ?? '',
      quantity: AppUtils.parseInt(json['quantity']) ?? 1,
      price: AppUtils.parseDouble(json['price']) ?? 0,
      lineTotal: AppUtils.parseDouble(json['lineTotal']) ?? 0,
      status: OrderItemStatus.fromValue(AppUtils.parseString(json['status'])),
      orderedAt: AppUtils.parseDateTime(json['orderedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'orderId': orderId,
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'unitLabel': unitLabel,
      'quantity': quantity,
      'price': price,
      'lineTotal': lineTotal,
      'status': status.value,
      'orderedAt': orderedAt?.toIso8601String(),
    };
  }
}
