import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/widgets/message_display_widget.dart';
import 'package:shleehcustomer/features/booking/presentation/bloc/bookings/bookings_bloc.dart';
import 'package:shleehcustomer/features/chalets/presentation/widgets/chalet_detail_page/chalet_detail_widget.dart';

import '../../../../core/util/Constants.dart';
import '../../../../core/widgets/app_bar_back.dart';
import '../../../../core/widgets/loading_widget.dart';

import '../widgets/booking_detail_page/booking_detail_widget.dart';

class BookingDetailPage extends StatelessWidget {
  // 1. Declare the variable as a final property of the class
  final bool isPendingBooking;
  final bool isChalet;
  final String? bookingId;

  const BookingDetailPage({
    this.isPendingBooking = false,
    this.isChalet = true,
    this.bookingId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  appBar: _buildAppbar(),
      body: SafeArea(
         bottom: false,
        child: _buildBody(), // 3. No need to pass it as an argument anymore
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<BookingsBloc, BookingState>(
      // Was missing both Error states here — meant that if fetching this
      // booking failed after the page was already open, the BlocBuilder
      // would never rebuild past the loading spinner, leaving the user
      // stuck looking at a permanent spinner with no way to know it failed.
      buildWhen: (previous, current) =>
      (current is LoadedBookingIdState) || (current is LoadingBookingIdState) || (current is LoadedBookingIdStateFlat) || (current is LoadingBookingIdStateFlat) || (current is LoadedBookingsStateFlat) || (current is ErrorBookingIdState) || (current is ErrorBookingIdStateFlat),
      builder: (context, state) {
        if (state is LoadedBookingIdState ) {
          // Safe to print/log, but consider moving business logic out of UI

          return ListView(
            padding: PADDING_PAGE,
            children: [
              const SizedBox(height: 10),
              AppBarBack(
                leadingWidgetAction: () {
                  Navigator.pop(context);
                },
              ), // Fixed the comma/syntax alignment here
              BookingDetailWidget(
                isChalet: isChalet, // 2. Use the class property directly
                bookingDetails: state.bookingDetails,
                isPendingBooking: isPendingBooking, // 4. Accessible globally in the class
              ),
            ],
          );
        }
        else   if (state is LoadedBookingIdStateFlat) {
          // Safe to print/log, but consider moving business logic out of UI

          return ListView(
            padding: PADDING_PAGE,
            children: [
              const SizedBox(height: 10),
              AppBarBack(
                leadingWidgetAction: () {
                  Navigator.pop(context);
                },
              ), // Fixed the comma/syntax alignment here
              BookingDetailWidget(
                isChalet: isChalet, // 2. Use the class property directly
                bookingDetails: state.bookingDetails,
                isPendingBooking: isPendingBooking, // 4. Accessible globally in the class
              ),
            ],
          );
        }

        else if (state is LoadingBookingIdState || state is LoadingBookingIdStateFlat) {
          return const LoadingWidget();
        } else {
          return MessageDisplayWidget(
            message: getTextByKey(key: TranslationKey.keyError),
            onRetry: bookingId == null
                ? null
                : () => context.read<BookingsBloc>().add(
                      isChalet
                          ? LoadBookingsById(id: bookingId!)
                          : LoadBookingsByIdFlat(id: bookingId!),
                    ),
          );
        }
      },
    );
  }
}