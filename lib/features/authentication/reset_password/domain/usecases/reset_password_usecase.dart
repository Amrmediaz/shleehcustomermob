import 'package:shleehcustomer/features/authentication/login/domain/repositories/login_repository.dart';

import '../../../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

import '../repositories/reset_password_repository.dart';


class ResetPasswordUsecase {
  final ResetPasswordRepositories repository;

  ResetPasswordUsecase(this.repository);

  Future<Either<Failure, Unit>> call(String phone) async {
    return await repository. resetPassword(phone);
  }

}
