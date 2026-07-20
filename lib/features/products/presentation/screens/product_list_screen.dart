import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/extensions/app_extensions.dart';
import '../../data/models/product_model.dart';
import '../bloc/category_bloc.dart';
import '../bloc/product_bloc.dart';
import '../widgets/product_filter_sheet.dart';
import '../widgets/product_thumbnail.dart';
import '../widgets/stock_status_pill.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  ProductStockFilter _stockFilter = ProductStockFilter.all;
  String? _categoryId;
  ProductSort? _sort;
  Set<String> _tags = {};

  bool get _hasActiveFilters =>
      _stockFilter != ProductStockFilter.all || _categoryId != null || _sort != null || _tags.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductBloc>().add(const ProductLoadMoreRequested());
    }
  }

  void _request() {
    _searchController.clear();
    context.read<ProductBloc>().add(
      ProductListRequested(
        lowStock: _stockFilter == ProductStockFilter.low ? true : null,
        outOfStock: _stockFilter == ProductStockFilter.out ? true : null,
        categoryId: _categoryId,
        tags: _tags.isEmpty ? null : _tags.toList(),
        sort: _sort,
      ),
    );
  }

  void _submitSearch(String value) {
    final query = value.trim();
    if (query.isEmpty) {
      _request();
      return;
    }
    context.read<ProductBloc>().add(ProductListRequested(query: query));
  }

  Future<void> _openFilters() async {
    final products = context.read<ProductBloc>().state.products;
    final availableTags = products.expand((p) => p.tags).toSet().toList()..sort();

    final result = await showProductFilterSheet(
      context,
      initialStockFilter: _stockFilter,
      initialCategoryId: _categoryId,
      initialSort: _sort,
      initialTags: _tags,
      categories: context.read<CategoryBloc>().state.categories,
      availableTags: availableTags,
    );
    if (result == null) return;

    setState(() {
      _stockFilter = result.stockFilter;
      _categoryId = result.categoryId;
      _sort = result.sort;
      _tags = result.tags;
    });
    _request();
  }

  void _clearStockFilter() {
    setState(() => _stockFilter = ProductStockFilter.all);
    _request();
  }

  void _clearCategoryFilter() {
    setState(() => _categoryId = null);
    _request();
  }

  void _clearSort() {
    setState(() => _sort = null);
    _request();
  }

  void _clearTag(String tag) {
    setState(() => _tags = {..._tags}..remove(tag));
    _request();
  }

  Future<void> _openAddProduct() async {
    final saved = await context.pushNamed<bool>(RouteNames.productForm.name);
    if (saved == true && mounted) _request();
  }

  Future<void> _openDetail(ProductModel product) async {
    final changed = await context.pushNamed<bool>(RouteNames.productDetail.name, extra: product);
    if (changed == true && mounted) _request();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('products.title'.tr(), style: AppTypography.style18Bold),
            2.heightBox,
            Text(
              'products.count'.plural(state.products.length, args: ['${state.products.length}${state.hasMore ? '+' : ''}']),
              style: AppTypography.style10SemiBold.copyWith(color: context.appColors.textSecondary),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => context.pushNamed(RouteNames.categories.name),
          icon: const Icon(Icons.category_outlined),
        ),
        IconButton.filled(onPressed: _openAddProduct, icon: const Icon(Icons.add)),
      ],
    ),
    body: Column(
      children: [
        16.heightBox,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _submitSearch,
                  decoration: InputDecoration(
                    hintText: 'products.search_hint'.tr(),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide.none),
                  ),
                ),
              ),
              8.widthBox,
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: _openFilters,
                    style: IconButton.styleFrom(
                      backgroundColor: context.surfaceContainerHighest,
                      shape: const CircleBorder(),
                    ),
                    icon: const Icon(Icons.tune),
                  ),
                  if (_hasActiveFilters)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: context.primaryColor, shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (_hasActiveFilters) ...[
          10.heightBox,
          SizedBox(
            height: 30,
            child: BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, categoryState) {
                final categoryName = categoryState.categories.firstWhereOrNull((c) => c.id == _categoryId)?.localizedName(context.locale.languageCode);
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    if (_stockFilter != ProductStockFilter.all)
                      _ActiveChip(
                        label: _stockFilter == ProductStockFilter.low ? 'home.low_stock'.tr() : 'home.out_of_stock'.tr(),
                        onRemove: _clearStockFilter,
                      ),
                    if (categoryName != null) ...[
                      6.widthBox,
                      _ActiveChip(label: categoryName, onRemove: _clearCategoryFilter),
                    ],
                    if (_sort != null) ...[
                      6.widthBox,
                      _ActiveChip(label: (_kSortShortLabels[_sort] ?? 'products.sorted').tr(), onRemove: _clearSort),
                    ],
                    for (final tag in _tags) ...[6.widthBox, _ActiveChip(label: tag, onRemove: () => _clearTag(tag))],
                  ],
                );
              },
            ),
          ),
        ],
        14.heightBox,
        Expanded(
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state.emitState == ProductEmitState.loading && state.products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.emitState == ProductEmitState.error && state.products.isEmpty) {
                return _EmptyState(message: state.errorMessage ?? 'products.load_error'.tr(), onRetry: _request);
              }

              if (state.products.isEmpty) {
                return _EmptyState(message: 'products.none_found'.tr());
              }

              return ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: state.products.length + (state.hasMore ? 1 : 0),
                separatorBuilder: (context, index) => 8.heightBox,
                itemBuilder: (context, index) {
                  if (index >= state.products.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
                    );
                  }
                  final product = state.products[index];
                  return _ProductRow(product: product, onTap: () => _openDetail(product));
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}

const _kSortShortLabels = {
  ProductSort.nameAsc: 'products.sort_name_az',
  ProductSort.nameDesc: 'products.sort_name_za',
  ProductSort.stockAsc: 'products.sort_stock_up',
  ProductSort.stockDesc: 'products.sort_stock_down',
  ProductSort.recent: 'products.sort_recent',
  ProductSort.updated: 'products.sort_updated',
};

class _ActiveChip extends StatelessWidget {
  const _ActiveChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.only(left: 12, right: 6),
    decoration: BoxDecoration(
      color: context.primaryColor.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: context.primaryColor),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTypography.style11SemiBold.copyWith(color: context.primaryColor)),
        4.widthBox,
        InkWell(
          onTap: onRemove,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.close, size: 13, color: context.primaryColor),
          ),
        ),
      ],
    ),
  );
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product, required this.onTap});

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: context.borderDefault),
        ),
        child: Row(
          children: [
            ProductThumbnail(name: product.localizedName(context.locale.languageCode), imageUrl: product.imageUrl),
            11.widthBox,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.localizedName(context.locale.languageCode),
                    style: AppTypography.style12SemiBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  2.heightBox,
                  Text(
                    [
                      if (product.sku != null && product.sku!.isNotEmpty) 'SKU ${product.sku}',
                      product.unit,
                    ].join(' · '),
                    style: AppTypography.style10Regular.copyWith(color: context.appColors.textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  product.sellingPrice != null ? priceFormat.format(product.sellingPrice) : '—',
                  style: AppTypography.style12Bold,
                ),
                4.heightBox,
                StockStatusPill(product: product),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, color: context.appColors.textSecondary, size: 36),
          12.heightBox,
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.style13Regular.copyWith(color: context.appColors.textSecondary),
          ),
          if (onRetry != null) ...[16.heightBox, FilledButton(onPressed: onRetry, child: Text('common.try_again'.tr()))],
        ],
      ),
    ),
  );
}
