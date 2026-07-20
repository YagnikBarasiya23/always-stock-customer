import '../../../../core/utils/app_utils.dart';

enum DevicePlatform {
  android('android'),
  ios('ios'),
  web('web'),
  unknown('unknown');

  const DevicePlatform(this.value);

  final String value;

  static DevicePlatform fromValue(String? value) =>
      values.firstWhere((e) => e.value == value, orElse: () => unknown);
}

class DeviceModel {
  final String id;
  final String userId;
  final String deviceId;
  final DevicePlatform platform;
  final String? fcmToken;
  final DateTime? lastSyncAt;
  final String? appVersion;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DeviceModel({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.platform,
    this.fcmToken,
    this.lastSyncAt,
    this.appVersion,
    this.createdAt,
    this.updatedAt,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: AppUtils.parseString(json['_id']) ?? '',
      userId: AppUtils.parseString(json['userId']) ?? '',
      deviceId: AppUtils.parseString(json['deviceId']) ?? '',
      platform: DevicePlatform.fromValue(AppUtils.parseString(json['platform'])),
      fcmToken: AppUtils.parseString(json['fcmToken']),
      lastSyncAt: AppUtils.parseDateTime(json['lastSyncAt']),
      appVersion: AppUtils.parseString(json['appVersion']),
      createdAt: AppUtils.parseDateTime(json['createdAt']),
      updatedAt: AppUtils.parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'deviceId': deviceId,
      'platform': platform.value,
      'fcmToken': fcmToken,
      'lastSyncAt': lastSyncAt?.toIso8601String(),
      'appVersion': appVersion,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
