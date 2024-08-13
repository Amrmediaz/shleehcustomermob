part of 'setting_bloc.dart';

abstract class SettingEvent extends Equatable {
  const SettingEvent();

  @override
  List<Object> get props => [];
}


class GetUserEvent extends SettingEvent {
  GetUserEvent();
  @override
  List<Object> get props => [];
}

class UpdateUserEvent extends SettingEvent {
  final dynamic body;
  const UpdateUserEvent(this.body);
  @override
  List<Object> get props => [body];
}
class DeleteUserEvent extends SettingEvent {
  final dynamic userId;
  const DeleteUserEvent(this.userId);
  @override
  List<Object> get props => [userId];
}