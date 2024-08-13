import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';

abstract class ResetPasswordRepositories {

  Future<Either<Failure,Unit>> resetPassword(String phone);

}
