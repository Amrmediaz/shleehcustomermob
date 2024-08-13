part of 'bookings_bloc.dart';

abstract class BookingsEvent extends Equatable {
  const BookingsEvent();

  @override
  List<Object> get props => [];
}

class BookingsEventIni extends BookingsEvent {
  BookingsEventIni();

  @override
  List<Object> get props => [];
}
class GetAllBookingsEvent extends BookingsEvent {
  final int pageNumber;
  final int pageSize;

  GetAllBookingsEvent({required this.pageNumber,required this.pageSize });

  @override
  List<Object> get props => [pageNumber,pageSize];
}
class RefreshBookingsEvent extends BookingsEvent {
  final int pageNumber;
  final int pageSize;

  RefreshBookingsEvent({required this.pageNumber,required this.pageSize });

  @override
  List<Object> get props => [pageNumber,pageSize];
}
class LoadMoreBookingsEvent extends BookingsEvent {
  final int pageNumber;
  final int pageSize;
  LoadMoreBookingsEvent({required this.pageNumber,required this.pageSize });

  @override
  List<Object> get props => [pageNumber,pageSize];
}
class LoadBookingsById extends BookingsEvent {
  final String id;
  LoadBookingsById({required this.id});

  @override
  List<Object> get props => [id];
}
class BookingChaletEvent extends BookingsEvent {
  final dynamic bookingData;
  BookingChaletEvent({required this.bookingData });
  @override
  List<Object> get props => [bookingData];
}
class BookingPaymentChaletEvent extends BookingsEvent {
  final dynamic paymentData;
  const BookingPaymentChaletEvent({required this.paymentData });
  @override
  List<Object> get props => [paymentData];
}
class CalculateBookingTotalPriceEvent extends BookingsEvent {
  final dynamic dates;
  CalculateBookingTotalPriceEvent({required this.dates });
  @override
  List<Object> get props => [dates];
}
