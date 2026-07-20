import '../../../../core/utils/app_utils.dart';

class AuthTokensModel {
  final String accessToken;
  final String refreshToken;

  const AuthTokensModel({required this.accessToken, required this.refreshToken});

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: AppUtils.parseString(json['accessToken']) ?? '',
      refreshToken: AppUtils.parseString(json['refreshToken']) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}
