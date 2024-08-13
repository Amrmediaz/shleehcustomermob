part of 'reset_password_bloc.dart';

abstract class ResetPasswordState extends Equatable {
  const ResetPasswordState();

  @override
  List<Object> get props => [];
}

class ResetPasswordInitial extends ResetPasswordState {}

class LoadingResetPasswordState extends ResetPasswordState {}

class ErrorResetPasswordState extends ResetPasswordState {
  final String message;

  ErrorResetPasswordState({required this.message});

  @override
  List<Object> get props => [message];
}

class MessageResetPasswordState extends ResetPasswordState {
  final String message;

  MessageResetPasswordState({required this.message});

  @override
  List<Object> get props => [message];
}
