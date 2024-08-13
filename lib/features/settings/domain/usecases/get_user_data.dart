import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/setting_repository.dart';

class GetUserSettingsUsecase {
  final SettingsRepository repository;

  GetUserSettingsUsecase(this.repository);

  Future<Either<Failure, User>> call() async {
    return await repository. getUser();
  }

}
