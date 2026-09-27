import 'package:bloc/bloc.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/features/buildings/domain/entities/building_details_model.dart';
import 'package:shleehcustomer/features/buildings/domain/entities/building_map.dart';
import 'package:shleehcustomer/features/buildings/domain/usecases/get_buildings.dart';
import 'package:shleehcustomer/features/buildings/domain/usecases/get_flats_by_building_id.dart';
import '../../../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/strings/messages/failures.dart';
import '../../../data/models/building_details.dart';
import '../../../domain/entities/building.dart';
import '../../../domain/entities/flat.dart';
import '../../../domain/usecases/get_building_by_id.dart';
import '../../../domain/usecases/get_buildings_map.dart';

part 'buildings_event.dart';
part 'buildings_state.dart';

class BuildingsBloc extends Bloc<BuildingsEvent, BuildingsState> {
  final GetBuildingsUsecase getBuildingsUsecase;
  final GetBuildingsMapUsecase getBuildingsMapUsecase;
  final GetBuildingIdUsecase getBuildingIdUsecase;

  BuildingsBloc({
    required this.getBuildingsUsecase,
    required this.getBuildingIdUsecase,
    required this.getBuildingsMapUsecase,
  }) : super(BuildingsInitial()) {
    on<BuildingsEvent>((event, emit) async {
      if (event is GetAllBuildingsEvent) {
        emit(LoadingBuildingsState());
        final failureOrPosts = await getBuildingsUsecase(body: event.body);
        emit(_mapFailureOrPostsToState(failureOrPosts, event.pageNumber, event.body));
      }

      else if (event is LoadMoreBuildingsEvent) {
        final failureOrPosts = await getBuildingsUsecase(body: event.body);
        emit(_mapFailureOrPostsToState(failureOrPosts, event.pageNumber, event.body));
      } else if (event is RefreshBuildingsEvent) {
        final failureOrPosts = await getBuildingsUsecase(body: event.body);
        emit(_mapFailureOrPostsToState(failureOrPosts, event.pageNumber, event.body));
      }



      else if (event is LoadBuildingsById) {
        emit(LoadingBuildingIdState());
        final failureOrPosts = await getBuildingIdUsecase(int.parse(event.id));
        emit(_mapFailureOrBuildingToState(failureOrPosts));
      } else if (event is GetAllBuildingsMapEvent) {
        emit(LoadingBuildingIdState());
        final failureOrBuilding = await getBuildingsMapUsecase();
        emit(_mapFailureOrBuildingsMapToState(failureOrBuilding));
      }
    });
  }

  BuildingsState _mapFailureOrPostsToState(
      Either<Failure, dynamic> either,
      int page,
      dynamic body,
      ) {
    return either.fold(
          (failure) => ErrorBuildingsState(message: _mapFailureToMessage(failure)),
          (response) {
        try {
          List<Building> newBuildings = [];
          bool lastEmpty = false;
          int currentPage = page;
          int pageCount = 1;

          if (response is List<Building>) {
            newBuildings = response;
            lastEmpty = response.isEmpty;
          } else if (response is Map<String, dynamic> || response.toString().contains('results')) {
            final results = response.results ?? [];
            currentPage = response.currentPage ?? page;
            pageCount = response.pageCount ?? 1;

            final existingBuildings = (state is LoadedBuildingsState)
                ? (state as LoadedBuildingsState).Buildings
                : [];

            newBuildings = [...existingBuildings, ...results];

            final bool isLastPage = currentPage >= pageCount;
            final bool hasNoResults = results.isEmpty;
            lastEmpty = isLastPage || hasNoResults;
          }

          return LoadedBuildingsState(
            Buildings: newBuildings,
            body: body,
            page: currentPage,
            lastEmpty: lastEmpty,
          );
        } catch (e) {
          print('❌ Error in _mapFailureOrPostsToState: $e');
          return ErrorBuildingsState(message: 'Error processing buildings');
        }
      },
    );
  }
  // NOTE: this bloc used to also fetch flats directly (a dead
  // _mapFailureOrFlatsToState helper lived here, never called from any
  // event handler — flat-fetching now lives entirely in FlatsBloc). It also
  // had a latent bug (cast state as LoadedBuildingsState while checking
  // `state is LoadedFlatssState`) that would have thrown if it were ever
  // reached. Removed as dead code rather than fixed, since nothing calls it.

  BuildingsState _mapFailureOrBuildingsMapToState(
      Either<Failure, List<BuildingMap>> either,
      ) {
    return either.fold(
          (failure) => ErrorBuildingsMapState(message: _mapFailureToMessage(failure)),
          (buildings) => LoadedBuildingsMapState(Buildings: buildings),
    );
  }

  BuildingsState _mapFailureOrBuildingToState(
      Either<Failure, BuildingDetailsModel> either,
      ) {
    return either.fold(
          (failure) => ErrorBuildingsIdState(message: _mapFailureToMessage(failure)),
          (building) => LoadedBuildingIdState(buildingDetails: building),
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