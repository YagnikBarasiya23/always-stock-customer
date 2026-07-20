import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_response_handler.dart';
import '../../data/models/order_item_model.dart';
import '../../data/repository/order_repository.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(const OrderState()) {
    on<OrderItemsRequested>(_onItemsRequested);
    on<OrderItemsLoadMoreRequested>(_onItemsLoadMoreRequested);
  }

  static const int _pageSize = 20;

  String? _orderId;

  Future<void> _onItemsRequested(OrderItemsRequested event, Emitter<OrderState> emit) async {
    _orderId = event.orderId;
    emit(state.asLoading());
    try {
      final result = await OrderRepository.listOrderItems(page: 1, limit: _pageSize, orderId: event.orderId);
      emit(state.copyWith(
        emitState: OrderEmitState.success,
        orderItems: result.items,
        page: 1,
        hasMore: result.pagination?.hasNextPage ?? false,
        nullError: true,
      ));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }

  Future<void> _onItemsLoadMoreRequested(OrderItemsLoadMoreRequested event, Emitter<OrderState> emit) async {
    if (!state.hasMore || state.emitState == OrderEmitState.loadingMore) return;
    emit(state.copyWith(emitState: OrderEmitState.loadingMore));
    try {
      final nextPage = state.page + 1;
      final result = await OrderRepository.listOrderItems(page: nextPage, limit: _pageSize, orderId: _orderId);
      emit(state.copyWith(
        emitState: OrderEmitState.success,
        orderItems: [...state.orderItems, ...result.items],
        page: nextPage,
        hasMore: result.pagination?.hasNextPage ?? false,
        nullError: true,
      ));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }
}
