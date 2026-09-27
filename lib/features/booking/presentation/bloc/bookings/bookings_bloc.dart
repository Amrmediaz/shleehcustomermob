import 'package:bloc/bloc.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/features/booking/domain/entities/PaginatedBookings.dart';
import 'package:shleehcustomer/features/booking/domain/usecases/get_bookings.dart';
import '../../../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/strings/messages/failures.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/entities/booking_details_model.dart';
import '../../../domain/usecases/book_chalet.dart';
import '../../../domain/usecases/get_booking_by_id.dart';
import '../../../domain/usecases/get_dates_cost.dart';
import '../../../domain/usecases/payment_book.dart';
part 'bookings_event.dart';
part 'bookings_state.dart';

class BookingsBloc extends Bloc<BookingsEvent, BookingState> {
  final GetBookingsUsecase getBookingsUsecase;
  final GetBookingIdUsecase getBookingIdUsecase;
  final GetBookingDatesCostUsecase getBookingDatesCostUsecase;
  final BookChaletUsecase bookChaletUsecase;
  final BookingPaymentUsecase bookingPaymentUsecase;

  BookingsBloc({
    required this.getBookingsUsecase,
    required this.getBookingIdUsecase,
    required this.getBookingDatesCostUsecase,
    required this.bookingPaymentUsecase,
    required this.bookChaletUsecase,
  }) : super(BookingInitial()) {
    on<BookingsEvent>((event, emit) async {
      if (event is GetAllBookingsEvent) {
        emit(LoadingBookingsState());
        final failureOrPosts = await getBookingsUsecase(
            pageNum: event.pageNumber, pageSize: event.pageSize, isChalet: true);
        emit(_mapFailureOrPostsToState(failureOrPosts));
      }

      else if (event is GetAllBookingsEventFlat) {
        emit(LoadingBookingsStateFlat());
        final failureOrPosts = await getBookingsUsecase(
            pageNum: event.pageNumber, pageSize: event.pageSize, isChalet: false);
        emit(_mapFailureOrPostsToStateFlat(failureOrPosts));
      }

      else if (event is BookingsEventIni) {
        emit(BookingStateInitial());
      }

      else if (event is CalculateBookingTotalPriceEvent) {
        emit(LoadingBookingTotalPriceState());
        final failureOrPosts =
        await getBookingDatesCostUsecase(dates: event.dates, isChalet: event.isChalet);
        emit(_mapFailureOrBookingTotalPriceToState(failureOrPosts));
      }

      else if (event is LoadMoreBookingsEvent) {
        final failureOrPosts = await getBookingsUsecase(
            pageNum: event.pageNumber, pageSize: event.pageSize, isChalet: event.isChalet);

        if (event.isChalet) {
          final previous =
          state is LoadedBookingsState ? (state as LoadedBookingsState).bookings : <Booking>[];
          emit(_mapFailureOrPostsToState(failureOrPosts, previousBookings: previous));
        } else {
          final previous = state is LoadedBookingsStateFlat
              ? (state as LoadedBookingsStateFlat).bookings
              : <Booking>[];
          emit(_mapFailureOrPostsToStateFlat(failureOrPosts, previousBookings: previous));
        }
      }

      else if (event is RefreshBookingsEvent) {
        final failureOrPosts = await getBookingsUsecase(
            pageNum: event.pageNumber, pageSize: event.pageSize, isChalet: true);
        emit(_mapFailureOrPostsToState(failureOrPosts)); // no previousBookings -> fresh list
      }

      else if (event is RefreshBookingsEventFlat) {
        final failureOrPosts = await getBookingsUsecase(
            pageNum: event.pageNumber, pageSize: event.pageSize, isChalet: false);
        emit(_mapFailureOrPostsToStateFlat(failureOrPosts));
      }

      else if (event is LoadBookingsById) {
        emit(LoadingBookingIdState());
        final failureOrBookingSingle =
        await getBookingIdUsecase(id: int.parse(event.id), isChalet: true);
        emit(_mapFailureOrBookingIdToState(failureOrBookingSingle));
      }

      else if (event is LoadBookingsByIdFlat) {
        emit(LoadingBookingIdStateFlat());
        final failureOrBookingSingle =
        await getBookingIdUsecase(id: int.parse(event.id), isChalet: false);
        emit(_mapFailureOrBookingIdToStateFlat(failureOrBookingSingle));
      }

      else if (event is BookingChaletEvent) {
        emit(LoadingBookingPaymentState());
        final failureOrBookingSingle =
        await bookChaletUsecase(bookingData: event.bookingData, isChalet: event.isChalet);
        emit(_mapFailureOrBookChaletToState(failureOrBookingSingle));
      }

      else if (event is BookingPaymentChaletEvent) {
        emit(LoadingBookingPaymentState());
        final failureOrBookingSingle =
        await bookingPaymentUsecase(paymentData: event.paymentData , isChalet: event.isChalet);
        emit(_mapFailureOrPayBookingToState(failureOrBookingSingle));
      }
    });
  }

