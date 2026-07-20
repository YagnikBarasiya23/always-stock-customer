import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/common_widgets/custom_text_field.dart';
import '../../../../core/extensions/app_extensions.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/presentation/widgets/product_thumbnail.dart';
import '../../data/models/inventory_transaction_model.dart';
import '../bloc/inventory_bloc.dart';

enum _UpdateMode { add, remove, adjust }

/// Shows the Add/Remove/Adjust stock sheet. Returns true if a change was saved.
///
/// [inventoryBloc] is passed explicitly (rather than read via context) because a
/// bottom sheet is a sibling route on the same Navigator, not a descendant of the
/// page that opened it — so a page-scoped BlocProvider isn't visible to it.
Future<bool?> showStockUpdateSheet(
  BuildContext context, {
  required ProductModel product,
  required InventoryBloc inventoryBloc,
}) => showModalBottomSheet<bool>(
  context: context,
  isScrollControlled: true,
  builder: (context) =>
      StockUpdateSheet(product: product, inventoryBloc: inventoryBloc),
);

class StockUpdateSheet extends StatefulWidget {
  const StockUpdateSheet({
    super.key,
    required this.product,
    required this.inventoryBloc,
  });

  final ProductModel product;
  final InventoryBloc inventoryBloc;

  @override
  State<StockUpdateSheet> createState() => _StockUpdateSheetState();
}

class _StockUpdateSheetState extends State<StockUpdateSheet> {
  _UpdateMode _mode = _UpdateMode.add;
  TransactionType _addReason = TransactionType.add;
  TransactionType _removeReason = TransactionType.remove;

