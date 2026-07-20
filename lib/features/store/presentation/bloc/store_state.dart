part of 'store_bloc.dart';

class StoreState extends Equatable {
  const StoreState({
    this.emitState = StoreEmitState.initial,
    this.serviceability,
    this.errorMessage,
  });

  final StoreEmitState emitState;
  final StoreServiceabilityModel? serviceability;
  final String? errorMessage;

  StoreState copyWith({
    StoreEmitState? emitState,
    StoreServiceabilityModel? serviceability,
    String? errorMessage,
    bool nullError = false,
  }) => StoreState(
    emitState: emitState ?? this.emitState,
    serviceability: serviceability ?? this.serviceability,
    errorMessage: nullError ? null : (errorMessage ?? this.errorMessage),
  );

  StoreState asLoading() => copyWith(emitState: StoreEmitState.loading, nullError: true);
  StoreState asError(String? errorMessage) => copyWith(emitState: StoreEmitState.error, errorMessage: errorMessage);

  @override
  List<Object?> get props => [emitState, serviceability, errorMessage];
}

enum StoreEmitState { initial, loading, success, error }
