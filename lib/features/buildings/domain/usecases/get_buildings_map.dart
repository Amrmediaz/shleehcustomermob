import 'package:shleehcustomer/features/buildings/domain/entities/building_map.dart';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/Building.dart';
import '../repositories/buildings_repository.dart';

class GetBuildingsMapUsecase {
  final BuildingsRepository repository;

  GetBuildingsMapUsecase(this.repository);

  Future<Either<Failure, List<BuildingMap>>> call() async {
    return await repository.getBuildingsMap();
  }

}
