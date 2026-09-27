import '../repositories/booking_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

// QPay OTP send/resend. otpData: { PaymentNumber, phoneNumber } —
// CONFIRMED shape (23 Aug 2026, exact casing). Resolves to a plain string
// message ("Otp Sended") on success.
class SendQpayOtpUsecase {
  final BookingRepository repository;

  SendQpayOtpUsecase(this.repository);

  Future<Either<Failure, String>> call({required dynamic otpData, required bool isChalet}) async {
    return await repository.sendQpayOtp(otpData: otpData, isChalet: isChalet);
  }
}
