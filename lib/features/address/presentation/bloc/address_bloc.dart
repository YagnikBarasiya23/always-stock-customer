import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_response_handler.dart';
import '../../data/models/address_model.dart';
import '../../data/repository/address_repository.dart';

part 'address_event.dart';
part 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  AddressBloc() : super(const AddressState()) {
    on<AddressListRequested>(_onListRequested);
  }

  Future<void> _onListRequested(AddressListRequested event, Emitter<AddressState> emit) async {
    emit(state.asLoading());
    try {
      final addresses = await AddressRepository.list();
      emit(state.copyWith(emitState: AddressEmitState.success, addresses: addresses, nullError: true));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }
}
