import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_response_handler.dart';
import '../../data/models/store_serviceability_model.dart';
import '../../data/repository/store_repository.dart';

part 'store_event.dart';
part 'store_state.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  StoreBloc() : super(const StoreState()) {
    on<StoreServiceabilityRequested>(_onServiceabilityRequested);
  }

  Future<void> _onServiceabilityRequested(StoreServiceabilityRequested event, Emitter<StoreState> emit) async {
    emit(state.asLoading());
    try {
      final serviceability = await StoreRepository.serviceability(
        pincode: event.pincode,
        latitude: event.latitude,
        longitude: event.longitude,
      );
      emit(state.copyWith(emitState: StoreEmitState.success, serviceability: serviceability, nullError: true));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }
}
