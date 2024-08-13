import '../repositories/setting_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

class UpdateUserSettingsUsecase {
  final SettingsRepository repository;

  UpdateUserSettingsUsecase(this.repository);

  Future<Either<Failure, Unit>> call(dynamic body) async {
    return await repository. updateUser(body);
  }

}
