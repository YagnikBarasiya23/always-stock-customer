import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../config/theme/language_bloc.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/common_widgets/custom_text_field.dart';
import '../../../../core/extensions/app_extensions.dart';
import '../../../../core/utils/app_prompts.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_hero_sheet_layout.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class _LanguageOption {
  const _LanguageOption({required this.code, required this.native, required this.english});

  final String code;
  final String native;
  final String english;
}

const _kLanguages = [
  _LanguageOption(code: 'en', native: 'English', english: 'English'),
  _LanguageOption(code: 'hi', native: 'हिन्दी', english: 'Hindi'),
  _LanguageOption(code: 'gu', native: 'ગુજરાતી', english: 'Gujarati'),
];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(AuthState state) {
    if (state.emitState == AuthEmitState.loading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
      AuthLoginRequested(email: _emailController.text.trim(), password: _passwordController.text),
    );
  }

  void _goToForgotPassword() {
    if (GoRouter.maybeOf(context) != null) context.pushNamed(RouteNames.forgotPassword.name);
  }

  void _goToRegister() {
    if (GoRouter.maybeOf(context) != null) context.pushNamed(RouteNames.register.name);
  }

  Future<void> _pickLanguage(BuildContext context) async {
    final currentCode = context.read<LanguageBloc>().state;
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final language in _kLanguages)
              ListTile(
                title: Text(language.native),
                subtitle: Text(language.english),
                trailing: language.code == currentCode ? Icon(Icons.check_circle, color: context.primaryColor) : null,
                onTap: () => context.pop(language.code),
              ),
          ],
        ),
      ),
    );

    if (selected == null || !context.mounted) return;
    context.read<LanguageBloc>().changeLanguage(selected);
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

        return Stack(
          children: [
            AuthHeroSheetLayout(
              heroHeightFraction: 0.32,
              heroChild: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AuthLogoMark(),
                  12.heightBox,
                  Text(
                    'ALWAYS STOCK',
                    style: AppTypography.style15Regular.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  4.heightBox,
                  Text(
                    'auth.tagline'.tr(),
                    style: AppTypography.style12Regular.copyWith(color: Colors.white.withValues(alpha: 0.75)),
                  ),
                ],
              ),
              sheetChild: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 28, 24, 24).add(MediaQuery.viewInsetsOf(context)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('auth.login_title'.tr(), style: AppTypography.style24Bold),
                      4.heightBox,
                      Text(
                        'auth.login_subtitle'.tr(),
                        style: AppTypography.style13Regular.copyWith(color: context.appColors.textSecondary),
                      ),
                      22.heightBox,
                      CustomTextField(
                        controller: _emailController,
                        headingLabelText: 'auth.email'.tr(),
                        hintText: 'owner@shopname.com',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (trimmed.isEmpty) return 'auth.enter_email'.tr();
                          if (!_emailPattern.hasMatch(trimmed)) {
                            return 'auth.valid_email'.tr();
                          }
                          return null;
                        },
                      ),
                      14.heightBox,
                      CustomTextField(
                        controller: _passwordController,
                        headingLabelText: 'auth.password'.tr(),
                        hintText: '••••••••••',
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onFieldSubmitted: (_) => _submit(state),
                        validator: (value) {
                          if ((value ?? '').isEmpty) return 'auth.enter_password'.tr();
                          if ((value ?? '').length < 6) {
                            return 'auth.password_min'.tr();
                          }
                          return null;
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isLoading ? null : _goToForgotPassword,
                          child: Text('auth.forgot_password'.tr()),
                        ),
                      ),
                      8.heightBox,
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: isLoading ? null : () => _submit(state),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                                )
                              : Text('auth.login_title'.tr()),
                        ),
                      ),
                      16.heightBox,
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            'auth.new_here'.tr(),
                            style: AppTypography.style13Regular.copyWith(color: context.appColors.textSecondary),
                          ),
                          GestureDetector(
                            onTap: _goToRegister,
                            child: Text(
                              'auth.create_account_link'.tr(),
                              style: AppTypography.style13SemiBold.copyWith(color: context.primaryColor),
                            ),
                          ),
                        ],
                      ).wrapCenter(),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 4,
              child: SafeArea(
                child: IconButton(
                  onPressed: () => _pickLanguage(context),
                  icon: const Icon(Icons.translate, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
