import '../repositories/booking_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

// QPay (installments) phone step. paymentData: { bookingId, paymentType: 3,
// phoneNumber } — CONFIRMED shape (23 Aug 2026). Resolves to
// { plansList, principalId, paymentNumber } on success.
class BookingPaymentQpayUsecase {
  final BookingRepository repository;

  BookingPaymentQpayUsecase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({required dynamic paymentData, required bool isChalet}) async {
    return await repository.bookPaymentQpay(paymentData: paymentData, isChalet: isChalet);
  }
}
