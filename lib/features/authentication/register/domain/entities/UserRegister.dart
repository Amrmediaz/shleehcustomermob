import 'package:equatable/equatable.dart';

class UserRegister extends Equatable {
  final String email;
  final String phone;
  final String password;
  final String firstName;
  final String lastName;

  UserRegister({required this.email, required this.phone,required this.password,required this.firstName,required this.lastName});
  @override
  List<Object?> get props => [email, phone,password,firstName,lastName];
}
