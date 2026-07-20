part of 'cart_bloc.dart';

class CartState extends Equatable {
  const CartState({
    this.emitState = CartEmitState.initial,
    this.cart,
    this.errorMessage,
  });

  final CartEmitState emitState;
  final CartModel? cart;
  final String? errorMessage;

  int get itemCount => cart?.itemCount ?? 0;

  CartState copyWith({
    CartEmitState? emitState,
    CartModel? cart,
    String? errorMessage,
    bool nullError = false,
  }) => CartState(
    emitState: emitState ?? this.emitState,
    cart: cart ?? this.cart,
    errorMessage: nullError ? null : (errorMessage ?? this.errorMessage),
  );

  CartState asLoading() => copyWith(emitState: CartEmitState.loading, nullError: true);
  CartState asError(String? errorMessage) => copyWith(emitState: CartEmitState.error, errorMessage: errorMessage);

  @override
  List<Object?> get props => [emitState, cart, errorMessage];
}

enum CartEmitState { initial, loading, updating, success, error }
