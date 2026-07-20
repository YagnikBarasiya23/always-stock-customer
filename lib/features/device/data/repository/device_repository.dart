import '../../../../config/api/api_services.dart';
import '../../../../config/constants/url_constants.dart';
import '../../../../core/utils/app_utils.dart';
import '../models/device_model.dart';

abstract class DeviceRepository {
  /// POST /devices/register → { device }.
  static Future<DeviceModel> register({
    required String deviceId,
    required DevicePlatform platform,
    String? fcmToken,
    String? appVersion,
  }) async {
    final result = await ApiServices.post(
      UrlConstants.deviceRegister,
      data: {
        'deviceId': deviceId,
        'platform': platform.value,
        'fcmToken': ?fcmToken,
        'appVersion': ?appVersion,
      },
    );
    return DeviceModel.fromJson(AppUtils.parseMap(AppUtils.parseMap(result.data)['device']));
  }
}
