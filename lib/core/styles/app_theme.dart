import 'package:flutter/material.dart';

final primaryColor = Color(0xff5850FF);
final secondaryColor = Color(0xff082659);
final formGreyColor = Color(0xffF8F8F8);
final GreyColor = Color(0xffF2F2F2);
final greyColorTxt = Color.fromRGBO(0x3C, 0x3C, 0x43, 0.6);


final appTextColor = const Color(0xff3C3C43);
final yellowAppColor = const Color(0xffFFC300);

final appTheme = ThemeData(
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      centerTitle: true,
    ),
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: primaryColor),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: secondaryColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
        floatingLabelStyle: TextStyle(color: primaryColor),
        iconColor: secondaryColor,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: secondaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(8),
        )));
