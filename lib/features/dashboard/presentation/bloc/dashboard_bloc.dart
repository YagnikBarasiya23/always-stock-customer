import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_response_handler.dart';
import '../../data/models/dashboard_summary_model.dart';
import '../../data/repository/dashboard_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardState()) {
    on<DashboardSummaryRequested>(_onSummaryRequested);
  }

  Future<void> _onSummaryRequested(DashboardSummaryRequested event, Emitter<DashboardState> emit) async {
    emit(state.asLoading());
    try {
      final summary = await DashboardRepository.summary();
      emit(state.copyWith(emitState: DashboardEmitState.success, summary: summary, nullError: true));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }
}
