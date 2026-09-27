import 'package:dartz/dartz.dart';
import 'package:shleehcustomer/features/booking/domain/entities/booking_details_model.dart';
import 'package:shleehcustomer/features/chalets/domain/entities/chalet_details_model.dart';

import '../../../../core/error/failures.dart';
import '../repositories/booking_repository.dart';

class GetBookingIdUsecase {
  final BookingRepository repository;

  GetBookingIdUsecase(this.repository);

  Future<Either<Failure, BookingDetails>> call( {required int id  , required bool isChalet}) async {
    return await repository.getBookingyID(id: id , isChalet: isChalet);
  }

}