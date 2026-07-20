import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_response_handler.dart';
import '../../../../core/utils/paged_result.dart';
import '../../data/models/product_model.dart';
import '../../data/repository/product_repository.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(const ProductState()) {
    on<ProductListRequested>(_onListRequested);
    on<ProductLoadMoreRequested>(_onLoadMoreRequested);
    on<ProductUpsertRequested>(_onUpsertRequested);
    on<ProductDeleteRequested>(_onDeleteRequested);
  }

  static const int _pageSize = 20;

  ProductListRequested _lastRequest = const ProductListRequested();

  Future<PagedResult<ProductModel>> _fetch(int page) {
    final r = _lastRequest;
    if (r.isSearch) {
      return ProductRepository.search(query: r.query, barcode: r.barcode, page: page, limit: _pageSize);
    }
    return ProductRepository.list(
      page: page,
      limit: _pageSize,
      categoryId: r.categoryId,
      tags: r.tags,
      lowStock: r.lowStock,
      outOfStock: r.outOfStock,
      includeInactive: r.includeInactive,
      sort: r.sort,
    );
  }

  Future<void> _onListRequested(ProductListRequested event, Emitter<ProductState> emit) async {
    _lastRequest = event;
    emit(state.asLoading());
    try {
      final result = await _fetch(1);
      emit(state.copyWith(
        emitState: ProductEmitState.success,
        products: result.items,
        page: 1,
        hasMore: result.pagination?.hasNextPage ?? false,
        nullError: true,
      ));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onLoadMoreRequested(ProductLoadMoreRequested event, Emitter<ProductState> emit) async {
    if (!state.hasMore || state.emitState == ProductEmitState.loadingMore) return;
    emit(state.copyWith(emitState: ProductEmitState.loadingMore));
    try {
      final nextPage = state.page + 1;
      final result = await _fetch(nextPage);
      emit(state.copyWith(
        emitState: ProductEmitState.success,
        products: [...state.products, ...result.items],
        page: nextPage,
        hasMore: result.pagination?.hasNextPage ?? false,
        nullError: true,
      ));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onUpsertRequested(ProductUpsertRequested event, Emitter<ProductState> emit) async {
    emit(state.copyWith(emitState: ProductEmitState.saving));
    try {
      final saved = await ProductRepository.upsert(event.request);
      final products = [...state.products];
      final index = products.indexWhere((p) => p.id == saved.id);
      if (index >= 0) {
        products[index] = saved;
      } else {
        products.insert(0, saved);
      }
      emit(state.copyWith(emitState: ProductEmitState.saved, products: products, nullError: true));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onDeleteRequested(ProductDeleteRequested event, Emitter<ProductState> emit) async {
    emit(state.copyWith(emitState: ProductEmitState.saving));
    try {
      await ProductRepository.delete(event.productId);
      emit(state.copyWith(
        emitState: ProductEmitState.deleted,
        products: state.products.where((p) => p.id != event.productId).toList(),
        nullError: true,
      ));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }
}
