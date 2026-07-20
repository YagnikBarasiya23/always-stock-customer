import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_response_handler.dart';
import '../../data/models/feedback_model.dart';
import '../../data/repository/feedback_repository.dart';

part 'feedback_event.dart';
part 'feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  FeedbackBloc() : super(const FeedbackState()) {
    on<FeedbackSubmitRequested>(_onSubmitRequested);
  }

  Future<void> _onSubmitRequested(FeedbackSubmitRequested event, Emitter<FeedbackState> emit) async {
    emit(state.asLoading());
    try {
      final feedback = await FeedbackRepository.submit(
        rating: event.rating,
        message: event.message,
        appVersion: event.appVersion,
      );
      emit(state.copyWith(emitState: FeedbackEmitState.success, feedback: feedback, nullError: true));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }
}
