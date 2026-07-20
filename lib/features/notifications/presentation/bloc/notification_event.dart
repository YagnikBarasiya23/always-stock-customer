part of 'notification_bloc.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationListRequested extends NotificationEvent {
  const NotificationListRequested({this.unreadOnly});

  final bool? unreadOnly;

  @override
  List<Object?> get props => [unreadOnly];
}

class NotificationLoadMoreRequested extends NotificationEvent {
  const NotificationLoadMoreRequested();
}

/// Marks all notifications read when [notificationIds] is null.
class NotificationMarkReadRequested extends NotificationEvent {
  const NotificationMarkReadRequested({this.notificationIds});

  final List<String>? notificationIds;

  @override
  List<Object?> get props => [notificationIds];
}

class NotificationPreferencesSaveRequested extends NotificationEvent {
  const NotificationPreferencesSaveRequested(this.preferences);

  final NotificationPreferencesModel preferences;

  @override
  List<Object?> get props => [preferences];
}
