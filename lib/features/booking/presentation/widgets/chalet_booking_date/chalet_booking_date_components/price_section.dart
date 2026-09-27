import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shleehcustomer/core/strings/language.dart';

import 'package:shleehcustomer/features/booking/presentation/bloc/bookings/bookings_bloc.dart';
import 'package:shleehcustomer/features/booking/presentation/pages/book_payment_chalet_screen.dart';
import 'package:shleehcustomer/features/booking/domain/entities/payment.dart';
import 'package:shleehcustomer/features/booking/presentation/widgets/chalet_booking_date/total_price_Widget.dart';

import '../../../../domain/entities/special_price_range.dart';
import 'deposit_checkbox.dart';

/// Shows the calculated total price + (optional) deposit checkbox, and
/// reacts to booking bloc state (already-booked / booked-success).
class PriceSection extends StatefulWidget {
  final List<Map<String, dynamic>> bookingDaysCalculatePrice;
  final dynamic chalet;
  final bool isChalet;
  final List<DateTime?> dates;
  final bool userEnableDeposit;
  final ValueChanged<bool> onDepositChanged;

  /// Called (after build) whenever a new total is calculated, so the
  /// parent can keep its own totalCost/paidAmount in sync for use when
  /// actually submitting the booking.
  final void Function(double totalCost, double paidAmount) onPriceCalculated;

  final VoidCallback onAlreadyBooked;

  const PriceSection({
    Key? key,
    required this.bookingDaysCalculatePrice,
    required this.chalet,
    required this.isChalet,
    required this.dates,
    required this.userEnableDeposit,
    required this.onDepositChanged,
    required this.onPriceCalculated,
    required this.onAlreadyBooked,
  }) : super(key: key);

  @override
  State<PriceSection> createState() => _PriceSectionState();
}

class _PriceSectionState extends State<PriceSection> {
  double _totalCost = 0.0;
  double _paidAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    if (widget.bookingDaysCalculatePrice.isEmpty) return Container();

    return BlocListener<BookingsBloc, BookingState>(
      listener: (context, state) {
        if (state is ChaletAlreadyBookedState) {
          widget.onAlreadyBooked();
        } else if (state is ChaletBookedSuccessState) {
          final dates = widget.dates;
          final hasBothDates = dates.length >= 2 && dates[0] != null && dates[1] != null;

          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: BookChaletScreen(
              paymentDetails: PaymentDetails(
                bookingId: state.bookingId,
                daysCount: widget.bookingDaysCalculatePrice.length,
                daysRange: hasBothDates
                    ? "${formatDateYyyyMmDd(dates[0]!)} - ${formatDateYyyyMmDd(dates[1]!)}"
                    : "${dates.isNotEmpty ? dates[0] : ''} - ${dates.length > 1 ? dates[1] : ''}",
                totalCost: _totalCost,
                insurance: widget.chalet.insuranceamount is double
                    ? '${widget.chalet.insuranceamount}'
                    : widget.chalet.insuranceamount,
                arbon: widget.chalet.acceptDeposit,
                chalet: widget.chalet,
                bookingDaysCalculatePrice: widget.bookingDaysCalculatePrice,
                currentPaid: _paidAmount,
              ),
              isChalet: widget.isChalet,
            ),
          );
        }
      },
      child: BlocBuilder<BookingsBloc, BookingState>(
        // Was missing ErrorBookingTotalPriceState here — if the price
        // calculation call failed, this stayed on the spinner forever
        // (buildWhen only let Loaded/Loading through), and the Book button
        // downstream would never get a total, so the user was stuck with
        // no way to tell what happened.
        buildWhen: (previous, current) =>
        current is LoadedBookingTotalPriceState ||
            current is LoadingBookingTotalPriceState ||
            current is ErrorBookingTotalPriceState,
        builder: (context, state) {
          if (state is LoadingBookingTotalPriceState) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LoadedBookingTotalPriceState) {
            return _buildLoaded(context, state);
          }
          if (state is ErrorBookingTotalPriceState) {
            return Center(
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, LoadedBookingTotalPriceState state) {
    final double total = state.totalBookingPrice;
    final double paid = (widget.chalet?.acceptDeposit == true && widget.userEnableDeposit)
        ? (total * 0.25).ceilToDouble()
        : total;

    _totalCost = total;
    _paidAmount = paid;

    // Defer notifying the parent until after this build completes, so we
    // never trigger setState() while the widget tree is still building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onPriceCalculated(_totalCost, _paidAmount);
    });

    return Column(
      children: [
        TotalPriceWidget(
          chalet: widget.chalet,
          bookingDaysCalculatePrice: widget.bookingDaysCalculatePrice,
          totalBookingPrice: total,
          currentPaid: paid.ceil(),
        ),
        const SizedBox(height: 15),
        if (widget.chalet.acceptDeposit)
          DepositCheckbox(
            value: widget.userEnableDeposit,
            onChanged: widget.onDepositChanged,
          ),
      ],
    );
  }
}