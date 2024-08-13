import 'package:equatable/equatable.dart';

class UserResetResponse extends Equatable {
  final bool status;
  final String message;

  UserResetResponse({
    required this.status,
    required this.message,
  });

  @override
  List<Object?> get props => [status, message];
}