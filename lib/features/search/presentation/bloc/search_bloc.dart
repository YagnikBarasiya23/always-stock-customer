import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_response_handler.dart';
import '../../data/models/global_search_result_model.dart';
import '../../data/models/search_suggestion_model.dart';
import '../../data/repository/search_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(const SearchState()) {
    on<GlobalSearchRequested>(_onGlobalSearchRequested);
    on<SearchSuggestionsRequested>(_onSuggestionsRequested);
    on<SearchCleared>(_onCleared);
  }

  Future<void> _onGlobalSearchRequested(GlobalSearchRequested event, Emitter<SearchState> emit) async {
    emit(state.asLoading());
    try {
      final result = await SearchRepository.globalSearch(query: event.query);
      emit(state.copyWith(emitState: SearchEmitState.success, result: result, nullError: true));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onSuggestionsRequested(SearchSuggestionsRequested event, Emitter<SearchState> emit) async {
    try {
      final suggestions = await SearchRepository.suggestions(event.query);
      emit(state.copyWith(emitState: SearchEmitState.suggestionsLoaded, suggestions: suggestions, nullError: true));
    } catch (_) {
      // Suggestions are best-effort; ignore failures silently.
    }
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) {
    emit(const SearchState());
  }
}
