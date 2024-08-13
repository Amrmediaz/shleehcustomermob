

import '../../domain/entities/user_login_response.dart';

class UserLoginResponseModel extends LoginResponse {
  UserLoginResponseModel({required super.token, required super.expaire});
  factory UserLoginResponseModel.fromJson(Map<String, dynamic> json) {
    print(json);
    return UserLoginResponseModel(token: json['token'], expaire: json['expaire']);
  }

  @override
  List<Object?> get props => [token, expaire];
}