/// PROVISIONAL: backend not implemented; request/response shapes are a
/// pragmatic guess based on UrlConstants.serviceability.
library;

import '../../../../config/api/api_services.dart';
import '../../../../config/constants/url_constants.dart';
import '../../../../core/utils/app_utils.dart';
import '../models/store_serviceability_model.dart';

abstract class StoreRepository {
  /// POST /stores/serviceability → serviceability for a pincode or location.
  static Future<StoreServiceabilityModel> serviceability({
    String? pincode,
    double? latitude,
    double? longitude,
  }) async {
    final result = await ApiServices.post(
      UrlConstants.serviceability,
      data: {
        'pincode': ?pincode,
        'latitude': ?latitude,
        'longitude': ?longitude,
      },
    );
    return StoreServiceabilityModel.fromJson(AppUtils.parseMap(result.data));
  }
}
