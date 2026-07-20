import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_response_handler.dart';
import '../../data/models/catalog_category_model.dart';
import '../../data/models/catalog_product_model.dart';
import '../../data/models/home_section_model.dart';
import '../../data/models/product_detail_model.dart';
import '../../data/repository/catalog_repository.dart';

part 'catalog_event.dart';
part 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc() : super(const CatalogState()) {
    on<CatalogHomeRequested>(_onHomeRequested);
    on<CatalogCategoryTreeRequested>(_onCategoryTreeRequested);
    on<CatalogByCategoryRequested>(_onByCategoryRequested);
    on<CatalogLoadMoreRequested>(_onLoadMoreRequested);
    on<CatalogProductDetailRequested>(_onProductDetailRequested);
  }

  static const int _pageSize = 20;

  String? _categoryId;

  Future<void> _onHomeRequested(CatalogHomeRequested event, Emitter<CatalogState> emit) async {
    emit(state.asLoading());
    try {
      final sections = await CatalogRepository.home();
      emit(state.copyWith(emitState: CatalogEmitState.success, sections: sections, nullError: true));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onCategoryTreeRequested(CatalogCategoryTreeRequested event, Emitter<CatalogState> emit) async {
    emit(state.asLoading());
    try {
      final tree = await CatalogRepository.categoryTree();
      emit(state.copyWith(emitState: CatalogEmitState.success, categoryTree: tree, nullError: true));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onByCategoryRequested(CatalogByCategoryRequested event, Emitter<CatalogState> emit) async {
    _categoryId = event.categoryId;
    emit(state.asLoading());
    try {
      final result = await CatalogRepository.byCategory(categoryId: event.categoryId, page: 1, limit: _pageSize);
      emit(state.copyWith(
        emitState: CatalogEmitState.success,
        products: result.items,
        page: 1,
        hasMore: result.pagination?.hasNextPage ?? false,
        nullError: true,
      ));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onLoadMoreRequested(CatalogLoadMoreRequested event, Emitter<CatalogState> emit) async {
    final categoryId = _categoryId;
    if (categoryId == null || !state.hasMore || state.emitState == CatalogEmitState.loadingMore) return;
    emit(state.copyWith(emitState: CatalogEmitState.loadingMore));
    try {
      final nextPage = state.page + 1;
      final result = await CatalogRepository.byCategory(categoryId: categoryId, page: nextPage, limit: _pageSize);
      emit(state.copyWith(
        emitState: CatalogEmitState.success,
        products: [...state.products, ...result.items],
        page: nextPage,
        hasMore: result.pagination?.hasNextPage ?? false,
        nullError: true,
      ));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onProductDetailRequested(CatalogProductDetailRequested event, Emitter<CatalogState> emit) async {
    emit(state.copyWith(emitState: CatalogEmitState.detailLoading));
    try {
      final detail = await CatalogRepository.productDetail(productId: event.productId);
      emit(state.copyWith(emitState: CatalogEmitState.detailLoaded, productDetail: detail, nullError: true));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }
}
