import 'package:shleehcustomer/features/chalets/domain/entities/chalet_map.dart';

import '../repositories/chalets_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/chalet.dart';

class GetChaletsMapUsecase {
  final ChaletsRepository repository;

  GetChaletsMapUsecase(this.repository);

  Future<Either<Failure, List<ChaletMap>>> call() async {
    return await repository.getChaletsMap();
  }

}
