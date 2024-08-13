import 'package:dartz/dartz.dart';
import 'package:shleehcustomer/features/authentication/register/domain/entities/UserRegister.dart';
import 'package:shleehcustomer/features/authentication/register/domain/repositories/register_repositories.dart';

import '../../../../../core/error/failures.dart';

class SendOtpUserCase {
  final RegisterRepositories registerRepositories;
  SendOtpUserCase({required this.registerRepositories});
  Future<Either<Failure,Unit>> call(String phoneNumber){
    return registerRepositories.sendOtpCode(phoneNumber);
  }

}