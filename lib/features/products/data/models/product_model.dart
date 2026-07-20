import '../../../../core/utils/app_utils.dart';

enum ProductSort {
  nameAsc('name_asc'),
  nameDesc('name_desc'),
  stockAsc('stock_asc'),
  stockDesc('stock_desc'),
  recent('recent'),
  updated('updated'),
  unknown('unknown');

  const ProductSort(this.value);

  final String value;

  static ProductSort fromValue(String? value) =>
      values.firstWhere((e) => e.value == value, orElse: () => unknown);
}

class ProductModel {
  final String id;
  final String businessId;
  final String name;

  /// User-entered translations of [name], keyed by locale code (hi, gu).
  final Map<String, String> nameTranslations;
  final String? sku;
  final String? barcode;
  final String? categoryId;
  final String unit;
  final double? costPrice;
  final double? sellingPrice;
  final String? imageUrl;
  final double currentStock;
  final double lowStockThreshold;
  final List<String> tags;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    required this.id,
    required this.businessId,
    required this.name,
    this.nameTranslations = const {},
    this.sku,
    this.barcode,
    this.categoryId,
    this.unit = 'pcs',
    this.costPrice,
    this.sellingPrice,
    this.imageUrl,
    this.currentStock = 0,
    this.lowStockThreshold = 0,
    this.tags = const [],
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  bool get isOutOfStock => currentStock <= 0;

  bool get isLowStock => !isOutOfStock && currentStock <= lowStockThreshold;

  /// The name to display for [locale], falling back to the base [name].
  String localizedName(String locale) => nameTranslations[locale] ?? name;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: AppUtils.parseString(json['_id']) ?? '',
      businessId: AppUtils.parseString(json['businessId']) ?? '',
      name: AppUtils.parseString(json['name']) ?? '',
      nameTranslations: AppUtils.parseStringMap(json['nameTranslations']),
      sku: AppUtils.parseString(json['sku']),
      barcode: AppUtils.parseString(json['barcode']),
      categoryId: AppUtils.parseRefId(json['categoryId']),
      unit: AppUtils.parseString(json['unit']) ?? 'pcs',
      costPrice: AppUtils.parseDouble(json['costPrice']),
      sellingPrice: AppUtils.parseDouble(json['sellingPrice']),
      imageUrl: AppUtils.parseString(json['imageUrl']),
      currentStock: AppUtils.parseDouble(json['currentStock']) ?? 0,
      lowStockThreshold: AppUtils.parseDouble(json['lowStockThreshold']) ?? 0,
      tags: AppUtils.parseStringList(json['tags']),
      isActive: AppUtils.parseBool(json['isActive']) ?? true,
      createdAt: AppUtils.parseDateTime(json['createdAt']),
      updatedAt: AppUtils.parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'businessId': businessId,
      'name': name,
      'nameTranslations': nameTranslations,
      'sku': sku,
      'barcode': barcode,
      'categoryId': categoryId,
      'unit': unit,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'imageUrl': imageUrl,
      'currentStock': currentStock,
      'lowStockThreshold': lowStockThreshold,
      'tags': tags,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? businessId,
    String? name,
    Map<String, String>? nameTranslations,
    String? sku,
    String? barcode,
    String? categoryId,
    String? unit,
    double? costPrice,
    double? sellingPrice,
    String? imageUrl,
    double? currentStock,
    double? lowStockThreshold,
    List<String>? tags,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      nameTranslations: nameTranslations ?? this.nameTranslations,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      categoryId: categoryId ?? this.categoryId,
      unit: unit ?? this.unit,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      currentStock: currentStock ?? this.currentStock,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Request body for `/products/upsert`. Write-only: [initialStock] is accepted
/// by the backend on create but never returned on the product entity.
class ProductUpsertRequest {
  final String? id;
  final String name;
  final Map<String, String>? nameTranslations;
  final String? sku;
  final String? barcode;
  final String? categoryId;
  final String? unit;
  final double? costPrice;
  final double? sellingPrice;
  final String? imageUrl;
  final double? lowStockThreshold;
  final double? initialStock;
  final List<String>? tags;
  final bool? isActive;

  const ProductUpsertRequest({
    this.id,
    required this.name,
    this.nameTranslations,
    this.sku,
    this.barcode,
    this.categoryId,
    this.unit,
    this.costPrice,
    this.sellingPrice,
    this.imageUrl,
    this.lowStockThreshold,
    this.initialStock,
    this.tags,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      if (nameTranslations != null) 'nameTranslations': nameTranslations,
      if (sku != null) 'sku': sku,
      if (barcode != null) 'barcode': barcode,
      if (categoryId != null) 'categoryId': categoryId,
      if (unit != null) 'unit': unit,
      if (costPrice != null) 'costPrice': costPrice,
      if (sellingPrice != null) 'sellingPrice': sellingPrice,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (lowStockThreshold != null) 'lowStockThreshold': lowStockThreshold,
      if (initialStock != null) 'initialStock': initialStock,
      if (tags != null) 'tags': tags,
      if (isActive != null) 'isActive': isActive,
    };
  }
}
