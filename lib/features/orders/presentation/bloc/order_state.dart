part of 'order_bloc.dart';

class OrderState extends Equatable {
  const OrderState({
    this.emitState = OrderEmitState.initial,
    this.orderItems = const [],
    this.page = 1,
    this.hasMore = false,
    this.errorMessage,
  });

  final OrderEmitState emitState;
  final List<OrderItemModel> orderItems;
  final int page;
  final bool hasMore;
  final String? errorMessage;

  OrderState copyWith({
    OrderEmitState? emitState,
    List<OrderItemModel>? orderItems,
    int? page,
    bool? hasMore,
    String? errorMessage,
    bool nullError = false,
  }) => OrderState(
    emitState: emitState ?? this.emitState,
    orderItems: orderItems ?? this.orderItems,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    errorMessage: nullError ? null : (errorMessage ?? this.errorMessage),
  );

  OrderState asLoading() => copyWith(emitState: OrderEmitState.loading, nullError: true);
  OrderState asError(String? errorMessage) => copyWith(emitState: OrderEmitState.error, errorMessage: errorMessage);

  @override
  List<Object?> get props => [emitState, orderItems, page, hasMore, errorMessage];
}

enum OrderEmitState { initial, loading, loadingMore, success, error }
