import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/extensions/app_extensions.dart';
import '../../data/models/notification_model.dart';
import '../bloc/notification_bloc.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final _scrollController = ScrollController();
  bool _unreadOnly = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationBloc>().add(const NotificationLoadMoreRequested());
    }
  }

  void _selectTab(bool unreadOnly) {
    setState(() => _unreadOnly = unreadOnly);
    context.read<NotificationBloc>().add(NotificationListRequested(unreadOnly: unreadOnly ? true : null));
  }

  void _markAllRead() => context.read<NotificationBloc>().add(const NotificationMarkReadRequested());

  void _markRead(NotificationModel notification) {
    if (notification.isRead) return;
    context.read<NotificationBloc>().add(NotificationMarkReadRequested(notificationIds: [notification.id]));
  }

  List<_DayGroup> _groupByDay(List<NotificationModel> notifications) {
    final now = DateTime.now();
    final groups = <String, List<NotificationModel>>{};

    for (final notification in notifications) {
      final time = notification.createdAt;
      final String label;
      if (time == null) {
        label = 'common.unknown_date'.tr();
      } else {
        final isToday = time.year == now.year && time.month == now.month && time.day == now.day;
        final yesterday = now.subtract(const Duration(days: 1));
        final isYesterday = time.year == yesterday.year && time.month == yesterday.month && time.day == yesterday.day;
        label = isToday
            ? 'common.today'.tr()
            : (isYesterday ? 'common.yesterday'.tr() : DateFormat('MMM d').format(time));
      }
      groups.putIfAbsent(label, () => []).add(notification);
    }

    return groups.entries.map((e) => _DayGroup(label: e.key, notifications: e.value)).toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('notifications.title'.tr()),
      actions: [
        BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) => state.unreadCount > 0
              ? TextButton(onPressed: _markAllRead, child: Text('notifications.mark_all_read'.tr()))
              : const SizedBox.shrink(),
        ),
        8.widthBox,
      ],
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) => Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: context.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _Tab(
                      label: 'notifications.all'.tr(),
                      selected: !_unreadOnly,
                      onTap: () => _selectTab(false),
                    ),
                  ),
                  Expanded(
                    child: _Tab(
                      label: '${'notifications.unread'.tr()}${state.unreadCount > 0 ? ' · ${state.unreadCount}' : ''}',
                      selected: _unreadOnly,
                      onTap: () => _selectTab(true),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        12.heightBox,
        Expanded(
          child: BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state.emitState == NotificationEmitState.loading && state.notifications.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.emitState == NotificationEmitState.error && state.notifications.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.errorMessage ?? 'notifications.load_error'.tr(),
                          textAlign: TextAlign.center,
                          style: AppTypography.style13Regular.copyWith(color: context.appColors.textSecondary),
                        ),
                        16.heightBox,
                        FilledButton(
                          onPressed: () => context.read<NotificationBloc>().add(
                            NotificationListRequested(unreadOnly: _unreadOnly ? true : null),
                          ),
                          child: Text('common.try_again'.tr()),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state.notifications.isEmpty) {
                return Center(
                  child: Text(
                    _unreadOnly ? 'notifications.caught_up'.tr() : 'notifications.none_yet'.tr(),
                    style: AppTypography.style12Regular.copyWith(color: context.appColors.textSecondary),
                  ),
                );
              }

              final groups = _groupByDay(state.notifications);

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: groups.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= groups.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
                    );
                  }
                  final group = groups[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 2, bottom: 8),
                          child: Text(
                            group.label.toUpperCase(),
                            style: AppTypography.style10Bold.copyWith(
                              color: context.appColors.textSecondary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: context.borderDefault),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              for (var i = 0; i < group.notifications.length; i++) ...[
                                if (i > 0) Divider(height: 1, color: context.borderDefault),
                                _NotificationRow(
                                  notification: group.notifications[i],
                                  onTap: () => _markRead(group.notifications[i]),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}

class _DayGroup {
  const _DayGroup({required this.label, required this.notifications});

  final String label;
  final List<NotificationModel> notifications;
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: selected ? context.surfaceColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTypography.style11Bold.copyWith(
          color: selected ? context.appColors.textPrimary : context.appColors.textSecondary,
        ),
      ),
    ),
  );
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.notification, required this.onTap});

  final NotificationModel notification;
  final VoidCallback onTap;

  static ({IconData icon, Color Function(BuildContext) background, Color Function(BuildContext) foreground})
  _presentation(NotificationCategory category) => switch (category) {
    NotificationCategory.lowStock => (
      icon: Icons.warning_amber_rounded,
      background: (c) => c.appColors.warningContainer,
      foreground: (c) => c.appColors.warning,
    ),
    NotificationCategory.outOfStock => (
      icon: Icons.error_outline,
      background: (c) => Theme.of(c).colorScheme.errorContainer,
      foreground: (c) => Theme.of(c).colorScheme.error,
    ),
    NotificationCategory.dailyReminder => (
      icon: Icons.alarm,
      background: (c) => Theme.of(c).colorScheme.tertiaryContainer,
      foreground: (c) => Theme.of(c).colorScheme.tertiary,
    ),
    NotificationCategory.weeklySummary => (
      icon: Icons.calendar_view_week,
      background: (c) => Theme.of(c).colorScheme.tertiaryContainer,
      foreground: (c) => Theme.of(c).colorScheme.tertiary,
    ),
    NotificationCategory.unknown => (
      icon: Icons.notifications_none,
      background: (c) => c.surfaceContainerHighest,
      foreground: (c) => c.appColors.textSecondary,
    ),
  };

  static String _relativeTime(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'common.just_now'.tr();
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays < 7) return '${diff.inDays} d ago';
    return DateFormat('MMM d').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final presentation = _presentation(notification.type);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead
            ? context.surfaceColor
            : Color.alphaBlend(context.primaryColor.withValues(alpha: 0.06), context.surfaceColor),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(top: 1),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: presentation.background(context),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(presentation.icon, size: 14, color: presentation.foreground(context)),
            ),
            10.widthBox,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(notification.title, style: AppTypography.style12Bold),
                      if (!notification.isRead) ...[
                        6.widthBox,
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  2.heightBox,
                  Text(
                    notification.body,
                    style: AppTypography.style10Regular.copyWith(color: context.appColors.textSecondary),
                  ),
                  2.heightBox,
                  Text(
                    _relativeTime(notification.createdAt),
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
