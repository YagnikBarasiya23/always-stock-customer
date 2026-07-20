part of 'product_bloc.dart';

class ProductState extends Equatable {
  const ProductState({
    this.emitState = ProductEmitState.initial,
    this.products = const [],
    this.page = 1,
    this.hasMore = false,
    this.errorMessage,
  });

  final ProductEmitState emitState;
  final List<ProductModel> products;
  final int page;
  final bool hasMore;
  final String? errorMessage;

  ProductState copyWith({
    ProductEmitState? emitState,
    List<ProductModel>? products,
    int? page,
    bool? hasMore,
    String? errorMessage,
    bool nullError = false,
  }) => ProductState(
    emitState: emitState ?? this.emitState,
    products: products ?? this.products,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    errorMessage: nullError ? null : (errorMessage ?? this.errorMessage),
  );

  ProductState asLoading() => copyWith(emitState: ProductEmitState.loading, nullError: true);
  ProductState asError(String? errorMessage) => copyWith(emitState: ProductEmitState.error, errorMessage: errorMessage);

  @override
  List<Object?> get props => [emitState, products, page, hasMore, errorMessage];
}

enum ProductEmitState { initial, loading, loadingMore, saving, success, saved, deleted, error }
