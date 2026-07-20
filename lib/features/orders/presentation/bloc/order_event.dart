part of 'order_bloc.dart';

sealed class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class OrderItemsRequested extends OrderEvent {
  const OrderItemsRequested({this.orderId});

  final String? orderId;

  @override
  List<Object?> get props => [orderId];
}

class OrderItemsLoadMoreRequested extends OrderEvent {
  const OrderItemsLoadMoreRequested();
}
