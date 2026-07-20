/// PROVISIONAL: backend not implemented; field shapes are a pragmatic guess
/// based on UrlConstants.byCategory / UrlConstants.catalogHome.
library;

import '../../../../core/utils/app_utils.dart';

class CatalogProductModel {
  final String id;
  final String name;
  final String? slug;
  final String? imageUrl;
  final String? brand;
  final String unitLabel;
  final double mrp;
  final double sellingPrice;
  final int discountPercent;
  final bool inStock;
  final int maxQuantityPerOrder;

  const CatalogProductModel({
    required this.id,
    required this.name,
    this.slug,
    this.imageUrl,
    this.brand,
    this.unitLabel = '',
    this.mrp = 0,
    this.sellingPrice = 0,
    this.discountPercent = 0,
    this.inStock = true,
    this.maxQuantityPerOrder = 10,
  });

  factory CatalogProductModel.fromJson(Map<String, dynamic> json) {
    return CatalogProductModel(
      id: AppUtils.parseString(json['_id']) ?? '',
      name: AppUtils.parseString(json['name']) ?? '',
      slug: AppUtils.parseString(json['slug']),
      imageUrl: AppUtils.parseString(json['imageUrl']),
      brand: AppUtils.parseString(json['brand']),
      unitLabel: AppUtils.parseString(json['unitLabel']) ?? '',
      mrp: AppUtils.parseDouble(json['mrp']) ?? 0,
      sellingPrice: AppUtils.parseDouble(json['sellingPrice']) ?? 0,
      discountPercent: AppUtils.parseInt(json['discountPercent']) ?? 0,
      inStock: AppUtils.parseBool(json['inStock']) ?? true,
      maxQuantityPerOrder: AppUtils.parseInt(json['maxQuantityPerOrder']) ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'slug': slug,
      'imageUrl': imageUrl,
      'brand': brand,
      'unitLabel': unitLabel,
      'mrp': mrp,
      'sellingPrice': sellingPrice,
      'discountPercent': discountPercent,
      'inStock': inStock,
      'maxQuantityPerOrder': maxQuantityPerOrder,
    };
  }
}
