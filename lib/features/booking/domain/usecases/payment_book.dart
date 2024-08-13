import '../repositories/booking_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/booking.dart';

class BookingPaymentUsecase {
  final BookingRepository repository;

  BookingPaymentUsecase(this.repository);

  Future<Either<Failure, String>> call( {required dynamic paymentData }) async {
    return await repository. bookPayment(paymentData: paymentData);
  }

}
