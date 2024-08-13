part of 'register_user_bloc.dart';

abstract class RegisterUserEvent extends Equatable {
  const RegisterUserEvent();

  @override
  List<Object> get props => [];
}

class RegisterUseEvent extends RegisterUserEvent {
  final UserRegister userRegister;

  RegisterUseEvent({required this.userRegister});

  @override
  List<Object> get props => [userRegister];
}
class OtpSendEvent extends RegisterUserEvent {
  final String phoneNumber;

  OtpSendEvent({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}
class OtpVerifyEvent extends RegisterUserEvent {
  final String phoneNumber;
  final String otpCode;
  OtpVerifyEvent({required this.phoneNumber,required this.otpCode});

  @override
  List<Object> get props => [phoneNumber,otpCode];
}
class CheckUserExistEvent extends RegisterUserEvent {
  final String phoneNumber;

  CheckUserExistEvent({required this.phoneNumber});
  @override
  List<Object> get props => [phoneNumber];
}

