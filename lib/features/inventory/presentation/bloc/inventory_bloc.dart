import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_response_handler.dart';
import '../../data/models/inventory_transaction_model.dart';
import '../../data/models/stock_change_result_model.dart';
import '../../data/repository/inventory_repository.dart';

part 'inventory_event.dart';
part 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  InventoryBloc() : super(const InventoryState()) {
    on<StockAddRequested>(_onStockAddRequested);
    on<StockRemoveRequested>(_onStockRemoveRequested);
    on<StockAdjustRequested>(_onStockAdjustRequested);
    on<InventoryHistoryRequested>(_onHistoryRequested);
    on<InventoryHistoryLoadMoreRequested>(_onHistoryLoadMoreRequested);
  }

  static const int _pageSize = 20;

  InventoryHistoryRequested _lastHistoryRequest = const InventoryHistoryRequested();

  Future<void> _onStockAddRequested(StockAddRequested event, Emitter<InventoryState> emit) async {
    emit(state.copyWith(emitState: InventoryEmitState.saving));
    try {
      final result = await InventoryRepository.addStock(
        productId: event.productId,
        quantity: event.quantity,
        reason: event.reason,
        type: event.type,
      );
      emit(state.copyWith(emitState: InventoryEmitState.stockChanged, lastChange: result, nullError: true));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onStockRemoveRequested(StockRemoveRequested event, Emitter<InventoryState> emit) async {
    emit(state.copyWith(emitState: InventoryEmitState.saving));
    try {
      final result = await InventoryRepository.removeStock(
        productId: event.productId,
        quantity: event.quantity,
        reason: event.reason,
        type: event.type,
      );
      emit(state.copyWith(emitState: InventoryEmitState.stockChanged, lastChange: result, nullError: true));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onStockAdjustRequested(StockAdjustRequested event, Emitter<InventoryState> emit) async {
    emit(state.copyWith(emitState: InventoryEmitState.saving));
    try {
      final result = await InventoryRepository.adjustStock(
        productId: event.productId,
        newStock: event.newStock,
        reason: event.reason,
      );
      emit(state.copyWith(emitState: InventoryEmitState.stockChanged, lastChange: result, nullError: true));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onHistoryRequested(InventoryHistoryRequested event, Emitter<InventoryState> emit) async {
    _lastHistoryRequest = event;
    emit(state.asLoading());
    try {
      final result = await InventoryRepository.history(
        page: 1,
        limit: _pageSize,
        productId: event.productId,
        type: event.type,
        from: event.from,
        to: event.to,
      );
      emit(state.copyWith(
        emitState: InventoryEmitState.success,
        transactions: result.items,
        page: 1,
        hasMore: result.pagination?.hasNextPage ?? false,
        nullError: true,
      ));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onHistoryLoadMoreRequested(
    InventoryHistoryLoadMoreRequested event,
    Emitter<InventoryState> emit,
  ) async {
    if (!state.hasMore || state.emitState == InventoryEmitState.loadingMore) return;
    emit(state.copyWith(emitState: InventoryEmitState.loadingMore));
    try {
      final nextPage = state.page + 1;
      final request = _lastHistoryRequest;
      final result = await InventoryRepository.history(
        page: nextPage,
        limit: _pageSize,
        productId: request.productId,
        type: request.type,
        from: request.from,
        to: request.to,
      );
      emit(state.copyWith(
        emitState: InventoryEmitState.success,
        transactions: [...state.transactions, ...result.items],
        page: nextPage,
        hasMore: result.pagination?.hasNextPage ?? false,
        nullError: true,
      ));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }
}
