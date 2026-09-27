// import 'package:flutter/material.dart';
// import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
// import 'package:shleehcustomer/core/styles/app_theme.dart';
// import 'package:shleehcustomer/core/strings/language.dart';
// import 'package:shleehcustomer/features/booking/presentation/pages/chalet_booking_date_page.dart';
// import '../../../domain/entities/chalet_details_model.dart';
//
//
// import 'package:flutter/material.dart';
// import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
// import 'package:shleehcustomer/core/styles/app_theme.dart';
// import 'package:shleehcustomer/core/strings/language.dart';
// import 'package:shleehcustomer/features/booking/presentation/pages/chalet_booking_date_page.dart';
// import '../../../domain/entities/chalet_details_model.dart';
//
// class BookingButton extends StatelessWidget {
//   final ChaletDetails chalet;
//   final VoidCallback? onUnavailable;
//   final bool isChalet;
//
//   const BookingButton({
//     Key? key,
//     required this.chalet,
//     required this.isChalet,
//     this.onUnavailable,
//   }) : super(key: key);
//
//   // ✅ Show unavailable dialog
//   void _showUnavailableDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         backgroundColor: Colors.white,
//         title: Row(
//           children: [
//             Icon(Icons.lock_outline, color: Colors.red, size: 28),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 'غير متاح للحجز',
//                 style: TextStyle(
//                   color: Colors.grey[900],
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         content: Text(
//           'هذا الشاليه غير متاح للحجز في الوقت الحالي من قبل المالك.',
//           style: TextStyle(
//             color: Colors.grey[700],
//             fontSize: 14,
//             height: 1.6,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'حسناً',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isUnavailable = chalet.stopBook == true;
//
//     return GestureDetector(
//       onTap: isUnavailable
//           ? () {
//         _showUnavailableDialog(context);
//         onUnavailable?.call();
//       }
//           : () {
//         PersistentNavBarNavigator.pushNewScreen(
//           context,
//           screen: ChaletBookingPage(chalet: chalet,isChalet: isChalet,),
//           withNavBar: false,
//         );
//       },
//       child: TweenAnimationBuilder<double>(
//         tween: Tween<double>(begin: 0, end: 1),
//         duration: const Duration(milliseconds: 800),
//         builder: (context, value, child) {
//           return Transform.scale(
//             scale: value,
//             child: child,
//           );
//         },
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           decoration: BoxDecoration(
//             // ✅ Change gradient based on availability
//             gradient: isUnavailable
//                 ? LinearGradient(
//               colors: [
//                 Colors.grey[400]!,
//                 Colors.grey[300]!,
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             )
//                 : LinearGradient(
//               colors: [primaryColor, primaryColor.withOpacity(0.8)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(18),
//             boxShadow: [
//               BoxShadow(
//                 color: isUnavailable
//                     ? Colors.grey.withOpacity(0.15)
//                     : primaryColor.withOpacity(0.35),
//                 blurRadius: 18,
//                 offset: const Offset(0, 6),
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // ✅ Change icon based on availability
//               Icon(
//                 isUnavailable ? Icons.lock_rounded : Icons.calendar_month_rounded,
//                 color: Colors.white,
//                 size: 21,
//               ),
//               const SizedBox(width: 10),
//               Text(
//                 // ✅ Change text based on availability
//                 isUnavailable
//                     ? 'غير متاح للحجز'
//                     : getTextByKey(key: TranslationKey.keyBookYourStay),
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 0.3,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }