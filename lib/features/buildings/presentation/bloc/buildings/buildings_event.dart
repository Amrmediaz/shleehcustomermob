part of 'buildings_bloc.dart';

abstract class BuildingsEvent extends Equatable {
  const BuildingsEvent();

  @override
  List<Object> get props => [];
}

class GetAllBuildingsMapEvent extends BuildingsEvent {

  GetAllBuildingsMapEvent();

  @override
  List<Object> get props => [];
}

class GetAllBuildingsEvent extends BuildingsEvent {
  final dynamic body;
  final int pageNumber;

  GetAllBuildingsEvent({required this.body , required this.pageNumber});

  @override
  List<Object> get props => [body];
}
class GetFlatByBuildingId extends BuildingsEvent {
  final dynamic body;


  GetFlatByBuildingId({required this.body });

  @override
  List<Object> get props => [body];
}
class RefreshBuildingsEvent extends BuildingsEvent {
  final dynamic body;
  final int pageNumber;

  RefreshBuildingsEvent({required this.body ,required this.pageNumber});

  @override
  List<Object> get props => [body];
}


class LoadMoreBuildingsEvent extends BuildingsEvent {
  final dynamic body;
  final int pageNumber;

  LoadMoreBuildingsEvent({required this.body, required this.pageNumber});

  @override
  List<Object> get props => [body];
}

class LoadMoreFlatsEvent extends BuildingsEvent {
  final dynamic body;


  LoadMoreFlatsEvent({required this.body});

  @override
  List<Object> get props => [body];
}

class LoadBuildingsById extends BuildingsEvent {
  final String id;
  LoadBuildingsById({required this.id});

  @override
  List<Object> get props => [id];
}
