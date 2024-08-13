part of 'reset_password_bloc.dart';

abstract class ResetPasswordEvent extends Equatable {
  const ResetPasswordEvent();

  @override
  List<Object> get props => [];
}

class ResetPasEvent extends ResetPasswordEvent {
  final String phoneNumber;

  ResetPasEvent({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}


