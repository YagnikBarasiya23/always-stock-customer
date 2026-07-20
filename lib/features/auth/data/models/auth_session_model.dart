import '../../../../core/utils/app_utils.dart';
import 'auth_tokens_model.dart';
import 'business_model.dart';
import 'user_model.dart';

/// Response of `/auth/register` ({user, business, tokens}) and
/// `/auth/login` ({user, tokens} — [business] is null).
/// `/auth/refresh-token` returns only {tokens}; parse [AuthTokensModel] directly.
class AuthSessionModel {
  final UserModel user;
  final BusinessModel? business;
  final AuthTokensModel tokens;

  const AuthSessionModel({required this.user, this.business, required this.tokens});

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      user: UserModel.fromJson(AppUtils.parseMap(json['user'])),
      business: json['business'] is Map<String, dynamic>
          ? BusinessModel.fromJson(json['business'] as Map<String, dynamic>)
          : null,
      tokens: AuthTokensModel.fromJson(AppUtils.parseMap(json['tokens'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'business': business?.toJson(),
      'tokens': tokens.toJson(),
    };
  }
}
