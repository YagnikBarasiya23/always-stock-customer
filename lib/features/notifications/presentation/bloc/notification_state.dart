part of 'notification_bloc.dart';

class NotificationState extends Equatable {
  const NotificationState({
    this.emitState = NotificationEmitState.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.page = 1,
    this.hasMore = false,
    this.preferences,
    this.errorMessage,
  });

  final NotificationEmitState emitState;
  final List<NotificationModel> notifications;
  final int unreadCount;
  final int page;
  final bool hasMore;
  final NotificationPreferencesModel? preferences;
  final String? errorMessage;

  NotificationState copyWith({
    NotificationEmitState? emitState,
    List<NotificationModel>? notifications,
    int? unreadCount,
    int? page,
    bool? hasMore,
    NotificationPreferencesModel? preferences,
    String? errorMessage,
    bool nullError = false,
  }) => NotificationState(
    emitState: emitState ?? this.emitState,
    notifications: notifications ?? this.notifications,
    unreadCount: unreadCount ?? this.unreadCount,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    preferences: preferences ?? this.preferences,
    errorMessage: nullError ? null : (errorMessage ?? this.errorMessage),
  );

  NotificationState asLoading() => copyWith(emitState: NotificationEmitState.loading, nullError: true);
  NotificationState asError(String? errorMessage) =>
      copyWith(emitState: NotificationEmitState.error, errorMessage: errorMessage);

  @override
  List<Object?> get props => [emitState, notifications, unreadCount, page, hasMore, preferences, errorMessage];
}

enum NotificationEmitState { initial, loading, loadingMore, saving, success, preferencesSaved, error }
