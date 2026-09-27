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
    // Smooth fade+scale transition for every screen change in the app,
    // instead of the platform-default (which on Android is an abrupt
    // slide-in-from-right with no fade — this applies everywhere without
    // touching each individual Navigator.push call site).
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _FadeScalePageTransitionsBuilder(),
        TargetPlatform.iOS: _FadeScalePageTransitionsBuilder(),
      },
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

/// A subtle fade + slight-slide-up transition, smoother and less jarring
/// than the platform default page transitions.
class _FadeScalePageTransitionsBuilder extends PageTransitionsBuilder {
  const _FadeScalePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
