import 'package:bloc/bloc.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/features/chalets/domain/entities/chalet_details_model.dart';
import 'package:shleehcustomer/features/chalets/domain/entities/chalet_map.dart';
import 'package:shleehcustomer/features/chalets/domain/usecases/get_chalets.dart';
import '../../../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/strings/messages/failures.dart';
import '../../../domain/entities/chalet.dart';
import '../../../domain/usecases/get_chalet_by_id.dart';
import '../../../domain/usecases/get_chalets_map.dart';
part 'chalets_event.dart';
part 'chalets_state.dart';

class ChaletsBloc extends Bloc<ChaletsEvent, ChaletsState> {
  final GetChaletsUsecase getChaletsUsecase;
  final GetChaletsMapUsecase getChaletsMapUsecase;

  final GetChaletIdUsecase getChaletIdUsecase;

  ChaletsBloc({required this.getChaletsUsecase,required this.getChaletIdUsecase , required this.getChaletsMapUsecase
  } ) : super(ChaletsInitial()) {
    on<ChaletsEvent>((event, emit) async {
      if (event is GetAllChaletsEvent) {
        emit(LoadingChaletsState());
        final failureOrPosts = await getChaletsUsecase( event.body);
        emit(_mapFailureOrPostsToState(failureOrPosts,event.pageNumber,event.body));
      }
      else if  (event is LoadMoreChaletsEvent) {
       // emit(LoadingChaletsState());
        final failureOrPosts = await getChaletsUsecase( event.body);
        emit(_mapFailureOrPostsToState(failureOrPosts,event.pageNumber,event.body));
      } else if (event is RefreshChaletsEvent) {
      //  emit(LoadingChaletsState());
        final failureOrPosts = await getChaletsUsecase( event.body);
        emit(_mapFailureOrPostsToState(failureOrPosts,event.pageNumber , event.body));
      }
      else if (event is LoadChaletsById) {
        emit(LoadingChaletIdState());
        final failureOrPosts = await getChaletIdUsecase(int.parse(event.id));
        emit(_mapFailureOrChaletToState(failureOrPosts));
      }
      else if (event is GetAllChaletsMapEvent) {
        emit(LoadingChaletIdState());
        final failureOrChalet = await getChaletsMapUsecase();
        emit(_mapFailureOrChaletsMapToState(failureOrChalet));
      }
    });
  }

  ChaletsState _mapFailureOrPostsToState(Either<Failure, List<Chalet>> either , int page , dynamic body) {
    return either.fold(
      (failure) => ErrorChaletsState(message: _mapFailureToMessage(failure)),
      (chalets) => LoadedChaletsState(
        chalets: chalets,
        body: body,
        page: page
      ),
    );
  }
  ChaletsState _mapFailureOrChaletsMapToState(Either<Failure, List<ChaletMap>> either) {
    return either.fold(
          (failure) => ErrorChaletsMapState(message: _mapFailureToMessage(failure)),
          (chalets) => LoadedChaletsMapState(
        chalets: chalets,
      ),
    );
  }
  ChaletsState _mapFailureOrChaletToState(Either<Failure, ChaletDetails> either) {
    return either.fold(

          (failure) => ErrorChaletsIdState(message: _mapFailureToMessage(failure)),
          (chalet) => LoadedChaletIdState(
        chalet: chalet,
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
