import 'package:shleehcustomer/features/chalets/domain/entities/chalet_details_model.dart';
import 'package:shleehcustomer/features/chalets/domain/entities/chalet_map.dart';

import '../repositories/chalets_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/chalet.dart';

class GetChaletIdUsecase {
  final ChaletsRepository repository;

  GetChaletIdUsecase(this.repository);

  Future<Either<Failure, ChaletDetails>> call(dynamic id) async {
    return await repository.getChaletByID(id:id);
  }

}