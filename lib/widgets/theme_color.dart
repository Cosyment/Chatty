import 'package:flutter/cupertino.dart';

class ThemeColor {
  static Color? appBarBackgroundColor = Color.lerp(CupertinoColors.darkBackgroundGray, backgroundColor, 0.3);
  static Color backgroundColor = const Color(0xFF111114);
  static Color primaryColor = CupertinoColors.darkBackgroundGray;
  static Color textColor = CupertinoColors.darkBackgroundGray;
  static Color selectColor = CupertinoColors.darkBackgroundGray;
}
