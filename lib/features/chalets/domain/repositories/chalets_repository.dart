import 'package:shleehcustomer/features/chalets/data/models/chalet_details.dart';
import 'package:shleehcustomer/features/chalets/domain/entities/chalet_map.dart';

import '../entities/chalet.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/chalet_details_model.dart';

abstract class ChaletsRepository {
  Future<Either<Failure, List<Chalet>>> getChalets(
      {dynamic body});
  Future<Either<Failure, List<ChaletMap>>> getChaletsMap(
      );
  Future<Either<Failure, ChaletDetails>> getChaletByID({required int id});
}
