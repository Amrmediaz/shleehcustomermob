import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shleehcustomer/core/strings/assets_path.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';

class AppBarAuth extends StatelessWidget {
  AppBarAuth();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        SvgPicture.asset(AssetsPath.homeSvgImg,
            height: MediaQuery.of(context).size.width * 0.085,
            fit: BoxFit.contain, // Adjust the fit as needed
            width: MediaQuery.of(context).size.width * 0.085),
        SvgPicture.asset(AssetsPath.privacySvg,
            height: MediaQuery.of(context).size.width * 0.055,
            fit: BoxFit.contain, // Adjust the fit as needed
            width: MediaQuery.of(context).size.width * 0.055),
      ]),
    );
  }
}
