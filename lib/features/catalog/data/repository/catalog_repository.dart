/// PROVISIONAL: backend not implemented; request/response shapes are a
/// pragmatic guess based on the UrlConstants catalog endpoints.
library;

import '../../../../config/api/api_services.dart';
import '../../../../config/constants/url_constants.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/paged_result.dart';
import '../models/catalog_category_model.dart';
import '../models/catalog_product_model.dart';
import '../models/home_section_model.dart';
import '../models/product_detail_model.dart';

abstract class CatalogRepository {
  /// POST /catalog/category-tree → { categories }. Cached for offline use.
  static Future<List<CatalogCategoryModel>> categoryTree() async {
    final result = await ApiServices.post(UrlConstants.categoryTree, data: {}, cacheKey: 'catalog_category_tree');
    return PagedResult.itemsOf(result.data, 'categories', CatalogCategoryModel.fromJson);
  }

  /// POST /catalog/home → { sections }. Cached for offline use.
  static Future<List<HomeSectionModel>> home() async {
    final result = await ApiServices.post(UrlConstants.catalogHome, data: {}, cacheKey: 'catalog_home');
    return PagedResult.itemsOf(result.data, 'sections', HomeSectionModel.fromJson);
  }

  /// POST /catalog/by-category → { products } + meta.
  static Future<PagedResult<CatalogProductModel>> byCategory({
    required String categoryId,
    int page = 1,
    int limit = 20,
  }) async {
    final result = await ApiServices.post(
      UrlConstants.byCategory,
      data: {'categoryId': categoryId, 'page': page, 'limit': limit},
    );
    return PagedResult.from(result, 'products', CatalogProductModel.fromJson);
  }

  /// POST /catalog/product-detail → product detail with variants.
  static Future<ProductDetailModel> productDetail({required String productId}) async {
    final result = await ApiServices.post(UrlConstants.productDetail, data: {'productId': productId});
    final map = AppUtils.parseMap(result.data);
    return ProductDetailModel.fromJson(
      map['product'] is Map<String, dynamic> ? map['product'] as Map<String, dynamic> : map,
    );
  }
}
