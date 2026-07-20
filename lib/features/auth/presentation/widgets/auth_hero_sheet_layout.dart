import 'package:flutter/material.dart';

import '../../../../config/constants/app_assets.dart';
import '../../../../core/extensions/app_extensions.dart';

class AuthHeroSheetLayout extends StatelessWidget {
  const AuthHeroSheetLayout({
    super.key,
    required this.heroHeightFraction,
    required this.heroChild,
    required this.sheetChild,
  });

  final double heroHeightFraction;
  final Widget heroChild;
  final Widget sheetChild;

  static const _overlap = 20.0;
  static const _sheetSurface = Color(0xFF1B2224);
  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D47A1), Color(0xFF16A34A)],
  );

  @override
  Widget build(BuildContext context) {
    final heroHeight = context.height * heroHeightFraction;

    return SizedBox.expand(
      child: Stack(
        children: [
          SizedBox(
            height: heroHeight,
            width: double.infinity,
            child: DecoratedBox(
              decoration: const BoxDecoration(gradient: _gradient),
              child: SafeArea(bottom: false, child: Center(child: heroChild)),
            ),
          ),
          Positioned(
            top: heroHeight - _overlap,
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: _sheetSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(top: false, child: sheetChild),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthLogoMark extends StatelessWidget {
  const AuthLogoMark({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) => Transform.scale(
    scale: 1.6,
    child: Image.asset(AppAssets.logo, width: size, height: size, color: Colors.white),
  );
}
