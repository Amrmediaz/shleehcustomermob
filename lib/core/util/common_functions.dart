import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shleehcustomer/core/util/cashed_data/cashed_file.dart';
import 'package:shleehcustomer/features/authentication/login/presentation/bloc/login/login_event.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import '../../features/authentication/login/presentation/bloc/login/login_bloc.dart';
import '../strings/language.dart';
import '../styles/text/text_style.dart';
import '../widgets/bottom_sheets.dart';
import 'Constants.dart';
import 'bottom_sheet_custom.dart';

class CommonFunctions {
 static Future<void> openMap(String latitude , String longitude) async {
    String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    String appleMapsUrl = 'https://maps.apple.com/?q=$latitude,$longitude';

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
      await launchUrl(Uri.parse(appleMapsUrl));
    } else {
      throw 'Could not launch maps';
    }
  }

  checkDeviceType(BuildContext context) async {
   final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

   if (Platform.isIOS) {
     final iosInfo = await deviceInfoPlugin.iosInfo;

     if (iosInfo.model != null && iosInfo.model!.toLowerCase().contains("ipad")) {
       CasheFile.isTablet = true;
     } else {
       CasheFile.isTablet = false;

     }
   } else if (Platform.isAndroid) {
     final screenSize = MediaQuery.of(context).size;
     final aspectRatio = screenSize.width / screenSize.height;

     // You can define a threshold here to differentiate between phone and tablet
     // For instance, a common approach is to consider devices with a screen size
     // larger than 600dp or an aspect ratio larger than 1.5 as tablets.
     if (screenSize.shortestSide >= 600 || aspectRatio > 1.5) {
       CasheFile.isTablet = true;

     } else {
       CasheFile.isTablet = false;

     }
   } else {
     CasheFile.isTablet = false;

   }
 }
  static String arabicToEnglish(String input) {
    Map<String, String> arabicToEnglishMap = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };

    return input.split('').map((char) {
      return arabicToEnglishMap[char] ?? char;
    }).join('');
  }
  static int pageNumberBookings= 1 ;

  static int pageNumberChalets = 1 ;
  static int pageNumberFilterChalets = 1 ;

  static bool fromHighToLowPrice = true ;
  static bool fromHighToLowRate = true ;
static double getSafeAreaTip(BuildContext context){
  return CasheFile.isTablet ? MediaQuery.of(context).viewPadding.top + 30 : MediaQuery.of(context).viewPadding.top;
}
  static PageRouteBuilder createRoute(dynamic page) {

    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const delayStart = 0.5;
        const delayEnd = 0.5;
        const curve = Curves.easeIn;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        var offsetAnimation = animation.drive(
          TweenSequence([
            TweenSequenceItem(tween: Tween(begin: begin, end: begin), weight: delayStart),
            TweenSequenceItem(tween: tween, weight: 1.0),
            TweenSequenceItem(tween: Tween(begin: end, end: end), weight: delayEnd),
          ]),
        );

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      // Adjust the duration as needed
      transitionDuration: const Duration(seconds: 1),
    );
  }
  static  showBottomDialog(BuildContext context,Icon icon , String title,String description) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DEFAULT_CORNER)),
      ),
      context: context,

      builder: (BuildContext context) {

        return  Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              icon,
              const SizedBox(height: 16.0),
              Text(
               title,
                style: TextStyles.textStyleTitle(context),
              ),
              const SizedBox(height: 12.0),
              Text(
                description,
                textAlign: TextAlign.center,
                  style: TextStyles.textStyleHelper(context)
              ),
               SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
  static  showBottomWidgetDialog(BuildContext context,Widget titleView , Widget item,) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DEFAULT_CORNER)),
      ),
      context: context,

      builder: (BuildContext context) {

        return  Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              titleView,
              const SizedBox(height: 16.0),
              item,
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
  static sendMessageToWhatsApp(String messageWh) async {
    // Replace 'your_message_here' with the message you want to send
    String message = Uri.encodeFull(messageWh);
    String url = "https://wa.me/96893866893?text=$message";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  static delay(VoidCallback action, {required int seconds}) {
    Future.delayed(Duration(seconds: seconds), () {

      action.call();
    });
  }
  static double calculateIconSize(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.15;
  }

}
String formatDate(DateTime dateTime) {
  // Extracting date components
  int year = dateTime.year;
  int month = dateTime.month;
  int day = dateTime.day;

  // Returning formatted date string
  return '$year-$month-$day';
}
String getBookedDatesWithCalendarFormat(  DateTime dateTime){
  // Extracting date components
  int year = dateTime.year;
  var month = dateTime.month.toString().length == 1 ?"0${dateTime.month}" :"${dateTime.month}" ;
  var day =  dateTime.day.toString().length == 1 ?"0${dateTime.day}" :"${dateTime.day}";

  // Returning formatted date string
  return '$day/$month/$year';
}
bool isTokenExpired(String expiryDate) {
  // Parse the expiration date
  DateTime expiryDateTime = DateTime.parse(expiryDate);

  // Get the current date and time
  DateTime now = DateTime.now().toUtc();

  // Check if the current date is after the expiration date
  return now.isAfter(expiryDateTime);
}
expireToken(BuildContext context) async {
  await CasheFile().setLogout(context);
  if (context.mounted) {
    BlocProvider.of<LoginBloc>(context).add( UserLoginInitialEvent());
    BottomSheetsCustom.showFailBottomWidgetDialog(
        context,
        getTextByKey(
          key: TranslationKey.keySessionExpired,
        ),
        getTextByKey(key: TranslationKey.keyShouldLogin));
  }
}