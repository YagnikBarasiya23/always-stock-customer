/// PROVISIONAL: backend not implemented; request/response shapes are a
/// pragmatic guess based on the UrlConstants search endpoints.
library;

import '../../../../config/api/api_services.dart';
import '../../../../config/constants/url_constants.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/paged_result.dart';
import '../models/global_search_result_model.dart';
import '../models/search_suggestion_model.dart';

abstract class SearchRepository {
  /// POST /search/global-search → { products, categories }.
  static Future<GlobalSearchResultModel> globalSearch({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    final result = await ApiServices.post(
      UrlConstants.globalSearch,
      data: {'query': query, 'page': page, 'limit': limit},
    );
    return GlobalSearchResultModel.fromJson(AppUtils.parseMap(result.data));
  }

  /// POST /search/suggestions → { suggestions }.
  static Future<List<SearchSuggestionModel>> suggestions(String query) async {
    final result = await ApiServices.post(UrlConstants.searchSuggestions, data: {'query': query});
    return PagedResult.itemsOf(result.data, 'suggestions', SearchSuggestionModel.fromJson);
  }
}
