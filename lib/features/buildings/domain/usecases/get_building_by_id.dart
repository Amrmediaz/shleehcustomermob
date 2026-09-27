
import 'package:dartz/dartz.dart';
import 'package:shleehcustomer/features/buildings/data/models/building_details.dart';

import '../../../../core/error/failures.dart';
import '../repositories/buildings_repository.dart';

import 'package:shleehcustomer/features/buildings/domain/entities/building_details_model.dart';


class GetBuildingIdUsecase {
  final BuildingsRepository repository;

  GetBuildingIdUsecase(this.repository);

  Future<Either<Failure, BuildingDetailsModel>> call(dynamic id) async {
    return await repository.getBuildingByID(id:id);
  }

}