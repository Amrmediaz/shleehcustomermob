import 'package:dartz/dartz.dart';
import 'package:shleehcustomer/features/home_page/data/model/onboard_model.dart';

import '../../../../core/error/failures.dart';
import '../../../home_page/domain/entities/onboard.dart';
import '../entities/onboard.dart';
import '../reposiitories/onboard_repositories.dart';


class GetOnBoardsUsecase {
  final  OnboardRepositories repository;

  GetOnBoardsUsecase(this.repository);

  Future<Either<Failure, List<Onboard>>> call() async {
    return await repository. getBoardItems();
  }

}
