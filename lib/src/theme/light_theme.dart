import 'package:flutter/material.dart';

const Color appPrimaryColor = Color(0xFFFFFFFF); //whiteColor
const Color appOnPrimaryColor = Color(0xFFF2F2F7); //Card Grey Color
const Color appSecondaryColor = Color(0xFF232323);
const Color appOnSecondaryColor = Color(0xFF000000);
const Color appSecondaryContainerColor = Color(0xFF6B6B6B);
const Color appOnSecondaryContainerColor = Color(0xFFFF3348);
const Color appPrimaryContainerColor = Color(0xFFAEAEB2);

ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: appPrimaryColor,
    scaffoldBackgroundColor: appPrimaryColor,
    fontFamily: 'SF Compact Display',
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: appPrimaryColor, //white Color
      onPrimary: appOnPrimaryColor, //Card Grey Color
      primaryContainer: appPrimaryContainerColor,
      secondary: appSecondaryColor, //Text Black Color 1
      onSecondary: appOnSecondaryColor, //Text Black Color 2
      secondaryContainer: appSecondaryContainerColor, //Text Grey Color
      onSecondaryContainer: appOnSecondaryContainerColor, //Red Color
    ),
  );
}
