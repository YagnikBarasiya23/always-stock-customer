import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/local/local_storage_services.dart';
import '../../../../core/utils/api_response_handler.dart';
import '../../data/models/business_model.dart';
import '../../data/models/notification_preferences_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthLanguageChanged>(_onLanguageChanged);
    on<AuthSessionRestoreRequested>(_onSessionRestoreRequested);
    on<AuthNotificationPreferencesChanged>(_onNotificationPreferencesChanged);
  }

  Future<void> _onSessionRestoreRequested(AuthSessionRestoreRequested event, Emitter<AuthState> emit) async {
    if (LocalStorageServices.getToken() == null) return;
    try {
      final session = await AuthRepository.me();
      emit(state.copyWith(user: session.user, business: session.business).asSuccess());
    } catch (_) {
      // Offline or expired session — screens keep their placeholder fallbacks.
    }
  }

  Future<void> _onNotificationPreferencesChanged(
    AuthNotificationPreferencesChanged event,
    Emitter<AuthState> emit,
  ) async {
    final user = state.user;
    if (user == null) return;
    emit(state.copyWith(user: user.copyWith(notificationPreferences: event.preferences)).asSuccess());
  }

  Future<void> _onRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(state.asLoading());
    try {
      final session = await AuthRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
        phone: event.phone,
        businessName: event.businessName,
        preferredLanguage: event.preferredLanguage,
      );
      emit(state.copyWith(user: session.user, business: session.business).asLoggedIn());
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(state.asLoading());
    try {
      final session = await AuthRepository.login(email: event.email, password: event.password);
      emit(state.copyWith(user: session.user, business: session.business).asLoggedIn());
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(state.asLoading());
    try {
      await AuthRepository.logout();
    } finally {
      emit(const AuthState(emitState: AuthEmitState.loggedOut));
    }
  }

  Future<void> _onLanguageChanged(AuthLanguageChanged event, Emitter<AuthState> emit) async {
    try {
      final language = await AuthRepository.updatePreferredLanguage(event.language);
      final user = state.user;
      if (user != null) {
        emit(state.copyWith(user: user.copyWith(preferredLanguage: language)));
      }
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }
}
