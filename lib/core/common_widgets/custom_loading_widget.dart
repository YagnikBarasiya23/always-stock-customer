import 'package:flutter/material.dart';

import '../extensions/app_extensions.dart';

class CustomLoadingWidget extends StatelessWidget {
  const CustomLoadingWidget({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size, height: size, child: CircularProgressIndicator(strokeWidth: 2).wrapCenter());
}
