

// Define events

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}


class LoadingLoginState extends LoginState {}

class ErrorLoginState extends LoginState {
  final String message;
  final bool isMainLogin;

  ErrorLoginState({required this.message, required this.isMainLogin});

  @override
  List<Object> get props => [message];
}

class MessageLoginState extends LoginState {
  final bool isMainLogin;
  MessageLoginState( this.isMainLogin);

  @override
  List<Object> get props => [];
}

