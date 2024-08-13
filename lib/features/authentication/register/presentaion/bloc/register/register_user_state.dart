part of 'register_user_bloc.dart';

abstract class RegisterUserState extends Equatable {
  const RegisterUserState();

  @override
  List<Object> get props => [];
}

class RegisterUserInitial extends RegisterUserState {}
class VerifySucessUser extends RegisterUserState {}
class SentOtpSuccessUser extends RegisterUserState {}
class CheckUserSucessUser extends RegisterUserState {}

class LoadingRegisterUserState extends RegisterUserState {}
class CheckLoadingRegisterUserState extends RegisterUserState {}

class ErrorRegisterUserState extends RegisterUserState {
  final String message;

  ErrorRegisterUserState({required this.message});

  @override
  List<Object> get props => [message];
}

class ErrorSendOtpUserState extends RegisterUserState {
  final String message;

  ErrorSendOtpUserState({required this.message});

  @override
  List<Object> get props => [message];
}
class ErrorVerifyOtpUserState extends RegisterUserState {
  final String message;

  ErrorVerifyOtpUserState({required this.message});

  @override
  List<Object> get props => [message];
}
class ErrorCheckExistedUserState extends RegisterUserState {
  final String message;

  ErrorCheckExistedUserState({required this.message});

  @override
  List<Object> get props => [message];
}
class MessageRegisterUserState extends RegisterUserState {
  final String message;
  MessageRegisterUserState({required this.message});

  @override
  List<Object> get props => [message];
}
class MessageVerifyOtpState extends RegisterUserState {
  final String message;
  MessageVerifyOtpState({required this.message});

  @override
  List<Object> get props => [message];
}
class MessageSendOtpState extends RegisterUserState {
  final String message;
  MessageSendOtpState({required this.message});

  @override
  List<Object> get props => [message];
}
class MessageCheckUserExistState extends RegisterUserState {
  final String message;
  const MessageCheckUserExistState({required this.message});

  @override
  List<Object> get props => [message];
}