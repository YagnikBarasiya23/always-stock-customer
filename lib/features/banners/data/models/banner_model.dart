/// PROVISIONAL: backend not implemented; field shapes are a pragmatic guess
/// based on UrlConstants.activeBanners.
library;

import '../../../../core/utils/app_utils.dart';

enum BannerTargetType {
  product('product'),
  category('category'),
  url('url'),
  none('none'),
  unknown('unknown');

  const BannerTargetType(this.value);

  final String value;

  static BannerTargetType fromValue(String? value) =>
      values.firstWhere((e) => e.value == value, orElse: () => unknown);
}

class BannerModel {
  final String id;
  final String imageUrl;
  final String? title;
  final BannerTargetType targetType;
  final String? targetValue;
  final int sortOrder;

  const BannerModel({
    required this.id,
    required this.imageUrl,
    this.title,
    this.targetType = BannerTargetType.none,
    this.targetValue,
    this.sortOrder = 0,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: AppUtils.parseString(json['_id']) ?? '',
      imageUrl: AppUtils.parseString(json['imageUrl']) ?? '',
      title: AppUtils.parseString(json['title']),
      targetType: json['targetType'] == null
          ? BannerTargetType.none
          : BannerTargetType.fromValue(AppUtils.parseString(json['targetType'])),
      targetValue: AppUtils.parseString(json['targetValue']),
      sortOrder: AppUtils.parseInt(json['sortOrder']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'imageUrl': imageUrl,
      'title': title,
      'targetType': targetType.value,
      'targetValue': targetValue,
      'sortOrder': sortOrder,
    };
  }
}
