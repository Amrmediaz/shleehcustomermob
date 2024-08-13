import 'package:flutter/cupertino.dart';
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        hasEndIcon == null
            ? SvgPicture.asset(AssetsPath.homeSvgImg,
                height: MediaQuery.of(context).size.width * 0.085,
                fit: BoxFit.contain, // Adjust the fit as needed
                width: MediaQuery.of(context).size.width * 0.085)
            : Container(),
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
                style: TextStyles.textStyleTitle(context)
                    .copyWith(color: primaryColor),
              )
      ]),
    );
  }
}
