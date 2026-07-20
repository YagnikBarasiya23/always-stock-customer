part of 'catalog_bloc.dart';

sealed class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => [];
}

class CatalogHomeRequested extends CatalogEvent {
  const CatalogHomeRequested();
}

class CatalogCategoryTreeRequested extends CatalogEvent {
  const CatalogCategoryTreeRequested();
}

class CatalogByCategoryRequested extends CatalogEvent {
  const CatalogByCategoryRequested(this.categoryId);

  final String categoryId;

  @override
  List<Object?> get props => [categoryId];
}

class CatalogLoadMoreRequested extends CatalogEvent {
  const CatalogLoadMoreRequested();
}

class CatalogProductDetailRequested extends CatalogEvent {
  const CatalogProductDetailRequested(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}
