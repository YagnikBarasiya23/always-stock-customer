import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../config/theme/language_bloc.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/extensions/app_extensions.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

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

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
    context.read<AuthBloc>().add(AuthLanguageChanged(selected));
  }

  void _logout(BuildContext context) => context.read<AuthBloc>().add(const AuthLogoutRequested());

  @override
  Widget build(BuildContext context) {
    final business = context.watch<AuthBloc>().state.business;
    final user = context.watch<AuthBloc>().state.user;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.emitState != current.emitState,
      listener: (context, state) {
        if (state.emitState == AuthEmitState.loggedOut && GoRouter.maybeOf(context) != null) {
          context.goNamed(RouteNames.login.name);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('settings.title'.tr())),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            const _GroupLabel('settings.account'),
            _SettingsList(
              children: [
                _SettingsRow(
                  icon: Icons.person_outline,
                  iconBackground: context.primaryColor,
                  title: user?.name ?? 'settings.your_profile'.tr(),
                  subtitle: business != null ? '${user?.role.name.capitalizeFirst() ?? ''} · ${business.name}' : null,
                  onTap: () => context.pushNamed(RouteNames.profile.name),
                ),
              ],
            ),
            16.heightBox,
            const _GroupLabel('settings.preferences'),
            BlocBuilder<LanguageBloc, String>(
              builder: (context, code) {
                final current = _kLanguages.firstWhereOrNull((l) => l.code == code);
                return _SettingsList(
                  children: [
                    _SettingsRow(
                      icon: Icons.translate,
                      iconBackground: Theme.of(context).colorScheme.tertiaryContainer,
                      iconColor: Theme.of(context).colorScheme.tertiary,
                      title: 'settings.language'.tr(),
                      trailingText: current?.native,
                      onTap: () => _pickLanguage(context),
                    ),
                  ],
                );
              },
            ),
            // 8.heightBox,
            // _SettingsList(
            //   children: [
            //     _SettingsRow(
            //       icon: Icons.notifications_none,
            //       iconBackground: context.appColors.warningContainer,
            //       iconColor: context.appColors.warning,
            //       title: 'settings.notifications'.tr(),
            //       onTap: () => context.pushNamed(RouteNames.notificationPreferences.name),
            //     ),
            //   ],
            // ),
            16.heightBox,
            const _GroupLabel('settings.session'),
            _SettingsList(
              children: [
                _SettingsRow(
                  icon: Icons.logout,
                  iconBackground: Theme.of(context).colorScheme.errorContainer,
                  iconColor: Theme.of(context).colorScheme.error,
                  title: 'settings.logout'.tr(),
                  titleColor: Theme.of(context).colorScheme.error,
                  onTap: () => _logout(context),
                ),
              ],
            ),
            24.heightBox,
            Center(
              child: Text(
                'settings.version'.tr(),
                style: AppTypography.style10Regular.copyWith(color: context.appColors.textSecondary),
              ),
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

class _SettingsList extends StatelessWidget {
  const _SettingsList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: context.borderDefault),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) Divider(height: 1, color: context.borderDefault),
          children[i],
        ],
      ],
    ),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconBackground,
    required this.title,
    this.iconColor = Colors.white,
    this.subtitle,
    this.trailingText,
    this.titleColor,
    this.onTap,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final Color? titleColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      color: context.surfaceColor,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: iconBackground, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 15, color: iconColor),
          ),
          11.widthBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.style12SemiBold.copyWith(color: titleColor)),
                if (subtitle != null)
                  Text(subtitle!, style: AppTypography.style10Regular.copyWith(color: context.appColors.textSecondary)),
              ],
            ),
          ),
          if (trailingText != null) ...[
            Text(trailingText!, style: AppTypography.style11Regular.copyWith(color: context.appColors.textSecondary)),
            4.widthBox,
          ],
          if (onTap != null) Icon(Icons.chevron_right, size: 18, color: context.appColors.textSecondary),
        ],
      ),
    ),
  );
}
