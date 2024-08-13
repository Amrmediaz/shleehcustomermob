
import 'package:shleehcustomer/features/authentication/login/domain/entities/user_login.dart';
import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';

abstract class LoginRepository {
  Future<Either<Failure,Unit>> login(dynamic body);
}
