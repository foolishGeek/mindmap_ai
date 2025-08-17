import 'package:flutter/material.dart';

class Styles {
  Styles._();

  static const TextStyle kNodeFont = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.1,
  );
  static const StrutStyle kStrut = StrutStyle(
    forceStrutHeight: true,
    height: 1.28,
  );
}

class ColorConstants {
  ColorConstants._();

  static const Color edgeColor = Color(0xFF3C3C3C);
  static const Color hintColor = Color(0x4D000000);
  static Color iconBgColor = const Color(0x00000008).withOpacity(0.03);
}
