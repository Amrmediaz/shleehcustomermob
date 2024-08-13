import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../entities/UserRegister.dart';

abstract class RegisterRepositories {
  Future<Either<Failure,Unit>> register(UserRegister userRegister);
  Future<Either<Failure,Unit>> verifyOtpCode(String otpCode,String phoneNumber);
  Future<Either<Failure,Unit>> sendOtpCode(dynamic body);
  Future<Either<Failure,Unit>> checkUserExist(String phone);

}
