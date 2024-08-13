


import 'package:dartz/dartz.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/features/authentication/register/domain/usecases/check_user_exist.dart';
import 'package:shleehcustomer/features/authentication/register/domain/usecases/register_user.dart';
import 'package:shleehcustomer/features/authentication/register/domain/usecases/verify_otp.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/strings/messages/failures.dart';
import '../../../../../../core/strings/messages/messages.dart';
import '../../../domain/entities/UserRegister.dart';
import '../../../domain/usecases/send_otp.dart';

part 'register_user_event.dart';
part 'register_user_state.dart';

class RegisterBloc
    extends Bloc<RegisterUserEvent, RegisterUserState> {
  final RegisterUserUserCase registerUserUserCase;
  final SendOtpUserCase sendOtpUserCase;
  final VerifyOtpUserCase verifyOtpUserCase;
  final CheckUserExistUserCase checkUserExistedUserCase;

  RegisterBloc({
        required this.registerUserUserCase , required this.sendOtpUserCase ,required this.verifyOtpUserCase,required this.checkUserExistedUserCase})
      : super(RegisterUserInitial()) {
    on<RegisterUserEvent>((event, emit) async {
      print("okkkk");
      if (event is RegisterUseEvent) {
        emit(LoadingRegisterUserState());
        final failureOrDoneMessage = await registerUserUserCase(event.userRegister);
        emit(
          _eitherDoneMessageOrErrorState(
              failureOrDoneMessage, ""),
        );
      } else if (event is OtpSendEvent){
        emit(LoadingRegisterUserState());
        final failureOrDoneMessage = await sendOtpUserCase(event.phoneNumber);
        emit(
          _eitherDoneMessageOrErrorStateSendOtp(
              failureOrDoneMessage, getTextByKey(key: TranslationKey.keyOtpSentSuccessMessage)),
        );
      }
      else if (event is OtpVerifyEvent){
        // emit(LoadingRegisterUserState());

        final failureOrDoneMessage = await verifyOtpUserCase(event.otpCode,event.phoneNumber);

        emit(
          _eitherDoneMessageOrErrorStateOtpVerify(
              failureOrDoneMessage, getTextByKey(key: TranslationKey.keyOtpVerifiedSuccessMessage)),
        );
      }
      else if (event is CheckUserExistEvent){
        emit(LoadingRegisterUserState());

        final failureOrDoneMessage = await checkUserExistedUserCase(event.phoneNumber);
        emit(
          _eitherDoneMessageOrErrorCheckUserExistedState(
              failureOrDoneMessage, "erreo"),
        );
      }
    });
  }

  RegisterUserState _eitherDoneMessageOrErrorState(
      Either<Failure, Unit> either, String message) {
    return either.fold(
      (failure) => ErrorRegisterUserState(
        message: _mapFailureToMessage(failure),
      ),
      (_) => MessageRegisterUserState(message: message),
    );
  }
  RegisterUserState _eitherDoneMessageOrErrorCheckUserExistedState(
      Either<Failure, Unit> either, String message) {
    print("okx");
    return either.fold(
          (failure) => ErrorCheckExistedUserState(
        message: _mapFailureToMessage(failure),
      ),
          (_) => MessageCheckUserExistState(message: message),
    );
  }
  RegisterUserState _eitherDoneMessageOrErrorStateOtpVerify(
      Either<Failure, Unit> either, String message) {
    return either.fold(
          (failure) => ErrorVerifyOtpUserState(
        message: _mapFailureToMessage(failure),
      ),
          (_) => MessageVerifyOtpState(message: message),
    );
  }
  RegisterUserState _eitherDoneMessageOrErrorStateSendOtp(
      Either<Failure, Unit> either, String message) {
    return either.fold(
          (failure) => ErrorSendOtpUserState(
        message: _mapFailureToMessage(failure),
      ),
          (_) => MessageSendOtpState(message: message),
    );
  }
  String _mapFailureToMessage(Failure failure) {

    switch (failure.runtimeType) {
      case UserExsitedFailure:
        return getTextByKey(key: TranslationKey.keyExistUser);
      case OtpException:
        return getTextByKey(key: TranslationKey.keyWrongOtp);
      case ResetPasswordFailure:
        return getTextByKey(key: TranslationKey.keyResetPasswordFailedMessage);
      case AuthenticationFailure:
        return getTextByKey(key: TranslationKey.keyError);
      case OfflineFailure:
        return getTextByKey(key: TranslationKey.keyNoInternet);
      default:
        return getTextByKey(key: TranslationKey.keyError);
    }
  }
}
