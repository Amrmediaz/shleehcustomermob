import 'package:dartz/dartz.dart';
import 'package:shleehcustomer/features/chalets/data/models/chalet_details.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
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
  Future<Either<Failure, List<Booking>>> getBooking(
      {required int pageNum, required int pageSize}) async {
    if (await networkInfo.isConnected) {
      try {
        final bookings = await remoteDataSource.getBookings(
            pageNum: pageNum, pageSize: pageSize);
        //localDataSource.cacheChalets(remoteChalets);

        return Right(bookings);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, BookingDetails>> getBookingyID(
      {required int id}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteChalet = await remoteDataSource.getBookingById(id: id);
        return Right(remoteChalet);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, double>> getBookingDatesCost({required dynamic dates})async  {
    if (await networkInfo.isConnected) {
      try {
        final totalPrice = await remoteDataSource.getBookingDates(dates: dates);
        return Right(totalPrice);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, int>> bookChalet({required bookingData}) async {

    if (await networkInfo.isConnected) {
      try {
       var bookingId =  await remoteDataSource.bookChalet(bookingData: bookingData);
        return  Right(bookingId);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, String>> bookPayment({required paymentData}) async {
    if (await networkInfo.isConnected) {
      try {
        var url = await remoteDataSource.bookPayment(paymentData: paymentData);
        return Right(url);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }
}
