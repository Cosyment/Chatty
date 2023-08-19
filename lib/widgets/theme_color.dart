import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeColor {
  // static Color primaryColor = CupertinoColors.darkBackgroundGray;
  static MaterialColor primaryColor = const MaterialColor(
    0xFF313134,
    <int, Color>{
      50: Color(0xFFF7F7FA),
      100: Color(0xFFEDEDF1),
      200: Color(0xFFE1E1E5),
      300: Color(0xFFCFCFD2),
      400: Color(0xFFAAAAAD),
      500: Color(0xFF89898c),
      600: Color(0xFF626265),
      700: Color(0xFF474752),
      800: Color(0xFF171717),
      900: Color(0xFF1b1b1d)
    },
  );

  static Color appBarBackgroundColor = primaryColor.shade900;
  static Color backgroundColor = primaryColor.shade800;
  static Color dialogBackground = primaryColor.shade800;
  static Color popupBackground = CupertinoColors.darkBackgroundGray;

  static Color textColor = primaryColor.shade600;
  static Color selectColor = primaryColor.shade300;
}
