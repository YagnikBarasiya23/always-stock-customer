/// PROVISIONAL: backend not implemented; field shapes are a pragmatic guess
/// based on UrlConstants.verifyOtp.
library;

import '../../../../core/utils/app_utils.dart';
import '../../../auth/data/models/auth_tokens_model.dart';
import 'customer_model.dart';

class OtpAuthResultModel {
  final CustomerModel customer;
  final AuthTokensModel tokens;
  final bool isNewUser;

  const OtpAuthResultModel({
    required this.customer,
    required this.tokens,
    this.isNewUser = false,
  });

  factory OtpAuthResultModel.fromJson(Map<String, dynamic> json) {
    return OtpAuthResultModel(
      customer: CustomerModel.fromJson(AppUtils.parseMap(json['customer'])),
      tokens: AuthTokensModel.fromJson(AppUtils.parseMap(json['tokens'])),
      isNewUser: AppUtils.parseBool(json['isNewUser']) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer': customer.toJson(),
      'tokens': tokens.toJson(),
      'isNewUser': isNewUser,
    };
  }
}
