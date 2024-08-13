import 'package:equatable/equatable.dart';

class UserRegisterResponse extends Equatable {
  final String token;
  final String expaire;

  UserRegisterResponse({
    required this.token,
    required this.expaire,
  });

  @override
  List<Object?> get props => [token, expaire];
}