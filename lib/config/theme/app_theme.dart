import 'package:flutter/material.dart';

import '../typography/app_typography.dart';

@immutable
class AppColorsExt extends ThemeExtension<AppColorsExt> {
  const AppColorsExt({
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.disabled,
    required this.shadow,
  });

  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color disabled;
  final Color shadow;

  static const dark = AppColorsExt(
    success: Color(0xFF16A34A),
    successContainer: Color(0xFF14401F),
    warning: Color(0xFFFBBF24),
    warningContainer: Color(0xFF4D3B0F),
    textPrimary: Color(0xFFF5F7F8),
    textSecondary: Color(0xFF9CA3AF),
    textTertiary: Color(0xFF6B7280),
    disabled: Color(0xFF3A4245),
    shadow: Color(0x33000000),
  );

  @override
  AppColorsExt copyWith({
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? warningContainer,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? disabled,
    Color? shadow,
  }) => AppColorsExt(
    success: success ?? this.success,
    successContainer: successContainer ?? this.successContainer,
    warning: warning ?? this.warning,
    warningContainer: warningContainer ?? this.warningContainer,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textTertiary: textTertiary ?? this.textTertiary,
    disabled: disabled ?? this.disabled,
    shadow: shadow ?? this.shadow,
  );

  @override
  AppColorsExt lerp(ThemeExtension<AppColorsExt>? other, double t) =>
      other is! AppColorsExt
      ? this
      : AppColorsExt(
          success: Color.lerp(success, other.success, t)!,
          successContainer: Color.lerp(
            successContainer,
            other.successContainer,
            t,
          )!,
          warning: Color.lerp(warning, other.warning, t)!,
          warningContainer: Color.lerp(
            warningContainer,
            other.warningContainer,
            t,
          )!,
          textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
          textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
          textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
          disabled: Color.lerp(disabled, other.disabled, t)!,
          shadow: Color.lerp(shadow, other.shadow, t)!,
        );
}

extension AppThemeContext on BuildContext {
  AppColorsExt get appColors => Theme.of(this).extension<AppColorsExt>()!;
  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get secondaryColor => Theme.of(this).colorScheme.secondary;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get scaffoldBackgroundColor => Theme.of(this).scaffoldBackgroundColor;
  Color get errorColor => Theme.of(this).colorScheme.error;
  Color get onPrimaryColor => Theme.of(this).colorScheme.onPrimary;
  Color get onSurfaceColor => Theme.of(this).colorScheme.onSurface;
  Color get onSecondaryColor => Theme.of(this).colorScheme.onSecondary;
  Color get onErrorColor => Theme.of(this).colorScheme.onError;
  Color get onSurfaceVariant => Theme.of(this).colorScheme.onSurfaceVariant;
  Color get surfaceContainerHighest =>
      Theme.of(this).colorScheme.surfaceContainerHighest;

  Color get textSubtle => const Color(0xFFB0B0B0);
  Color get textQuaternary => const Color(0xFF8A8A8A);

  Color get borderDefault => Theme.of(this).colorScheme.outline;
  Color get borderStrong => const Color(0xFF3A4245);

  Color get gaugeEmptyColor => const Color(0xFF30363D);
  Color get disabledColor => const Color(0xFF5A6266);

  double get radius => 14;
}

abstract class AppTheme {
  static const String _fontFamily = 'PlusJakartaSans';

  static const _primary = Color(0xFF0D47A1);
  static const _primaryContainer = Color(0xFF14315C);
  static const _secondary = Color(0xFF16A34A);
  static const _secondaryContainer = Color(0xFF14401F);
  static const _tertiary = Color(0xFF38BDF8);
  static const _tertiaryContainer = Color(0xFF0C3A4F);

  static const _background = Color(0xFF12181A);
  static const _surface = Color(0xFF1B2224);
  static const _surfaceVariant = Color(0xFF232B2E);

  static const _textPrimary = Color(0xFFF5F7F8);
  static const _textSecondary = Color(0xFF9CA3AF);
  static const _border = Color(0xFF2E3639);

  static const _error = Color(0xFFEF5350);
  static const _white = Colors.white;

  // Fills that must stay visually distinct from _surface/_textPrimary (tooltip, slider value indicator).
  static const _elevatedGrey = Color(0xFF2E3639);
  static const _disabledFill = Color(0xFF2E3639);
  static const _disabledForeground = Color(0xFF6B7280);

  static const double _radiusSm = 10.0;
  static const double _radiusMd = 14.0;
  static const double _radiusLg = 20.0;
  static const double _radiusPill = 999.0;

