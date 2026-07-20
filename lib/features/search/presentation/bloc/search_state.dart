part of 'search_bloc.dart';

class SearchState extends Equatable {
  const SearchState({
    this.emitState = SearchEmitState.initial,
    this.result,
    this.suggestions = const [],
    this.errorMessage,
  });

  final SearchEmitState emitState;
  final GlobalSearchResultModel? result;
  final List<SearchSuggestionModel> suggestions;
  final String? errorMessage;

  SearchState copyWith({
    SearchEmitState? emitState,
    GlobalSearchResultModel? result,
    List<SearchSuggestionModel>? suggestions,
    String? errorMessage,
    bool nullError = false,
  }) => SearchState(
    emitState: emitState ?? this.emitState,
    result: result ?? this.result,
    suggestions: suggestions ?? this.suggestions,
    errorMessage: nullError ? null : (errorMessage ?? this.errorMessage),
  );

  SearchState asLoading() => copyWith(emitState: SearchEmitState.loading, nullError: true);
  SearchState asError(String? errorMessage) => copyWith(emitState: SearchEmitState.error, errorMessage: errorMessage);

  @override
  List<Object?> get props => [emitState, result, suggestions, errorMessage];
}

enum SearchEmitState { initial, loading, success, suggestionsLoaded, error }
