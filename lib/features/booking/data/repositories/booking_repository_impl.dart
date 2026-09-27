import 'package:dartz/dartz.dart';
import 'package:shleehcustomer/features/chalets/data/models/chalet_details.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/PaginatedBookings.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_details_model.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/chalet_local_data_source.dart';
import '../datasources/chalet_remote_data_source.dart';
import '../models/booking_model.dart';

typedef Future<Unit> DeleteOrUpdateOrAddPost();

class BookingssRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;
  // final Booking localDataSource;
  final NetworkInfo networkInfo;

  BookingssRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PaginatedBookings>> getBooking(
      {required int pageNum, required int pageSize, required bool isChalet}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getBookings(
            pageNum: pageNum, pageSize: pageSize, isChalet: isChalet);
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        print('❌ getBooking network error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }
  @override
  Future<Either<Failure, BookingDetails>> getBookingyID(
      {required int id , required bool isChalet}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteChalet = await remoteDataSource.getBookingById(id: id,isChalet: isChalet);
        return Right(remoteChalet);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        print('❌ getBookingyID network error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, double>> getBookingDatesCost({required dynamic dates , required bool isChalet})async  {
    if (await networkInfo.isConnected) {
      try {
        final totalPrice = await remoteDataSource.getBookingDates(dates: dates,isChalet:isChalet);
        return Right(totalPrice);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        print('❌ getBookingDatesCost network error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, int>> bookChalet({required bookingData , required bool isChalet}) async {

    if (await networkInfo.isConnected) {
      try {
       var bookingId =  await remoteDataSource.bookChalet(bookingData: bookingData,isChalet:isChalet);
        return  Right(bookingId);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        print('❌ bookChalet network error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, String>> bookPayment({required paymentData , required bool isChalet}) async {
    if (await networkInfo.isConnected) {
      try {
        var url = await remoteDataSource.bookPayment(paymentData: paymentData , isChalet:isChalet);
        return Right(url);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        print('❌ bookPayment network error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> bookPaymentQpay({required paymentData , required bool isChalet}) async {
    if (await networkInfo.isConnected) {
      try {
        var result = await remoteDataSource.bookPaymentQpay(paymentData: paymentData , isChalet:isChalet);
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        print('❌ bookPaymentQpay network error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, String>> sendQpayOtp({required otpData, required bool isChalet}) async {
    if (await networkInfo.isConnected) {
      try {
        var message = await remoteDataSource.sendQpayOtp(otpData: otpData, isChalet: isChalet);
        return Right(message);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        print('❌ sendQpayOtp network error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, dynamic>> getQpayCards({required cardsData, required bool isChalet}) async {
    if (await networkInfo.isConnected) {
      try {
        var cards = await remoteDataSource.getQpayCards(cardsData: cardsData, isChalet: isChalet);
        return Right(cards);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        print('❌ getQpayCards network error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, dynamic>> confirmQpay({required confirmData, required bool isChalet}) async {
    if (await networkInfo.isConnected) {
      try {
        var result = await remoteDataSource.confirmQpay(confirmData: confirmData, isChalet: isChalet);
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        print('❌ confirmQpay network error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }
}
