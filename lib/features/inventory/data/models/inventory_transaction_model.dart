import '../../../../core/utils/app_utils.dart';

enum TransactionType {
  add('add'),
  remove('remove'),
  adjust('adjust'),
  initial('initial'),
  damaged('damaged'),
  returned('returned'),
  transfer('transfer'),
  unknown('unknown');

  const TransactionType(this.value);

  final String value;

  static TransactionType fromValue(String? value) =>
      values.firstWhere((e) => e.value == value, orElse: () => unknown);
}

/// Ref fields (productId, performedBy) may arrive populated as objects.
String _refId(dynamic value) => AppUtils.parseRefId(value) ?? '';

class InventoryTransactionModel {
  final String id;
  final String businessId;
  final String productId;
  final TransactionType type;
  final double quantity;
  final double previousStock;
  final double newStock;
  final String? reason;
  final String? warehouseId;
  final String performedBy;
  final DateTime? createdAt;

  const InventoryTransactionModel({
    required this.id,
    required this.businessId,
    required this.productId,
    required this.type,
    required this.quantity,
    this.previousStock = 0,
    this.newStock = 0,
    this.reason,
    this.warehouseId,
    this.performedBy = '',
    this.createdAt,
  });

  factory InventoryTransactionModel.fromJson(Map<String, dynamic> json) {
    return InventoryTransactionModel(
      id: AppUtils.parseString(json['_id']) ?? '',
      businessId: AppUtils.parseString(json['businessId']) ?? '',
      productId: _refId(json['productId']),
      type: TransactionType.fromValue(AppUtils.parseString(json['type'])),
      quantity: AppUtils.parseDouble(json['quantity']) ?? 0,
      previousStock: AppUtils.parseDouble(json['previousStock']) ?? 0,
      newStock: AppUtils.parseDouble(json['newStock']) ?? 0,
      reason: AppUtils.parseString(json['reason']),
      warehouseId: AppUtils.parseString(json['warehouseId']),
      performedBy: _refId(json['performedBy']),
      createdAt: AppUtils.parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'businessId': businessId,
      'productId': productId,
      'type': type.value,
      'quantity': quantity,
      'previousStock': previousStock,
      'newStock': newStock,
      'reason': reason,
      'warehouseId': warehouseId,
      'performedBy': performedBy,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
