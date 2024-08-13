import 'package:bloc/bloc.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/features/booking/domain/usecases/get_bookings.dart';
import 'package:shleehcustomer/features/settings/domain/entities/user.dart';
import 'package:shleehcustomer/features/settings/domain/usecases/delete_user.dart';
import 'package:shleehcustomer/features/settings/domain/usecases/get_user_data.dart';
import '../../../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/strings/messages/failures.dart';
import '../../../domain/usecases/update_user.dart';

part 'setting_event.dart';
part 'settings_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  final GetUserSettingsUsecase getUserSettingsUsecase;
  final UpdateUserSettingsUsecase updateUserSettingsUsecase;
  final DeleteUserSettingsUsecase deleteUserSettingsUsecase;


  SettingBloc({required this.getUserSettingsUsecase , required this.updateUserSettingsUsecase , required this.deleteUserSettingsUsecase
  } ) : super(SettingInitial()) {
    on<SettingEvent>((event, emit) async {
      if (event is GetUserEvent) {
        emit(LoadingUserDataState());
        final failureOrUser = await getUserSettingsUsecase();
        emit(_mapFailureOrUserToState(failureOrUser));
      } else if (event is UpdateUserEvent){
        final failureOrUpdateUser = await updateUserSettingsUsecase(event.body);
        emit(_mapFailureOrUpdateUserToState(failureOrUpdateUser));
      }
      else if (event is DeleteUserEvent){
        final failureOrDeleteUser = await deleteUserSettingsUsecase(event.userId);
        emit(_mapFailureOrDeleteUserToState(failureOrDeleteUser));
      }

    });
  }

  SettingState _mapFailureOrUserToState(Either<Failure, User> either) {
    return either.fold(
      (failure) => ErrorGetUserState(message: _mapFailureToMessage(failure)),
      (user) => LoadedUserState(
        user: user,

      ),
    );
  }
  SettingState _mapFailureOrUpdateUserToState(Either<Failure, Unit> either) {
    return either.fold(
          (failure) => ErrorUpdateUserState(message: _mapFailureToMessage(failure)),
          (_) => UpdatedUserState(


      ),
    );
  }
  SettingState _mapFailureOrDeleteUserToState(Either<Failure, Unit> either) {
    return either.fold(
          (failure) => ErrorDeletedUserState(message: _mapFailureToMessage(failure)),
          (_) => DeletedUserState(


      ),
    );
  }
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case EmptyCacheFailure:
        return EMPTY_CACHE_FAILURE_MESSAGE;
      case OfflineFailure:
        return getTextByKey(key: TranslationKey.keyNoInternet);
      default:
        return getTextByKey(key: TranslationKey.keyError);
    }
  }
}
