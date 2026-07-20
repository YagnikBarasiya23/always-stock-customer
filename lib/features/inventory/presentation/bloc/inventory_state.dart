part of 'inventory_bloc.dart';

class InventoryState extends Equatable {
  const InventoryState({
    this.emitState = InventoryEmitState.initial,
    this.transactions = const [],
    this.page = 1,
    this.hasMore = false,
    this.lastChange,
    this.errorMessage,
  });

  final InventoryEmitState emitState;
  final List<InventoryTransactionModel> transactions;
  final int page;
  final bool hasMore;

  /// Result of the most recent add/remove/adjust stock action.
  final StockChangeResultModel? lastChange;
  final String? errorMessage;

  InventoryState copyWith({
    InventoryEmitState? emitState,
    List<InventoryTransactionModel>? transactions,
    int? page,
    bool? hasMore,
    StockChangeResultModel? lastChange,
    String? errorMessage,
    bool nullError = false,
  }) => InventoryState(
    emitState: emitState ?? this.emitState,
    transactions: transactions ?? this.transactions,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    lastChange: lastChange ?? this.lastChange,
    errorMessage: nullError ? null : (errorMessage ?? this.errorMessage),
  );

  InventoryState asLoading() => copyWith(emitState: InventoryEmitState.loading, nullError: true);
  InventoryState asError(String? errorMessage) =>
      copyWith(emitState: InventoryEmitState.error, errorMessage: errorMessage);

  @override
  List<Object?> get props => [emitState, transactions, page, hasMore, lastChange, errorMessage];
}

enum InventoryEmitState { initial, loading, loadingMore, saving, success, stockChanged, error }
