import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_response_handler.dart';
import '../../data/models/cms_page_model.dart';
import '../../data/repository/cms_repository.dart';

part 'cms_event.dart';
part 'cms_state.dart';

class CmsBloc extends Bloc<CmsEvent, CmsState> {
  CmsBloc() : super(const CmsState()) {
    on<CmsPageRequested>(_onPageRequested);
  }

  Future<void> _onPageRequested(CmsPageRequested event, Emitter<CmsState> emit) async {
    emit(state.asLoading());
    try {
      final page = await CmsRepository.pageBySlug(event.slug);
      emit(state.copyWith(emitState: CmsEmitState.success, page: page, nullError: true));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }
}
