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

  ChaletsBloc({
    required this.getChaletsUsecase,
    required this.getChaletIdUsecase,
    required this.getChaletsMapUsecase,
  }) : super(ChaletsInitial()) {
    on<ChaletsEvent>((event, emit) async {
      if (event is GetAllChaletsEvent) {
        emit(LoadingChaletsState());
        final failureOrPosts = await getChaletsUsecase(event.body);
        emit(_mapFailureOrPostsToState(failureOrPosts, event.pageNumber, event.body));
      }
      if (event is GetAllChaletsFilterDateEvent) {
        emit(LoadingFilterDateChaletsState());
        final failureOrPosts = await getChaletsUsecase(event.body);
        emit(_mapFailureOrPostsToState(failureOrPosts, event.pageNumber, event.body));
      }
      else if (event is LoadMoreChaletsEvent) {
        // Don't emit loading state for pagination
        final failureOrPosts = await getChaletsUsecase(event.body);
        emit(_mapFailureOrPostsToState(failureOrPosts, event.pageNumber, event.body));
      } else if (event is RefreshChaletsEvent) {
        // Don't emit loading state for refresh
        final failureOrPosts = await getChaletsUsecase(event.body);
        emit(_mapFailureOrPostsToState(failureOrPosts, event.pageNumber, event.body));
      } else if (event is LoadChaletsById) {
        emit(LoadingChaletIdState());
        final failureOrPosts = await getChaletIdUsecase(int.parse(event.id));
        emit(_mapFailureOrChaletToState(failureOrPosts));
      } else if (event is GetAllChaletsMapEvent) {
        emit(LoadingChaletIdState());
        final failureOrChalet = await getChaletsMapUsecase();
        emit(_mapFailureOrChaletsMapToState(failureOrChalet));
      }
      // ── NEW: FilterWidget -> ChaletsByFilterPage flow ─────────────────
      // Kept as its own branch (own Loading/Loaded/Error*Filter* states,
      // own pagination-merge function below) instead of reusing
      // GetAllChaletsEvent/LoadedChaletsState, so the filter results page
      // never mixes its list with whatever the home feed was holding.
      if (event is GetAllChaletsFilterEvent) {
        emit(LoadingChaletsFilterState());
        final failureOrPosts = await getChaletsUsecase(event.body);
        emit(_mapFailureOrPostsToFilterState(failureOrPosts, event.pageNumber, event.body));
      } else if (event is LoadMoreChaletsFilterEvent) {
        // Don't emit loading state for pagination
        final failureOrPosts = await getChaletsUsecase(event.body);
        emit(_mapFailureOrPostsToFilterState(failureOrPosts, event.pageNumber, event.body));
      } else if (event is RefreshChaletsFilterEvent) {
        // Don't emit loading state for refresh
        final failureOrPosts = await getChaletsUsecase(event.body);
        emit(_mapFailureOrPostsToFilterState(failureOrPosts, event.pageNumber, event.body));
      }
    });
  }

  /// ✅ FIXED: Properly handles pagination with lastEmpty flag
  ChaletsState _mapFailureOrPostsToState(
      Either<Failure, dynamic> either,
      int page,
      dynamic body,
      ) {
    return either.fold(
          (failure) => ErrorChaletsState(message: _mapFailureToMessage(failure)),
          (response) {
        try {
          // Handle the response - check if it has pagination data
          List<Chalet> newChalets = [];
          bool lastEmpty = false;
          int currentPage = page;
          int pageCount = 1;

          // If response is a list (fallback for old response format)
          if (response is List<Chalet>) {
            newChalets = response;
            lastEmpty = response.isEmpty;
          }
          // If response has pagination metadata (new format)
          else if (response is Map<String, dynamic> || response.toString().contains('results')) {
            // Extract data from response object
            final results = response.results ?? [];
            currentPage = response.currentPage ?? page;
            pageCount = response.pageCount ?? 1;

            // Get existing buildings from state
            final existingChalets = (state is LoadedChaletsState)
                ? (state as LoadedChaletsState).chalets
                : [];

            // Combine existing + new results
            newChalets = [...existingChalets, ...results];

            // ✅ CRITICAL: Determine if pagination should stop
            final bool isLastPage = currentPage >= pageCount;
            final bool hasNoResults = results.isEmpty;
            lastEmpty = isLastPage || hasNoResults;
          }

          if (body.toString().contains("endDate")){
            return LoadedChaletsFilterDateState(
              chalets: newChalets,
              body: body,
              page: currentPage,
              lastEmpty: lastEmpty, // ← This is the key to stopping pagination
            );
          } else {
            return LoadedChaletsState(
              chalets: newChalets,
              body: body,
              page: currentPage,
              lastEmpty: lastEmpty, // ← This is the key to stopping pagination
            );
          }
        } catch (e) {
          print('❌ Error in _mapFailureOrPostsToState: $e');
          return ErrorChaletsState(message: 'Error processing buildings');
        }
      },
    );
  }

  /// NEW: same pagination-merge logic as [_mapFailureOrPostsToState], but
  /// always resolves to LoadedChaletsFilterState/ErrorChaletsFilterState —
  /// used exclusively by GetAllChaletsFilterEvent / LoadMoreChaletsFilterEvent
  /// / RefreshChaletsFilterEvent. Kept as a separate function (rather than
  /// branching inside _mapFailureOrPostsToState) so:
  ///   1. The "existing chalets" lookup reads from LoadedChaletsFilterState,
  ///      not LoadedChaletsState — pagination on the filter page can't
  ///      accidentally append onto the home feed's list or vice versa.
  ///   2. There's no ambiguity from body-content sniffing (the old
  ///      `body.toString().contains("endDate")` check) — every event
  ///      routed here always resolves to a Filter state, whether or not
  ///      the filter body happens to include a date range.
  ChaletsState _mapFailureOrPostsToFilterState(
      Either<Failure, dynamic> either,
      int page,
      dynamic body,
      ) {
    return either.fold(
          (failure) =>
          ErrorChaletsFilterState(message: _mapFailureToMessage(failure)),
          (response) {
        try {
          List<Chalet> newChalets = [];
          bool lastEmpty = false;
          int currentPage = page;
          int pageCount = 1;

          if (response is List<Chalet>) {
            newChalets = response;
            lastEmpty = response.isEmpty;
          } else if (response is Map<String, dynamic> ||
              response.toString().contains('results')) {
            final results = response.results ?? [];
            currentPage = response.currentPage ?? page;
            pageCount = response.pageCount ?? 1;

            final existingChalets = (state is LoadedChaletsFilterState)
                ? (state as LoadedChaletsFilterState).chalets
                : [];

            newChalets = [...existingChalets, ...results];

            final bool isLastPage = currentPage >= pageCount;
            final bool hasNoResults = results.isEmpty;
            lastEmpty = isLastPage || hasNoResults;
          }

          return LoadedChaletsFilterState(
            chalets: newChalets,
            body: body,
            page: currentPage,
            lastEmpty: lastEmpty,
          );
        } catch (e) {
          print('❌ Error in _mapFailureOrPostsToFilterState: $e');
          return ErrorChaletsFilterState(message: 'Error processing buildings');
        }
      },
    );
  }

  ChaletsState _mapFailureOrChaletsMapToState(
      Either<Failure, List<ChaletMap>> either,
      ) {
    return either.fold(
          (failure) => ErrorChaletsMapState(message: _mapFailureToMessage(failure)),
          (chalets) => LoadedChaletsMapState(
        chalets: chalets,
      ),
    );
  }

  ChaletsState _mapFailureOrChaletToState(
      Either<Failure, ChaletDetails> either,
      ) {
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