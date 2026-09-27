import 'package:shleehcustomer/features/chalets/data/models/chalet_details.dart';

import '../entities/PaginatedBookings.dart';
import '../entities/booking.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/booking_details_model.dart';

abstract class BookingRepository {
  Future<Either<Failure, PaginatedBookings>>  getBooking(
      {required int pageNum,
      required int pageSize,
        required bool isChalet
      });
  Future<Either<Failure, BookingDetails>> getBookingyID({required int id , required bool isChalet});
  Future<Either<Failure, double>> getBookingDatesCost({required dynamic dates , required bool isChalet} );
  Future<Either<Failure, int>> bookChalet({required dynamic bookingData , required bool isChalet});
  Future<Either<Failure, String>> bookPayment({required dynamic paymentData , required bool isChalet});
  Future<Either<Failure, Map<String, dynamic>>> bookPaymentQpay({required dynamic paymentData , required bool isChalet});
  Future<Either<Failure, String>> sendQpayOtp({required dynamic otpData, required bool isChalet});
  Future<Either<Failure, dynamic>> getQpayCards({required dynamic cardsData, required bool isChalet});
  Future<Either<Failure, dynamic>> confirmQpay({required dynamic confirmData, required bool isChalet});


}
