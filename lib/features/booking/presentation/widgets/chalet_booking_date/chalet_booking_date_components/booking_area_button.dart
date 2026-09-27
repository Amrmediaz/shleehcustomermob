import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/util/bottom_sheet_custom.dart';
import 'package:shleehcustomer/core/util/common_functions.dart';
import 'package:shleehcustomer/core/util/snackbar_message.dart';
import 'package:shleehcustomer/core/widgets/action_btn.dart';
import 'package:shleehcustomer/features/authentication/login/presentation/bloc/login/login_bloc.dart';
import 'package:shleehcustomer/features/authentication/login/presentation/bloc/login/login_state.dart';
import 'package:shleehcustomer/features/booking/presentation/bloc/bookings/bookings_bloc.dart';

/// Book button when logged in, or a "please login" prompt + login button
/// when not.
class BookButtonArea extends StatelessWidget {
  final bool isLoggedIn;
  final bool canBook;
  final VoidCallback onBookPressed;

  /// Called after a successful login from this widget, so the parent can
  /// rebuild and pick up the new login state.
  final VoidCallback? onLoginSuccess;

  const BookButtonArea({
    Key? key,
    required this.isLoggedIn,
    required this.canBook,
    required this.onBookPressed,
    this.onLoginSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      return BlocBuilder<BookingsBloc, BookingState>(
        builder: (context, state) {
          final isBooking = state is LoadingBookingPaymentState;
          return ActionBtn(
            onPressed: onBookPressed,
            btnTitle: getTextByKey(key: TranslationKey.keyBook),
            btnColor: canBook ? primaryColor : Colors.grey.shade500,
            isLoading: isBooking,
          );
        },
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          Text(
            getTextByKey(key: TranslationKey.keyShouldLogin),
            style: TextStyles.textStyleHeadline(context, titleSizeFactor: 0.65)
                .copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          _LoginButton(onLoginSuccess: onLoginSuccess),
        ],
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback? onLoginSuccess;

  const _LoginButton({this.onLoginSuccess});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is MessageLoginState && !state.isMainLogin) {
          Navigator.pop(context);
          CommonFunctions.showBottomWidgetDialog(
            context,
            Icon(Icons.check_circle_outlined, color: primaryColor, size: MediaQuery.of(context).size.width / 7),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  Text(
                    getTextByKey(key: TranslationKey.keyLoginSuccessMessage),
                    style: TextStyles.textStyleHeadline(context, titleSizeFactor: 0.7),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
          onLoginSuccess?.call();
        } else if (state is ErrorLoginState && !state.isMainLogin) {
          SnackBarMessage().showErrorSnackBar(message: state.message, context: context);
          CommonFunctions.showBottomDialog(
            context,
            icon: Icon(Icons.error, color: primaryColor, size: CommonFunctions.calculateIconSize(context)),
            title: state.message,
            description: "",
          );
        }
      },
      builder: (context, state) {
        return ActionBtn(
          onPressed: () => BottomSheetsCustom.showLoginBottomDialog(context),
          btnTitle: getTextByKey(key: TranslationKey.keyLogin),
          btnColor: primaryColor,
        );
      },
    );
  }
}