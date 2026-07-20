import '../../../../core/utils/app_utils.dart';

class NotificationPreferencesModel {
  final bool lowStock;
  final bool outOfStock;
  final bool dailyReminder;
  final bool weeklySummary;

  const NotificationPreferencesModel({
    this.lowStock = true,
    this.outOfStock = true,
    this.dailyReminder = false,
    this.weeklySummary = true,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesModel(
      lowStock: AppUtils.parseBool(json['lowStock']) ?? true,
      outOfStock: AppUtils.parseBool(json['outOfStock']) ?? true,
      dailyReminder: AppUtils.parseBool(json['dailyReminder']) ?? false,
      weeklySummary: AppUtils.parseBool(json['weeklySummary']) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lowStock': lowStock,
      'outOfStock': outOfStock,
      'dailyReminder': dailyReminder,
      'weeklySummary': weeklySummary,
    };
  }

  NotificationPreferencesModel copyWith({
    bool? lowStock,
    bool? outOfStock,
    bool? dailyReminder,
    bool? weeklySummary,
  }) {
    return NotificationPreferencesModel(
      lowStock: lowStock ?? this.lowStock,
      outOfStock: outOfStock ?? this.outOfStock,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      weeklySummary: weeklySummary ?? this.weeklySummary,
    );
  }
}
