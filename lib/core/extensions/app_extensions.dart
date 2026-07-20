import 'package:flutter/material.dart';

extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

extension MediaQueryExt on BuildContext {
  Size get mqSize => MediaQuery.sizeOf(this);

  double get height => mqSize.height;

  double get width => mqSize.width;
}

extension PaddingExt on Widget {
  Padding viewInsets(BuildContext context) =>
      Padding(padding: MediaQuery.viewInsetsOf(context), child: this);

  Padding pAll(double value, {Key? key}) =>
      Padding(key: key, padding: EdgeInsets.all(value), child: this);

  Padding pOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
    Key? key,
  }) => Padding(
    key: key,
    padding: EdgeInsets.only(
      top: top,
      left: left,
      bottom: bottom,
      right: right,
    ),
    child: this,
  );

  Padding px(double horizontal, {Key? key}) => Padding(
    key: key,
    padding: EdgeInsets.symmetric(vertical: 0, horizontal: horizontal),
    child: this,
  );

  Padding py(double vertical, {Key? key}) => Padding(
    key: key,
    padding: EdgeInsets.symmetric(vertical: vertical, horizontal: 0),
    child: this,
  );

  Padding pSymmetric({
    double horizontal = 0.0,
    double vertical = 0.0,
    Key? key,
  }) => Padding(
    key: key,
    padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
    child: this,
  );
}

extension SizeBoxEx on num {
  Widget get widthBox => SizedBox(width: toDouble());

  Widget get heightBox => SizedBox(height: toDouble());
}

extension IterableExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

extension CenterExtension on Widget {
  Widget wrapCenter() => Center(child: this);
}
