/// PROVISIONAL: backend not implemented; request/response shapes are a
/// pragmatic guess based on UrlConstants.addressList.
library;

import '../../../../config/api/api_services.dart';
import '../../../../config/constants/url_constants.dart';
import '../../../../core/utils/paged_result.dart';
import '../models/address_model.dart';

abstract class AddressRepository {
  /// POST /addresses/list → { addresses }.
  static Future<List<AddressModel>> list() async {
    final result = await ApiServices.post(UrlConstants.addressList, data: {});
    return PagedResult.itemsOf(result.data, 'addresses', AddressModel.fromJson);
  }
}
