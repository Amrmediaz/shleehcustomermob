import 'package:flutter/material.dart';

import '../../util/cashed_data/cashed_file.dart';
import '../app_theme.dart';

class TextStyles {
  static double calculateFontSize(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    // Adjust the scaling factor based on screen size
    double scaleFactor =
        screenHeight < 600 ? 0.02 : (screenHeight > 900 ? 0.85 : 0.85);

    double fontSize = screenHeight * scaleFactor;

    // Set an upper limit for the font size
    double maxFontSize = 20.0;

    return fontSize.clamp(10.0, maxFontSize);
  }

  static TextStyle _baseTextStyle(BuildContext context,
      {double scaleFactor = 0.6,
      bool isBold = false,
      Color textColor = const Color(0xff3C3C43)}) {
    double fontSize =
        calculateFontSize(context) * (CasheFile.isTablet ? 1.2   : scaleFactor);

    return TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontFamily: isBold ? "FFShamelFamily" : "FFShamelFamilyRegular");
  }

  static TextStyle textStyleHelper(BuildContext context,
          {double scaleFactor = 0.6}) =>
      _baseTextStyle(context, scaleFactor: (CasheFile.isTablet ? 0.9  : scaleFactor));

  static TextStyle textStyleHeadline(BuildContext context,
          {double titleSizeFactor = 1.2, bool isBold = true}) =>
      _baseTextStyle(context, scaleFactor: (CasheFile.isTablet ? 1.6  : titleSizeFactor), isBold: isBold);

  static TextStyle textStyleTitle(BuildContext context,
          {double titleSizeFactor = 0.6}) =>
      _baseTextStyle(context, scaleFactor: (CasheFile.isTablet ? 0.9  : titleSizeFactor), isBold: true);

  static TextStyle textStyleBody(BuildContext context) =>
      _baseTextStyle(context);

  static TextStyle textStyleButton(BuildContext context,
          {double scaleFactor = 0.6}) =>
      _baseTextStyle(context,
          scaleFactor: (CasheFile.isTablet ? 0.9  : scaleFactor), textColor: Colors.white, isBold: true);

  static TextStyle textStyleHint(BuildContext context,
      {bool isObscure = false}) {
    double fontSize = calculateFontSize(context) * (isObscure ? 0.6 : 0.8);

    return TextStyle(
      color: Colors.grey.shade600,
      fontSize: fontSize,
    );
  }

  static TextStyle textStyleForm(BuildContext context) =>
      _baseTextStyle(context);
}
