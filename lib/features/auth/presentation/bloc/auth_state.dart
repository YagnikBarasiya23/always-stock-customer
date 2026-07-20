part of 'auth_bloc.dart';

class AuthState extends Equatable {
  const AuthState({
    this.emitState = AuthEmitState.initial,
    this.user,
    this.business,
    this.errorMessage,
  });

  final AuthEmitState emitState;
  final UserModel? user;
  final BusinessModel? business;
  final String? errorMessage;

  AuthState copyWith({
    AuthEmitState? emitState,
    UserModel? user,
    BusinessModel? business,
    String? errorMessage,
    bool nullError = false,
  }) => AuthState(
    emitState: emitState ?? this.emitState,
    user: user ?? this.user,
    business: business ?? this.business,
    errorMessage: nullError ? null : (errorMessage ?? this.errorMessage),
  );

  AuthState asLoading() => copyWith(emitState: AuthEmitState.loading, nullError: true);
  AuthState asSuccess() => copyWith(emitState: AuthEmitState.success, nullError: true);
  AuthState asError(String? errorMessage) => copyWith(emitState: AuthEmitState.error, errorMessage: errorMessage);
  AuthState asLoggedIn() => copyWith(emitState: AuthEmitState.loggedIn, nullError: true);

  @override
  List<Object?> get props => [emitState, user, business, errorMessage];
}

enum AuthEmitState { initial, loading, success, error, loggedIn, loggedOut }
