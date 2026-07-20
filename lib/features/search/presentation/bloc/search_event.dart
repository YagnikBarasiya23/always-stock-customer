part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class GlobalSearchRequested extends SearchEvent {
  const GlobalSearchRequested(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class SearchSuggestionsRequested extends SearchEvent {
  const SearchSuggestionsRequested(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class SearchCleared extends SearchEvent {
  const SearchCleared();
}
