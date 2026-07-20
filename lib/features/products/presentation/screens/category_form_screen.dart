import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/common_widgets/custom_text_field.dart';
import '../../../../core/extensions/app_extensions.dart';
import '../../../../core/utils/app_prompts.dart';
import '../../data/models/category_model.dart';
import '../bloc/category_bloc.dart';

class CategoryFormScreen extends StatefulWidget {
  const CategoryFormScreen({super.key, this.category});

  /// Null means "add a new category"; non-null means "edit this category".
  final CategoryModel? category;

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _nameHiController;
  late final TextEditingController _nameGuController;

  bool get _isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _nameHiController = TextEditingController(
      text: widget.category?.nameTranslations['hi'] ?? '',
    );
    _nameGuController = TextEditingController(
      text: widget.category?.nameTranslations['gu'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameHiController.dispose();
    _nameGuController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<CategoryBloc>().add(
      CategoryUpsertRequested(
        id: widget.category?.id,
        name: _nameController.text.trim(),
        nameTranslations: {
          'hi': _nameHiController.text.trim(),
          'gu': _nameGuController.text.trim(),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parentId = widget.category?.parentCategoryId;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'categories.edit'.tr() : 'categories.add'.tr())),
      body: BlocListener<CategoryBloc, CategoryState>(
        listenWhen: (previous, current) =>
            previous.emitState != current.emitState,
        listener: (context, state) {
          if (state.emitState == CategoryEmitState.saved) {
            AppPrompts.success(
              context,
              _isEdit ? 'categories.updated_toast'.tr() : 'categories.added_toast'.tr(),
            );
            context.pop(true);
          } else if (state.emitState == CategoryEmitState.error) {
            AppPrompts.error(
              context,
              state.errorMessage ?? 'common.something_went_wrong'.tr(),
            );
          }
        },
        child: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            final isSaving = state.emitState == CategoryEmitState.saving;
            final parentName = parentId == null
                ? null
                : state.categories
                      .firstWhereOrNull((c) => c.id == parentId)
                      ?.name;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                24,
              ).add(MediaQuery.viewInsetsOf(context)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      headingLabelText: 'categories.name'.tr(),
                      hintText: 'Groceries',
                      textCapitalization: TextCapitalization.words,
                      autofocus: !_isEdit,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => (value?.trim().isEmpty ?? true)
                          ? 'categories.enter_name'.tr()
                          : null,
                    ),
                    14.heightBox,
                    CustomTextField(
                      controller: _nameHiController,
                      headingLabelText: 'form.name_hi'.tr(),
                      hintText: 'किराना',
                      textInputAction: TextInputAction.next,
                    ),
                    14.heightBox,
                    CustomTextField(
                      controller: _nameGuController,
                      headingLabelText: 'form.name_gu'.tr(),
                      hintText: 'કરિયાણું',
                      textInputAction: TextInputAction.done,
                    ),
                    if (parentName != null) ...[
                      14.heightBox,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: context.surfaceColor,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: context.borderDefault),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_tree_outlined,
                              size: 14,
                              color: context.appColors.textSecondary,
                            ),
                            8.widthBox,
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  style: AppTypography.style11Regular.copyWith(
                                    color: context.appColors.textSecondary,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Subcategory of '),
                                    TextSpan(
                                      text: parentName,
                                      style: AppTypography.style11SemiBold
                                          .copyWith(
                                            color:
                                                context.appColors.textPrimary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    24.heightBox,
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: isSaving ? null : _submit,
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_isEdit ? 'form.save_changes'.tr() : 'categories.add'.tr()),
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
}
