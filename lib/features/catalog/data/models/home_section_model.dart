/// PROVISIONAL: backend not implemented; field shapes are a pragmatic guess
/// based on UrlConstants.catalogHome.
library;

import '../../../../core/utils/app_utils.dart';
import '../../../banners/data/models/banner_model.dart';
import 'catalog_category_model.dart';
import 'catalog_product_model.dart';

enum HomeSectionType {
  bannerStrip('banner_strip'),
  categoryGrid('category_grid'),
  productCarousel('product_carousel'),
  unknown('unknown');

  const HomeSectionType(this.value);

  final String value;

  static HomeSectionType fromValue(String? value) =>
      values.firstWhere((e) => e.value == value, orElse: () => unknown);
}

class HomeSectionModel {
  final String id;
  final HomeSectionType type;
  final String title;
  final int sortOrder;
  final List<CatalogProductModel> products;
  final List<CatalogCategoryModel> categories;
  final List<BannerModel> banners;

  const HomeSectionModel({
    required this.id,
    required this.type,
    this.title = '',
    this.sortOrder = 0,
    this.products = const [],
    this.categories = const [],
    this.banners = const [],
  });

  factory HomeSectionModel.fromJson(Map<String, dynamic> json) {
    return HomeSectionModel(
      id: AppUtils.parseString(json['_id']) ?? '',
      type: HomeSectionType.fromValue(AppUtils.parseString(json['type'])),
      title: AppUtils.parseString(json['title']) ?? '',
      sortOrder: AppUtils.parseInt(json['sortOrder']) ?? 0,
      products: AppUtils.parseObjectList(json['products'], CatalogProductModel.fromJson),
      categories: AppUtils.parseObjectList(json['categories'], CatalogCategoryModel.fromJson),
      banners: AppUtils.parseObjectList(json['banners'], BannerModel.fromJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type.value,
      'title': title,
      'sortOrder': sortOrder,
      'products': products.map((e) => e.toJson()).toList(),
      'categories': categories.map((e) => e.toJson()).toList(),
      'banners': banners.map((e) => e.toJson()).toList(),
    };
  }
}
