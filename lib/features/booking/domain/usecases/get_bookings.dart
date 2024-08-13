

import '../repositories/booking_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/booking.dart';

class GetBookingsUsecase {
  final BookingRepository repository;

  GetBookingsUsecase(this.repository);

  Future<Either<Failure, List<Booking>>> call( {required int pageSize ,required int pageNum }) async {
    return await repository. getBooking(pageSize:pageSize ,pageNum:pageNum );
  }

}
