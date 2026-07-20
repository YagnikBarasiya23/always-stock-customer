part of 'catalog_bloc.dart';

class CatalogState extends Equatable {
  const CatalogState({
    this.emitState = CatalogEmitState.initial,
    this.sections = const [],
    this.categoryTree = const [],
    this.products = const [],
    this.page = 1,
    this.hasMore = false,
    this.productDetail,
    this.errorMessage,
  });

  final CatalogEmitState emitState;
  final List<HomeSectionModel> sections;
  final List<CatalogCategoryModel> categoryTree;
  final List<CatalogProductModel> products;
  final int page;
  final bool hasMore;
  final ProductDetailModel? productDetail;
  final String? errorMessage;

  CatalogState copyWith({
    CatalogEmitState? emitState,
    List<HomeSectionModel>? sections,
    List<CatalogCategoryModel>? categoryTree,
    List<CatalogProductModel>? products,
    int? page,
    bool? hasMore,
    ProductDetailModel? productDetail,
    String? errorMessage,
    bool nullError = false,
  }) => CatalogState(
    emitState: emitState ?? this.emitState,
    sections: sections ?? this.sections,
    categoryTree: categoryTree ?? this.categoryTree,
    products: products ?? this.products,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    productDetail: productDetail ?? this.productDetail,
    errorMessage: nullError ? null : (errorMessage ?? this.errorMessage),
  );

  CatalogState asLoading() => copyWith(emitState: CatalogEmitState.loading, nullError: true);
  CatalogState asError(String? errorMessage) =>
      copyWith(emitState: CatalogEmitState.error, errorMessage: errorMessage);

  @override
  List<Object?> get props =>
      [emitState, sections, categoryTree, products, page, hasMore, productDetail, errorMessage];
}

enum CatalogEmitState { initial, loading, loadingMore, detailLoading, success, detailLoaded, error }
