// Patch for BookingsPageWidget (booking_page_widget.dart) — full file, only
// change is a new required `isChalet` field that gets forwarded to
// BookingListWidget, so pagination further down the tree knows which tab
// it's fetching for.

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../../core/strings/language.dart';
import '../../../../../core/styles/text/text_style.dart';
import '../../../domain/entities/booking.dart';
import '../../bloc/bookings/bookings_bloc.dart';
import '../../pages/payment_bank_screen_web_view.dart';
import 'booking_list_widget.dart';

class BookingsPageWidget extends StatelessWidget {
  final List<Booking> bookings;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final bool isChalet;

  const BookingsPageWidget({
    super.key,
    required this.bookings,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.isChalet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "  ${getTextByKey(key: TranslationKey.keyMyBookings)}",
                style: TextStyles.textStyleHeadline(context),
              ),
              Expanded(
                child: BookingListWidget(
                  bookings: bookings,
                  hasMore: hasMore,
                  isLoadingMore: isLoadingMore,
                  isChalet: isChalet,
                  onLoadMore: onLoadMore,
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}