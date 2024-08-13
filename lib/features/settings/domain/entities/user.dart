import 'package:equatable/equatable.dart';

import 'package:equatable/equatable.dart';

import 'package:equatable/equatable.dart';

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String birthDate;
  final String userImage;
  final int gender;
  final String? password;
  final String governorate;
  final String state;
  final int points;
  final DateTime createdDate;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.birthDate,
    required this.userImage,
    required this.gender,
    this.password,
    required this.governorate,
    required this.state,
    required this.points,
    required this.createdDate,
  });
}