import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_response_handler.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/send_otp_result_model.dart';
import '../../data/repository/account_repository.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc() : super(const AccountState()) {
    on<AccountOtpSendRequested>(_onOtpSendRequested);
    on<AccountOtpVerifyRequested>(_onOtpVerifyRequested);
    on<AccountProfileRequested>(_onProfileRequested);
    on<AccountProfileUpdateRequested>(_onProfileUpdateRequested);
    on<AccountDeleteRequested>(_onDeleteRequested);
    on<AccountLogoutAllRequested>(_onLogoutAllRequested);
  }

  Future<void> _onOtpSendRequested(AccountOtpSendRequested event, Emitter<AccountState> emit) async {
    emit(state.asLoading());
    try {
      final otpResult = await AccountRepository.sendOtp(phone: event.phone);
      emit(state.copyWith(emitState: AccountEmitState.otpSent, otpResult: otpResult, nullError: true));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onOtpVerifyRequested(AccountOtpVerifyRequested event, Emitter<AccountState> emit) async {
    emit(state.asLoading());
    try {
      final auth = await AccountRepository.verifyOtp(
        phone: event.phone,
        otp: event.otp,
        otpToken: state.otpResult?.otpToken,
      );
      emit(state.copyWith(emitState: AccountEmitState.loggedIn, customer: auth.customer, nullError: true));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onProfileRequested(AccountProfileRequested event, Emitter<AccountState> emit) async {
    emit(state.asLoading());
    try {
      final customer = await AccountRepository.getProfile();
      emit(state.copyWith(emitState: AccountEmitState.success, customer: customer, nullError: true));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onProfileUpdateRequested(AccountProfileUpdateRequested event, Emitter<AccountState> emit) async {
    emit(state.copyWith(emitState: AccountEmitState.saving));
    try {
      final customer = await AccountRepository.updateProfile(
        name: event.name,
        email: event.email,
        avatarUrl: event.avatarUrl,
      );
      emit(state.copyWith(emitState: AccountEmitState.saved, customer: customer, nullError: true));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onDeleteRequested(AccountDeleteRequested event, Emitter<AccountState> emit) async {
    emit(state.asLoading());
    try {
      await AccountRepository.deleteAccount();
      emit(const AccountState(emitState: AccountEmitState.loggedOut));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onLogoutAllRequested(AccountLogoutAllRequested event, Emitter<AccountState> emit) async {
    emit(state.asLoading());
    try {
      await AccountRepository.logoutAll();
    } finally {
      emit(const AccountState(emitState: AccountEmitState.loggedOut));
    }
  }
}
