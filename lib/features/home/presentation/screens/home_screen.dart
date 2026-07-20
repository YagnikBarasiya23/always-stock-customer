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
import '../../../dashboard/data/models/dashboard_summary_model.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../inventory/data/models/inventory_transaction_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => context.read<DashboardBloc>().add(const DashboardSummaryRequested()),
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            final summary = state.summary;

            if (summary == null && state.emitState == DashboardEmitState.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (summary == null && state.emitState == DashboardEmitState.error) {
              return _ErrorState(
                message: state.errorMessage ?? 'home.dashboard_error'.tr(),
                onRetry: () => context.read<DashboardBloc>().add(const DashboardSummaryRequested()),
              );
            }

            if (summary == null) return const SizedBox.shrink();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                const _DashboardHeader(),
                20.heightBox,
                _AttentionHero(lowStock: summary.lowStock, outOfStock: summary.outOfStock),
                16.heightBox,
                _KpiGrid(totalProducts: summary.totalProducts, totalStock: summary.totalStock),
                16.heightBox,
                _TodayCard(today: summary.today),
                20.heightBox,
                _SectionHead(
                  title: 'home.recent_transactions'.tr(),
                  onSeeAll: () => AppPrompts.info(context, 'home.full_history_soon'.tr()),
                ),
                10.heightBox,
                _TransactionList(transactions: summary.recentTransactions),
              ],
            );
          },
        ),
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, color: context.appColors.textSecondary, size: 40),
          12.heightBox,
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.style13Regular.copyWith(color: context.appColors.textSecondary),
          ),
          16.heightBox,
          FilledButton(onPressed: onRetry, child: Text('common.try_again'.tr())),
        ],
      ),
    ),
  );
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'home.good_morning';
    if (hour < 17) return 'home.good_afternoon';
    return 'home.good_evening';
  }

  static String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final business = context.watch<AuthBloc>().state.business;
    final businessName = business?.name ?? 'home.your_business'.tr();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                businessName.toUpperCase(),
                style: AppTypography.style10SemiBold.copyWith(
                  color: context.appColors.textSecondary,
                  letterSpacing: 0.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              2.heightBox,
              Text(_greeting().tr(), style: AppTypography.style18Bold),
            ],
          ),
        ),
        8.widthBox,
        IconButton(
          onPressed: () => context.pushNamed(RouteNames.notifications.name),
          icon: const Icon(Icons.notifications_none),
        ),
        4.widthBox,
        InkWell(
          onTap: () => context.pushNamed(RouteNames.settings.name),
          borderRadius: BorderRadius.circular(11),
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: context.primaryColor, borderRadius: BorderRadius.circular(11)),
            child: Text(_initials(businessName), style: AppTypography.style13Bold.copyWith(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

class _AttentionHero extends StatelessWidget {
  const _AttentionHero({required this.lowStock, required this.outOfStock});

  final int lowStock;
  final int outOfStock;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => AppPrompts.info(context, 'home.stock_health_soon'.tr()),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorScheme.errorContainer, context.surfaceColor],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: colorScheme.error, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.warning_rounded, color: Colors.white, size: 15),
                ),
                8.widthBox,
                Text('home.needs_attention'.tr(), style: AppTypography.style13Bold),
              ],
            ),
            14.heightBox,
            Row(
              children: [
                _AttentionNumber(value: lowStock, label: 'home.low_stock'.tr(), color: context.appColors.warning),
                24.widthBox,
                _AttentionNumber(value: outOfStock, label: 'home.out_of_stock'.tr(), color: colorScheme.error),
              ],
            ),
            10.heightBox,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('home.review_items'.tr(), style: AppTypography.style11SemiBold.copyWith(color: colorScheme.error)),
                4.widthBox,
                Icon(Icons.arrow_forward, size: 12, color: colorScheme.error),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttentionNumber extends StatelessWidget {
  const _AttentionNumber({required this.value, required this.label, required this.color});

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('$value', style: AppTypography.style24Bold.copyWith(color: color, height: 1)),
      4.heightBox,
      Text(label, style: AppTypography.style10Medium.copyWith(color: context.appColors.textSecondary)),
    ],
  );
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.totalProducts, required this.totalStock});

  final int totalProducts;
  final double totalStock;

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.decimalPattern();

    return Row(
      children: [
        Expanded(
          child: _KpiTile(
            label: 'home.total_products'.tr(),
            value: numberFormat.format(totalProducts),
            onTap: () => context.pushNamed(RouteNames.products.name),
          ),
        ),
        10.widthBox,
        Expanded(
          child: _KpiTile(
            label: 'home.total_stock'.tr(),
            value: numberFormat.format(totalStock),
            unit: 'home.units'.tr(),
          ),
        ),
      ],
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({required this.label, required this.value, this.unit, this.onTap});

  final String label;
  final String value;
  final String? unit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.style10SemiBold.copyWith(color: context.appColors.textSecondary, letterSpacing: 0.3),
          ),
          6.heightBox,
          Text.rich(
            TextSpan(
              style: AppTypography.style20Bold,
              children: [
                TextSpan(text: value),
                if (unit != null)
                  TextSpan(
                    text: ' $unit',
                    style: AppTypography.style11Medium.copyWith(color: context.appColors.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: content);
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.today});

  final TodayStatsModel today;

  @override
  Widget build(BuildContext context) {
    final tertiary = Theme.of(context).colorScheme.tertiary;
    final tertiaryContainer = Theme.of(context).colorScheme.tertiaryContainer;
    final isPositive = today.netQuantity >= 0;
    final changeColor = isPositive ? context.appColors.success : Theme.of(context).colorScheme.error;
    final numberFormat = NumberFormat.decimalPattern();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tertiaryContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tertiary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'home.today_caps'.tr(),
                  style: AppTypography.style10Bold.copyWith(color: tertiary, letterSpacing: 0.6),
                ),
                2.heightBox,
                Text(
                  'home.transactions'.plural(today.transactionCount, args: ['${today.transactionCount}']),
                  style: AppTypography.style13SemiBold,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, size: 13, color: changeColor),
                4.widthBox,
                Text(
                  '${isPositive ? '+' : ''}${numberFormat.format(today.netQuantity)}',
                  style: AppTypography.style13Bold.copyWith(color: changeColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHead extends StatelessWidget {
  const _SectionHead({required this.title, required this.onSeeAll});

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: AppTypography.style13Bold),
      GestureDetector(
        onTap: onSeeAll,
        child: Text('common.see_all'.tr(), style: AppTypography.style11SemiBold.copyWith(color: context.primaryColor)),
      ),
    ],
  );
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.transactions});

  final List<InventoryTransactionModel> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderDefault),
        ),
        child: Text(
          'home.no_transactions'.tr(),
          style: AppTypography.style12Regular.copyWith(color: context.appColors.textSecondary),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderDefault),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < transactions.length; i++) ...[
            if (i > 0) Divider(height: 1, color: context.borderDefault),
            _TransactionRow(transaction: transactions[i]),
          ],
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});

  final InventoryTransactionModel transaction;

  static ({IconData icon, String label}) _presentation(TransactionType type) => switch (type) {
    TransactionType.add => (icon: Icons.arrow_upward, label: 'txn.added'.tr()),
    TransactionType.remove => (icon: Icons.arrow_downward, label: 'txn.removed'.tr()),
    TransactionType.adjust => (icon: Icons.tune, label: 'txn.adjusted'.tr()),
    TransactionType.initial => (icon: Icons.flag_outlined, label: 'txn.initial'.tr()),
    TransactionType.damaged => (icon: Icons.warning_amber_rounded, label: 'txn.damaged'.tr()),
    TransactionType.returned => (icon: Icons.undo, label: 'txn.returned'.tr()),
    TransactionType.transfer => (icon: Icons.swap_horiz, label: 'txn.transferred'.tr()),
    TransactionType.unknown => (icon: Icons.help_outline, label: 'txn.updated'.tr()),
  };

  static String _relativeTime(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'common.just_now'.tr();
    if (diff.inMinutes < 60) return 'common.min_ago'.tr(args: ['${diff.inMinutes}']);
    if (diff.inHours < 24) return 'common.hr_ago'.tr(args: ['${diff.inHours}']);
    if (diff.inDays < 7) return 'common.d_ago'.tr(args: ['${diff.inDays}']);
    return DateFormat('MMM d').format(time.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final presentation = _presentation(transaction.type);
    final delta = transaction.newStock - transaction.previousStock;
    final isPositive = delta >= 0;
    final changeColor = isPositive ? context.appColors.success : Theme.of(context).colorScheme.error;
    final iconContainerColor = isPositive
        ? context.appColors.successContainer
        : Theme.of(context).colorScheme.errorContainer;
    final numberFormat = NumberFormat.decimalPattern();

    return Container(
      color: context.surfaceColor,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: iconContainerColor, borderRadius: BorderRadius.circular(9)),
            child: Icon(presentation.icon, size: 16, color: changeColor),
          ),
          11.widthBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(presentation.label.tr(), style: AppTypography.style12SemiBold),
                2.heightBox,
                Text(
                  _relativeTime(transaction.createdAt),
                  style: AppTypography.style10Regular.copyWith(color: context.appColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : ''}${numberFormat.format(delta)}',
                style: AppTypography.style12Bold.copyWith(color: changeColor),
              ),
              2.heightBox,
              Text(
                '${numberFormat.format(transaction.previousStock)} → ${numberFormat.format(transaction.newStock)}',
                style: AppTypography.style10Regular.copyWith(color: context.appColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
