part of 'cart_bloc.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartRequested extends CartEvent {
  const CartRequested();
}

class CartItemAdded extends CartEvent {
  const CartItemAdded({required this.productId, this.variantId, this.quantity = 1});

  final String productId;
  final String? variantId;
  final int quantity;

  @override
  List<Object?> get props => [productId, variantId, quantity];
}

class CartItemQuantityChanged extends CartEvent {
  const CartItemQuantityChanged({required this.itemId, required this.quantity});

  final String itemId;
  final int quantity;

  @override
  List<Object?> get props => [itemId, quantity];
}

class CartItemRemoved extends CartEvent {
  const CartItemRemoved({required this.itemId});

  final String itemId;

  @override
  List<Object?> get props => [itemId];
}
