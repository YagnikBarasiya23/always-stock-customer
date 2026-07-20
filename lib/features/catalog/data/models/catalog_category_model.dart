/// PROVISIONAL: backend not implemented; field shapes are a pragmatic guess
/// based on UrlConstants.categoryTree / UrlConstants.byCategory.
library;

import '../../../../core/utils/app_utils.dart';

class CatalogCategoryModel {
  final String id;
  final String name;
  final String? slug;
  final String? imageUrl;
  final int sortOrder;
  final List<CatalogCategoryModel> children;

  const CatalogCategoryModel({
    required this.id,
    required this.name,
    this.slug,
    this.imageUrl,
    this.sortOrder = 0,
    this.children = const [],
  });

  factory CatalogCategoryModel.fromJson(Map<String, dynamic> json) {
    return CatalogCategoryModel(
      id: AppUtils.parseString(json['_id']) ?? '',
      name: AppUtils.parseString(json['name']) ?? '',
      slug: AppUtils.parseString(json['slug']),
      imageUrl: AppUtils.parseString(json['imageUrl']),
      sortOrder: AppUtils.parseInt(json['sortOrder']) ?? 0,
      children: AppUtils.parseObjectList(json['children'], CatalogCategoryModel.fromJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'slug': slug,
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
}