  static const _colorScheme = ColorScheme(
    brightness: Brightness.dark,

    primary: _primary,
    onPrimary: _white,
    primaryContainer: _primaryContainer,
    onPrimaryContainer: Color(0xFFB8CCE8),

    secondary: _secondary,
    onSecondary: _white,
    secondaryContainer: _secondaryContainer,
    onSecondaryContainer: Color(0xFFA8E6BC),

    tertiary: _tertiary,
    onTertiary: Color(0xFF00303F),
    tertiaryContainer: _tertiaryContainer,
    onTertiaryContainer: Color(0xFF9BDFF7),

    error: _error,
    onError: Color(0xFF3A0A0A),
    errorContainer: Color(0xFF4C1414),
    onErrorContainer: Color(0xFFFFB4AB),

    surface: _surface,
    onSurface: _textPrimary,
    surfaceContainerHighest: _surfaceVariant,
    onSurfaceVariant: _textSecondary,

    outline: _border,
    outlineVariant: _border,
    surfaceTint: _primary,
    shadow: Colors.black,
    scrim: Colors.black87,
    inverseSurface: _textPrimary,
    onInverseSurface: Color(0xFF1B2224),
    inversePrimary: Color(0xFF8AB4E8),
  );

  static ThemeData get theme =>
      ThemeData(
        useMaterial3: true,
        fontFamily: _fontFamily,
        colorScheme: _colorScheme,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        splashFactory: InkSparkle.splashFactory,
        extensions: const [AppColorsExt.dark],
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            visualDensity: VisualDensity.comfortable,
            foregroundColor: _textPrimary,
          ),
        ),
      ).copyWith(
        scaffoldBackgroundColor: _background,
        canvasColor: _background,

        appBarTheme: AppBarTheme(
          backgroundColor: _background,
          foregroundColor: _textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleSpacing: 12,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: _textPrimary, size: 22),
          actionsPadding: const EdgeInsets.only(right: 8),
          titleTextStyle: AppTypography.style18Bold.copyWith(
            color: _textPrimary,
          ),
        ),

        cardTheme: CardThemeData(
          color: _surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusMd),
            side: const BorderSide(color: _border, width: 1),
          ),
        ),

        listTileTheme: ListTileThemeData(
          tileColor: _surface,
          selectedTileColor: _primaryContainer,
          iconColor: _textPrimary,
          textColor: _textPrimary,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusMd),
          ),
          minLeadingWidth: 24,
        ),

        popupMenuTheme: PopupMenuThemeData(
          color: _surface,
          surfaceTintColor: Colors.transparent,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusMd),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surfaceVariant,
          hintStyle: AppTypography.style15Regular.copyWith(
            color: _textSecondary,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radiusMd),
            borderSide: const BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radiusMd),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radiusMd),
            borderSide: const BorderSide(color: _primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radiusMd),
            borderSide: const BorderSide(color: _error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radiusMd),
            borderSide: const BorderSide(color: _error, width: 1.5),
          ),
        ),

        searchBarTheme: SearchBarThemeData(
          backgroundColor: const WidgetStatePropertyAll(_surfaceVariant),
          elevation: const WidgetStatePropertyAll(0),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          side: const WidgetStatePropertyAll(BorderSide(color: _border)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radiusPill),
            ),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16),
          ),
          hintStyle: WidgetStatePropertyAll(
            AppTypography.style15Regular.copyWith(color: _textSecondary),
          ),
          textStyle: WidgetStatePropertyAll(
            AppTypography.style15Regular.copyWith(color: _textPrimary),
          ),
        ),
        searchViewTheme: SearchViewThemeData(
          backgroundColor: _surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusMd),
          ),
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: _white,
            disabledBackgroundColor: _disabledFill,
            disabledForegroundColor: _disabledForeground,
            minimumSize: const Size(double.infinity, 52),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            textStyle: AppTypography.style15Regular.copyWith(
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radiusMd),
            ),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: _white,
            disabledBackgroundColor: _disabledFill,
            disabledForegroundColor: _disabledForeground,
            elevation: 0,
            minimumSize: const Size(double.infinity, 52),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            textStyle: AppTypography.style15Regular.copyWith(
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radiusMd),
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _primary,
            side: const BorderSide(color: _primary),
            minimumSize: const Size(double.infinity, 52),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            textStyle: AppTypography.style15Regular.copyWith(
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radiusMd),
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _primary,
            textStyle: AppTypography.style15Regular.copyWith(
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radiusSm),
            ),
          ),
        ),

        segmentedButtonTheme: SegmentedButtonThemeData(
          style: SegmentedButton.styleFrom(
            backgroundColor: _surface,
            foregroundColor: _textPrimary,
            selectedBackgroundColor: _primaryContainer,
            selectedForegroundColor: const Color(0xFFB8CCE8),
            side: const BorderSide(color: _border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radiusMd),
            ),
          ),
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: _surface,
          selectedItemColor: _primary,
          unselectedItemColor: _disabledForeground,
          selectedLabelStyle: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),

        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _surface,
          surfaceTintColor: Colors.transparent,
          indicatorColor: _primaryContainer,
          elevation: 2,
          height: 64,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => AppTypography.style14Medium.copyWith(
              color: states.contains(WidgetState.selected)
                  ? _primary
                  : _disabledForeground,
              fontSize: 11,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? _primary
                  : _disabledForeground,
            ),
          ),
        ),

        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: _surface,
          selectedIconTheme: const IconThemeData(color: _primary),
          unselectedIconTheme: const IconThemeData(color: _disabledForeground),
          selectedLabelTextStyle: AppTypography.style14Medium.copyWith(
            color: _primary,
          ),
          unselectedLabelTextStyle: AppTypography.style14Medium.copyWith(
            color: _disabledForeground,
          ),
          indicatorColor: _primaryContainer,
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusMd),
          ),
        ),

        tabBarTheme: TabBarThemeData(
          labelColor: _primary,
          unselectedLabelColor: _textSecondary,
          labelStyle: AppTypography.style14Medium.copyWith(
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: AppTypography.style14Medium,
          indicatorColor: _primary,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: _border,
        ),

        dividerTheme: const DividerThemeData(
          color: _border,
          thickness: 1,
          space: 1,
        ),

        chipTheme: ChipThemeData(
          backgroundColor: _surfaceVariant,
          selectedColor: _primary,
          secondarySelectedColor: _primary,
          disabledColor: _disabledFill,
          labelStyle: AppTypography.style14Medium.copyWith(color: _textPrimary),
          secondaryLabelStyle: AppTypography.style14Medium.copyWith(
            color: _white,
          ),
          side: const BorderSide(color: Colors.transparent),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusPill),
          ),
        ),

        iconTheme: const IconThemeData(color: _textPrimary, size: 22),

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: _primary,
          foregroundColor: _white,
          elevation: 3,
          extendedTextStyle: AppTypography.style15Regular.copyWith(
            color: _white,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusPill),
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _surfaceVariant,
          contentTextStyle: AppTypography.style14Medium.copyWith(
            color: _textPrimary,
          ),
          actionTextColor: const Color(0xFF7FE0A0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusMd),
          ),
        ),

        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: _surface,
          surfaceTintColor: Colors.transparent,
          elevation: 4,
          modalElevation: 4,
          showDragHandle: true,
          dragHandleColor: _border,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(_radiusLg),
            ),
          ),
        ),

        dialogTheme: DialogThemeData(
          backgroundColor: _surface,
          surfaceTintColor: Colors.transparent,
          elevation: 4,
          titleTextStyle: AppTypography.style18Bold.copyWith(
            color: _textPrimary,
          ),
          contentTextStyle: AppTypography.style15Regular.copyWith(
            color: _textSecondary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusLg),
          ),
        ),

        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: _elevatedGrey,
            borderRadius: BorderRadius.circular(_radiusSm),
          ),
          textStyle: AppTypography.style14Medium.copyWith(color: _white),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),

        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: _primary,
          circularTrackColor: _border,
          linearTrackColor: _border,
        ),

        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.selected) ? _primary : _surface,
          ),
          checkColor: const WidgetStatePropertyAll(_white),
          side: const BorderSide(color: _border, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),

        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? _primary
                : _disabledForeground,
          ),
        ),

        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? _primary
                : const Color(0xFFB0B0B0),
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? _primary.withValues(alpha: 0.4)
                : const Color(0xFF3A4245),
          ),
          trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        ),

        sliderTheme: SliderThemeData(
          activeTrackColor: _primary,
          inactiveTrackColor: _border,
          thumbColor: _primary,
          overlayColor: _primary.withValues(alpha: 0.12),
          valueIndicatorColor: _elevatedGrey,
          valueIndicatorTextStyle: AppTypography.style14Medium.copyWith(
            color: _white,
          ),
        ),
      );
}
