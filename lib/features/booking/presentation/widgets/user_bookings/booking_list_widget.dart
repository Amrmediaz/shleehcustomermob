// Full file for booking_list_widget.dart (drop-in replacement).
//
// Matches your latest BookingsBloc: GetAllBookingsEvent/GetAllBookingsEventFlat
// and LoadBookingsById/LoadBookingsByIdFlat no longer take an `isChalet`
// param — the bloc infers it from which event type it receives. So
// pagination and the card tap now pick the right event constructor based
// on `widget.isChalet` instead of passing a flag.
//
// Also: page number is local to this widget's State instead of the old
// shared CommonFunctions.pageNumberBookings static field, so each tab's
// scroll pagination is isolated from the other's.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/util/Constants.dart';
import 'package:shleehcustomer/core/util/common_functions.dart';
import 'package:shleehcustomer/core/widgets/payment_method_badge.dart';
import '../../bloc/bookings/bookings_bloc.dart';
import '../../pages/booking_detail_page.dart';
import '../../../domain/entities/booking.dart';

class BookingListWidget extends StatelessWidget {
  final List<Booking> bookings;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isChalet;
  final VoidCallback onLoadMore;

  const BookingListWidget({
    Key? key,
    required this.bookings,
    required this.hasMore,
    required this.isLoadingMore,
    required this.isChalet,
    required this.onLoadMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bookings.length + (hasMore ? 1 : 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemBuilder: (context, index) {
        if (index == bookings.length) {
          // Parent (_BookingsTabBodyState) guards against duplicate
          // in-flight requests via _isLoadingMore, so it's safe to call
          // this every time the footer item builds.
          WidgetsBinding.instance.addPostFrameCallback((_) => onLoadMore());
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
          );
        }

        final booking = bookings[index];
        final isPending = booking.bookingStatus == 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _BookingCard(
            booking: booking,
            index: index,
            isPending: isPending,
            isChalet: isChalet,
          ),
        );
      },
    );
  }
}

class _BookingCard extends StatefulWidget {
  final Booking booking;
  final int index;
  final bool isPending;
  final bool isChalet; // NEW

  const _BookingCard({
    required this.booking,
    required this.index,
    required this.isPending,
    required this.isChalet, // NEW
  });

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                // LoadBookingsById / LoadBookingsByIdFlat no longer carry an
                // isChalet flag either — pick the right event type here.
                final event = widget.isChalet
                    ? LoadBookingsById(id: '${widget.booking.id}')
                    : LoadBookingsByIdFlat(id: '${widget.booking.id}');
                BlocProvider.of<BookingsBloc>(context).add(event);
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: BookingDetailPage(
                    isPendingBooking: widget.isPending,
                    isChalet: widget.isChalet,
                    bookingId: '${widget.booking.id}',
                  ),
                  withNavBar: false,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header Section ──────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        // ── Index Badge ──
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primaryColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${widget.index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // ── Booking Info ──
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              const SizedBox(height: 5),
                              Text(
                                '${getTextByKey(key: TranslationKey.keyBookingNumber)} #${widget.booking.id} ',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.booking.noOfDays} ${getTextByKey(key: TranslationKey.keyDays)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ── Status ──
                        _StatusChip(isPending: widget.isPending),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primaryColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.villa_rounded, size: 14, color: primaryColor),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            widget.booking.itemName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(height: 1, color: Colors.grey.shade100),

                  // ── Payment Status Section ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: widget.isPending
                        ? _PendingPaymentInfo(booking: widget.booking)
                        : _PaidPaymentInfo(booking: widget.booking),
                  ),

                  Container(height: 1, color: Colors.grey.shade100),

                  // ── Action Button ──
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: widget.isPending
                        ? _PayButton(booking: widget.booking, isChalet: widget.isChalet)
                        : const _ConfirmedRow(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── PENDING PAYMENT INFO ──
class _PendingPaymentInfo extends StatelessWidget {
  final Booking booking;

  const _PendingPaymentInfo({required this.booking});

  @override
  Widget build(BuildContext context) {
    final totalAmount = booking.coast.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.orange.shade200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.payment_rounded,
                color: Colors.orange.shade700,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المبلغ الإجمالي',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$totalAmount',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          TextSpan(
                            text: ' ريال',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // ✅ Arrow hint
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // ✅ Updated hint message
        Text(
          'اضغط لرؤية المبلغ المطلوب دفعه الآن',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

// ── PAID PAYMENT INFO ──
class _PaidPaymentInfo extends StatelessWidget {
  final Booking booking;

  const _PaidPaymentInfo({required this.booking});

  @override
  Widget build(BuildContext context) {
    final amountPaid = booking.coast.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.green.shade200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.green.shade700,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تم الدفع',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$amountPaid',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.green.shade700,
                            ),
                          ),
                          TextSpan(
                            text: ' ريال',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // How this was paid — 1 = normal online payment, 3 = QPay
        // installments. Renders nothing when paymentType isn't set.
        if (booking.paymentType != null) ...[
          const SizedBox(height: 8),
          PaymentMethodBadge(paymentType: booking.paymentType),
        ],
      ],
    );
  }
}

// ── STATUS CHIP ──
class _StatusChip extends StatelessWidget {
  final bool isPending;

  const _StatusChip({required this.isPending});

  @override
  Widget build(BuildContext context) {
    final statusColor = isPending ? Colors.orange.shade600 : Colors.green;
    final backgroundColor = isPending ? Colors.orange.shade50 : Colors.green.shade50;
    final statusIcon = isPending ? Icons.schedule_rounded : Icons.check_circle_rounded;
    final statusLabel = isPending ? 'إنتظار الدفع' : 'مدفوع';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 15, color: statusColor),
          const SizedBox(width: 6),
          Text(
            statusLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: statusColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── PAY BUTTON ──
class _PayButton extends StatefulWidget {
  final Booking booking;
  final bool isChalet;

  const _PayButton({required this.booking, required this.isChalet});

  @override
  State<_PayButton> createState() => _PayButtonState();
}

class _PayButtonState extends State<_PayButton> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.02).animate(
          CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
        ),
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.25),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                // ✅ Get payment amount from booking details
                // This will be shown in booking detail page
                BlocProvider.of<BookingsBloc>(context).add(
                  BookingPaymentChaletEvent(
                    paymentData: {
                      'bookingId': widget.booking.id,
                      'paymentType': 1,
                      // ✅ Amount details are in booking details page
                    },
                    isChalet: widget.isChalet,
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.payment_rounded, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'ادفع الآن',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── CONFIRMED ROW ──
class _ConfirmedRow extends StatelessWidget {
  const _ConfirmedRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.done_all_rounded,
              size: 16,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'تم الدفع بنجاح',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.green,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}