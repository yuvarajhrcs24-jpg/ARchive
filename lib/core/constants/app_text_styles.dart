import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Roboto';

  static const TextStyle headline1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle headline2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
  );

  static const TextStyle headline3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  static const TextStyle title1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  static const TextStyle title2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.25,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.normal,
    letterSpacing: 1.5,
  );
}
