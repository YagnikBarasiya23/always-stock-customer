/// PROVISIONAL: backend not implemented; request/response shapes are a
/// pragmatic guess based on UrlConstants.activeBanners.
library;

import '../../../../config/api/api_services.dart';
import '../../../../config/constants/url_constants.dart';
import '../../../../core/utils/paged_result.dart';
import '../models/banner_model.dart';

abstract class BannerRepository {
  /// POST /banners/active-list → { banners }. Cached for offline use.
  static Future<List<BannerModel>> activeList() async {
    final result = await ApiServices.post(UrlConstants.activeBanners, data: {}, cacheKey: 'banners_active');
    return PagedResult.itemsOf(result.data, 'banners', BannerModel.fromJson);
  }
}
