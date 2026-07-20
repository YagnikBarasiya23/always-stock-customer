import '../../../../config/api/api_services.dart';
import '../../../../config/constants/url_constants.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/paged_result.dart';
import '../models/product_model.dart';

abstract class ProductRepository {
  /// POST /products/upsert → { product }. Creates when [ProductUpsertRequest.id] is null.
  static Future<ProductModel> upsert(ProductUpsertRequest request) async {
    final result = await ApiServices.post(UrlConstants.productUpsert, data: request.toJson());
    return ProductModel.fromJson(AppUtils.parseMap(AppUtils.parseMap(result.data)['product']));
  }

  /// POST /products/list → { products } + meta.
  static Future<PagedResult<ProductModel>> list({
    int page = 1,
    int limit = 20,
    String? categoryId,
    List<String>? tags,
    bool? lowStock,
    bool? outOfStock,
    bool? includeInactive,
    ProductSort? sort,
  }) async {
    final result = await ApiServices.post(
      UrlConstants.productList,
      data: {
        'page': page,
        'limit': limit,
        'categoryId': ?categoryId,
        'tags': ?tags,
        'lowStock': ?lowStock,
        'outOfStock': ?outOfStock,
        'includeInactive': ?includeInactive,
        'sort': ?sort?.value,
      },
    );
    return PagedResult.from(result, 'products', ProductModel.fromJson);
  }

  /// POST /products/search → { products } + meta. Search by [query] or exact [barcode].
  static Future<PagedResult<ProductModel>> search({
    String? query,
    String? barcode,
    int page = 1,
    int limit = 20,
  }) async {
    final result = await ApiServices.post(
      UrlConstants.productSearch,
      data: {
        'page': page,
        'limit': limit,
        'query': ?query,
        'barcode': ?barcode,
      },
    );
    return PagedResult.from(result, 'products', ProductModel.fromJson);
  }

  /// POST /products/delete (soft delete) → { product }.
  static Future<ProductModel> delete(String productId) async {
    final result = await ApiServices.post(UrlConstants.productDelete, data: {'_id': productId});
    return ProductModel.fromJson(AppUtils.parseMap(AppUtils.parseMap(result.data)['product']));
  }
}