  BookingState _mapFailureOrPostsToState(
      Either<Failure, PaginatedBookings> either, {
        List<Booking> previousBookings = const [],
      }) {
    return either.fold(
          (failure) => ErrorBookingsState(message: _mapFailureToMessage(failure)),
          (result) => LoadedBookingsState(
        bookings: [...previousBookings, ...result.bookings],
        page: result.currentPage,
        hasMore: result.hasMore,
      ),
    );
  }

  BookingState _mapFailureOrPostsToStateFlat(
      Either<Failure, PaginatedBookings> either, {
        List<Booking> previousBookings = const [],
      }) {
    return either.fold(
          (failure) => ErrorBookingsStateFlat(message: _mapFailureToMessage(failure)),
          (result) => LoadedBookingsStateFlat(
        bookings: [...previousBookings, ...result.bookings],
        page: result.currentPage,
        hasMore: result.hasMore,
      ),
    );
  }

  BookingState _mapFailureOrBookingTotalPriceToState(Either<Failure, dynamic> either) {
    return either.fold(
          (failure) => ErrorBookingTotalPriceState(message: _mapFailureToMessage(failure)),
          (totalPrice) => LoadedBookingTotalPriceState(totalBookingPrice
          : totalPrice,
      ),
    );
  }
  BookingState _mapFailureOrBookingIdToState(Either<Failure, BookingDetails> either) {
    return either.fold(

          (failure) => ErrorBookingIdState(message: _mapFailureToMessage(failure)),
          (bookingDetails) => LoadedBookingIdState(
        bookingDetails: bookingDetails,
      ),
    );
  }
  BookingState _mapFailureOrBookingIdToStateFlat(Either<Failure, BookingDetails> either) {
    return either.fold(

          (failure) => ErrorBookingIdStateFlat(message: _mapFailureToMessage(failure)),
          (bookingDetails) => LoadedBookingIdStateFlat(
        bookingDetails: bookingDetails,
      ),
    );
  }
  BookingState _mapFailureOrBookChaletToState(Either<Failure, int> either) {
    return either.fold(
          (failure) => ChaletAlreadyBookedState(),
          (bookingId) => ChaletBookedSuccessState(bookingId:bookingId), // Assuming this represents a successful booking state
    );
  }
  BookingState _mapFailureOrPayBookingToState(Either<Failure, String> either) {
    return either.fold(
          (failure) => ErrorPaymentBookingState(message :_mapFailureToMessage(failure)),
          (url) => LoadedBookingPaymentState(url: url), // Assuming this represents a successful booking state
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return getTextByKey(key: TranslationKey.keyServerError);
      case EmptyCacheFailure:
        return getTextByKey(key: TranslationKey.keyNoData);
      case OfflineFailure:
        return getTextByKey(key: TranslationKey.keyNoInternet);
      default:
        return getTextByKey(key: TranslationKey.keyError);
    }
  }
}
