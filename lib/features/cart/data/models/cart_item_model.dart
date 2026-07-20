/// PROVISIONAL: backend not implemented; field shapes are a pragmatic guess
/// based on UrlConstants.cartDetail / cartAddItem / cartUpdateItemQuantity.
library;

import '../../../../core/utils/app_utils.dart';

class CartItemModel {
  final String id;
  final String productId;
  final String? variantId;
  final String name;
  final String? imageUrl;
  final String unitLabel;
  final int quantity;
  final double mrp;
  final double sellingPrice;
  final double lineTotal;
  final bool inStock;

  const CartItemModel({
    required this.id,
    required this.productId,
    this.variantId,
    required this.name,
    this.imageUrl,
    this.unitLabel = '',
    this.quantity = 1,
    this.mrp = 0,
    this.sellingPrice = 0,
    this.lineTotal = 0,
    this.inStock = true,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: AppUtils.parseString(json['_id']) ?? '',
      productId: AppUtils.parseString(json['productId']) ?? '',
      variantId: AppUtils.parseString(json['variantId']),
      name: AppUtils.parseString(json['name']) ?? '',
      imageUrl: AppUtils.parseString(json['imageUrl']),
      unitLabel: AppUtils.parseString(json['unitLabel']) ?? '',
      quantity: AppUtils.parseInt(json['quantity']) ?? 1,
      mrp: AppUtils.parseDouble(json['mrp']) ?? 0,
      sellingPrice: AppUtils.parseDouble(json['sellingPrice']) ?? 0,
      lineTotal: AppUtils.parseDouble(json['lineTotal']) ?? 0,
      inStock: AppUtils.parseBool(json['inStock']) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productId': productId,
      'variantId': variantId,
      'name': name,
      'imageUrl': imageUrl,
      'unitLabel': unitLabel,
      'quantity': quantity,
      'mrp': mrp,
      'sellingPrice': sellingPrice,
      'lineTotal': lineTotal,
      'inStock': inStock,
    };
  }

  CartItemModel copyWith({
    String? id,
    String? productId,
    String? variantId,
    String? name,
    String? imageUrl,
    String? unitLabel,
    int? quantity,
    double? mrp,
    double? sellingPrice,
    double? lineTotal,
    bool? inStock,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      unitLabel: unitLabel ?? this.unitLabel,
      quantity: quantity ?? this.quantity,
      mrp: mrp ?? this.mrp,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      lineTotal: lineTotal ?? this.lineTotal,
      inStock: inStock ?? this.inStock,
    );
  }
}
