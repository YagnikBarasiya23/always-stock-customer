import '../../../../core/utils/app_utils.dart';

class CategoryModel {
  final String id;
  final String businessId;
  final String name;

  /// User-entered translations of [name], keyed by locale code (hi, gu).
  final Map<String, String> nameTranslations;
  final String? parentCategoryId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoryModel({
    required this.id,
    required this.businessId,
    required this.name,
    this.nameTranslations = const {},
    this.parentCategoryId,
    this.createdAt,
    this.updatedAt,
  });

  /// The name to display for [locale], falling back to the base [name].
  String localizedName(String locale) => nameTranslations[locale] ?? name;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: AppUtils.parseString(json['_id']) ?? '',
      businessId: AppUtils.parseString(json['businessId']) ?? '',
      name: AppUtils.parseString(json['name']) ?? '',
      nameTranslations: AppUtils.parseStringMap(json['nameTranslations']),
      parentCategoryId: AppUtils.parseString(json['parentCategoryId']),
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
      'parentCategoryId': parentCategoryId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
