import '../repositories/booking_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

// QPay confirm — the final charge step. confirmData: { paymentNumber,
// phoneNumber, otp, principalId, planId, account } — CONFIRMED shape
// (Ahmed Younes, 24 Aug 2026).
class ConfirmQpayUsecase {
  final BookingRepository repository;

  ConfirmQpayUsecase(this.repository);

  Future<Either<Failure, dynamic>> call({required dynamic confirmData, required bool isChalet}) async {
    return await repository.confirmQpay(confirmData: confirmData, isChalet: isChalet);
  }
}
