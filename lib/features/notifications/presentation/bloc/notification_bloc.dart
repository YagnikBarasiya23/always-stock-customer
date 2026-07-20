import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_response_handler.dart';
import '../../../auth/data/models/notification_preferences_model.dart';
import '../../data/models/notification_model.dart';
import '../../data/repository/notification_repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(const NotificationState()) {
    on<NotificationListRequested>(_onListRequested);
    on<NotificationLoadMoreRequested>(_onLoadMoreRequested);
    on<NotificationMarkReadRequested>(_onMarkReadRequested);
    on<NotificationPreferencesSaveRequested>(_onPreferencesSaveRequested);
  }

  static const int _pageSize = 20;

  bool? _unreadOnly;

  Future<void> _onListRequested(NotificationListRequested event, Emitter<NotificationState> emit) async {
    _unreadOnly = event.unreadOnly;
    emit(state.asLoading());
    try {
      final result = await NotificationRepository.list(page: 1, limit: _pageSize, unreadOnly: event.unreadOnly);
      emit(state.copyWith(
        emitState: NotificationEmitState.success,
        notifications: result.notifications,
        unreadCount: result.unreadCount,
        page: 1,
        hasMore: result.pagination?.hasNextPage ?? false,
        nullError: true,
      ));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onLoadMoreRequested(NotificationLoadMoreRequested event, Emitter<NotificationState> emit) async {
    if (!state.hasMore || state.emitState == NotificationEmitState.loadingMore) return;
    emit(state.copyWith(emitState: NotificationEmitState.loadingMore));
    try {
      final nextPage = state.page + 1;
      final result = await NotificationRepository.list(page: nextPage, limit: _pageSize, unreadOnly: _unreadOnly);
      emit(state.copyWith(
        emitState: NotificationEmitState.success,
        notifications: [...state.notifications, ...result.notifications],
        unreadCount: result.unreadCount,
        page: nextPage,
        hasMore: result.pagination?.hasNextPage ?? false,
        nullError: true,
      ));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onMarkReadRequested(NotificationMarkReadRequested event, Emitter<NotificationState> emit) async {
    try {
      final modified = await NotificationRepository.markRead(notificationIds: event.notificationIds);
      final ids = event.notificationIds;
      final notifications = state.notifications
          .map((n) => ids == null || ids.contains(n.id) ? n.copyWith(isRead: true) : n)
          .toList();
      final unreadCount =
          ids == null ? 0 : (state.unreadCount - modified).clamp(0, state.unreadCount);
      emit(state.copyWith(
        emitState: NotificationEmitState.success,
        notifications: notifications,
        unreadCount: unreadCount,
        nullError: true,
      ));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onPreferencesSaveRequested(
    NotificationPreferencesSaveRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(emitState: NotificationEmitState.saving));
    try {
      final preferences = await NotificationRepository.upsertPreferences(event.preferences);
      emit(state.copyWith(
        emitState: NotificationEmitState.preferencesSaved,
        preferences: preferences,
        nullError: true,
      ));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }
}
