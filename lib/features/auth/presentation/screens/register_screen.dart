import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/local/local_storage_services.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/common_widgets/custom_text_field.dart';
import '../../../../core/extensions/app_extensions.dart';
import '../../../../core/utils/app_prompts.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_hero_sheet_layout.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final _phonePattern = RegExp(r'^[0-9]{7,15}$');

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _accountFormKey = GlobalKey<FormState>();
  final _businessFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();

  int _step = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_step == 1) {
      setState(() => _step = 0);
    } else if (GoRouter.maybeOf(context) != null) {
      context.pop();
    }
  }

  void _continueToBusinessStep() {
    if (!(_accountFormKey.currentState?.validate() ?? false)) return;
    setState(() => _step = 1);
  }

  void _submit({required bool includeBusinessInfo}) {
    if (includeBusinessInfo && !(_businessFormKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: includeBusinessInfo && _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        businessName: includeBusinessInfo && _businessNameController.text.trim().isNotEmpty
            ? _businessNameController.text.trim()
            : null,
        preferredLanguage: LocalStorageServices.getLanguageCode(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.emitState != current.emitState,
      listener: (context, state) {
        if (state.emitState == AuthEmitState.error) {
          AppPrompts.error(context, state.errorMessage ?? 'common.something_went_wrong'.tr());
        } else if (state.emitState == AuthEmitState.loggedIn) {
          if (GoRouter.maybeOf(context) != null) context.goNamed(RouteNames.home.name);
        }
      },
      builder: (context, state) {
        final isLoading = state.emitState == AuthEmitState.loading;

        return AuthHeroSheetLayout(
          heroHeightFraction: 0.26,
          heroChild: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AuthLogoMark(size: 52),
              10.heightBox,
              Text(
                'auth.create_your_account'.tr(),
                style: AppTypography.style15Regular.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
              ),
              10.heightBox,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(2, (i) {
                  final active = i == _step;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ],
          ),
          sheetChild: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 24).add(MediaQuery.viewInsetsOf(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: isLoading ? null : _goBack,
                      icon: const Icon(Icons.arrow_back),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    8.widthBox,
                    Text(
                      'auth.back_to_login'.tr(),
                      style: AppTypography.style12SemiBold.copyWith(color: context.appColors.textSecondary),
                    ),
                  ],
                ),
                16.heightBox,
                if (_step == 0)
                  _AccountStep(
                    formKey: _accountFormKey,
                    name: _nameController,
                    email: _emailController,
                    password: _passwordController,
                  )
                else
                  _BusinessStep(
                    formKey: _businessFormKey,
                    businessName: _businessNameController,
                    phone: _phoneController,
                  ),
                8.heightBox,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isLoading
                        ? null
                        : _step == 0
                        ? _continueToBusinessStep
                        : () => _submit(includeBusinessInfo: true),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                          )
                        : Text(_step == 0 ? 'auth.continue_btn'.tr() : 'auth.create_account_btn'.tr()),
                  ),
                ),
                if (_step == 1) ...[
                  10.heightBox,
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: isLoading ? null : () => _submit(includeBusinessInfo: false),
                      child: Text('auth.skip_for_now'.tr()),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _AccountStep extends StatelessWidget {
  const _AccountStep({required this.formKey, required this.name, required this.email, required this.password});

  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController password;

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('auth.create_your_account'.tr(), style: AppTypography.style24Bold),
        4.heightBox,
        Text(
          'auth.step1'.tr(),
          style: AppTypography.style13Regular.copyWith(color: context.appColors.textSecondary),
        ),
        22.heightBox,
        CustomTextField(
          controller: name,
          headingLabelText: 'auth.full_name'.tr(),
          hintText: 'Priya Sharma',
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) => (value?.trim().isEmpty ?? true) ? 'auth.enter_full_name'.tr() : null,
        ),
        14.heightBox,
        CustomTextField(
          controller: email,
          headingLabelText: 'auth.email'.tr(),
          hintText: 'owner@shopname.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) return 'auth.enter_email'.tr();
            if (!_emailPattern.hasMatch(trimmed)) return 'auth.valid_email'.tr();
            return null;
          },
        ),
        14.heightBox,
        CustomTextField(
          controller: password,
          headingLabelText: 'auth.password'.tr(),
          hintText: '••••••••••',
          isPassword: true,
          textInputAction: TextInputAction.done,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if ((value ?? '').isEmpty) return 'auth.enter_a_password'.tr();
            if ((value ?? '').length < 6) {
              return 'auth.password_min'.tr();
            }
            return null;
          },
        ),
      ],
    ),
  );
}

class _BusinessStep extends StatelessWidget {
  const _BusinessStep({required this.formKey, required this.businessName, required this.phone});

  final GlobalKey<FormState> formKey;
  final TextEditingController businessName;
  final TextEditingController phone;

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('auth.about_shop'.tr(), style: AppTypography.style24Bold),
        4.heightBox,
        Text(
          'auth.step2'.tr(),
          style: AppTypography.style13Regular.copyWith(color: context.appColors.textSecondary),
        ),
        22.heightBox,
        CustomTextField(
          controller: businessName,
          headingLabelText: 'auth.business_name_opt'.tr(),
          hintText: 'Sharma Kirana Store',
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
        14.heightBox,
        CustomTextField(
          controller: phone,
          headingLabelText: 'auth.phone_opt'.tr(),
          hintText: '+91 98765 43210',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) return null;
            if (!_phonePattern.hasMatch(trimmed.replaceAll(RegExp(r'[\s+]'), ''))) {
              return 'auth.valid_phone'.tr();
            }
            return null;
          },
        ),
      ],
    ),
  );
}
