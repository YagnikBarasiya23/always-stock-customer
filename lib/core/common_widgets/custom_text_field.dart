import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/theme/app_theme.dart';
import '../../config/typography/app_typography.dart';
import '../extensions/app_extensions.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final bool isPassword;
  final bool readOnly;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final AutovalidateMode? autovalidateMode;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final bool autofocus;
  final String obscuringCharacter;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final bool expands;
  final bool? showCursor;
  final Color? cursorColor;
  final double? cursorHeight;
  final double cursorWidth;
  final Radius? cursorRadius;
  final EdgeInsets? scrollPadding;
  final bool enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final InputCounterWidgetBuilder? buildCounter;
  final ScrollPhysics? scrollPhysics;
  final ScrollController? scrollController;
  final String? restorationId;
  final bool enableIMEPersonalizedLearning;
  final String? headingLabelText;
  final TextStyle? headingLabelStyle;
  final String? hintText;
  final TextStyle? hintStyle;

  final String? errorText;
  final String? helperText;
  final int? helperMaxLines;
  final TextStyle? helperStyle;
  final bool isDense;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final InputBorder? disabledBorder;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool filled;
  final Color? fillColor;
  final String? labelText;
  final TextStyle? labelStyle;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final TextStyle? floatingLabelStyle;
  final TextStyle? errorStyle;
  final int? errorMaxLines;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final TextStyle? counterStyle;
  final bool disableAllBorder;

  const CustomTextField({
    super.key,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLength,
    this.minLines,
    this.maxLines,
    this.isPassword = false,
    this.readOnly = false,
    this.enabled = true,
    this.inputFormatters,
    this.focusNode,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.autovalidateMode,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.autofocus = false,
    this.obscuringCharacter = '•',
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.expands = false,
    this.showCursor,
    this.cursorColor,
    this.cursorHeight,
    this.cursorWidth = 2.0,
    this.cursorRadius,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.buildCounter,
    this.scrollPhysics,
    this.scrollController,
    this.restorationId,
    this.enableIMEPersonalizedLearning = true,
    this.headingLabelText,
    this.headingLabelStyle,
    this.hintText,
    this.hintStyle,
    this.errorText,
    this.helperText,
    this.helperMaxLines,
    this.helperStyle,
    this.isDense = false,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.disabledBorder,
    this.prefixIcon,
    this.suffixIcon,
    this.filled = true,
    this.fillColor,
    this.labelText,
    this.labelStyle,
    this.floatingLabelBehavior,
    this.floatingLabelStyle,
    this.errorStyle,
    this.errorMaxLines,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.counterStyle,
    this.disableAllBorder = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (widget.headingLabelText != null)
        Text(
          widget.headingLabelText!,
          style:
              widget.headingLabelStyle ??
              AppTypography.style13Regular.copyWith(
                color: context.onSurfaceColor,
              ),
        ).pOnly(bottom: 10),
      _buildRegularField(),
    ],
  );

  Widget _buildRegularField() => TextFormField(
    controller: widget.controller,
    keyboardType: widget.keyboardType,
    validator: widget.validator,
    maxLength: widget.maxLength,
    minLines: widget.isPassword ? 1 : widget.minLines,
    maxLines: widget.isPassword ? 1 : widget.maxLines,
    obscureText: widget.isPassword && !_isPasswordVisible,
    readOnly: widget.readOnly,
    enabled: widget.enabled,
    inputFormatters: widget.inputFormatters,
    focusNode: widget.focusNode,
    onChanged: widget.onChanged,
    onTap: widget.onTap,
    onEditingComplete: widget.onEditingComplete,
    onFieldSubmitted: widget.onFieldSubmitted,
    onSaved: widget.onSaved,
    autovalidateMode: widget.autovalidateMode,
    textInputAction: widget.textInputAction,
    textCapitalization: widget.textCapitalization,
    style: widget.style,
    strutStyle: widget.strutStyle,
    textAlign: widget.textAlign,
    textAlignVertical: widget.textAlignVertical,
    autofocus: widget.autofocus,
    obscuringCharacter: widget.obscuringCharacter,
    autocorrect: widget.autocorrect,
    smartDashesType: widget.smartDashesType,
    smartQuotesType: widget.smartQuotesType,
    enableSuggestions: widget.enableSuggestions,
    expands: widget.expands,
    showCursor: widget.showCursor,
    cursorColor: widget.cursorColor,
    cursorHeight: widget.cursorHeight,
    cursorWidth: widget.cursorWidth,
    cursorRadius: widget.cursorRadius,
    scrollPadding: widget.scrollPadding ?? const EdgeInsets.all(20.0),
    enableInteractiveSelection: widget.enableInteractiveSelection,
    selectionControls: widget.selectionControls,
    buildCounter: widget.buildCounter,
    scrollPhysics: widget.scrollPhysics,
    scrollController: widget.scrollController,
    restorationId: widget.restorationId,
    enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
    decoration: _commonDecoration,
  );

  InputDecoration get _commonDecoration {
    Widget? suffixIcon = widget.suffixIcon;
    if (widget.isPassword) {
      suffixIcon = IconButton(
        icon: Icon(
          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          color: const Color(0xFF9CA3AF),
        ),
        onPressed: () =>
            setState(() => _isPasswordVisible = !_isPasswordVisible),
      );
    }

    return InputDecoration(
      hintText: widget.hintText,
      hintStyle: widget.hintStyle,
      errorText: widget.errorText,
      helperText: widget.helperText,
      helperMaxLines: widget.helperMaxLines,
      helperStyle: widget.helperStyle,
      isDense: widget.isDense,
      border: widget.disableAllBorder ? InputBorder.none : widget.border,
      enabledBorder: widget.disableAllBorder
          ? InputBorder.none
          : widget.enabledBorder,
      focusedBorder: widget.disableAllBorder
          ? InputBorder.none
          : widget.focusedBorder,
      errorBorder: widget.disableAllBorder
          ? InputBorder.none
          : widget.errorBorder,
      focusedErrorBorder: widget.disableAllBorder
          ? InputBorder.none
          : widget.focusedErrorBorder,
      disabledBorder: widget.disableAllBorder
          ? InputBorder.none
          : widget.disabledBorder,
      prefixIcon: widget.prefixIcon,
      suffixIcon: suffixIcon,
      filled: widget.filled,
      fillColor: widget.fillColor,
      labelText: widget.labelText,
      labelStyle: widget.labelStyle,
      floatingLabelBehavior:
          widget.floatingLabelBehavior ?? FloatingLabelBehavior.auto,
      floatingLabelStyle: widget.floatingLabelStyle,
      errorStyle: widget.errorStyle,
      errorMaxLines: widget.errorMaxLines,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      prefixIconConstraints: widget.prefixIconConstraints,
      suffixIconConstraints: widget.suffixIconConstraints,
      counterText: '',
      counterStyle: widget.counterStyle,
      enabled: widget.enabled,
    );
  }
}
