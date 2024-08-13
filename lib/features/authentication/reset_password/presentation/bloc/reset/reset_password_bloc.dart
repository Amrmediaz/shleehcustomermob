
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shleehcustomer/core/strings/language.dart';

import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/strings/messages/failures.dart';
import '../../../../../../core/strings/messages/messages.dart';
import '../../../domain/usecases/reset_password_usecase.dart';

part 'reset_password_event.dart';
part 'reset_password_state.dart';

class ResetBloc
    extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  final ResetPasswordUsecase resetPasswordUsecase;

  ResetBloc({
        required this.resetPasswordUsecase})
      : super(ResetPasswordInitial()) {
    on<ResetPasswordEvent>((event, emit) async {
      if (event is ResetPasEvent) {
        emit(LoadingResetPasswordState());
        final failureOrDoneMessage = await resetPasswordUsecase(event.phoneNumber);
        emit(
          _eitherDoneMessageOrErrorState(
              failureOrDoneMessage, RESET_PASSWORD_SUCCESS_MESSAGE),
        );
      }
    });
  }

  ResetPasswordState _eitherDoneMessageOrErrorState(
      Either<Failure, Unit> either, String message) {
    return either.fold(
      (failure) => ErrorResetPasswordState(
        message: _mapFailureToMessage(failure),
      ),
      (_) => MessageResetPasswordState(message: message),
    );
  }
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ResetPasswordException:
        return getTextByKey(key: TranslationKey.keyResetPasswordFailedMessage);
      case OfflineFailure:
        return getTextByKey(key: TranslationKey.keyNoInternet);
      default:
        return getTextByKey(key: TranslationKey.keyError);
    }
  }
}
