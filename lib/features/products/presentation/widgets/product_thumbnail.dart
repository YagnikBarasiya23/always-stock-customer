import 'package:flutter/material.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../config/typography/app_typography.dart';

class ProductThumbnail extends StatelessWidget {
  const ProductThumbnail({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 42,
    this.borderRadius = 10,
  });

  final String name;
  final String? imageUrl;
  final double size;
  final double borderRadius;

  String get _initials {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    Widget fallback() => Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.surfaceContainerHighest,
        borderRadius: radius,
      ),
      child: Text(
        _initials,
        style: AppTypography.style13Bold.copyWith(
          color: context.appColors.textSecondary,
          fontSize: size * 0.32,
        ),
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) return fallback();

    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback(),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : fallback(),
      ),
    );
  }
}
