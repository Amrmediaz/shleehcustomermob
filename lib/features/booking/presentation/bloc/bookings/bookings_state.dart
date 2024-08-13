part of 'bookings_bloc.dart';
abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object> get props => [];
}

class BookingInitial extends BookingState {}
class BookingStateInitial extends BookingState {}

class LoadingBookingsState extends BookingState {}
class LoadingBookingIdState extends BookingState {}
class LoadingBookingTotalPriceState extends BookingState {}
class LoadingBookingChaletState extends BookingState {

}
class LoadingBookingPaymentState extends BookingState {

}
class LoadedBookingPaymentState extends BookingState {
  final String url;
  const LoadedBookingPaymentState({required this.url});
  @override
  List<Object> get props => [url];
}
class LoadedBookChaletState extends BookingState {

}
class ChaletAlreadyBookedState extends BookingState {

}
class ChaletBookedSuccessState extends BookingState {
  final int bookingId;
  const ChaletBookedSuccessState({required this.bookingId});
  @override
  List<Object> get props => [bookingId];

}
class ErrorPaymentBookingState extends BookingState {
  final String message;
  const ErrorPaymentBookingState({required this.message});
  @override
  List<Object> get props => [message];
}


class LoadedBookingsState extends BookingState {
  final List<Booking> bookings;
  final int page;

  LoadedBookingsState({required this.bookings , required this.page });
  @override
  List<Object> get props => [bookings];
}
class LoadedBookingIdState extends BookingState {
  final BookingDetails bookingDetails;
  LoadedBookingIdState({required this.bookingDetails});
  @override
  List<Object> get props => [bookingDetails];
}


class ErrorBookingsState extends BookingState {
  final String message;
  ErrorBookingsState({required this.message});
  @override
  List<Object> get props => [message];
}
class ErrorBookingIdState extends BookingState {
  final String message;
  ErrorBookingIdState({required this.message});
  @override
  List<Object> get props => [message];
}

class LoadedBookingTotalPriceState extends BookingState {
  final double totalBookingPrice;
  LoadedBookingTotalPriceState({required this.totalBookingPrice});
  @override
  List<Object> get props => [totalBookingPrice];
}
class ErrorBookingTotalPriceState extends BookingState {
  final String message;
  ErrorBookingTotalPriceState({required this.message});
  @override
  List<Object> get props => [message];
}
