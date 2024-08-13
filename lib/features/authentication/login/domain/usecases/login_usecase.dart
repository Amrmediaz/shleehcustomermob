import 'package:shleehcustomer/features/authentication/login/domain/repositories/login_repository.dart';

import '../../../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';


class LoginUsecase {
  final LoginRepository repository;

  LoginUsecase(this.repository);

  Future<Either<Failure, Unit>> call(dynamic body) async {
    return await repository. login(body);
  }

}
