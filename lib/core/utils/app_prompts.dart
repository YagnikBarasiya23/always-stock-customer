import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

import '../../config/theme/app_theme.dart';
import '../../config/typography/app_typography.dart';

enum _PromptType { success, error, warning, info }

abstract class AppPrompts {
  static Future<T?> showAppDialog<T>(BuildContext context, Widget child) => showGeneralDialog<T>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, _, _) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, _, _) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack, reverseCurve: Curves.easeIn);
      return ScaleTransition(
        scale: Tween<double>(begin: .9, end: 1).animate(curved),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );

  static void success(BuildContext context, String message, {String? title}) =>
      _show(context, type: _PromptType.success, message: message, title: title);

  static void error(BuildContext context, String message, {String? title}) =>
      _show(context, type: _PromptType.error, message: message, title: title);

  static void warning(BuildContext context, String message, {String? title}) =>
      _show(context, type: _PromptType.warning, message: message, title: title);

  static void info(BuildContext context, String message, {String? title}) =>
      _show(context, type: _PromptType.info, message: message, title: title);

  static void _show(BuildContext context, {required _PromptType type, required String message, String? title}) {
    final config = _configFor(context, type);

    HapticFeedback.lightImpact();

    toastification.show(
      context: context,
      type: config.toastType,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: config.duration,
      title: title != null
          ? Text(title, style: AppTypography.style14SemiBold.copyWith(color: context.appColors.textPrimary))
          : null,
      description: Text(
        message,
        style: AppTypography.style13Regular.copyWith(color: context.appColors.textSecondary),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      icon: DecoratedBox(
        decoration: BoxDecoration(color: config.primary.withValues(alpha: 0.14), shape: BoxShape.circle),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(config.icon, color: config.primary, size: 16),
        ),
      ),
      primaryColor: config.primary,
      backgroundColor: context.surfaceColor,
      borderRadius: BorderRadius.circular(context.radius),
      borderSide: BorderSide(color: config.primary.withValues(alpha: 0.3)),
      boxShadow: [BoxShadow(color: context.appColors.shadow, blurRadius: 16, offset: const Offset(0, 6))],
      showProgressBar: true,
      // `always` (not `onHover`) so the dismiss affordance is actually visible on touch devices.
      closeButton: const ToastCloseButton(showType: CloseButtonShowType.always),
      dragToClose: true,
      alignment: Alignment.topCenter,
    );
  }

  static _PromptConfig _configFor(BuildContext context, _PromptType type) {
    switch (type) {
      case _PromptType.success:
        return _PromptConfig(
          toastType: ToastificationType.success,
          primary: context.appColors.success,
          icon: Icons.check_circle_rounded,
          duration: const Duration(seconds: 3),
        );
      case _PromptType.error:
        return _PromptConfig(
          toastType: ToastificationType.error,
          primary: context.errorColor,
          icon: Icons.error_rounded,
          // Errors get a little extra time on screen so the message can actually be read.
          duration: const Duration(seconds: 4),
        );
      case _PromptType.warning:
        return _PromptConfig(
          toastType: ToastificationType.warning,
          primary: context.appColors.warning,
          icon: Icons.warning_rounded,
          duration: const Duration(seconds: 4),
        );
      case _PromptType.info:
        return _PromptConfig(
          toastType: ToastificationType.info,
          primary: context.secondaryColor,
          icon: Icons.info_rounded,
          duration: const Duration(seconds: 3),
        );
    }
  }
}

class _PromptConfig {
  final ToastificationType toastType;
  final Color primary;
  final IconData icon;
  final Duration duration;

  const _PromptConfig({required this.toastType, required this.primary, required this.icon, required this.duration});
}
