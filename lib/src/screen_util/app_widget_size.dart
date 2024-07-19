import 'package:flutter/material.dart';
import 'package:product_expo/src/screen_util/screen_util.dart';

class AppWidgetSize {
  static REdgeInsets expoAppPadding =
      REdgeInsets.fromLTRB(dimen_18, dimen_8, dimen_18, dimen_0);

  static const double dimen_0 = 0;
    static const double dimen_1 = 1;
  static const double dimen_2 = 2;
  static const double dimen_3 = 3;
  static const double dimen_6 = 6;
  static const double dimen_8 = 8;
  static const double dimen_10 = 10;
  static const double dimen_12 = 12;
  static const double dimen_14 = 14;
  static const double dimen_15 = 15;
  static const double dimen_16 = 16;
  static const double dimen_18 = 18;
  static const double dimen_20 = 20;
  static const double dimen_24 = 24;
  static const double dimen_26 = 26;
  static const double dimen_28 = 28;
  static const double dimen_32 = 32;
  static const double dimen_34 = 34;
  static const double dimen_36 = 36;
  static const double dimen_40 = 40;
  static const double dimen_52 = 52;
  static const double dimen_64 = 64;
  static const double dimen_72 = 72;
  static const double dimen_178 = 178;
  initSize() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  static double getSize(double size) {
    return size * 1;
  }

  static Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).viewPadding;
  }

  static double screenHeight(BuildContext context, {double dividedBy = 1}) {
    return (screenSize(context).height) / dividedBy;
  }

  static double bottomInset(BuildContext context) {
    return (MediaQuery.of(context).viewInsets.bottom);
  }

  static double screenWidth(BuildContext context, {double dividedBy = 1}) {
    return screenSize(context).width / dividedBy;
  }
}
