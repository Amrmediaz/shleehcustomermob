import 'package:dartz/dartz.dart';
import 'package:shleehcustomer/features/buildings/domain/entities/building.dart';
import 'package:shleehcustomer/features/buildings/domain/entities/flat.dart';
import '../../domain/repositories/buildings_repository.dart';
import '../../domain/entities/building_map.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../datasources/building_local_data_source.dart';
import '../datasources/building_remote_data_source.dart';
import '../models/building_details.dart';
import '../models/flat_Response.dart';

class BuildingsRepositoryImpl implements BuildingsRepository {
  final BuildingRemoteDataSource remoteDataSource;
  final BuildingLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  BuildingsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Building>>> getBuildings({dynamic body}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteBuildings = await remoteDataSource.getBuildings(body: body);
        return Right(remoteBuildings);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        print('❌ getBuildings network error: $e');
        return Left(ServerFailure());
      }
    } else {
      try {
        final localPosts = await localDataSource.getCachedBuildings();
        return Right(localPosts);
      } on EmptyCacheException {
        return Left(EmptyCacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, BuildingDetailsModel>> getBuildingByID({required int id}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteBuilding = await remoteDataSource.getBuildingById(id: id);
        return Right(remoteBuilding);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        print('❌ getBuildingByID network error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, List<BuildingMap>>> getBuildingsMap() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteBuildings = await remoteDataSource.getBuildingsMap();
        return Right(remoteBuildings);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        print('❌ getBuildingsMap network error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, FlatsResponse>> getFlats({required dynamic body}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteFlats = await remoteDataSource.getFlatsByBuildingId(body);
        return Right(remoteFlats);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        print('❌ getFlats network error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(EmptyCacheFailure());
    }
  }

}