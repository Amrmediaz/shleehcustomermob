import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {}

class OfflineFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class ServerFailure extends Failure {
  @override
  List<Object?> get props => [];
}
class AuthenticationFailure extends Failure {
  @override
  List<Object?> get props => [];
}
class ResetPasswordFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class EmptyCacheFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class UserExsitedFailure extends Failure {
  @override
  List<Object?> get props => [];
}
class OtpFailure extends Failure {
  @override
  List<Object?> get props => [];
}
