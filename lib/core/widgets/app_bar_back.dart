import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shleehcustomer/core/strings/assets_path.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';

class AppBarBack extends StatelessWidget {
  final Function leadingWidgetAction;
  final bool? hasEndIcon;
  final bool? isMain;
  AppBarBack({required this.leadingWidgetAction, this.hasEndIcon, this.isMain});

  // Only the home-page logo bar (isMain: false) now sits on a solid purple
  // background — every other screen still uses this widget for its
  // white-background back button, so the color swap below is scoped to
  // that one variant instead of changing the icon/text globally.
  bool get _isLogoBar => isMain == false;

  @override
  Widget build(BuildContext context) {
    final homeIcon = SvgPicture.asset(AssetsPath.homeSvgImg,
        height: MediaQuery.of(context).size.width * 0.085,
        fit: BoxFit.contain, // Adjust the fit as needed
        width: MediaQuery.of(context).size.width * 0.085,
        colorFilter: _isLogoBar
            ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
            : null);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        hasEndIcon == null ? homeIcon : Container(),
        isMain == null
            ? GestureDetector(
                onTap: () {
                  leadingWidgetAction();
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      getTextByKey(key: TranslationKey.keyBack),
                      style: TextStyles.textStyleBody(context),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SvgPicture.asset(AssetsPath.backImg,
                        height: MediaQuery.of(context).size.width * 0.065,
                        width: MediaQuery.of(context).size.width * 0.065)
                  ],
                ),
              )
            : Text(
                "شاليه كوم",
                style: TextStyles.textStyleTitle(context).copyWith(
                    color: _isLogoBar ? Colors.white : primaryColor,
                    fontWeight: FontWeight.bold),
              )
      ]),
    );
  }
}
