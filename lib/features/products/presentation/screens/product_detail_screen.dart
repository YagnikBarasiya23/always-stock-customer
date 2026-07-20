import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/extensions/app_extensions.dart';
import '../../../../core/utils/app_prompts.dart';
import '../../../inventory/data/models/inventory_transaction_model.dart';
import '../../../inventory/presentation/bloc/inventory_bloc.dart';
import '../../../inventory/presentation/widgets/stock_update_sheet.dart';
import '../../data/models/product_model.dart';
import '../bloc/category_bloc.dart';
import '../widgets/product_thumbnail.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final ProductModel product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductModel _product;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    context.read<CategoryBloc>().add(const CategoryListRequested());
    context.read<InventoryBloc>().add(InventoryHistoryRequested(productId: _product.id));
  }

  Future<void> _updateStock() async {
    final changed = await showStockUpdateSheet(
      context,
      product: _product,
      inventoryBloc: context.read<InventoryBloc>(),
    );
    if (changed == true) _changed = true;
  }

  Future<void> _editProduct() async {
    final saved = await context.pushNamed<bool>(RouteNames.productForm.name, extra: _product);
    if (saved == true) _changed = true;
  }

  void _openHistory() => context.pushNamed(RouteNames.productHistory.name, extra: _product);

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) context.pop(_changed);
    },
    child: Scaffold(
      appBar: AppBar(title: Text('detail.product'.tr())),
      body: BlocListener<InventoryBloc, InventoryState>(
        listenWhen: (previous, current) => previous.emitState != current.emitState,
        listener: (context, state) {
          if (state.emitState == InventoryEmitState.stockChanged && state.lastChange != null) {
            setState(() {
              _product = state.lastChange!.product;
              _changed = true;
            });
            AppPrompts.success(context, 'detail.stock_updated'.tr());
            context.read<InventoryBloc>().add(InventoryHistoryRequested(productId: _product.id));
          } else if (state.emitState == InventoryEmitState.error) {
            AppPrompts.error(context, state.errorMessage ?? 'common.something_went_wrong'.tr());
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            children: [
              ProductThumbnail(name: _product.localizedName(context.locale.languageCode), imageUrl: _product.imageUrl, size: 88, borderRadius: 18),
              10.heightBox,
              Text(_product.localizedName(context.locale.languageCode), style: AppTypography.style18Bold, textAlign: TextAlign.center),
              4.heightBox,
              Text(
                [
                  if (_product.sku != null && _product.sku!.isNotEmpty) 'SKU ${_product.sku}',
                  if (_product.barcode != null && _product.barcode!.isNotEmpty) 'Barcode ${_product.barcode}',
                ].join(' · '),
                style: AppTypography.style11Regular.copyWith(color: context.appColors.textSecondary),
              ),
              if (!_product.isActive) ...[
                6.heightBox,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: context.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'detail.inactive_caps'.tr(),
                    style: AppTypography.style10Bold.copyWith(
                      color: context.appColors.textSecondary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
              20.heightBox,
              _StatCard(product: _product),
              14.heightBox,
              _QuickActions(onUpdateStock: _updateStock, onHistory: _openHistory, onEdit: _editProduct),
              14.heightBox,
              _InfoCard(product: _product),
              18.heightBox,
              InkWell(
                onTap: _openHistory,
                child: Row(
                  children: [
                    Expanded(child: Text('detail.recent_activity'.tr(), style: AppTypography.style13Bold)),
                    Text('common.see_all'.tr(), style: AppTypography.style11SemiBold.copyWith(color: context.primaryColor)),
                  ],
                ),
              ),
              8.heightBox,
              BlocBuilder<InventoryBloc, InventoryState>(
                builder: (context, state) {
                  if (state.emitState == InventoryEmitState.loading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
                    );
                  }
                  if (state.transactions.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 22),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: context.borderDefault),
                      ),
                      child: Text(
                        'detail.no_activity'.tr(),
                        style: AppTypography.style12Regular.copyWith(color: context.appColors.textSecondary),
                      ),
                    );
                  }
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.borderDefault),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (var i = 0; i < state.transactions.length; i++) ...[
                          if (i > 0) Divider(height: 1, color: context.borderDefault),
                          _ActivityRow(transaction: state.transactions[i]),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final margin = product.costPrice != null && product.costPrice! > 0 && product.sellingPrice != null
        ? ((product.sellingPrice! - product.costPrice!) / product.costPrice! * 100)
        : null;
    final stockColor = product.isOutOfStock
        ? Theme.of(context).colorScheme.error
        : product.isLowStock
        ? context.appColors.warning
        : context.appColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderDefault),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Stat(
              value: product.currentStock.toStringAsFixed(
                product.currentStock.truncateToDouble() == product.currentStock ? 0 : 1,
              ),
              label: 'detail.current_stock_unit'.tr(args: [product.unit]),
              color: stockColor,
            ),
          ),
          Container(width: 1, height: 32, color: context.borderDefault),
          Expanded(
            child: _Stat(
              value: product.lowStockThreshold.toStringAsFixed(
                product.lowStockThreshold.truncateToDouble() == product.lowStockThreshold ? 0 : 1,
              ),
              label: 'products.low_stock_threshold'.tr(),
            ),
          ),
          if (margin != null) ...[
            Container(width: 1, height: 32, color: context.borderDefault),
            Expanded(
              child: _Stat(value: '${margin.toStringAsFixed(0)}%', label: 'detail.margin'.tr(), color: context.appColors.success),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.color});

  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: AppTypography.style24Bold.copyWith(color: color, height: 1)),
      5.heightBox,
      Text(
        label,
        textAlign: TextAlign.center,
        style: AppTypography.style10Medium.copyWith(color: context.appColors.textSecondary),
      ),
    ],
  );
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onUpdateStock, required this.onHistory, required this.onEdit});

  final VoidCallback onUpdateStock;
  final VoidCallback onHistory;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _ActionButton(
          icon: Icons.swap_vert,
          label: 'detail.update_stock'.tr(),
          color: context.primaryColor,
          background: Theme.of(context).colorScheme.primaryContainer,
          onTap: onUpdateStock,
        ),
      ),
      8.widthBox,
      Expanded(
        child: _ActionButton(
          icon: Icons.history,
          label: 'detail.history'.tr(),
          color: Theme.of(context).colorScheme.tertiary,
          background: Theme.of(context).colorScheme.tertiaryContainer,
          onTap: onHistory,
        ),
      ),
      8.widthBox,
      Expanded(
        child: _ActionButton(
          icon: Icons.edit_outlined,
          label: 'detail.edit'.tr(),
          color: context.appColors.textPrimary,
          background: context.surfaceContainerHighest,
          onTap: onEdit,
        ),
      ),
    ],
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderDefault),
      ),
      child: Column(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 15, color: color),
          ),
          5.heightBox,
          Text(label, style: AppTypography.style10SemiBold),
        ],
      ),
    ),
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderDefault),
      ),
      child: Column(
        children: [
          _InfoRow(label: 'detail.cost_price'.tr(), value: product.costPrice != null ? priceFormat.format(product.costPrice) : '—'),
          _InfoRow(
            label: 'detail.selling_price'.tr(),
            value: product.sellingPrice != null ? priceFormat.format(product.sellingPrice) : '—',
          ),
          _InfoRow(
            label: 'detail.category'.tr(),
            value: BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                final name = state.categories.firstWhereOrNull((c) => c.id == product.categoryId)?.localizedName(context.locale.languageCode);
                return Text(name ?? '—', style: AppTypography.style12SemiBold);
              },
            ),
          ),
          if (product.tags.isNotEmpty)
            _InfoRow(
              label: 'detail.tags'.tr(),
              value: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final tag in product.tags)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: context.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        tag,
                        style: AppTypography.style10SemiBold.copyWith(color: context.appColors.textSecondary),
                      ),
                    ),
                ],
              ),
              isLast: true,
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.isLast = false});

  final String label;
  final dynamic value;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 11),
    decoration: BoxDecoration(
      border: isLast ? null : Border(bottom: BorderSide(color: context.borderDefault)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: AppTypography.style11Regular.copyWith(color: context.appColors.textSecondary)),
        const Spacer(),
        if (value is String)
          Text(value as String, style: AppTypography.style12SemiBold)
        else
          Flexible(child: value as Widget),
      ],
    ),
  );
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.transaction});

  final InventoryTransactionModel transaction;

  static ({IconData icon, String label}) _presentation(TransactionType type) => switch (type) {
    TransactionType.add => (icon: Icons.arrow_upward, label: 'txn.added'.tr()),
    TransactionType.remove => (icon: Icons.arrow_downward, label: 'txn.removed'.tr()),
    TransactionType.adjust => (icon: Icons.tune, label: 'txn.adjusted'.tr()),
    TransactionType.initial => (icon: Icons.flag_outlined, label: 'txn.initial'.tr()),
    TransactionType.damaged => (icon: Icons.warning_amber_rounded, label: 'txn.damaged'.tr()),
    TransactionType.returned => (icon: Icons.undo, label: 'txn.returned'.tr()),
    TransactionType.transfer => (icon: Icons.swap_horiz, label: 'txn.transferred'.tr()),
    TransactionType.unknown => (icon: Icons.help_outline, label: 'txn.updated'.tr()),
  };

  static String _relativeTime(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'common.just_now'.tr();
    if (diff.inMinutes < 60) return 'common.min_ago'.tr(args: ['${diff.inMinutes}']);
    if (diff.inHours < 24) return 'common.hr_ago'.tr(args: ['${diff.inHours}']);
    if (diff.inDays < 7) return 'common.d_ago'.tr(args: ['${diff.inDays}']);
    return DateFormat('MMM d').format(time.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final presentation = _presentation(transaction.type);
    final delta = transaction.newStock - transaction.previousStock;
    final isPositive = delta >= 0;
    final changeColor = isPositive ? context.appColors.success : Theme.of(context).colorScheme.error;

    return Container(
      color: context.surfaceColor,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      child: Row(
        children: [
          Icon(presentation.icon, size: 15, color: changeColor),
          10.widthBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(presentation.label.tr(), style: AppTypography.style12SemiBold),
                Text(
                  _relativeTime(transaction.createdAt),
                  style: AppTypography.style10Regular.copyWith(color: context.appColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}${delta.toStringAsFixed(delta.truncateToDouble() == delta ? 0 : 1)}',
            style: AppTypography.style12Bold.copyWith(color: changeColor),
          ),
        ],
      ),
    );
  }
}
