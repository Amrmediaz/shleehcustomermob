import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shleehcustomer/features/authentication/login/domain/entities/user_login_response.dart';

import '../../../../../../core/error/failures.dart';
import '../../../../../../core/strings/language.dart';
import '../../../../../../core/strings/messages/failures.dart';
import '../../../domain/usecases/login_usecase.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUsecase loginUsecase;

  LoginBloc({
    required this.loginUsecase,
  }) : super(LoginInitial()) {
    on<LoginEvent>((event, emit) async {
      if (event is LoginUserEvent) {
        emit(LoadingLoginState());
        final failureOLogin = await loginUsecase(event.body);
        emit(_mapFailureOrLoginToState(failureOLogin, event.isMainLogin));
      }
    });
  }

  LoginState _mapFailureOrLoginToState(
      Either<Failure, Unit> either, bool isMainLogin) {
    return either.fold(
      (failure) => ErrorLoginState(
          message: _mapFailureToMessage(failure), isMainLogin: isMainLogin),
      (_) => MessageLoginState(isMainLogin),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return getTextByKey(key: TranslationKey.keyServerError);
      case EmptyCacheFailure:
        return getTextByKey(key: TranslationKey.keyNoData);
      case OfflineFailure:
        return getTextByKey(key: TranslationKey.keyNoInternet);
      default:
        return getTextByKey(key: TranslationKey.keyError);
    }
  }
}
