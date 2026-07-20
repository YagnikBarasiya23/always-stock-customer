/// PROVISIONAL: backend not implemented; field shapes are a pragmatic guess
/// based on UrlConstants.sendOtp.
library;

import '../../../../core/utils/app_utils.dart';

class SendOtpResultModel {
  final String? otpToken;
  final int expiresInSeconds;
  final int resendAfterSeconds;

  const SendOtpResultModel({
    this.otpToken,
    this.expiresInSeconds = 300,
    this.resendAfterSeconds = 30,
  });

  factory SendOtpResultModel.fromJson(Map<String, dynamic> json) {
    return SendOtpResultModel(
      otpToken: AppUtils.parseString(json['otpToken']),
      expiresInSeconds: AppUtils.parseInt(json['expiresInSeconds']) ?? 300,
      resendAfterSeconds: AppUtils.parseInt(json['resendAfterSeconds']) ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'otpToken': otpToken,
      'expiresInSeconds': expiresInSeconds,
      'resendAfterSeconds': resendAfterSeconds,
    };
  }
}
