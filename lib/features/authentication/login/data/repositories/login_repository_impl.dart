



import 'package:shleehcustomer/features/authentication/login/domain/entities/user_login.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/repositories/login_repository.dart';
import '../datasources/login_data_source.dart';
import '../models/user_logon_model.dart';



typedef Future<Unit> DeleteOrUpdateOrAddPost();

class LoginRepositoryImpl implements LoginRepository {
  final NetworkInfo networkInfo;
  final LoginDataSource loginDataSource;
  LoginRepositoryImpl(
      {
      required this.networkInfo ,
      required this.loginDataSource});
  @override
  Future<Either<Failure, Unit>> login(dynamic body) async {
    // TODO: implement login
    if (await networkInfo.isConnected) {
      try {
        await loginDataSource.login(body);
        return const Right(unit);
      } on AuthenticationException {
        return Left(AuthenticationFailure());
      } catch (e) {
        print('❌ login network error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

}
