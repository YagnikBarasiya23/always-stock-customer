part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.businessName,
    this.preferredLanguage,
  });

  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? businessName;
  final String? preferredLanguage;

  @override
  List<Object?> get props => [name, email, password, phone, businessName, preferredLanguage];
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Fetches /user/me to hydrate user + business when a stored token exists
/// (cold start). Silently ignored when signed out or offline.
class AuthSessionRestoreRequested extends AuthEvent {
  const AuthSessionRestoreRequested();
}

/// Keeps the in-memory user in sync after notification preferences are
/// saved from the preferences screen.
class AuthNotificationPreferencesChanged extends AuthEvent {
  const AuthNotificationPreferencesChanged(this.preferences);

  final NotificationPreferencesModel preferences;

  @override
  List<Object?> get props => [preferences];
}

class AuthLanguageChanged extends AuthEvent {
  const AuthLanguageChanged(this.language);

  final String language;

  @override
  List<Object?> get props => [language];
}
