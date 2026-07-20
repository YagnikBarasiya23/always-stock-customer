import '../../../../config/api/api_services.dart';
import '../../../../config/constants/url_constants.dart';
import '../../../../core/utils/api_response_handler.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../auth/data/models/notification_preferences_model.dart';
import '../models/notification_model.dart';

/// Result of `/notifications/list`: the page of notifications plus the
/// total unread count the backend sends alongside it.
class NotificationListResult {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final Pagination? pagination;

  const NotificationListResult({
    this.notifications = const [],
    this.unreadCount = 0,
    this.pagination,
  });
}

abstract class NotificationRepository {
  /// POST /notifications/list → { notifications, unreadCount } + meta.
  static Future<NotificationListResult> list({
    int page = 1,
    int limit = 20,
    bool? unreadOnly,
  }) async {
    final result = await ApiServices.post(
      UrlConstants.notificationList,
      data: {
        'page': page,
        'limit': limit,
        'unreadOnly': ?unreadOnly,
      },
    );
    final map = AppUtils.parseMap(result.data);
    return NotificationListResult(
      notifications: AppUtils.parseObjectList(map['notifications'], NotificationModel.fromJson),
      unreadCount: AppUtils.parseInt(map['unreadCount']) ?? 0,
      pagination: result.pagination,
    );
  }

  /// POST /notifications/mark-read → { modified }. Marks all when
  /// [notificationIds] is null.
  static Future<int> markRead({List<String>? notificationIds}) async {
    final result = await ApiServices.post(
      UrlConstants.notificationMarkRead,
      data: {'notificationIds': ?notificationIds},
    );
    return AppUtils.parseInt(AppUtils.parseMap(result.data)['modified']) ?? 0;
  }

  /// POST /notifications/preferences/upsert → { preferences }.
  static Future<NotificationPreferencesModel> upsertPreferences(
    NotificationPreferencesModel preferences,
  ) async {
    final result = await ApiServices.post(
      UrlConstants.notificationPreferencesUpsert,
      data: preferences.toJson(),
    );
    return NotificationPreferencesModel.fromJson(
      AppUtils.parseMap(AppUtils.parseMap(result.data)['preferences']),
    );
  }
}
