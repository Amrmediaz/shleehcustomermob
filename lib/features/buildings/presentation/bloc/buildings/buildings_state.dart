part of 'buildings_bloc.dart';

abstract class BuildingsState extends Equatable {
  const BuildingsState();

  @override
  List<Object?> get props => [];
}

class BuildingsInitial extends BuildingsState {
  const BuildingsInitial();
}

class LoadingBuildingsState extends BuildingsState {
  const LoadingBuildingsState();
}

class LoadingFlatsState extends BuildingsState {
  const LoadingFlatsState();
}

class LoadingBuildingsMapState extends BuildingsState {
  const LoadingBuildingsMapState();
}

class LoadingBuildingIdState extends BuildingsState {
  const LoadingBuildingIdState();
}

class LoadedBuildingsState extends BuildingsState {
  final List<Building> Buildings;
  final dynamic body;
  final int page;
  final bool lastEmpty;

  const LoadedBuildingsState({
    required this.Buildings,
    required this.page,
    required this.body,
    this.lastEmpty = false,
  });

  @override
  List<Object?> get props => [Buildings, page, body, lastEmpty];
}

class LoadedFlatssState extends BuildingsState {
  final List<Flat> flats;
  final dynamic body;
  final int page;
  final bool lastEmpty;

  const LoadedFlatssState({
    required this.flats,
    required this.page,
    required this.body,
    this.lastEmpty = false,
  });

  @override
  List<Object?> get props => [flats, page, body, lastEmpty];
}

class LoadedBuildingsMapState extends BuildingsState {
  final List<BuildingMap> Buildings;

  const LoadedBuildingsMapState({required this.Buildings});

  @override
  List<Object?> get props => [Buildings];
}

class LoadedBuildingIdState extends BuildingsState {
  final BuildingDetailsModel buildingDetails;

  const LoadedBuildingIdState({required this.buildingDetails});

  @override
  List<Object?> get props => [Building];
}

class ErrorBuildingsMapState extends BuildingsState {
  final String message;

  const ErrorBuildingsMapState({required this.message});

  @override
  List<Object?> get props => [message];
}

class ErrorBuildingsState extends BuildingsState {
  final String message;

  const ErrorBuildingsState({required this.message});

  @override
  List<Object?> get props => [message];
}

class ErrorFlatsState extends BuildingsState {
  final String message;

  const ErrorFlatsState({required this.message});

  @override
  List<Object?> get props => [message];
}

class ErrorBuildingsIdState extends BuildingsState {
  final String message;

  const ErrorBuildingsIdState({required this.message});

  @override
  List<Object?> get props => [message];
}