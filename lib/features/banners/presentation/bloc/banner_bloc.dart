import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_response_handler.dart';
import '../../data/models/banner_model.dart';
import '../../data/repository/banner_repository.dart';

part 'banner_event.dart';
part 'banner_state.dart';

class BannerBloc extends Bloc<BannerEvent, BannerState> {
  BannerBloc() : super(const BannerState()) {
    on<ActiveBannersRequested>(_onActiveBannersRequested);
  }

  Future<void> _onActiveBannersRequested(ActiveBannersRequested event, Emitter<BannerState> emit) async {
    emit(state.asLoading());
    try {
      final banners = await BannerRepository.activeList();
      emit(state.copyWith(emitState: BannerEmitState.success, banners: banners, nullError: true));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }
}
