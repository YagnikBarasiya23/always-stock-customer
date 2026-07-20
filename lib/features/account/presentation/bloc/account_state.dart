part of 'account_bloc.dart';

class AccountState extends Equatable {
  const AccountState({
    this.emitState = AccountEmitState.initial,
    this.customer,
    this.otpResult,
    this.errorMessage,
  });

  final AccountEmitState emitState;
  final CustomerModel? customer;
  final SendOtpResultModel? otpResult;
  final String? errorMessage;

  AccountState copyWith({
    AccountEmitState? emitState,
    CustomerModel? customer,
    SendOtpResultModel? otpResult,
    String? errorMessage,
    bool nullError = false,
  }) => AccountState(
    emitState: emitState ?? this.emitState,
    customer: customer ?? this.customer,
    otpResult: otpResult ?? this.otpResult,
    errorMessage: nullError ? null : (errorMessage ?? this.errorMessage),
  );

  AccountState asLoading() => copyWith(emitState: AccountEmitState.loading, nullError: true);
  AccountState asError(String? errorMessage) =>
      copyWith(emitState: AccountEmitState.error, errorMessage: errorMessage);

  @override
  List<Object?> get props => [emitState, customer, otpResult, errorMessage];
}

enum AccountEmitState { initial, loading, saving, otpSent, loggedIn, success, saved, error, loggedOut }
