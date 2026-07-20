/// PROVISIONAL: backend not implemented; field shapes are a pragmatic guess
/// based on UrlConstants.globalSearch.
library;

import '../../../../core/utils/app_utils.dart';
import '../../../catalog/data/models/catalog_category_model.dart';
import '../../../catalog/data/models/catalog_product_model.dart';

class GlobalSearchResultModel {
  final List<CatalogProductModel> products;
  final List<CatalogCategoryModel> categories;

  const GlobalSearchResultModel({this.products = const [], this.categories = const []});

  factory GlobalSearchResultModel.fromJson(Map<String, dynamic> json) {
    return GlobalSearchResultModel(
      products: AppUtils.parseObjectList(json['products'], CatalogProductModel.fromJson),
      categories: AppUtils.parseObjectList(json['categories'], CatalogCategoryModel.fromJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((e) => e.toJson()).toList(),
      'categories': categories.map((e) => e.toJson()).toList(),
    };
  }
}
