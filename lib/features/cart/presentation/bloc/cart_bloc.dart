import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_response_handler.dart';
import '../../data/models/cart_model.dart';
import '../../data/repository/cart_repository.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<CartRequested>(_onRequested);
    on<CartItemAdded>(_onItemAdded);
    on<CartItemQuantityChanged>(_onItemQuantityChanged);
    on<CartItemRemoved>(_onItemRemoved);
  }

  Future<void> _onRequested(CartRequested event, Emitter<CartState> emit) async {
    emit(state.asLoading());
    await _run(emit, () => CartRepository.detail());
  }

  Future<void> _onItemAdded(CartItemAdded event, Emitter<CartState> emit) async {
    emit(state.copyWith(emitState: CartEmitState.updating));
    await _run(
      emit,
      () => CartRepository.addItem(
        productId: event.productId,
        variantId: event.variantId,
        quantity: event.quantity,
      ),
    );
  }

  Future<void> _onItemQuantityChanged(CartItemQuantityChanged event, Emitter<CartState> emit) async {
    emit(state.copyWith(emitState: CartEmitState.updating));
    await _run(emit, () => CartRepository.updateItemQuantity(itemId: event.itemId, quantity: event.quantity));
  }

  Future<void> _onItemRemoved(CartItemRemoved event, Emitter<CartState> emit) async {
    emit(state.copyWith(emitState: CartEmitState.updating));
    await _run(emit, () => CartRepository.removeItem(itemId: event.itemId));
  }

  Future<void> _run(Emitter<CartState> emit, Future<CartModel> Function() action) async {
    try {
      final cart = await action();
      emit(state.copyWith(emitState: CartEmitState.success, cart: cart, nullError: true));
    } catch (e) {
      emit(state.asError(apiErrorMessage(e)));
    }
  }
}
