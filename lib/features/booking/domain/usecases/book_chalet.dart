import '../repositories/booking_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/booking.dart';

class BookChaletUsecase {
  final BookingRepository repository;

  BookChaletUsecase(this.repository);

  Future<Either<Failure, int>> call( {required dynamic bookingData }) async {
    return await repository. bookChalet(bookingData: bookingData);
  }

}
