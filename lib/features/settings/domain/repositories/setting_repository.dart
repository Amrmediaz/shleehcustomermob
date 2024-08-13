import 'package:shleehcustomer/features/chalets/data/models/chalet_details.dart';

import '../entities/user.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

abstract class SettingsRepository {
  Future<Either<Failure, User>> getUser(
   );
  Future<Either<Failure, Unit>> updateUser(dynamic body
      );
  Future<Either<Failure, Unit>> deleteAccountUser(dynamic userId
      );

}
