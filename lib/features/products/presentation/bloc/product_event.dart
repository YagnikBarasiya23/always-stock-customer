part of 'product_bloc.dart';

sealed class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the first page. Set [query] or [barcode] to search instead of list.
class ProductListRequested extends ProductEvent {
  const ProductListRequested({
    this.categoryId,
    this.tags,
    this.lowStock,
    this.outOfStock,
    this.includeInactive,
    this.sort,
    this.query,
    this.barcode,
  });

  final String? categoryId;
  final List<String>? tags;
  final bool? lowStock;
  final bool? outOfStock;
  final bool? includeInactive;
  final ProductSort? sort;
  final String? query;
  final String? barcode;

  bool get isSearch => query != null || barcode != null;

  @override
  List<Object?> get props => [categoryId, tags, lowStock, outOfStock, includeInactive, sort, query, barcode];
}

class ProductLoadMoreRequested extends ProductEvent {
  const ProductLoadMoreRequested();
}

class ProductUpsertRequested extends ProductEvent {
  const ProductUpsertRequested(this.request);

  final ProductUpsertRequest request;

  @override
  List<Object?> get props => [request];
}

class ProductDeleteRequested extends ProductEvent {
  const ProductDeleteRequested(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}
