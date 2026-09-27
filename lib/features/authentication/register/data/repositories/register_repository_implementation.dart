
import 'package:shleehcustomer/features/authentication/login/domain/entities/user_login.dart';
import 'package:dartz/dartz.dart';
import 'package:shleehcustomer/features/authentication/register/data/datasources/register_data_source.dart';
import 'package:shleehcustomer/features/authentication/register/data/models/UserRegisterModel.dart';
import 'package:shleehcustomer/features/authentication/register/domain/entities/UserRegister.dart';
import 'package:shleehcustomer/features/authentication/register/domain/repositories/register_repositories.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/network/network_info.dart';



typedef Future<Unit> DeleteOrUpdateOrAddPost();

class RegisterRepositoryImplementation implements RegisterRepositories {
  final NetworkInfo networkInfo;
  final RegisterDataSource registerDataSource;
  RegisterRepositoryImplementation(
      {
        required this.networkInfo ,
        required this.registerDataSource});
 

  @override
  Future<Either<Failure, Unit>> checkUserExist(String phone)async {
    if (await networkInfo.isConnected) {
      try {
        await registerDataSource.checkUser(phone);
        return const Right(unit);
      } on AuthenticationException {
        return Left(AuthenticationFailure());
      } catch (e) {
        print('❌ checkUserExist network error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> register(UserRegister userRegister) async{
    if (await networkInfo.isConnected) {
      try {
        await registerDataSource.register(UserRegisterModel(email: userRegister.email, phone: userRegister.phone, password: userRegister.password, firstName: userRegister.firstName, lastName: userRegister.lastName));
        return const Right(unit);
      } on AuthenticationException {
        return Left(AuthenticationFailure());
      } catch (e) {
        print('❌ register network error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> sendOtpCode(phone)async {
    if (await networkInfo.isConnected) {
      try {
        await registerDataSource.sendOtp(phone);
        return const Right(unit);
      } on AuthenticationException {
        return Left(AuthenticationFailure());
      } catch (e) {
        print('❌ sendOtpCode network error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> verifyOtpCode(String otpCode, String phoneNumber)async {
    if (await networkInfo.isConnected) {
      try {
        await registerDataSource.verifyOtp(phoneNumber,otpCode);
        return const Right(unit);
      } on OtpException {
        return Left(OtpFailure());
      } catch (e) {
        print('❌ verifyOtpCode network error: $e');
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

}
