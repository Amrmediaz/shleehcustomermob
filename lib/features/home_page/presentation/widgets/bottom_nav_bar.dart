import 'package:flutter/cupertino.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../core/styles/app_theme.dart';
import '../../../../core/styles/text/text_style.dart';

class BottomNavBar {
  PersistentBottomNavBarItem getNavBar({required String title , required Icon icon, required BuildContext buildContext}){
    return  PersistentBottomNavBarItem(
        icon: icon  ,
        title: " $title " ,
        activeColorPrimary: primaryColor,
        inactiveColorPrimary: secondaryColor,
        textStyle: TextStyles.textStyleBody(buildContext)
    );
  }
}