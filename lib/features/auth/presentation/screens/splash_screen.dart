import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/app_assets.dart';
import '../../../../config/local/local_storage_services.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/extensions/app_extensions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _splashPrimary = Color(0xFF0D47A1);
  static const _splashSecondary = Color(0xFF16A34A);
  static const _backdrop = Color(0xFF12181A);

  late final AnimationController _introController;

  late final Animation<double> _wipeProgress;
  late final Animation<double> _markScale;
  late final Animation<double> _markRotate;
  late final Animation<double> _markOpacity;
  late final Animation<double> _wordmarkOpacity;
  late final Animation<Offset> _wordmarkSlide;

  bool _exiting = false;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _wipeProgress = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    );

    _markScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.40, 0.75, curve: Curves.elasticOut),
      ),
    );

    _markRotate = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.40, 0.75, curve: Curves.easeOutBack),
      ),
    );

    _markOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.40, 0.60, curve: Curves.easeOut),
    );

    _wordmarkOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );

    _wordmarkSlide =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
          ),
        );

    _scheduleNavigation();
  }

  Future<void> _scheduleNavigation() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final hasToken = LocalStorageServices.getToken() != null;

    setState(() => _exiting = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    if (GoRouter.maybeOf(context) != null) {
      if (hasToken) {
        context.goNamed(RouteNames.home.name);
      } else {
        context.goNamed(RouteNames.login.name);
      }
    }
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _backdrop,
    body: AnimatedOpacity(
      opacity: _exiting ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: context.width / 2,
            child: ScaleTransition(
              scale: _wipeProgress,
              alignment: Alignment.centerLeft,
              child: Container(color: _splashPrimary),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: context.width / 2,
            child: ScaleTransition(
              scale: _wipeProgress,
              alignment: Alignment.centerRight,
              child: Container(color: _splashSecondary),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _markOpacity,
                  child: ScaleTransition(
                    scale: _markScale,
                    child: AnimatedBuilder(
                      animation: _markRotate,
                      builder: (context, child) => Transform.rotate(
                        angle: _markRotate.value,
                        child: child,
                      ),
                      child: Transform.scale(
                        scale: 2,
                        child: Image.asset(
                          AppAssets.logo,
                          width: 120,
                          height: 120,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                20.heightBox,
                FadeTransition(
                  opacity: _wordmarkOpacity,
                  child: SlideTransition(
                    position: _wordmarkSlide,
                    child: Text(
                      'Always Stock',
                      style: AppTypography.style28Bold.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
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
