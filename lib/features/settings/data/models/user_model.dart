import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required int id,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String birthDate,
    required String userImage,
    required int gender,
    String? password,
    required String governorate,
    required String state,
    required int points,
    required DateTime createdDate,
  }) : super(
    id: id,
    firstName: firstName,
    lastName: lastName,
    email: email,
    phoneNumber: phoneNumber,
    birthDate: birthDate,
    userImage: userImage,
    gender: gender,
    password: password,
    governorate: governorate,
    state: state,
    points: points,
    createdDate: createdDate,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      birthDate: json['birthDate'] ?? "",
      userImage: json['userImage'] ?? "",
      gender: json['gender'] ?? "",
      password: json['password'],
      governorate: json['governorate'] ?? "",
      state: json['state'] ?? "",
      points: json['points'] ?? 0,
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}