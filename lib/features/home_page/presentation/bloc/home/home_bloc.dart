import 'package:dartz/dartz.dart';
import 'package:shleehcustomer/features/home_page/domain/entities/onboard.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../core/strings/language.dart';
import '../../../../../core/strings/messages/failures.dart';
import '../../../../landing/domain/entities/onboard.dart';
import '../../../domain/usescases/get_onboard_items.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(LoginInitial()) {
    on<HomeEvent>((event, emit) async {
      if (event is HomeEventObj) {
        emit(LoadingHomeState());
      } else if (event is HideBottomBarEvent) {
        emit(hideBottomBarState(isHidden: event.isHidden));
      }
    });
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case AuthenticationFailure:
        return getTextByKey(key: LOGIN_FAILED_MESSAGE);

      case OfflineFailure:
        return getTextByKey(key: TranslationKey.keyNoInternet);
      default:
        return getTextByKey(key: TranslationKey.keyError);
    }
  }
}
