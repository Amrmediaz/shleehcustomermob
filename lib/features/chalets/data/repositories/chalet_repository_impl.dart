

import 'package:dartz/dartz.dart';
import 'package:shleehcustomer/features/chalets/domain/entities/chalet_map.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/chalet.dart';
import '../../domain/entities/chalet_details_model.dart';
import '../../domain/repositories/chalets_repository.dart';
import '../datasources/chalet_local_data_source.dart';
import '../datasources/chalet_remote_data_source.dart';
import '../models/chalet_model.dart';


typedef Future<Unit> DeleteOrUpdateOrAddPost();

class ChaletsRepositoryImpl implements ChaletsRepository {
  final ChaletRemoteDataSource remoteDataSource;
  final ChaletLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ChaletsRepositoryImpl(
      {required this.remoteDataSource,
      required this.localDataSource,
      required this.networkInfo ,
     });




  @override
  Future<Either<Failure, List<Chalet>>> getChalets({dynamic body}) async{


    if (await networkInfo.isConnected) {
      try {
        final remoteChalets = await remoteDataSource.getChalets(body:body);
        localDataSource.cacheChalets(remoteChalets);

        return Right(remoteChalets);
      } on ServerException {

        return Left(ServerFailure());
      } catch (e) {
        print('❌ getChalets network error: $e');
        return Left(ServerFailure());
      }
    } else {
      try {
        final localPosts = await localDataSource.getCachedChalets();
        return Right(localPosts);
      } on EmptyCacheException {
        return Left(EmptyCacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, ChaletDetails>> getChaletByID({required int id}) async{

    if (await networkInfo.isConnected) {
      try {
        final remoteChalet = await remoteDataSource.getChaletById(id: id);
        return Right(remoteChalet);
      } on ServerException {

        return Left(ServerFailure());
      } catch (e) {
        print('❌ getChaletByID network error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());

    }
  }

  @override
  Future<Either<Failure, List<ChaletMap>>> getChaletsMap()async {
    if (await networkInfo.isConnected) {
      try {
        final remoteChalets = await remoteDataSource.getChaletsMap();

        return Right(remoteChalets);
      } on ServerException {

        return Left(ServerFailure());
      } catch (e) {
        print('❌ getChaletsMap network error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());

    }
  }

}
