import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/utils/app_prompts.dart';
import '../../../auth/data/models/notification_preferences_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/notification_bloc.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({
    super.key,
    required this.initialPreferences,
  });

  final NotificationPreferencesModel initialPreferences;

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  late NotificationPreferencesModel _preferences;

  @override
  void initState() {
    super.initState();
    _preferences = widget.initialPreferences;
  }

  void _toggle(NotificationPreferencesModel Function() apply) {
    setState(() => _preferences = apply());
    context.read<NotificationBloc>().add(
      NotificationPreferencesSaveRequested(_preferences),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<NotificationBloc, NotificationState>(
    listenWhen: (previous, current) => previous.emitState != current.emitState,
    listener: (context, state) {
      if (state.emitState == NotificationEmitState.preferencesSaved &&
          state.preferences != null) {
        // Keep the session user in sync so reopening this screen (which
        // seeds from AuthBloc) shows the saved values.
        context.read<AuthBloc>().add(
          AuthNotificationPreferencesChanged(state.preferences!),
        );
      } else if (state.emitState == NotificationEmitState.error) {
        AppPrompts.error(
          context,
          state.errorMessage ?? 'notifications.save_error'.tr(),
        );
      }
    },
    child: Scaffold(
      appBar: AppBar(title: Text('notifications.title'.tr())),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: context.borderDefault),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _PreferenceRow(
                  title: 'notifications.low_stock_alerts'.tr(),
                  subtitle:
                      'notifications.low_stock_sub'.tr(),
                  value: _preferences.lowStock,
                  onChanged: (value) =>
                      _toggle(() => _preferences.copyWith(lowStock: value)),
                ),
                Divider(height: 1, color: context.borderDefault),
                _PreferenceRow(
                  title: 'notifications.oos_alerts'.tr(),
                  subtitle: 'notifications.oos_sub'.tr(),
                  value: _preferences.outOfStock,
                  onChanged: (value) =>
                      _toggle(() => _preferences.copyWith(outOfStock: value)),
                ),
                Divider(height: 1, color: context.borderDefault),
                _PreferenceRow(
                  title: 'notifications.daily'.tr(),
                  subtitle: 'notifications.daily_sub'.tr(),
                  value: _preferences.dailyReminder,
                  onChanged: (value) => _toggle(
                    () => _preferences.copyWith(dailyReminder: value),
                  ),
                ),
                Divider(height: 1, color: context.borderDefault),
                _PreferenceRow(
                  title: 'notifications.weekly'.tr(),
                  subtitle:
                      'notifications.weekly_sub'.tr(),
                  value: _preferences.weeklySummary,
                  onChanged: (value) => _toggle(
                    () => _preferences.copyWith(weeklySummary: value),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Material(
    color: context.surfaceColor,
    child: SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      title: Text(title, style: AppTypography.style12SemiBold),
      subtitle: Text(
        subtitle,
        style: AppTypography.style10Regular.copyWith(
          color: context.appColors.textSecondary,
        ),
      ),
      value: value,
      onChanged: onChanged,
    ),
  );
}
