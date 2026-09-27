import 'package:dartz/dartz.dart';
import 'package:shleehcustomer/features/buildings/domain/entities/flat.dart';

import '../../../../core/error/failures.dart';
// Changed "Building.dart" to "building.dart" 👇
import '../../data/models/flat_Response.dart';
import '../entities/building.dart';
import '../entities/building_map.dart';
import '../../data/models/building_details.dart';

abstract class BuildingsRepository {
  Future<Either<Failure, List<Building>>> getBuildings({dynamic body});
  Future<Either<Failure, List<BuildingMap>>> getBuildingsMap();
  Future<Either<Failure, BuildingDetailsModel>> getBuildingByID({required int id});
  Future<Either<Failure, FlatsResponse>> getFlats({required body});

}