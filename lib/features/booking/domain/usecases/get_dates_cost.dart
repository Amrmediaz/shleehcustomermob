import '../repositories/booking_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/booking.dart';

class GetBookingDatesCostUsecase {
  final BookingRepository repository;

  GetBookingDatesCostUsecase(this.repository);

  Future<Either<Failure, double>> call( {required dynamic dates }) async {
    return await repository. getBookingDatesCost(dates: dates);
  }

}
