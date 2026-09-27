import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/booking_repository.dart';

class GetBookingDatesCostUsecase {
  final BookingRepository repository;
  GetBookingDatesCostUsecase(this.repository);

  Future<Either<Failure, double>> call({required dynamic dates, required bool isChalet}) async {
    return await repository.getBookingDatesCost(dates: dates, isChalet: isChalet);
  }
}