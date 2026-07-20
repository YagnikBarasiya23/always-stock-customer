import 'package:flutter/material.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../config/typography/app_typography.dart';
import '../../data/models/product_model.dart';

class StockStatusPill extends StatelessWidget {
  const StockStatusPill({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color background;
    final Color foreground;

    if (product.isOutOfStock) {
      background = colorScheme.errorContainer;
      foreground = colorScheme.error;
    } else if (product.isLowStock) {
      background = context.appColors.warningContainer;
      foreground = context.appColors.warning;
    } else {
      background = context.appColors.successContainer;
      foreground = context.appColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${product.currentStock.toStringAsFixed(product.currentStock.truncateToDouble() == product.currentStock ? 0 : 1)} ${product.unit}',
        style: AppTypography.style10Bold.copyWith(color: foreground),
      ),
    );
  }
}
