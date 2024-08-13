import '../repositories/setting_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

class DeleteUserSettingsUsecase {
  final SettingsRepository repository;

  DeleteUserSettingsUsecase(this.repository);

  Future<Either<Failure, Unit>> call(dynamic userId) async {
    return await repository. deleteAccountUser(userId);
  }

}
