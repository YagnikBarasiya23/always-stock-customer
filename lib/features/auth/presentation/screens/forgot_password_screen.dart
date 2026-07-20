import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/common_widgets/custom_text_field.dart';
import '../../../../core/extensions/app_extensions.dart';
import '../../../../core/utils/app_prompts.dart';
import '../widgets/auth_hero_sheet_layout.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
const _resendCooldown = Duration(seconds: 45);

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _submitted = false;
  bool _isSending = false;
  Timer? _cooldownTimer;
  int _secondsRemaining = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _secondsRemaining = _resendCooldown.inSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _sendResetLink() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSending = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() {
      _isSending = false;
      _submitted = true;
    });
    _startCooldown();
  }

  void _resetToRequestState() {
    _cooldownTimer?.cancel();
    setState(() {
      _submitted = false;
      _secondsRemaining = 0;
    });
  }

  void _openEmailApp() =>
      AppPrompts.info(context, 'auth.email_app_not_wired'.tr());

  void _goBack() {
    if (GoRouter.maybeOf(context) != null) context.pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AuthHeroSheetLayout(
      heroHeightFraction: 0.24,
      heroChild: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AuthLogoMark(size: 52),
          10.heightBox,
          Text(
            'auth.reset_your_password'.tr(),
            style: AppTypography.style15Regular.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      sheetChild: _submitted
          ? _ConfirmationState(
              email: _emailController.text.trim(),
              secondsRemaining: _secondsRemaining,
              onOpenEmailApp: _openEmailApp,
              onResend: _secondsRemaining == 0 ? _sendResetLink : null,
              onTryAgain: _resetToRequestState,
            )
          : _RequestState(
              formKey: _formKey,
              emailController: _emailController,
              isSending: _isSending,
              onBack: _goBack,
              onSubmit: _sendResetLink,
            ),
    ),
  );
}

class _RequestState extends StatelessWidget {
  const _RequestState({
    required this.formKey,
    required this.emailController,
    required this.isSending,
    required this.onBack,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isSending;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(
      24,
      24,
      24,
      24,
    ).add(MediaQuery.viewInsetsOf(context)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: isSending ? null : onBack,
              icon: const Icon(Icons.arrow_back),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            8.widthBox,
            Text(
              'auth.back_to_login'.tr(),
              style: AppTypography.style12SemiBold.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
          ],
        ),
        16.heightBox,
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('auth.forgot_q'.tr(), style: AppTypography.style24Bold),
              4.heightBox,
              Text(
                'auth.forgot_help'.tr(),
                style: AppTypography.style13Regular.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
              22.heightBox,
              CustomTextField(
                controller: emailController,
                headingLabelText: 'auth.email'.tr(),
                hintText: 'owner@shopname.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onFieldSubmitted: (_) => onSubmit(),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return 'auth.enter_email'.tr();
                  if (!_emailPattern.hasMatch(trimmed)) {
                    return 'auth.valid_email'.tr();
                  }
                  return null;
                },
              ),
              20.heightBox,
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isSending ? null : onSubmit,
                  child: isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text('auth.send_reset'.tr()),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ConfirmationState extends StatelessWidget {
  const _ConfirmationState({
    required this.email,
    required this.secondsRemaining,
    required this.onOpenEmailApp,
    required this.onResend,
    required this.onTryAgain,
  });

  final String email;
  final int secondsRemaining;
  final VoidCallback onOpenEmailApp;
  final VoidCallback? onResend;
  final VoidCallback onTryAgain;

  String get _cooldownLabel =>
      '${secondsRemaining ~/ 60}:${(secondsRemaining % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: context.appColors.successContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.mark_email_read_outlined,
          color: context.appColors.success,
          size: 28,
        ),
      ),
      16.heightBox,
      Text(
        'auth.check_email'.tr(),
        style: AppTypography.style18Bold,
        textAlign: TextAlign.center,
      ),
      8.heightBox,
      Text.rich(
        TextSpan(
          style: AppTypography.style13Regular.copyWith(
            color: context.appColors.textSecondary,
          ),
          children: [
            TextSpan(text: 'auth.sent_link_to'.tr()),
            TextSpan(
              text: email,
              style: AppTypography.style13SemiBold.copyWith(
                color: context.appColors.textPrimary,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
      22.heightBox,
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onOpenEmailApp,
          child: Text('auth.open_email_app'.tr()),
        ),
      ),
      10.heightBox,
      if (onResend != null)
        TextButton(
          onPressed: onResend,
          child: Text('auth.resend'.tr()),
        )
      else
        Text(
          'auth.resend_in'.tr(args: [_cooldownLabel]),
          style: AppTypography.style12Regular.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
      4.heightBox,
      TextButton(
        onPressed: onTryAgain,
        child: Text('auth.wrong_email'.tr()),
      ),
    ],
  ).pAll(28);
}
