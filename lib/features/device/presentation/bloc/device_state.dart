part of 'device_bloc.dart';

class DeviceState extends Equatable {
  const DeviceState({
    this.emitState = DeviceEmitState.initial,
    this.device,
    this.errorMessage,
  });

  final DeviceEmitState emitState;
  final DeviceModel? device;
  final String? errorMessage;

  DeviceState copyWith({
    DeviceEmitState? emitState,
    DeviceModel? device,
    String? errorMessage,
    bool nullError = false,
  }) => DeviceState(
    emitState: emitState ?? this.emitState,
    device: device ?? this.device,
    errorMessage: nullError ? null : (errorMessage ?? this.errorMessage),
  );

  DeviceState asLoading() => copyWith(emitState: DeviceEmitState.loading, nullError: true);
  DeviceState asError(String? errorMessage) => copyWith(emitState: DeviceEmitState.error, errorMessage: errorMessage);

  @override
  List<Object?> get props => [emitState, device, errorMessage];
}

enum DeviceEmitState { initial, loading, success, error }
