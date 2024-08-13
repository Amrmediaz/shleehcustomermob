

import 'package:dartz/dartz.dart';
import 'package:shleehcustomer/features/authentication/register/domain/entities/UserRegister.dart';
import 'package:shleehcustomer/features/authentication/register/domain/repositories/register_repositories.dart';

import '../../../../../core/error/failures.dart';

class RegisterUserUserCase {
  final RegisterRepositories registerRepositories;
  RegisterUserUserCase({required this.registerRepositories});
  Future<Either<Failure,Unit>> call(UserRegister userRegister){
    return registerRepositories.register( userRegister);
  }

}