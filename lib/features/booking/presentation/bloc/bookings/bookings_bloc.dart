import 'package:bloc/bloc.dart';
import 'package:shleehcustomer/core/strings/language.dart';
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

  BookingsBloc({required this.getBookingsUsecase,required this.getBookingIdUsecase , required this.getBookingDatesCostUsecase , required this.bookingPaymentUsecase,required this.bookChaletUsecase
  } ) : super(BookingInitial()) {
    on<BookingsEvent>((event, emit) async {
      if (event is GetAllBookingsEvent) {
        emit(LoadingBookingsState());
        final failureOrPosts = await getBookingsUsecase(pageNum: event.pageNumber , pageSize: event.pageSize);
        emit(_mapFailureOrPostsToState(failureOrPosts,event.pageNumber));
      }
     else if (event is BookingsEventIni) {
        emit(BookingStateInitial());

      }
      else if (event is CalculateBookingTotalPriceEvent) {
        emit(LoadingBookingTotalPriceState());
        final failureOrPosts = await getBookingDatesCostUsecase(dates:event.dates);
        emit(_mapFailureOrBookingTotalPriceToState(failureOrPosts));
      }
      else if  (event is LoadMoreBookingsEvent) {
       // emit(LoadingChaletsState());
        final failureOrPosts = await getBookingsUsecase(pageNum: event.pageNumber , pageSize: event.pageSize);
        emit(_mapFailureOrPostsToState(failureOrPosts,event.pageNumber));
      } else if (event is RefreshBookingsEvent) {
      //  emit(LoadingChaletsState());
        final failureOrPosts = await getBookingsUsecase(pageNum: event.pageNumber , pageSize: event.pageSize);
        emit(_mapFailureOrPostsToState(failureOrPosts,event.pageNumber));
      } else if (event is LoadBookingsById) {
        emit(LoadingBookingIdState());
        final failureOrBookingSingle = await getBookingIdUsecase(id:int.parse(event.id));
        emit(_mapFailureOrBookingIdToState(failureOrBookingSingle));
      }
      else if (event is BookingChaletEvent) {
        emit(LoadingBookingPaymentState());
        final failureOrBookingSingle = await bookChaletUsecase(bookingData: event.bookingData);
        emit(_mapFailureOrBookChaletToState(failureOrBookingSingle));
      }
      else if (event is BookingPaymentChaletEvent) {
        emit(LoadingBookingPaymentState());
        final failureOrBookingSingle = await bookingPaymentUsecase(paymentData: event.paymentData);
        emit(_mapFailureOrPayBookingToState(failureOrBookingSingle));
      }
    });
  }

  BookingState _mapFailureOrPostsToState(Either<Failure, List<Booking>> either , int page) {
    return either.fold(
      (failure) => ErrorBookingsState(message: _mapFailureToMessage(failure)),
      (bookings) => LoadedBookingsState(
        bookings: bookings,
        page: page
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
        return SERVER_FAILURE_MESSAGE;
      case EmptyCacheFailure:
        return EMPTY_CACHE_FAILURE_MESSAGE;
      case OfflineFailure:
        return getTextByKey(key: TranslationKey.keyNoInternet);
      default:
        return getTextByKey(key: TranslationKey.keyError);
    }
  }
}
