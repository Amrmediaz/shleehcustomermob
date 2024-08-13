



import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/repositories/reset_password_repository.dart';
import '../datasources/reset_password_data_source.dart';


class ResetPasswordRepositoryImpl implements ResetPasswordRepositories {
  final NetworkInfo networkInfo;
  final ResetPasswordDataSource resetPasswordDataSource;
  ResetPasswordRepositoryImpl(
      {
      required this.networkInfo ,
      required this.resetPasswordDataSource});
  @override
  Future<Either<Failure, Unit>> resetPassword(String phoneNumber) async {
    // TODO: implement login
    if (await networkInfo.isConnected) {
      try {
        await resetPasswordDataSource.resetPassword(phoneNumber);
        return Right(unit);
      } on ResetPasswordException {
        return Left(ResetPasswordFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

}
