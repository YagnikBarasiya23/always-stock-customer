import '../../../../core/utils/app_utils.dart';

enum NotificationCategory {
  lowStock('low_stock'),
  outOfStock('out_of_stock'),
  dailyReminder('daily_reminder'),
  weeklySummary('weekly_summary'),
  unknown('unknown');

  const NotificationCategory(this.value);

  final String value;

  static NotificationCategory fromValue(String? value) =>
      values.firstWhere((e) => e.value == value, orElse: () => unknown);
}

class NotificationModel {
  final String id;
  final String userId;
  final String businessId;
  final NotificationCategory type;
  final String title;
  final String body;
  final String locale;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.businessId,
    required this.type,
    required this.title,
    required this.body,
    this.locale = 'en',
    this.data = const {},
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: AppUtils.parseString(json['_id']) ?? '',
      userId: AppUtils.parseString(json['userId']) ?? '',
      businessId: AppUtils.parseString(json['businessId']) ?? '',
      type: NotificationCategory.fromValue(AppUtils.parseString(json['type'])),
      title: AppUtils.parseString(json['title']) ?? '',
      body: AppUtils.parseString(json['body']) ?? '',
      locale: AppUtils.parseString(json['locale']) ?? 'en',
      data: AppUtils.parseMap(json['data']),
      isRead: AppUtils.parseBool(json['isRead']) ?? false,
      createdAt: AppUtils.parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'businessId': businessId,
      'type': type.value,
      'title': title,
      'body': body,
      'locale': locale,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? businessId,
    NotificationCategory? type,
    String? title,
    String? body,
    String? locale,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessId: businessId ?? this.businessId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      locale: locale ?? this.locale,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
