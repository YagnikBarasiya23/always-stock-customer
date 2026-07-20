import '../../../../config/api/api_services.dart';
import '../../../../config/cache/response_cache_service.dart';
import '../../../../config/constants/url_constants.dart';
import '../../../../config/local/local_storage_services.dart';
import '../../../../core/utils/app_utils.dart';
import '../models/auth_session_model.dart';
import '../models/auth_tokens_model.dart';
import '../models/business_model.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  /// POST /auth/register → { user, business, tokens }. Stores the token pair.
  static Future<AuthSessionModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? businessName,
    String? preferredLanguage,
  }) async {
    final result = await ApiServices.post(
      UrlConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': ?phone,
        'businessName': ?businessName,
        'preferredLanguage': ?preferredLanguage,
      },
    );
    final session = AuthSessionModel.fromJson(AppUtils.parseMap(result.data));
    await _storeTokens(session.tokens);
    return session;
  }

  /// POST /auth/login → { user, business, tokens }. Stores the token pair.
  static Future<AuthSessionModel> login({required String email, required String password}) async {
    final result = await ApiServices.post(
      UrlConstants.login,
      data: {'email': email, 'password': password},
    );
    final session = AuthSessionModel.fromJson(AppUtils.parseMap(result.data));
    await _storeTokens(session.tokens);
    return session;
  }

  /// POST /user/me → { user, business }. Used to restore the session on a
  /// cold start when a stored token exists.
  static Future<({UserModel user, BusinessModel? business})> me() async {
    final result = await ApiServices.post(UrlConstants.me);
    final data = AppUtils.parseMap(result.data);
    return (
      user: UserModel.fromJson(AppUtils.parseMap(data['user'])),
      business: data['business'] is Map<String, dynamic>
          ? BusinessModel.fromJson(data['business'] as Map<String, dynamic>)
          : null,
    );
  }

  /// POST /auth/logout. Always clears local tokens and cache, even if the call fails.
  static Future<void> logout() async {
    try {
      await ApiServices.post(
        UrlConstants.logout,
        data: {'refreshToken': LocalStorageServices.getRefreshToken()},
      );
    } finally {
      await LocalStorageServices.clearTokens();
      await ResponseCacheService.clearAll();
    }
  }

  /// POST /user/language/upsert → { preferredLanguage }.
  static Future<String> updatePreferredLanguage(String language) async {
    final result = await ApiServices.post(
      UrlConstants.userLanguageUpsert,
      data: {'preferredLanguage': language},
    );
    return AppUtils.parseString(AppUtils.parseMap(result.data)['preferredLanguage']) ?? language;
  }

  static Future<void> _storeTokens(AuthTokensModel tokens) {
    return LocalStorageServices.setTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
  }
}
