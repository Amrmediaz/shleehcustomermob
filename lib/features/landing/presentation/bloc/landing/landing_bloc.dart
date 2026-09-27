

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/strings/language.dart';
import '../../../../../core/strings/messages/failures.dart';
import '../../../../home_page/domain/entities/onboard.dart';
import '../../../domain/entities/onboard.dart';
import '../../../domain/usescases/get_onboard_items.dart';

part 'landing_event.dart';
part 'landing_state.dart';

class LandingBloc extends Bloc<LandingEvent, LandingState> {
  final GetOnBoardsUsecase getOnBoardsUsecase;

  LandingBloc({required this.getOnBoardsUsecase ,
  } ) : super(LandingInitial()) {
    on<LandingEvent>((event, emit) async {
      if (event is LandingEventObj) {
        emit(LoadingLandingState());
        final failureOrOnboard = await getOnBoardsUsecase();
        emit(_mapFailureOrOnboardToState(failureOrOnboard));
      }

    });
  }

  LandingState _mapFailureOrOnboardToState(Either<Failure, List<Onboard>> either) {
    return either.fold(
          (failure) => ErrorLandingState(message: _mapFailureToMessage(failure)),
          (onboards) => LoadedOnboardState(
            onboards: onboards,

      ),
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