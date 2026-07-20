import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/extensions/app_extensions.dart';
import '../../../../core/utils/app_prompts.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  void _logout(BuildContext context) => context.read<AuthBloc>().add(const AuthLogoutRequested());

  void _contactSupportForDeletion(BuildContext context) =>
      AppPrompts.info(context, 'profile.delete_help'.tr());

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final business = context.watch<AuthBloc>().state.business;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.emitState != current.emitState,
      listener: (context, state) {
        if (state.emitState == AuthEmitState.loggedOut && GoRouter.maybeOf(context) != null) {
          context.goNamed(RouteNames.login.name);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('profile.title'.tr())),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Column(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: context.primaryColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    _initials(user?.name ?? '?'),
                    style: AppTypography.style24Bold.copyWith(color: Colors.white),
                  ),
                ),
                10.heightBox,
                Text(user?.name ?? '—', style: AppTypography.style18Bold),
                2.heightBox,
                Text(
                  user?.email ?? '—',
                  style: AppTypography.style11Regular.copyWith(color: context.appColors.textSecondary),
                ),
                6.heightBox,
                if (user != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.appColors.successContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      user.role.name.toUpperCase(),
                      style: AppTypography.style10Bold.copyWith(color: context.appColors.success, letterSpacing: 0.4),
                    ),
                  ),
              ],
            ),
            20.heightBox,
            _GroupLabel('profile.contact'),
            _InfoList(
              rows: [_InfoRowData('profile.email'.tr(), user?.email ?? '—'), _InfoRowData('profile.phone'.tr(), user?.phone ?? 'profile.not_added'.tr())],
            ),
            16.heightBox,
            _GroupLabel('profile.business'),
            _InfoList(
              rows: [
                _InfoRowData('profile.name'.tr(), business?.name ?? '—'),
                _InfoRowData('profile.currency'.tr(), business?.currency ?? '—'),
                _InfoRowData('profile.timezone'.tr(), business?.timezone ?? '—'),
              ],
            ),
            10.heightBox,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                "To change your name, phone, or business details, contact support — self-serve editing isn't available yet.",
                style: AppTypography.style10Regular.copyWith(color: context.appColors.textSecondary),
              ),
            ),
            20.heightBox,
            _DangerRow(label: 'settings.logout'.tr(), onTap: () => _logout(context)),
            8.heightBox,
            _DangerRow(
              label: 'profile.delete_account'.tr(),
              subtitle: 'profile.delete_sub'.tr(),
              onTap: () => _contactSupportForDeletion(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
    child: Text(
      label.tr().toUpperCase(),
      style: AppTypography.style10Bold.copyWith(color: context.appColors.textSecondary, letterSpacing: 0.4),
    ),
  );
}

class _InfoRowData {
  const _InfoRowData(this.label, this.value);

  final String label;
  final String value;
}

class _InfoList extends StatelessWidget {
  const _InfoList({required this.rows});

  final List<_InfoRowData> rows;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.surfaceColor,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: context.borderDefault),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: Column(
      children: [
        for (var i = 0; i < rows.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              border: i == rows.length - 1 ? null : Border(bottom: BorderSide(color: context.borderDefault)),
            ),
            child: Row(
              children: [
                Text(
                  rows[i].label,
                  style: AppTypography.style11Regular.copyWith(color: context.appColors.textSecondary),
                ),
                const Spacer(),
                Text(rows[i].value, style: AppTypography.style12SemiBold),
              ],
            ),
          ),
      ],
    ),
  );
}

class _DangerRow extends StatelessWidget {
  const _DangerRow({required this.label, required this.onTap, this.subtitle});

  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: context.borderDefault),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.style12SemiBold.copyWith(color: errorColor)),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppTypography.style10Regular.copyWith(color: context.appColors.textSecondary),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
