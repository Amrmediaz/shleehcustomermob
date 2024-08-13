part of 'setting_bloc.dart';


abstract class SettingState extends Equatable {
  const SettingState();

  @override
  List<Object> get props => [];
}

class SettingInitial extends SettingState {}

class LoadingUserDataState extends SettingState {}


class LoadedUserState extends SettingState {
  final User user;
  const LoadedUserState({required this.user});
  @override
  List<Object> get props => [user];
}

class UpdatedUserState extends SettingState {

}

class DeletedUserState extends SettingState {

}

class ErrorGetUserState extends SettingState {
  final String message;
  ErrorGetUserState({required this.message});
  @override
  List<Object> get props => [message];
}

class ErrorUpdateUserState extends SettingState {
  final String message;
  ErrorUpdateUserState({required this.message});
  @override
  List<Object> get props => [message];
}

class ErrorDeletedUserState extends SettingState {
  final String message;
  ErrorDeletedUserState({required this.message});
  @override
  List<Object> get props => [message];
}