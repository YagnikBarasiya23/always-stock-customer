import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/extensions/app_extensions.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';

enum ProductStockFilter { all, low, out }

class ProductFilterResult {
  const ProductFilterResult({
    required this.stockFilter,
    required this.categoryId,
    required this.sort,
    required this.tags,
  });

  final ProductStockFilter stockFilter;
  final String? categoryId;
  final ProductSort? sort;
  final Set<String> tags;
}

/// Shows the sort/stock-status/category/tags filter sheet. Returns null if
/// dismissed without applying.
///
/// [categories] and [availableTags] are passed in as snapshots rather than
/// read from a bloc via context, because a bottom sheet is a sibling route on
/// the same Navigator, not a descendant of the page that opened it — a
/// page-scoped BlocProvider isn't visible to it.
Future<ProductFilterResult?> showProductFilterSheet(
  BuildContext context, {
  required ProductStockFilter initialStockFilter,
  required String? initialCategoryId,
  required ProductSort? initialSort,
  required Set<String> initialTags,
  required List<CategoryModel> categories,
  required List<String> availableTags,
}) => showModalBottomSheet<ProductFilterResult>(
  context: context,
  isScrollControlled: true,
  builder: (context) => ProductFilterSheet(
    initialStockFilter: initialStockFilter,
    initialCategoryId: initialCategoryId,
    initialSort: initialSort,
    initialTags: initialTags,
    categories: categories,
    availableTags: availableTags,
  ),
);

const _kSortLabels = {
  ProductSort.nameAsc: 'filter.name_az',
  ProductSort.nameDesc: 'filter.name_za',
  ProductSort.stockAsc: 'filter.stock_lh',
  ProductSort.stockDesc: 'filter.stock_hl',
  ProductSort.recent: 'products.sort_recent',
  ProductSort.updated: 'products.sort_updated',
};

class ProductFilterSheet extends StatefulWidget {
  const ProductFilterSheet({
    super.key,
    required this.initialStockFilter,
    required this.initialCategoryId,
    required this.initialSort,
    required this.initialTags,
    required this.categories,
    required this.availableTags,
  });

  final ProductStockFilter initialStockFilter;
  final String? initialCategoryId;
  final ProductSort? initialSort;
  final Set<String> initialTags;
  final List<CategoryModel> categories;
  final List<String> availableTags;

  @override
  State<ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends State<ProductFilterSheet> {
  late ProductStockFilter _stockFilter;
  late String? _categoryId;
  late ProductSort? _sort;
  late Set<String> _tags;

  @override
  void initState() {
    super.initState();
    _stockFilter = widget.initialStockFilter;
    _categoryId = widget.initialCategoryId;
    _sort = widget.initialSort;
    _tags = Set.of(widget.initialTags);
  }

  void _reset() => setState(() {
    _stockFilter = ProductStockFilter.all;
    _categoryId = null;
    _sort = null;
    _tags = {};
  });

  void _apply() => Navigator.of(context).pop(
    ProductFilterResult(
      stockFilter: _stockFilter,
      categoryId: _categoryId,
      sort: _sort,
      tags: _tags,
    ),
  );

  @override
  Widget build(BuildContext context) => Padding(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('filter.title'.tr(), style: AppTypography.style15Bold),
              GestureDetector(
                onTap: _reset,
                child: Text(
                  'filter.reset'.tr(),
                  style: AppTypography.style11SemiBold.copyWith(
                    color: context.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          18.heightBox,
          Text(
            'filter.sort_by'.tr(),
            style: AppTypography.style10Bold.copyWith(
              color: context.appColors.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
          8.heightBox,
          _SortOption(
            label: 'filter.default_order'.tr(),
            selected: _sort == null,
            onTap: () => setState(() => _sort = null),
          ),
          for (final entry in _kSortLabels.entries)
            _SortOption(
              label: entry.value.tr(),
              selected: _sort == entry.key,
              onTap: () => setState(() => _sort = entry.key),
            ),
          18.heightBox,
          Text(
            'filter.stock_status'.tr(),
            style: AppTypography.style10Bold.copyWith(
              color: context.appColors.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
          8.heightBox,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'filter.all'.tr(),
                selected: _stockFilter == ProductStockFilter.all,
                onTap: () =>
                    setState(() => _stockFilter = ProductStockFilter.all),
              ),
              _FilterChip(
                label: 'home.low_stock'.tr(),
                selected: _stockFilter == ProductStockFilter.low,
                color: context.appColors.warning,
                onTap: () =>
                    setState(() => _stockFilter = ProductStockFilter.low),
              ),
              _FilterChip(
                label: 'home.out_of_stock'.tr(),
                selected: _stockFilter == ProductStockFilter.out,
                color: Theme.of(context).colorScheme.error,
                onTap: () =>
                    setState(() => _stockFilter = ProductStockFilter.out),
              ),
            ],
          ),
          if (widget.categories.isNotEmpty) ...[
            18.heightBox,
            Text(
              'filter.category_caps'.tr(),
              style: AppTypography.style10Bold.copyWith(
                color: context.appColors.textSecondary,
                letterSpacing: 0.4,
              ),
            ),
            8.heightBox,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in widget.categories)
                  _FilterChip(
                    label: category.localizedName(context.locale.languageCode),
                    selected: _categoryId == category.id,
                    onTap: () => setState(
                      () => _categoryId = _categoryId == category.id
                          ? null
                          : category.id,
                    ),
                  ),
              ],
            ),
          ],
          if (widget.availableTags.isNotEmpty) ...[
            18.heightBox,
            Text(
              'filter.tags_caps'.tr(),
              style: AppTypography.style10Bold.copyWith(
                color: context.appColors.textSecondary,
                letterSpacing: 0.4,
              ),
            ),
            8.heightBox,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in widget.availableTags)
                  _FilterChip(
                    label: tag,
                    selected: _tags.contains(tag),
                    onTap: () => setState(
                      () => _tags.contains(tag)
                          ? _tags.remove(tag)
                          : _tags.add(tag),
                    ),
                  ),
              ],
            ),
            6.heightBox,
            Text(
              "From products currently loaded — there's no central tag list yet.",
              style: AppTypography.style10Regular.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
          ],
          20.heightBox,
          FilledButton(onPressed: _apply, child: Text('filter.apply'.tr())),
        ],
      ),
    ),
  );
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.style12Medium.copyWith(
                color: selected
                    ? context.primaryColor
                    : context.appColors.textPrimary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? context.primaryColor : Colors.transparent,
              border: Border.all(
                color: selected ? context.primaryColor : context.borderDefault,
                width: 1.5,
              ),
            ),
            child: selected
                ? const Icon(Icons.circle, size: 8, color: Colors.white)
                : null,
          ),
        ],
      ),
    ),
  );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? context.primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? activeColor : context.borderDefault,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.style11SemiBold.copyWith(
            color: selected ? activeColor : context.appColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
