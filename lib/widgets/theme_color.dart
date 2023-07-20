import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeColor {
  static Color? appBarBackgroundColor = Color.lerp(CupertinoColors.darkBackgroundGray, Colors.black, 0.2);
  static Color backgroundColor = CupertinoColors.darkBackgroundGray;
  static Color primaryColor = CupertinoColors.secondaryLabel;
  static Color textColor = CupertinoColors.darkBackgroundGray;
  static Color selectColor = CupertinoColors.darkBackgroundGray;
}
