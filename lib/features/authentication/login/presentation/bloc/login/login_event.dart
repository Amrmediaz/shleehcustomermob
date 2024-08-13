import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shleehcustomer/features/authentication/login/domain/entities/user_login_response.dart';

// Define events
abstract class LoginEvent {}

class UserLoginInitialEvent extends LoginEvent {}

// Define states
class LoginUserEvent extends LoginEvent {
  final bool isMainLogin ;
  final dynamic body ;
  LoginUserEvent(this.body , this.isMainLogin);
}


class LoadingLogin extends LoginEvent {}



