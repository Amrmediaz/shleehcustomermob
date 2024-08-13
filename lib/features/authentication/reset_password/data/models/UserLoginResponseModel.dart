

import '../../domain/entities/user_reset_response.dart';

class ResetPasswordModelResponse extends UserResetResponse {
  ResetPasswordModelResponse({required super.status, required super.message});
  @override
  List<Object?> get props => [status, message];
}