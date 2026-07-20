part of 'inventory_bloc.dart';

sealed class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object?> get props => [];
}

/// [type] may be [TransactionType.add] (default) or [TransactionType.returned].
class StockAddRequested extends InventoryEvent {
  const StockAddRequested({
    required this.productId,
    required this.quantity,
    this.reason,
    this.type,
  });

  final String productId;
  final double quantity;
  final String? reason;
  final TransactionType? type;

  @override
  List<Object?> get props => [productId, quantity, reason, type];
}

/// [type] may be [TransactionType.remove] (default) or [TransactionType.damaged].
class StockRemoveRequested extends InventoryEvent {
  const StockRemoveRequested({
    required this.productId,
    required this.quantity,
    this.reason,
    this.type,
  });

  final String productId;
  final double quantity;
  final String? reason;
  final TransactionType? type;

  @override
  List<Object?> get props => [productId, quantity, reason, type];
}

class StockAdjustRequested extends InventoryEvent {
  const StockAdjustRequested({
    required this.productId,
    required this.newStock,
    required this.reason,
  });

  final String productId;
  final double newStock;
  final String reason;

  @override
  List<Object?> get props => [productId, newStock, reason];
}

class InventoryHistoryRequested extends InventoryEvent {
  const InventoryHistoryRequested({this.productId, this.type, this.from, this.to});

  final String? productId;
  final TransactionType? type;
  final DateTime? from;
  final DateTime? to;

  @override
  List<Object?> get props => [productId, type, from, to];
}

class InventoryHistoryLoadMoreRequested extends InventoryEvent {
  const InventoryHistoryLoadMoreRequested();
}
