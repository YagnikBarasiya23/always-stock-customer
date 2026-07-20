import '../../../../core/utils/app_utils.dart';

class BusinessModel {
  final String id;
  final String name;
  final String ownerId;
  final String timezone;
  final String currency;
  final String defaultLanguage;
  final String? logoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BusinessModel({
    required this.id,
    required this.name,
    required this.ownerId,
    this.timezone = 'Asia/Kolkata',
    this.currency = 'INR',
    this.defaultLanguage = 'en',
    this.logoUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: AppUtils.parseString(json['_id']) ?? '',
      name: AppUtils.parseString(json['name']) ?? '',
      ownerId: AppUtils.parseString(json['ownerId']) ?? '',
      timezone: AppUtils.parseString(json['timezone']) ?? 'Asia/Kolkata',
      currency: AppUtils.parseString(json['currency']) ?? 'INR',
      defaultLanguage: AppUtils.parseString(json['defaultLanguage']) ?? 'en',
      logoUrl: AppUtils.parseString(json['logoUrl']),
      createdAt: AppUtils.parseDateTime(json['createdAt']),
      updatedAt: AppUtils.parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'ownerId': ownerId,
      'timezone': timezone,
      'currency': currency,
      'defaultLanguage': defaultLanguage,
      'logoUrl': logoUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
