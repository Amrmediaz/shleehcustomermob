import 'package:dartz/dartz.dart';
import 'package:shleehcustomer/features/authentication/register/domain/entities/UserRegister.dart';
import 'package:shleehcustomer/features/authentication/register/domain/repositories/register_repositories.dart';

import '../../../../../core/error/failures.dart';

class VerifyOtpUserCase {
  final RegisterRepositories registerRepositories;
  VerifyOtpUserCase({required this.registerRepositories});
  Future<Either<Failure,Unit>> call(String otpCode,String phoneNumber){
    return registerRepositories.verifyOtpCode( otpCode,phoneNumber);
  }

}