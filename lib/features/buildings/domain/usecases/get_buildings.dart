import 'package:dartz/dartz.dart';
import 'package:shleehcustomer/features/buildings/domain/entities/building.dart';
import '../../../../core/error/failures.dart';
import '../repositories/buildings_repository.dart';

class GetBuildingsUsecase {
  final BuildingsRepository repository;

  GetBuildingsUsecase(this.repository);

  Future<Either<Failure, List<Building>>> call({dynamic body}) async {
    return await repository.getBuildings(body: body);
  }
}