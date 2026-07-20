import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/common_widgets/custom_text_field.dart';
import '../../../../core/extensions/app_extensions.dart';
import '../../../../core/utils/app_prompts.dart';
import '../../data/models/product_model.dart';
import '../bloc/category_bloc.dart';
import '../bloc/product_bloc.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  /// Null means "add a new product"; non-null means "edit this product".
  final ProductModel? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tagController = TextEditingController();

  late final TextEditingController _nameController;
  late final TextEditingController _nameHiController;
  late final TextEditingController _nameGuController;
  late final TextEditingController _skuController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _unitController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _lowStockThresholdController;
  late final TextEditingController _initialStockController;

  String? _categoryId;
  late List<String> _tags;
  late bool _isActive;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _nameHiController = TextEditingController(text: product?.nameTranslations['hi'] ?? '');
    _nameGuController = TextEditingController(text: product?.nameTranslations['gu'] ?? '');
    _skuController = TextEditingController(text: product?.sku ?? '');
    _barcodeController = TextEditingController(text: product?.barcode ?? '');
    _unitController = TextEditingController(text: product?.unit ?? 'pcs');
    _costPriceController = TextEditingController(text: product?.costPrice?.toString() ?? '');
    _sellingPriceController = TextEditingController(text: product?.sellingPrice?.toString() ?? '');
    _lowStockThresholdController = TextEditingController(text: product?.lowStockThreshold.toString() ?? '');
    _initialStockController = TextEditingController();
    _categoryId = product?.categoryId;
    _tags = List.of(product?.tags ?? const []);
    _isActive = product?.isActive ?? true;

    context.read<CategoryBloc>().add(const CategoryListRequested());
  }

  @override
  void dispose() {
    _tagController.dispose();
    _nameController.dispose();
    _nameHiController.dispose();
    _nameGuController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _unitController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _lowStockThresholdController.dispose();
    _initialStockController.dispose();
    super.dispose();
  }

  void _addTag(String value) {
    final tag = value.trim();
    if (tag.isEmpty || _tags.contains(tag)) return;
    setState(() => _tags.add(tag));
    _tagController.clear();
  }

  void _removeTag(String tag) => setState(() => _tags.remove(tag));

  Future<void> _pickCategory() async {
    final categories = context.read<CategoryBloc>().state.categories;
    final selected = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text('form.no_category'.tr()), onTap: () => sheetContext.pop(null)),
            for (final category in categories)
              ListTile(title: Text(category.localizedName(context.locale.languageCode)), onTap: () => sheetContext.pop(category.id)),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: Text('form.manage_categories'.tr()),
              onTap: () async {
                sheetContext.pop(_categoryId);
                await context.pushNamed(RouteNames.categories.name);
                if (!mounted) return;
                context.read<CategoryBloc>().add(const CategoryListRequested());
              },
            ),
            16.heightBox,
          ],
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _categoryId = selected);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<ProductBloc>().add(
      ProductUpsertRequested(
        ProductUpsertRequest(
          id: widget.product?.id,
          name: _nameController.text.trim(),
          nameTranslations: {
            'hi': _nameHiController.text.trim(),
            'gu': _nameGuController.text.trim(),
          },
          sku: _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
          barcode: _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
          categoryId: _categoryId,
          unit: _unitController.text.trim().isEmpty ? 'pcs' : _unitController.text.trim(),
          costPrice: double.tryParse(_costPriceController.text.trim()),
          sellingPrice: double.tryParse(_sellingPriceController.text.trim()),
          lowStockThreshold: double.tryParse(_lowStockThresholdController.text.trim()) ?? 0,
          initialStock: _isEdit ? null : double.tryParse(_initialStockController.text.trim()),
          tags: _tags,
          isActive: _isEdit ? _isActive : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_isEdit ? 'form.edit_product'.tr() : 'form.add_product'.tr())),
    body: BlocListener<ProductBloc, ProductState>(
      listenWhen: (previous, current) => previous.emitState != current.emitState,
      listener: (context, state) {
        if (state.emitState == ProductEmitState.saved) {
          AppPrompts.success(context, _isEdit ? 'form.product_updated'.tr() : 'form.product_added'.tr());
          context.pop(true);
        } else if (state.emitState == ProductEmitState.error) {
          AppPrompts.error(context, state.errorMessage ?? 'common.something_went_wrong'.tr());
        }
      },
      child: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          final isSaving = state.emitState == ProductEmitState.saving;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 24).add(MediaQuery.viewInsetsOf(context)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: _nameController,
                    headingLabelText: 'form.product_name'.tr(),
                    hintText: 'Tata Salt 1kg',
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => (value?.trim().isEmpty ?? true) ? 'form.enter_product_name'.tr() : null,
                  ),
                  14.heightBox,
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _nameHiController,
                          headingLabelText: 'form.name_hi'.tr(),
                          hintText: 'टाटा नमक 1 किलो',
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      10.widthBox,
                      Expanded(
                        child: CustomTextField(
                          controller: _nameGuController,
                          headingLabelText: 'form.name_gu'.tr(),
                          hintText: 'ટાટા મીઠું 1 કિલો',
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  14.heightBox,
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _skuController,
                          headingLabelText: 'form.sku_opt'.tr(),
                          hintText: 'TS-1000',
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      10.widthBox,
                      Expanded(
                        child: CustomTextField(
                          controller: _barcodeController,
                          headingLabelText: 'form.barcode_opt'.tr(),
                          hintText: 'form.scan_or_type'.tr(),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  14.heightBox,
                  Text(
                    'form.category_opt'.tr(),
                    style: AppTypography.style13Regular.copyWith(color: context.appColors.textSecondary),
                  ),
                  6.heightBox,
                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, categoryState) {
                      final name = categoryState.categories.firstWhereOrNull((c) => c.id == _categoryId)?.localizedName(context.locale.languageCode);
                      return InkWell(
                        onTap: _pickCategory,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: context.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name ?? 'form.no_category'.tr(),
                                  style: AppTypography.style15Regular.copyWith(
                                    color: name != null
                                        ? context.appColors.textPrimary
                                        : context.appColors.textSecondary,
                                  ),
                                ),
                              ),
                              Icon(Icons.expand_more, color: context.appColors.textSecondary),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  14.heightBox,
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _unitController,
                          headingLabelText: 'form.unit'.tr(),
                          hintText: 'pcs',
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      if (!_isEdit) ...[
                        10.widthBox,
                        Expanded(
                          child: CustomTextField(
                            controller: _initialStockController,
                            headingLabelText: 'form.starting_stock'.tr(),
                            hintText: '0',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (!_isEdit) ...[
                    6.heightBox,
                    Text(
                      'form.starting_stock_help'.tr(),
                      style: AppTypography.style10Regular.copyWith(color: context.appColors.textSecondary),
                    ),
                  ],
                  14.heightBox,
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _costPriceController,
                          headingLabelText: 'form.cost_price_opt'.tr(),
                          hintText: '0.00',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      10.widthBox,
                      Expanded(
                        child: CustomTextField(
                          controller: _sellingPriceController,
                          headingLabelText: 'form.selling_price_opt'.tr(),
                          hintText: '0.00',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  14.heightBox,
                  CustomTextField(
                    controller: _lowStockThresholdController,
                    headingLabelText: 'products.low_stock_threshold'.tr(),
                    hintText: '0',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                  ),
                  14.heightBox,
                  Text(
                    'form.tags_opt'.tr(),
                    style: AppTypography.style13Regular.copyWith(color: context.appColors.textSecondary),
                  ),
                  6.heightBox,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: context.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final tag in _tags)
                          Chip(
                            label: Text(tag),
                            onDeleted: () => _removeTag(tag),
                            visualDensity: VisualDensity.compact,
                          ),
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: _tagController,
                            onSubmitted: _addTag,
                            decoration: InputDecoration(
                              hintText: 'form.add_tag'.tr(),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isEdit) ...[
                    16.heightBox,
                    Material(
                      color: context.surfaceColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: context.borderDefault),
                      ),
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        title: Text('form.active'.tr()),
                        subtitle: Text(
                          'form.inactive_help'.tr(),
                          style: AppTypography.style10Regular.copyWith(color: context.appColors.textSecondary),
                        ),
                        value: _isActive,
                        onChanged: (value) => setState(() => _isActive = value),
                      ),
                    ),
                  ],
                  20.heightBox,
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isSaving ? null : _submit,
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                            )
                          : Text(_isEdit ? 'form.save_changes'.tr() : 'form.add_product'.tr()),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
