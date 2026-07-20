import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/extensions/app_extensions.dart';
import '../../data/models/category_model.dart';
import '../bloc/category_bloc.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  Future<void> _openAdd() async {
    final saved = await context.pushNamed<bool>(RouteNames.categoryForm.name);
    if (saved == true && mounted) {
      context.read<CategoryBloc>().add(const CategoryListRequested());
    }
  }

  Future<void> _openEdit(CategoryModel category) async {
    final saved = await context.pushNamed<bool>(RouteNames.categoryForm.name, extra: category);
    if (saved == true && mounted) {
      context.read<CategoryBloc>().add(const CategoryListRequested());
    }
  }

  List<Widget> _buildRows(List<CategoryModel> categories) {
    final topLevel = categories.where((c) => c.parentCategoryId == null).toList();
    final childless = categories.where(
      (c) => c.parentCategoryId != null && !categories.any((p) => p.id == c.parentCategoryId),
    );
    final roots = [...topLevel, ...childless];

    final rows = <Widget>[];
    for (final root in roots) {
      rows.add(_CategoryRow(category: root, isChild: false, onTap: () => _openEdit(root)));
      final children = categories.where((c) => c.parentCategoryId == root.id);
      for (final child in children) {
        rows.add(_CategoryRow(category: child, isChild: true, onTap: () => _openEdit(child)));
      }
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('categories.title'.tr(), style: AppTypography.style18Bold),
            Text(
              'categories.count'.plural(state.categories.length, args: ['${state.categories.length}']),
              style: AppTypography.style10SemiBold.copyWith(color: context.appColors.textSecondary),
            ),
          ],
        ),
      ),
      actions: [
        IconButton.filled(onPressed: _openAdd, icon: const Icon(Icons.add)),
        8.widthBox,
      ],
    ),
    body: SafeArea(
      child: Column(
        children: [
          8.heightBox,
          Expanded(
            child: BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state.emitState == CategoryEmitState.loading && state.categories.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.emitState == CategoryEmitState.error && state.categories.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.errorMessage ?? 'categories.load_error'.tr(),
                            textAlign: TextAlign.center,
                            style: AppTypography.style13Regular.copyWith(color: context.appColors.textSecondary),
                          ),
                          16.heightBox,
                          FilledButton(
                            onPressed: () => context.read<CategoryBloc>().add(const CategoryListRequested()),
                            child: Text('common.try_again'.tr()),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state.categories.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No categories yet — add one to organize your products.',
                        textAlign: TextAlign.center,
                        style: AppTypography.style13Regular.copyWith(color: context.appColors.textSecondary),
                      ),
                    ),
                  );
                }

                final rows = _buildRows(state.categories);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: context.borderDefault),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (var i = 0; i < rows.length; i++) ...[
                            if (i > 0) Divider(height: 1, color: context.borderDefault),
                            rows[i],
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.isChild, required this.onTap});

  final CategoryModel category;
  final bool isChild;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      color: context.surfaceColor,
      padding: EdgeInsets.fromLTRB(isChild ? 34 : 13, 12, 13, 12),
      child: Row(
        children: [
          Container(
            width: isChild ? 5 : 7,
            height: isChild ? 5 : 7,
            decoration: BoxDecoration(
              color: isChild ? context.appColors.textSecondary : context.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          10.widthBox,
          Expanded(
            child: Text(
              category.localizedName(context.locale.languageCode),
              style: isChild
                  ? AppTypography.style12Medium.copyWith(color: context.appColors.textSecondary)
                  : AppTypography.style12SemiBold,
            ),
          ),
          Icon(Icons.chevron_right, size: 18, color: context.appColors.textSecondary),
        ],
      ),
    ),
  );
}
