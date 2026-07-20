import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/extensions/app_extensions.dart';
import '../../../products/data/models/product_model.dart';
import '../../data/models/inventory_transaction_model.dart';
import '../bloc/inventory_bloc.dart';

enum _DateRange { last7, last30, all }

class StockHistoryScreen extends StatefulWidget {
  const StockHistoryScreen({super.key, required this.product});

  final ProductModel product;

  @override
  State<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends State<StockHistoryScreen> {
  final _scrollController = ScrollController();
  TransactionType? _typeFilter;
  _DateRange _range = _DateRange.last30;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _requestHistory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<InventoryBloc>().add(
        const InventoryHistoryLoadMoreRequested(),
      );
    }
  }

  DateTime? get _fromDate => switch (_range) {
    _DateRange.last7 => DateTime.now().subtract(const Duration(days: 7)),
    _DateRange.last30 => DateTime.now().subtract(const Duration(days: 30)),
    _DateRange.all => null,
  };

  void _requestHistory() => context.read<InventoryBloc>().add(
    InventoryHistoryRequested(
      productId: widget.product.id,
      type: _typeFilter,
      from: _fromDate,
    ),
  );

  void _selectType(TransactionType? type) {
    setState(() => _typeFilter = type);
    _requestHistory();
  }

  void _selectRange(_DateRange range) {
    setState(() => _range = range);
    _requestHistory();
  }

  Future<void> _pickRange() async {
    final selected = await showModalBottomSheet<_DateRange>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('history.last7'.tr()),
              onTap: () => context.pop(_DateRange.last7),
            ),
            ListTile(
              title: Text('history.last30'.tr()),
              onTap: () => context.pop(_DateRange.last30),
            ),
            ListTile(
              title: Text('history.all_time'.tr()),
              onTap: () => context.pop(_DateRange.all),
            ),
            8.heightBox,
          ],
        ),
      ),
    );
    if (selected != null) _selectRange(selected);
  }

  String get _rangeLabel => switch (_range) {
    _DateRange.last7 => 'Last 7 days',
    _DateRange.last30 => 'Last 30 days',
    _DateRange.all => 'All time',
  };

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.localizedName(context.locale.languageCode), maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: context.borderDefault),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _StockFigure(
                      value: product.currentStock,
                      unit: product.unit,
                      label: 'history.current_stock'.tr(),
                      color: product.isOutOfStock
                          ? Theme.of(context).colorScheme.error
                          : product.isLowStock
                          ? context.appColors.warning
                          : null,
                    ),
                  ),
                  Expanded(
                    child: _StockFigure(
                      value: product.lowStockThreshold,
                      unit: product.unit,
                      label: 'products.low_stock_threshold'.tr(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          12.heightBox,
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _Chip(
                  label: 'history.all'.tr(),
                  selected: _typeFilter == null,
                  onTap: () => _selectType(null),
                ),
                8.widthBox,
                _Chip(
                  label: 'history.added'.tr(),
                  selected: _typeFilter == TransactionType.add,
                  onTap: () => _selectType(TransactionType.add),
                ),
                8.widthBox,
                _Chip(
                  label: 'history.removed'.tr(),
                  selected: _typeFilter == TransactionType.remove,
                  onTap: () => _selectType(TransactionType.remove),
                ),
                8.widthBox,
                _Chip(
                  label: 'history.adjusted'.tr(),
                  selected: _typeFilter == TransactionType.adjust,
                  onTap: () => _selectType(TransactionType.adjust),
                ),
                8.widthBox,
                _Chip(
                  label: 'history.damaged'.tr(),
                  selected: _typeFilter == TransactionType.damaged,
                  onTap: () => _selectType(TransactionType.damaged),
                ),
                8.widthBox,
                _Chip(
                  label: 'history.returned'.tr(),
                  selected: _typeFilter == TransactionType.returned,
                  onTap: () => _selectType(TransactionType.returned),
                ),
                12.widthBox,
                _Chip(
                  label: _rangeLabel,
                  selected: false,
                  trailingIcon: true,
                  onTap: _pickRange,
                ),
              ],
            ),
          ),
          12.heightBox,
          Expanded(
            child: BlocBuilder<InventoryBloc, InventoryState>(
              builder: (context, state) {
                if (state.emitState == InventoryEmitState.loading &&
                    state.transactions.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.emitState == InventoryEmitState.error &&
                    state.transactions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.errorMessage ??
                                'history.load_error'.tr(),
                            textAlign: TextAlign.center,
                            style: AppTypography.style13Regular.copyWith(
                              color: context.appColors.textSecondary,
                            ),
                          ),
                          16.heightBox,
                          FilledButton(
                            onPressed: _requestHistory,
                            child: Text('common.try_again'.tr()),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state.transactions.isEmpty) {
                  return Center(
                    child: Text(
                      'history.no_activity_range'.tr(),
                      style: AppTypography.style12Regular.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  );
                }

                final groups = _groupByDay(state.transactions);

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: groups.length + (state.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= groups.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        ),
                      );
                    }
                    final group = groups[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 2, bottom: 8),
                            child: Text(
                              group.label,
                              style: AppTypography.style10Bold.copyWith(
                                color: context.appColors.textSecondary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: context.borderDefault),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                for (
                                  var i = 0;
                                  i < group.transactions.length;
                                  i++
                                ) ...[
                                  if (i > 0)
                                    Divider(
                                      height: 1,
                                      color: context.borderDefault,
                                    ),
                                  _HistoryRow(
                                    transaction: group.transactions[i],
                                    unit: product.unit,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<_DayGroup> _groupByDay(List<InventoryTransactionModel> transactions) {
    final now = DateTime.now();
    final groups = <String, List<InventoryTransactionModel>>{};

    for (final transaction in transactions) {
      // Server timestamps are UTC; bucket by the user's local calendar day.
      final time = transaction.createdAt?.toLocal();
      final String label;
      if (time == null) {
        label = 'common.unknown_date'.tr();
      } else {
        final isToday =
            time.year == now.year &&
            time.month == now.month &&
            time.day == now.day;
        final yesterday = now.subtract(const Duration(days: 1));
        final isYesterday =
            time.year == yesterday.year &&
            time.month == yesterday.month &&
            time.day == yesterday.day;
        if (isToday) {
          label = 'common.today'.tr();
        } else if (isYesterday) {
          label = 'common.yesterday'.tr();
        } else {
          label = DateFormat('MMM d').format(time);
        }
      }
      groups.putIfAbsent(label, () => []).add(transaction);
    }

    return groups.entries
        .map((e) => _DayGroup(label: e.key, transactions: e.value))
        .toList();
  }
}

class _DayGroup {
  const _DayGroup({required this.label, required this.transactions});

  final String label;
  final List<InventoryTransactionModel> transactions;
}

class _StockFigure extends StatelessWidget {
  const _StockFigure({
    required this.value,
    required this.unit,
    required this.label,
    this.color,
  });

  final double value;
  final String unit;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)} $unit',
        style: AppTypography.style18Bold.copyWith(color: color),
      ),
      2.heightBox,
      Text(
        label.toUpperCase(),
        style: AppTypography.style10SemiBold.copyWith(
          color: context.appColors.textSecondary,
          letterSpacing: 0.3,
        ),
      ),
    ],
  );
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailingIcon = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool trailingIcon;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: selected
            ? context.primaryColor.withValues(alpha: 0.16)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected ? context.primaryColor : context.borderDefault,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.style11SemiBold.copyWith(
              color: selected
                  ? context.primaryColor
                  : context.appColors.textSecondary,
            ),
          ),
          if (trailingIcon) ...[
            2.widthBox,
            Icon(
              Icons.expand_more,
              size: 14,
              color: context.appColors.textSecondary,
            ),
          ],
        ],
      ),
    ),
  );
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.transaction, required this.unit});

  final InventoryTransactionModel transaction;
  final String unit;

  static ({IconData icon, String label}) _presentation(TransactionType type) =>
      switch (type) {
        TransactionType.add => (icon: Icons.arrow_upward, label: 'txn.added'.tr()),
        TransactionType.remove => (
          icon: Icons.arrow_downward,
          label: 'txn.removed'.tr(),
        ),
        TransactionType.adjust => (icon: Icons.tune, label: 'txn.adjusted'.tr()),
        TransactionType.initial => (
          icon: Icons.flag_outlined,
          label: 'txn.initial'.tr(),
        ),
        TransactionType.damaged => (
          icon: Icons.warning_amber_rounded,
          label: 'txn.damaged'.tr(),
        ),
        TransactionType.returned => (icon: Icons.undo, label: 'txn.returned'.tr()),
        TransactionType.transfer => (
          icon: Icons.swap_horiz,
          label: 'txn.transferred'.tr(),
        ),
        TransactionType.unknown => (icon: Icons.help_outline, label: 'txn.updated'.tr()),
      };

  @override
  Widget build(BuildContext context) {
    final presentation = _presentation(transaction.type);
    final delta = transaction.newStock - transaction.previousStock;
    final isPositive = delta >= 0;
    final changeColor = isPositive
        ? context.appColors.success
        : Theme.of(context).colorScheme.error;
    final time = transaction.createdAt?.toLocal();

    return Container(
      color: context.surfaceColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isPositive
                  ? context.appColors.successContainer
                  : Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(presentation.icon, size: 14, color: changeColor),
          ),
          11.widthBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(presentation.label, style: AppTypography.style12SemiBold),
                if (transaction.reason != null &&
                    transaction.reason!.isNotEmpty)
                  Text(
                    transaction.reason!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.style10Regular.copyWith(
                      color: context.appColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : ''}${delta.toStringAsFixed(delta.truncateToDouble() == delta ? 0 : 1)}',
                style: AppTypography.style12Bold.copyWith(color: changeColor),
              ),
              Text(
                '${transaction.previousStock.toStringAsFixed(0)} → ${transaction.newStock.toStringAsFixed(0)}',
                style: AppTypography.style10Regular.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
              if (time != null)
                Text(
                  DateFormat('h:mm a').format(time),
                  style: AppTypography.style10Regular.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
