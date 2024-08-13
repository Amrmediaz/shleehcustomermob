import 'package:dartz/dartz.dart';
import 'package:shleehcustomer/core/error/failures.dart';
import 'package:shleehcustomer/features/home_page/domain/entities/onboard.dart';
import '../../../landing/domain/reposiitories/onboard_repositories.dart';
import '../../domain/reposiitories/onboard_repositories.dart';
import '../datasource/local_data_source.dart';
import '../model/onboard_model.dart';

class OnBoardRepositoriesImplementation implements OnboardRepositories{
  final OnboardLocalDataSource onboardLocalDataSource;
  OnBoardRepositoriesImplementation({required this.onboardLocalDataSource});
  @override
  Future<Either<Failure, List<OnboardModel>>> getBoardItems()  {
    var onboardList =  onboardLocalDataSource.getOnBoardItems();
    return Future.value(Right(onboardList));
  }

}