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

  GetAllBookingsEvent({required this.pageNumber,required this.pageSize  });

  @override
  List<Object> get props => [pageNumber,pageSize];
}
class GetAllBookingsEventFlat extends BookingsEvent {
  final int pageNumber;
  final int pageSize;

  GetAllBookingsEventFlat({required this.pageNumber,required this.pageSize  });

  @override
  List<Object> get props => [pageNumber,pageSize];
}

class RefreshBookingsEvent extends BookingsEvent {
  final int pageNumber;
  final int pageSize;

  RefreshBookingsEvent({required this.pageNumber,required this.pageSize  });

  @override
  List<Object> get props => [pageNumber,pageSize];
}
class RefreshBookingsEventFlat extends BookingsEvent {
  final int pageNumber;
  final int pageSize;

  RefreshBookingsEventFlat({required this.pageNumber,required this.pageSize  });

  @override
  List<Object> get props => [pageNumber,pageSize];
}

class LoadMoreBookingsEvent extends BookingsEvent {
  final int pageNumber;
  final int pageSize;
  final bool isChalet;

  LoadMoreBookingsEvent({required this.pageNumber,required this.pageSize , required this.isChalet });

  @override
  List<Object> get props => [pageNumber,pageSize];
}
class LoadMoreBookingsEventFlat extends BookingsEvent {
  final int pageNumber;
  final int pageSize;

  LoadMoreBookingsEventFlat({required this.pageNumber,required this.pageSize  });

  @override
  List<Object> get props => [pageNumber,pageSize];
}

class LoadBookingsById extends BookingsEvent {
  final String id;
  LoadBookingsById({required this.id});

  @override
  List<Object> get props => [id];
}
class LoadBookingsByIdFlat extends BookingsEvent {
  final String id;
  LoadBookingsByIdFlat({required this.id});

  @override
  List<Object> get props => [id];
}

class BookingChaletEvent extends BookingsEvent {
  final dynamic bookingData;
  final bool isChalet;
  BookingChaletEvent({required this.bookingData  , required this.isChalet});
  @override
  List<Object> get props => [bookingData];
}
class BookingPaymentChaletEvent extends BookingsEvent {
  final dynamic paymentData;
  final bool isChalet;
  const BookingPaymentChaletEvent({required this.paymentData  , required this.isChalet});
  @override
  List<Object> get props => [paymentData];
}
class CalculateBookingTotalPriceEvent extends BookingsEvent {
  final dynamic dates;
  final bool isChalet;
  CalculateBookingTotalPriceEvent({required this.dates , required this.isChalet });
  @override
  List<Object> get props => [dates];
}
