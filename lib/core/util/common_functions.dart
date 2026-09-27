import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
 static int pageNumberBookingsBildings= 1 ;

 static int pageNumberbuildings = 1 ;
 static int pageNumberFilterBuildings = 1 ;


  static int pageNumberChalets = 1 ;
  static int pageNumberFilterChalets = 1 ;
 static int pageNumberFillterChalets = 1 ;

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
 static showBottomDialog(
     BuildContext context, {
       required Icon icon,
       required String title,
       required String description,
       String? buttonText,
       VoidCallback? onButtonPressed,
       bool isDanger = false,
     }) {
   showModalBottomSheet(
     context: context,
     shape: const RoundedRectangleBorder(
       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
     ),
     backgroundColor: Colors.white,
     isScrollControlled: true,
     builder: (BuildContext context) {
       return SafeArea(
         child: Container(
           width: double.infinity,
           padding: EdgeInsets.fromLTRB(
             20,
             24,
             20,
             20 + MediaQuery.of(context).viewInsets.bottom,
           ),
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               // ✅ Drag Handle
               Container(
                 width: 40,
                 height: 4,
                 decoration: BoxDecoration(
                   color: Colors.grey[300],
                   borderRadius: BorderRadius.circular(2),
                 ),
               ),
               const SizedBox(height: 20),

               // ✅ Icon with Background
               Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: isDanger
                       ? Colors.red.withOpacity(0.1)
                       : const Color(0xFF6366F1).withOpacity(0.1),
                   borderRadius: BorderRadius.circular(16),
                 ),
                 child: IconTheme(
                   data: IconThemeData(
                     color: isDanger ? Colors.red : const Color(0xFF6366F1),
                     size: 32,
                   ),
                   child: icon,
                 ),
               ),
               const SizedBox(height: 20),

               // ✅ Title
               Text(
                 title,
                 textAlign: TextAlign.center,
                 style: const TextStyle(
                   fontSize: 18,
                   fontWeight: FontWeight.w800,
                   color: Color(0xFF1A1F2E),
                   letterSpacing: 0.3,
                 ),
               ),
               const SizedBox(height: 12),

               // ✅ Description
               Text(
                 description,
                 textAlign: TextAlign.center,
                 style: TextStyle(
                   fontSize: 13,
                   fontWeight: FontWeight.w400,
                   color: Colors.grey[600],
                   height: 1.6,
                 ),
               ),
               const SizedBox(height: 28),

               // ✅ Action Button
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   onPressed: () {
                     Navigator.pop(context);
                     onButtonPressed?.call();
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: isDanger
                         ? Colors.red
                         : const Color(0xFF6366F1),
                     foregroundColor: Colors.white,
                     padding: const EdgeInsets.symmetric(vertical: 16),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(12),
                     ),
                     elevation: 0,
                   ),
                   child: Text(
                     buttonText ?? 'حسناً',
                     style: const TextStyle(
                       fontSize: 14,
                       fontWeight: FontWeight.w700,
                       letterSpacing: 0.3,
                     ),
                   ),
                 ),
               ),
             ],
           ),
         ),
       );
     },
   );
 }  static  showBottomWidgetDialog(BuildContext context,Widget titleView , Widget item,) {
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

// ✅ Fixed WhatsApp function
  static Future<void> sendMessageToWhatsApp(
      BuildContext context,
      String messageWh,
      ) async {
    final encodedMessage = Uri.encodeComponent(messageWh);
    const phoneNumber = "96893866893";

    final whatsappSchema = Uri.parse("whatsapp://send?phone=$phoneNumber&text=$encodedMessage");
    final whatsappHttps = Uri.parse("https://wa.me/$phoneNumber?text=$encodedMessage");

    try {
      if (await launchUrl(whatsappSchema, mode: LaunchMode.externalApplication)) return;
    } catch (_) {/* fall through */}

    try {
      if (await launchUrl(whatsappHttps, mode: LaunchMode.externalApplication)) return;
    } catch (_) {/* fall through */}

    await Clipboard.setData(ClipboardData(text: "+$phoneNumber"));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'تم نسخ رقم الدعم: +$phoneNumber\nيمكنك الآن فتح واتس آب يدويًا',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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