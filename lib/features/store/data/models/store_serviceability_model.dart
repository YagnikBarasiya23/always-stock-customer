/// PROVISIONAL: backend not implemented; field shapes are a pragmatic guess
/// based on UrlConstants.serviceability.
library;

import '../../../../core/utils/app_utils.dart';

class StoreServiceabilityModel {
  final bool serviceable;
  final String? storeId;
  final String? storeName;
  final int? etaMinutes;
  final double? minOrderAmount;
  final double? deliveryFee;
  final String? message;

  const StoreServiceabilityModel({
    this.serviceable = false,
    this.storeId,
    this.storeName,
    this.etaMinutes,
    this.minOrderAmount,
    this.deliveryFee,
    this.message,
  });

  factory StoreServiceabilityModel.fromJson(Map<String, dynamic> json) {
    return StoreServiceabilityModel(
      serviceable: AppUtils.parseBool(json['serviceable']) ?? false,
      storeId: AppUtils.parseString(json['storeId']),
      storeName: AppUtils.parseString(json['storeName']),
      etaMinutes: AppUtils.parseInt(json['etaMinutes']),
      minOrderAmount: AppUtils.parseDouble(json['minOrderAmount']),
      deliveryFee: AppUtils.parseDouble(json['deliveryFee']),
      message: AppUtils.parseString(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceable': serviceable,
      'storeId': storeId,
      'storeName': storeName,
      'etaMinutes': etaMinutes,
      'minOrderAmount': minOrderAmount,
      'deliveryFee': deliveryFee,
      'message': message,
    };
  }
}
