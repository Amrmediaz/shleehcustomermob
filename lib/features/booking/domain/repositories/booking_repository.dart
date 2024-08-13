import 'package:shleehcustomer/features/chalets/data/models/chalet_details.dart';

import '../entities/booking.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/booking_details_model.dart';

abstract class BookingRepository {
  Future<Either<Failure, List<Booking>>> getBooking(
      {required int pageNum,
      required int pageSize,
 });
  Future<Either<Failure, BookingDetails>> getBookingyID({required int id});
  Future<Either<Failure, double>> getBookingDatesCost({required dynamic dates} );
  Future<Either<Failure, int>> bookChalet({required dynamic bookingData});
  Future<Either<Failure, String>> bookPayment({required dynamic paymentData});


}
