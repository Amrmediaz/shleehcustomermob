part of 'bookings_bloc.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object> get props => [];
}

class BookingInitial extends BookingState {}
class BookingStateInitial extends BookingState {}

// ── Chalets list (unchanged) ────────────────────────────────────────────
class LoadingBookingsState extends BookingState {}

class LoadedBookingsState extends BookingState {
  final List<Booking> bookings;
  final int page;
  final bool hasMore;

  LoadedBookingsState({required this.bookings, required this.page, required this.hasMore});
  @override
  List<Object> get props => [bookings, page, hasMore];
}
class ErrorBookingsState extends BookingState {
  final String message;
  ErrorBookingsState({required this.message});
  @override
  List<Object> get props => [message];
}

// ── Flats list — NEW, mirrors the chalets list states above so each tab's
//    BlocBuilder can filter with `buildWhen: current is <ItsOwnStateTypes>`
//    and completely ignore the other tab's emissions, even though both
//    share the same global BookingsBloc. ─────────────────────────────────
class LoadingBookingsStateFlat extends BookingState {}

class LoadedBookingsStateFlat extends BookingState {
  final List<Booking> bookings;
  final int page;
  final bool hasMore;

  LoadedBookingsStateFlat({required this.bookings, required this.page, required this.hasMore});
  @override
  List<Object> get props => [bookings, page, hasMore];
}

class ErrorBookingsStateFlat extends BookingState {
  final String message;
  ErrorBookingsStateFlat({required this.message});
  @override
  List<Object> get props => [message];
}

// ── Booking details — chalet (unchanged) ────────────────────────────────
class LoadingBookingIdState extends BookingState {}

class LoadedBookingIdState extends BookingState {
  final BookingDetails bookingDetails;
  LoadedBookingIdState({required this.bookingDetails});
  @override
  List<Object> get props => [bookingDetails];
}

class ErrorBookingIdState extends BookingState {
  final String message;
  ErrorBookingIdState({required this.message});
  @override
  List<Object> get props => [message];
}

// ── Booking details — flat — NEW, mirrors the chalet detail states so
//    LoadBookingsByIdFlat has its own state trio, matching the event file.
class LoadingBookingIdStateFlat extends BookingState {}

class LoadedBookingIdStateFlat extends BookingState {
  final BookingDetails bookingDetails;
  LoadedBookingIdStateFlat({required this.bookingDetails});
  @override
  List<Object> get props => [bookingDetails];
}

class ErrorBookingIdStateFlat extends BookingState {
  final String message;
  ErrorBookingIdStateFlat({required this.message});
  @override
  List<Object> get props => [message];
}

// ── Everything below is unchanged — no Flat variant exists for these
//    events, so no new states needed. ───────────────────────────────────
class LoadingBookingTotalPriceState extends BookingState {}
class LoadingBookingChaletState extends BookingState {}
class LoadingBookingPaymentState extends BookingState {}

class LoadedBookingPaymentState extends BookingState {
  final String url;
  const LoadedBookingPaymentState({required this.url});
  @override
  List<Object> get props => [url];
}

class LoadedBookChaletState extends BookingState {}
class ChaletAlreadyBookedState extends BookingState {}

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