
import '../../domain/entities/UserRegisterResponse.dart';
class RegisterUserModelResponse extends UserRegisterResponse {
  RegisterUserModelResponse({required super.token, required super.expaire});
  factory RegisterUserModelResponse.fromJson(Map<String, dynamic> json) {
    return RegisterUserModelResponse(token: json["message"]['token'], expaire: json["message"]['expaire']);
  }

  @override
  List<Object?> get props => [token, expaire];
}