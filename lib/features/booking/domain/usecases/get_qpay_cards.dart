import '../repositories/booking_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

// QPay cards. cardsData: { paymentNumber, phoneNumber, otp } — CONFIRMED
// shape (Ahmed Younes, 24 Aug 2026). Resolves to the card list to charge.
class GetQpayCardsUsecase {
  final BookingRepository repository;

  GetQpayCardsUsecase(this.repository);

  Future<Either<Failure, dynamic>> call({required dynamic cardsData, required bool isChalet}) async {
    return await repository.getQpayCards(cardsData: cardsData, isChalet: isChalet);
  }
}
