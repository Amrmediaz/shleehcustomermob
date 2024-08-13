import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/features/chalets/presentation/bloc/chalets/chalets_bloc.dart';

import '../../../../../core/strings/assets_path.dart';
import '../../../../../core/strings/language.dart';
import '../../../../../core/util/Constants.dart';
import '../../../../../core/util/common_functions.dart';
import '../../../../../core/widgets/app_bar_back.dart';
import '../../../../../core/widgets/text_icon.dart';
import '../../../domain/entities/booking.dart';
import '../../bloc/bookings/bookings_bloc.dart';
import '../../pages/payment_bank_screen_web_view.dart';
import 'booking_list_widget.dart';
// import 'booking_list_widget.dart';

class BookingsPageWidget extends StatefulWidget {
  final List<Booking> bookings;
  final bool bookingStateIsEmpty;
  final BuildContext buildContext;
  BookingsPageWidget(
      {super.key, required this.bookings,
      required this.bookingStateIsEmpty,
      required this.buildContext});
  @override
  State<BookingsPageWidget> createState() => _BookingsPageWidgetState();
}

class _BookingsPageWidgetState extends State<BookingsPageWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: Container(
        padding: const EdgeInsets.all(5),
        color: Colors.grey.shade50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "  ${getTextByKey(key: TranslationKey.keyMyBookings)}",
              style: TextStyles.textStyleHeadline(context),
            ),
            Expanded(
              child: BlocListener<BookingsBloc, BookingState>(
                  listener: (context, state) {
                    if (state is LoadedBookingPaymentState) {
                      PersistentNavBarNavigator.pushNewScreen(context,
                          screen: PaymentBankWebViewScreen(
                            paymentId: state.url.split("/").last,

                          ),
                          withNavBar: false);
                      // BlocProvider.of<BookingsBloc>(
                      //     context)
                      //     .add(BookingsEventIni(
                      //    ));
                    }
                  },
                  child: BlocBuilder<BookingsBloc, BookingState>(
                      builder: (context, state) {
                    return BookingListWidget(
                      bookings: widget.bookings,
                      lastEmpty: widget.bookingStateIsEmpty ? true : false,
                    );
                  }, buildWhen: (previous, current) {
                    if (current is LoadedBookingPaymentState) {
                      return true;
                    } else {
                      return false;
                    }
                  })),
            )
          ],
        ),
      ))
    ]);
  }
}
