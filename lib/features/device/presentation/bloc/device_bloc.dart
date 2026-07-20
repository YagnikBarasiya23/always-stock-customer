import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_response_handler.dart';
import '../../data/models/device_model.dart';
import '../../data/repository/device_repository.dart';

part 'device_event.dart';
part 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  DeviceBloc() : super(const DeviceState()) {
    on<DeviceRegisterRequested>(_onRegisterRequested);
  }

  Future<void> _onRegisterRequested(DeviceRegisterRequested event, Emitter<DeviceState> emit) async {
    emit(state.asLoading());
    try {
      final device = await DeviceRepository.register(
        deviceId: event.deviceId,
        platform: event.platform,
        fcmToken: event.fcmToken,
        appVersion: event.appVersion,
      );
      emit(state.copyWith(emitState: DeviceEmitState.success, device: device, nullError: true));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }
}
