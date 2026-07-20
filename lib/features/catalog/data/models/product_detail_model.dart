/// PROVISIONAL: backend not implemented; field shapes are a pragmatic guess
/// based on UrlConstants.productDetail.
library;

import '../../../../core/utils/app_utils.dart';
import 'catalog_product_model.dart';

class ProductVariantModel {
  final String id;
  final String label;
  final double mrp;
  final double sellingPrice;
  final bool inStock;
  final bool isDefault;

  const ProductVariantModel({
    required this.id,
    required this.label,
    this.mrp = 0,
    this.sellingPrice = 0,
    this.inStock = true,
    this.isDefault = false,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: AppUtils.parseString(json['_id']) ?? '',
      label: AppUtils.parseString(json['label']) ?? '',
      mrp: AppUtils.parseDouble(json['mrp']) ?? 0,
      sellingPrice: AppUtils.parseDouble(json['sellingPrice']) ?? 0,
      inStock: AppUtils.parseBool(json['inStock']) ?? true,
      isDefault: AppUtils.parseBool(json['isDefault']) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'label': label,
      'mrp': mrp,
      'sellingPrice': sellingPrice,
      'inStock': inStock,
      'isDefault': isDefault,
    };
  }
}

class ProductDetailModel {
  final CatalogProductModel product;
  final String? description;
  final List<String> images;
  final List<ProductVariantModel> variants;
  final Map<String, dynamic> attributes;

  const ProductDetailModel({
    required this.product,
    this.description,
    this.images = const [],
    this.variants = const [],
    this.attributes = const {},
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailModel(
      product: CatalogProductModel.fromJson(json),
      description: AppUtils.parseString(json['description']),
      images: AppUtils.parseStringList(json['images']),
      variants: AppUtils.parseObjectList(json['variants'], ProductVariantModel.fromJson),
      attributes: AppUtils.parseMap(json['attributes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...product.toJson(),
      'description': description,
      'images': images,
      'variants': variants.map((e) => e.toJson()).toList(),
      'attributes': attributes,
    };
  }
}
