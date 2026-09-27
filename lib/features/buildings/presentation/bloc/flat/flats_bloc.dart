import 'package:bloc/bloc.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/features/buildings/data/models/flat_model.dart';
import 'package:shleehcustomer/features/buildings/domain/usecases/get_flats_by_building_id.dart';

import '../../../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/strings/messages/failures.dart';
import '../../../data/models/flat_Response.dart';
import '../../../domain/entities/flat.dart';


part 'flats_event.dart';
part 'flats_state.dart';

class FlatsBloc extends Bloc<flatsEvent, FlatsState> {

  final GetFlatByBuildingIdUsecase getFlatByBuildingIdUsecase;

  int _loadingPage = -1;
  // Was only ever compared on page number (see below), so if this bloc
  // (a single app-wide instance, shared by every building detail page)
  // was mid-request for Building A's page 1 and the user backed out and
  // opened Building B before it finished, Building B's page-1 request
  // would silently be dropped — same page number looked like a duplicate
  // even though it was a totally different building. Now keyed on
  // buildingId+page together.
  dynamic _loadingBuildingId;
  bool _isLoading = false;

  FlatsBloc({
    required this.getFlatByBuildingIdUsecase
  }) : super(flatsInitial()) {
    on<GetFlatByBuildingIdEvent>((event, emit) async {
      final requestedPage = event.body["page"] as int;
      final requestedBuildingId = event.body["buildingId"];

      // Prevent duplicate requests for the *same* building's *same* page.
      if (_isLoading &&
          _loadingPage == requestedPage &&
          _loadingBuildingId == requestedBuildingId) {
        return;
      }

      _isLoading = true;
      _loadingPage = requestedPage;
      _loadingBuildingId = requestedBuildingId;

      if (requestedPage == 1) {
        emit(LoadingFlatsState());
      }

      try {
        final failureOrResponse = await getFlatByBuildingIdUsecase(event.body);
        emit(_mapFailureOrFlatsToState(failureOrResponse, requestedPage));
      } finally {
        _isLoading = false;
        _loadingPage = -1;
        _loadingBuildingId = null;
      }
    });
  }


  FlatsState _mapFailureOrFlatsToState(
      Either<Failure, dynamic> either,
      int requestedPage,
      ) {
    return either.fold(
          (failure) {
        print('❌ Failure: ${failure.runtimeType}');
        return ErrorFlatsState(message: _mapFailureToMessage(failure));
      },
          (response) {
        try {
          List<Flat> newFlats = [];
          bool lastEmpty = false;
          int currentPage = requestedPage;
          int pageCount = 1;

          if (response is FlatsResponse) {
            // Get existing flats
            final existingFlats = (state is LoadedFlatssState)
                ? (state as LoadedFlatssState).flats
                : [];

            // Convert results to Flat objects
            List<Flat> flatResults = [];
            for (var result in response.results) {
              if (result is Flat) {
                flatResults.add(result);
              } else if (result is FlatModel) {
                flatResults.add(result as Flat);
              }
            }

            // Append to existing
            newFlats = [...existingFlats, ...flatResults];

            currentPage = response.currentPage;
            pageCount = response.pageCount;
            lastEmpty = response.currentPage >= response.pageCount || flatResults.isEmpty;
          } else {
            print('❌ FlatsBloc: unexpected response type ${response.runtimeType}');
            return ErrorFlatsState(message: 'Unexpected response type');
          }

          return LoadedFlatssState(
            flats: newFlats,
            body: {},
            page: currentPage,
            pageCount: pageCount,
            lastEmpty: lastEmpty,
          );
        } catch (e, stackTrace) {
          print('❌ Exception: $e');
          print('❌ StackTrace: $stackTrace');
          return ErrorFlatsState(message: 'Error: $e');
        }
      },
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