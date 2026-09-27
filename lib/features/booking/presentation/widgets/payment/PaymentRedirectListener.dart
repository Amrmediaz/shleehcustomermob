import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../../core/strings/language.dart';
import '../../../../../core/styles/app_theme.dart';
import '../../../../../core/util/biometric_auth.dart';
import '../../../../../core/util/common_functions.dart';
import '../../bloc/bookings/bookings_bloc.dart';
import '../../pages/payment_bank_screen_web_view.dart';

/// Mount this ONCE, wrapping whatever ancestor provides BookingsBloc
/// (wherever BlocProvider<BookingsBloc>(...) is created — send me that
/// file and I'll show exactly where). Do NOT add another
/// BlocListener<BookingsBloc, BookingState> for LoadedBookingPaymentState
/// or ErrorPaymentBookingState anywhere else — every screen that needs to
/// react to a payment result already sits underneath this listener in the
/// tree for the app's whole lifetime.
class PaymentRedirectListener extends StatelessWidget {
  final Widget child;
  const PaymentRedirectListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingsBloc, BookingState>(
      listenWhen: (previous, current) =>
      current is LoadedBookingPaymentState ||
          current is ErrorPaymentBookingState,
      listener: (context, state) async {
        if (state is LoadedBookingPaymentState) {
          // Single choke point for every booking flow (chalets + buildings
          // both funnel through this one BookingsBloc state) — if the
          // guest has turned on "confirm payment with biometrics" in
          // settings, require a successful fingerprint/Face ID check right
          // here before the payment webview ever opens. Declining or
          // failing the prompt cancels the payment attempt entirely; it
          // does NOT fall back to letting the payment through.
          final payGateEnabled = await BiometricPrefs.isPayEnabled();
          if (payGateEnabled) {
            final available = await BiometricAuthService.isAvailable();
            final confirmed = available &&
                await BiometricAuthService.authenticate(
                  reason: 'الرجاء تأكيد بصمتك لإتمام عملية الدفع',
                );
            if (!confirmed) {
              context.read<BookingsBloc>().add(BookingsEventIni());
              if (context.mounted) {
                CommonFunctions.showBottomDialog(
                  context,
                  icon: Icon(Icons.fingerprint, color: primaryColor),
                  title: getTextByKey(key: TranslationKey.keyBiometricPaymentFailed),
                  description: 'لم يتم تأكيد الدفع، حاول مرة أخرى',
                );
              }
              return;
            }
          }

          if (!context.mounted) return;
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: PaymentBankWebViewScreen(paymentUrl: state.url),
            withNavBar: false,
          );
          context.read<BookingsBloc>().add(BookingsEventIni());
        } else if (state is ErrorPaymentBookingState) {
          CommonFunctions.showBottomDialog(
            context,
            icon: Icon(Icons.calendar_month_sharp, color: primaryColor),
            title: getTextByKey(key: TranslationKey.keyDatesBooked),
            description: getTextByKey(key: TranslationKey.keyPleaseSelectAnotherDates),
          );
        }
      },
      child: child,
    );
  }
}