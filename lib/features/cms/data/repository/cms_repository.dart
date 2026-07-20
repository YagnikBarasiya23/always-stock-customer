/// PROVISIONAL: backend not implemented; request/response shapes are a
/// pragmatic guess based on UrlConstants.cmsPageDetailBySlug.
library;

import '../../../../config/api/api_services.dart';
import '../../../../config/constants/url_constants.dart';
import '../../../../core/utils/app_utils.dart';
import '../models/cms_page_model.dart';

abstract class CmsRepository {
  /// POST /cms-pages/detail-by-slug → CMS page. Cached per slug for offline use.
  static Future<CmsPageModel> pageBySlug(String slug) async {
    final result = await ApiServices.post(
      UrlConstants.cmsPageDetailBySlug,
      data: {'slug': slug},
      cacheKey: 'cms_page_$slug',
    );
    final map = AppUtils.parseMap(result.data);
    return CmsPageModel.fromJson(
      map['page'] is Map<String, dynamic> ? map['page'] as Map<String, dynamic> : map,
    );
  }
}
