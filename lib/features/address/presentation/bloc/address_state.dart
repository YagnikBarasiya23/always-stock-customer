part of 'address_bloc.dart';

class AddressState extends Equatable {
  const AddressState({
    this.emitState = AddressEmitState.initial,
    this.addresses = const [],
    this.errorMessage,
  });

  final AddressEmitState emitState;
  final List<AddressModel> addresses;
  final String? errorMessage;

  AddressState copyWith({
    AddressEmitState? emitState,
    List<AddressModel>? addresses,
    String? errorMessage,
    bool nullError = false,
  }) => AddressState(
    emitState: emitState ?? this.emitState,
    addresses: addresses ?? this.addresses,
    errorMessage: nullError ? null : (errorMessage ?? this.errorMessage),
  );

  AddressState asLoading() => copyWith(emitState: AddressEmitState.loading, nullError: true);
  AddressState asError(String? errorMessage) =>
      copyWith(emitState: AddressEmitState.error, errorMessage: errorMessage);

  @override
  List<Object?> get props => [emitState, addresses, errorMessage];
}

enum AddressEmitState { initial, loading, success, error }
