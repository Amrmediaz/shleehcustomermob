part of 'flats_bloc.dart';

abstract class flatsEvent extends Equatable {
  const flatsEvent();

  @override
  List<Object> get props => [];
}


class GetFlatByBuildingIdEvent extends flatsEvent {
  final dynamic body;


  GetFlatByBuildingIdEvent({required this.body });

  @override
  List<Object> get props => [body];
}

