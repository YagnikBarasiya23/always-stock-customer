/// PROVISIONAL: backend not implemented; field shapes are a pragmatic guess
/// based on UrlConstants.cartDetail — all four cart endpoints are assumed to
/// return the full cart.
library;

import '../../../../core/utils/app_utils.dart';
import 'cart_item_model.dart';

class CartModel {
  final String id;
  final List<CartItemModel> items;
  final int itemCount;
  final double subtotal;
  final double discountTotal;
  final double deliveryFee;
  final double grandTotal;

  const CartModel({
    required this.id,
    this.items = const [],
    this.itemCount = 0,
    this.subtotal = 0,
    this.discountTotal = 0,
    this.deliveryFee = 0,
    this.grandTotal = 0,
  });

  bool get isEmpty => items.isEmpty;

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: AppUtils.parseString(json['_id']) ?? '',
      items: AppUtils.parseObjectList(json['items'], CartItemModel.fromJson),
      itemCount: AppUtils.parseInt(json['itemCount']) ?? 0,
      subtotal: AppUtils.parseDouble(json['subtotal']) ?? 0,
      discountTotal: AppUtils.parseDouble(json['discountTotal']) ?? 0,
      deliveryFee: AppUtils.parseDouble(json['deliveryFee']) ?? 0,
      grandTotal: AppUtils.parseDouble(json['grandTotal']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'items': items.map((e) => e.toJson()).toList(),
      'itemCount': itemCount,
      'subtotal': subtotal,
      'discountTotal': discountTotal,
      'deliveryFee': deliveryFee,
      'grandTotal': grandTotal,
    };
  }

  CartModel copyWith({
    String? id,
    List<CartItemModel>? items,
    int? itemCount,
    double? subtotal,
    double? discountTotal,
    double? deliveryFee,
    double? grandTotal,
  }) {
    return CartModel(
      id: id ?? this.id,
      items: items ?? this.items,
      itemCount: itemCount ?? this.itemCount,
      subtotal: subtotal ?? this.subtotal,
      discountTotal: discountTotal ?? this.discountTotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      grandTotal: grandTotal ?? this.grandTotal,
    );
  }
}
