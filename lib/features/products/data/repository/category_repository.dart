import '../../../../config/api/api_services.dart';
import '../../../../config/constants/url_constants.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/paged_result.dart';
import '../models/category_model.dart';

abstract class CategoryRepository {
  /// POST /categories/upsert → { category }. Creates when [id] is null.
  static Future<CategoryModel> upsert({
    String? id,
    required String name,
    Map<String, String>? nameTranslations,
  }) async {
    final result = await ApiServices.post(
      UrlConstants.categoryUpsert,
      data: {'_id': ?id, 'name': name, 'nameTranslations': ?nameTranslations},
    );
    return CategoryModel.fromJson(AppUtils.parseMap(AppUtils.parseMap(result.data)['category']));
  }

  /// POST /categories/list → { categories }. Cached for offline use.
  static Future<List<CategoryModel>> list() async {
    final result = await ApiServices.post(UrlConstants.categoryList, data: {}, cacheKey: 'category_list');
    return PagedResult.itemsOf(result.data, 'categories', CategoryModel.fromJson);
  }
}
