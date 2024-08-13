import 'package:shleehcustomer/features/chalets/domain/entities/chalet_map.dart';

import '../repositories/chalets_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/chalet.dart';

class GetChaletsUsecase {
  final ChaletsRepository repository;

  GetChaletsUsecase(this.repository);

  Future<Either<Failure, List<Chalet>>> call(dynamic body) async {
    return await repository.getChalets(body:body);
  }

}