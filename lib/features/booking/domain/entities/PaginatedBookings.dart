import 'booking.dart';

class PaginatedBookings {
  final List<Booking> bookings;
  final int currentPage;
  final int pageCount;
  final bool hasMore;

  const PaginatedBookings({
    required this.bookings,
    required this.currentPage,
    required this.pageCount,
  }) : hasMore = currentPage < pageCount;
}