  final _quantityController = TextEditingController(text: '1');
  final _newStockController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _newStockController.text = widget.product.currentStock.toStringAsFixed(
      widget.product.currentStock.truncateToDouble() ==
              widget.product.currentStock
          ? 0
          : 1,
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _newStockController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _quantity => double.tryParse(_quantityController.text.trim()) ?? 0;

  void _stepQuantity(double delta) {
    final next = (_quantity + delta).clamp(0, double.infinity);
    setState(
      () => _quantityController.text = next.toStringAsFixed(
        next.truncateToDouble() == next ? 0 : 1,
      ),
    );
  }

  double? get _previewNewStock {
    final current = widget.product.currentStock;
    switch (_mode) {
      case _UpdateMode.add:
        return current + _quantity;
      case _UpdateMode.remove:
        return current - _quantity;
      case _UpdateMode.adjust:
        return double.tryParse(_newStockController.text.trim());
    }
  }

  String get _reasonNote => _noteController.text.trim();

  bool get _isValid {
    switch (_mode) {
      case _UpdateMode.add:
        return _quantity > 0;
      case _UpdateMode.remove:
        return _quantity > 0 && _quantity <= widget.product.currentStock;
      case _UpdateMode.adjust:
        final value = double.tryParse(_newStockController.text.trim());
        return value != null && value >= 0 && _reasonNote.isNotEmpty;
    }
  }

  Color _modeColor(BuildContext context) => switch (_mode) {
    _UpdateMode.add => context.appColors.success,
    _UpdateMode.remove => Theme.of(context).colorScheme.error,
    _UpdateMode.adjust => Theme.of(context).colorScheme.tertiary,
  };

  void _submit() {
    if (!_isValid) return;
    switch (_mode) {
      case _UpdateMode.add:
        widget.inventoryBloc.add(
          StockAddRequested(
            productId: widget.product.id,
            quantity: _quantity,
            reason: _reasonNote.isEmpty ? null : _reasonNote,
            type: _addReason,
          ),
        );
      case _UpdateMode.remove:
        widget.inventoryBloc.add(
          StockRemoveRequested(
            productId: widget.product.id,
            quantity: _quantity,
            reason: _reasonNote.isEmpty ? null : _reasonNote,
            type: _removeReason,
          ),
        );
      case _UpdateMode.adjust:
        widget.inventoryBloc.add(
          StockAdjustRequested(
            productId: widget.product.id,
            newStock: double.parse(_newStockController.text.trim()),
            reason: _reasonNote,
          ),
        );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<InventoryBloc, InventoryState>(
    bloc: widget.inventoryBloc,
    listenWhen: (previous, current) => previous.emitState != current.emitState,
    listener: (context, state) {
      if (state.emitState == InventoryEmitState.stockChanged) {
        Navigator.of(context).pop(true);
      }
    },
    builder: (context, state) {
      final isSaving = state.emitState == InventoryEmitState.saving;

      return Padding(
        padding: const EdgeInsets.fromLTRB(
          18,
          10,
          18,
          22,
        ).add(MediaQuery.viewInsetsOf(context)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.borderDefault,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              14.heightBox,
              Row(
                children: [
                  ProductThumbnail(
                    name: widget.product.localizedName(context.locale.languageCode),
                    imageUrl: widget.product.imageUrl,
                    size: 38,
                  ),
                  10.widthBox,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.localizedName(context.locale.languageCode),
                          style: AppTypography.style12Bold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'stock.in_stock'.tr(
                            args: [
                              widget.product.currentStock.toStringAsFixed(
                                widget.product.currentStock.truncateToDouble() == widget.product.currentStock ? 0 : 1,
                              ),
                              widget.product.unit,
                            ],
                          ),
                          style: AppTypography.style10Regular.copyWith(
                            color: context.appColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              14.heightBox,
              SegmentedButton<_UpdateMode>(
                segments: [
                  ButtonSegment(value: _UpdateMode.add, label: Text('stock.add'.tr())),
                  ButtonSegment(
                    value: _UpdateMode.remove,
                    label: Text('stock.remove'.tr()),
                  ),
                  ButtonSegment(
                    value: _UpdateMode.adjust,
                    label: Text('stock.adjust'.tr()),
                  ),
                ],
                selected: {_mode},
                showSelectedIcon: false,
                onSelectionChanged: (selection) =>
                    setState(() => _mode = selection.first),
              ),
              14.heightBox,
              if (_mode == _UpdateMode.add) ...[
                Text(
                  'stock.reason'.tr(),
                  style: AppTypography.style10SemiBold.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
                6.heightBox,
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Text('stock.restock'.tr()),
                        selected: _addReason == TransactionType.add,
                        onSelected: (_) =>
                            setState(() => _addReason = TransactionType.add),
                      ),
                    ),
                    8.widthBox,
                    Expanded(
                      child: ChoiceChip(
                        label: Text('stock.customer_return'.tr()),
                        selected: _addReason == TransactionType.returned,
                        onSelected: (_) => setState(
                          () => _addReason = TransactionType.returned,
                        ),
                      ),
                    ),
                  ],
                ),
                14.heightBox,
                _QuantityStepper(
                  controller: _quantityController,
                  unit: widget.product.unit,
                  onStep: _stepQuantity,
                  onChanged: (_) => setState(() {}),
                ),
              ] else if (_mode == _UpdateMode.remove) ...[
                Text(
                  'stock.reason'.tr(),
                  style: AppTypography.style10SemiBold.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
                6.heightBox,
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Text('stock.sold'.tr()),
                        selected: _removeReason == TransactionType.remove,
                        onSelected: (_) => setState(
                          () => _removeReason = TransactionType.remove,
                        ),
                      ),
                    ),
                    8.widthBox,
                    Expanded(
                      child: ChoiceChip(
                        label: Text('stock.damaged_wasted'.tr()),
                        selected: _removeReason == TransactionType.damaged,
                        onSelected: (_) => setState(
                          () => _removeReason = TransactionType.damaged,
                        ),
                      ),
                    ),
                  ],
                ),
                14.heightBox,
                _QuantityStepper(
                  controller: _quantityController,
                  unit: widget.product.unit,
                  onStep: _stepQuantity,
                  onChanged: (_) => setState(() {}),
                ),
                if (_quantity > widget.product.currentStock) ...[
                  8.heightBox,
                  Text(
                    'stock.cant_remove'.tr(
                      args: [widget.product.currentStock.toStringAsFixed(0), widget.product.unit],
                    ),
                    style: AppTypography.style10Regular.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ] else ...[
                CustomTextField(
                  controller: _newStockController,
                  headingLabelText: 'stock.new_stock_count'.tr(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
              14.heightBox,
              CustomTextField(
                controller: _noteController,
                headingLabelText: _mode == _UpdateMode.adjust
                    ? 'stock.reason'.tr()
                    : 'stock.note_opt'.tr(),
                hintText: _mode == _UpdateMode.adjust
                    ? 'stock.why_changing'.tr()
                    : null,
                onChanged: (_) => setState(() {}),
              ),
              14.heightBox,
              if (_previewNewStock != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: context.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'stock.new_stock'.tr(),
                        style: AppTypography.style10Regular.copyWith(
                          color: context.appColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${_previewNewStock!.toStringAsFixed(_previewNewStock!.truncateToDouble() == _previewNewStock! ? 0 : 1)} ${widget.product.unit}',
                        style: AppTypography.style12Bold.copyWith(
                          color:
                              _previewNewStock! >= widget.product.currentStock
                              ? context.appColors.success
                              : Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              18.heightBox,
              FilledButton(
                onPressed: isSaving || !_isValid ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: _modeColor(context),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Text(switch (_mode) {
                        _UpdateMode.add => 'stock.add_stock'.tr(),
                        _UpdateMode.remove => 'stock.remove_stock'.tr(),
                        _UpdateMode.adjust => 'stock.save_adjustment'.tr(),
                      }),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.controller,
    required this.unit,
    required this.onStep,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String unit;
  final ValueChanged<double> onStep;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: context.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        _StepperButton(icon: Icons.remove, onTap: () => onStep(-1)),
        Expanded(
          child: Column(
            children: [
              TextField(
                controller: controller,
                textAlign: TextAlign.center,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: AppTypography.style20Bold,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: onChanged,
              ),
              Text(
                unit,
                style: AppTypography.style10Regular.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _StepperButton(icon: Icons.add, onTap: () => onStep(1)),
      ],
    ),
  );
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18),
    ),
  );
}
