

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

import '../../../../core/error/failures.dart';
import '../../../landing/data/datasource/local_data_source.dart';
import '../../domain/entities/onboard.dart';
import '../../domain/reposiitories/onboard_repositories.dart';

class OnBoardRepositoriesImplementation implements OnboardRepositories{
  final OnboardLocalDataSource onboardLocalDataSource;
  OnBoardRepositoriesImplementation({required this.onboardLocalDataSource});
  @override
  Future<Either<Failure, List<Onboard>>> getBoardItems()  {
    var onboardList =  onboardLocalDataSource.getOnBoardItems();
    return Future.value(Right(onboardList));
  }

}

