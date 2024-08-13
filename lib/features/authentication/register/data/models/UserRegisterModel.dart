import 'dart:convert';

import '../../domain/entities/UserRegister.dart';
class UserRegisterModel extends UserRegister {
  UserRegisterModel({
    required String email,
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
  }) : super(
    email: email,
    phone: phone,
    password: password,
    firstName: firstName,
    lastName: lastName,
  );

  factory UserRegisterModel.fromJson(Map<String, dynamic> json) {
    return UserRegisterModel(
      email: json['email'],
      phone: json['phone'],
      password: json['password'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phoneNumber': phone,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  @override
  List<Object?> get props => [email, phone, password, firstName, lastName];
}