part of 'account_bloc.dart';

sealed class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class AccountOtpSendRequested extends AccountEvent {
  const AccountOtpSendRequested({required this.phone});

  final String phone;

  @override
  List<Object?> get props => [phone];
}

class AccountOtpVerifyRequested extends AccountEvent {
  const AccountOtpVerifyRequested({required this.phone, required this.otp});

  final String phone;
  final String otp;

  @override
  List<Object?> get props => [phone, otp];
}

class AccountProfileRequested extends AccountEvent {
  const AccountProfileRequested();
}

class AccountProfileUpdateRequested extends AccountEvent {
  const AccountProfileUpdateRequested({this.name, this.email, this.avatarUrl});

  final String? name;
  final String? email;
  final String? avatarUrl;

  @override
  List<Object?> get props => [name, email, avatarUrl];
}

class AccountDeleteRequested extends AccountEvent {
  const AccountDeleteRequested();
}

class AccountLogoutAllRequested extends AccountEvent {
  const AccountLogoutAllRequested();
}
