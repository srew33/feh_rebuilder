import 'package:flutter/material.dart';

extension CustomStyle on TextTheme {
  TextStyle get descStyle {
    return const TextStyle(
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      fontSize: 12.5,
    );
  }
}
