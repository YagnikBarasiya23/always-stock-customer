part of 'category_bloc.dart';

class CategoryState extends Equatable {
  const CategoryState({
    this.emitState = CategoryEmitState.initial,
    this.categories = const [],
    this.errorMessage,
  });

  final CategoryEmitState emitState;
  final List<CategoryModel> categories;
  final String? errorMessage;

  CategoryState copyWith({
    CategoryEmitState? emitState,
    List<CategoryModel>? categories,
    String? errorMessage,
    bool nullError = false,
  }) => CategoryState(
    emitState: emitState ?? this.emitState,
    categories: categories ?? this.categories,
    errorMessage: nullError ? null : (errorMessage ?? this.errorMessage),
  );

  CategoryState asLoading() => copyWith(emitState: CategoryEmitState.loading, nullError: true);
  CategoryState asError(String? errorMessage) => copyWith(emitState: CategoryEmitState.error, errorMessage: errorMessage);

  @override
  List<Object?> get props => [emitState, categories, errorMessage];
}

enum CategoryEmitState { initial, loading, saving, success, saved, error }
