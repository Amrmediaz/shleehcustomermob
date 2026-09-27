import 'package:dartz/dartz.dart';
import 'package:shleehcustomer/features/buildings/domain/entities/building.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/flat_Response.dart';
import '../entities/flat.dart';
import '../repositories/buildings_repository.dart';

class GetFlatByBuildingIdUsecase {
  final BuildingsRepository repository;

  GetFlatByBuildingIdUsecase(this.repository);

  Future<Either<Failure, FlatsResponse>> call(dynamic body) async {
    return await repository.getFlats(body: body);
  }
}

