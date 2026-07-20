/// PROVISIONAL: backend not implemented; request/response shapes are a
/// pragmatic guess based on the UrlConstants auth/user endpoints.
library;

import '../../../../config/api/api_services.dart';
import '../../../../config/cache/response_cache_service.dart';
import '../../../../config/constants/url_constants.dart';
import '../../../../config/local/local_storage_services.dart';
import '../../../../core/utils/app_utils.dart';
import '../models/customer_model.dart';
import '../models/otp_auth_result_model.dart';
import '../models/send_otp_result_model.dart';

abstract class AccountRepository {
  /// POST /auth/send-otp → { otpToken, expiresInSeconds, resendAfterSeconds }.
  static Future<SendOtpResultModel> sendOtp({required String phone}) async {
    final result = await ApiServices.post(UrlConstants.sendOtp, data: {'phone': phone});
    return SendOtpResultModel.fromJson(AppUtils.parseMap(result.data));
  }

  /// POST /auth/verify-otp → { customer, tokens, isNewUser }. Stores the token pair.
  static Future<OtpAuthResultModel> verifyOtp({
    required String phone,
    required String otp,
    String? otpToken,
  }) async {
    final result = await ApiServices.post(
      UrlConstants.verifyOtp,
      data: {
        'phone': phone,
        'otp': otp,
        'otpToken': ?otpToken,
      },
    );
    final auth = OtpAuthResultModel.fromJson(AppUtils.parseMap(result.data));
    await LocalStorageServices.setTokens(
      accessToken: auth.tokens.accessToken,
      refreshToken: auth.tokens.refreshToken,
    );
    return auth;
  }

  /// POST /users/me → customer profile.
  static Future<CustomerModel> getProfile() async {
    final result = await ApiServices.post(UrlConstants.me, data: {}, cacheKey: 'account_me');
    return CustomerModel.fromJson(AppUtils.parseMap(result.data));
  }

  /// POST /users/update-profile → updated customer profile.
  static Future<CustomerModel> updateProfile({
    String? name,
    String? email,
    String? avatarUrl,
  }) async {
    final result = await ApiServices.post(
      UrlConstants.updateProfile,
      data: {
        'name': ?name,
        'email': ?email,
        'avatarUrl': ?avatarUrl,
      },
    );
    return CustomerModel.fromJson(AppUtils.parseMap(result.data));
  }

  /// POST /users/delete-account. Clears local tokens and cache afterwards.
  static Future<void> deleteAccount() async {
    await ApiServices.post(UrlConstants.deleteAccount, data: {});
    await LocalStorageServices.clearTokens();
    await ResponseCacheService.clearAll();
  }

  /// POST /auth/logout-all. Always clears local tokens and cache.
  static Future<void> logoutAll() async {
    try {
      await ApiServices.post(UrlConstants.logoutAll, data: {});
    } finally {
      await LocalStorageServices.clearTokens();
      await ResponseCacheService.clearAll();
    }
  }
}
