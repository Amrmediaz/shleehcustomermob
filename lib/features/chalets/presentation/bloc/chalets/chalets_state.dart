part of 'chalets_bloc.dart';


abstract class ChaletsState extends Equatable {
  const ChaletsState();

  @override
  List<Object> get props => [];
}

class ChaletsInitial extends ChaletsState {}

class LoadingChaletsState extends ChaletsState {}
class LoadingChaletsMapState extends ChaletsState {}

class LoadingChaletIdState extends ChaletsState {}

class LoadedChaletsState extends ChaletsState {
  final List<Chalet> chalets;
  final dynamic body;
  final int page;
  LoadedChaletsState({required this.chalets , required this.page , required this.body});
  @override
  List<Object> get props => [chalets];
}
class LoadedChaletsMapState extends ChaletsState {
  final List<ChaletMap> chalets;
  LoadedChaletsMapState({required this.chalets});
  @override
  List<Object> get props => [chalets];
}

class LoadedChaletIdState extends ChaletsState {
  final ChaletDetails chalet;
  LoadedChaletIdState({required this.chalet});
  @override
  List<Object> get props => [chalet];
}



class ErrorChaletsMapState extends ChaletsState {
  final String message;
  ErrorChaletsMapState({required this.message});
  @override
  List<Object> get props => [message];
}
class ErrorChaletsState extends ChaletsState {
  final String message;
  ErrorChaletsState({required this.message});
  @override
  List<Object> get props => [message];
}
class ErrorChaletsIdState extends ChaletsState {
  final String message;
  ErrorChaletsIdState({required this.message});
  @override
  List<Object> get props => [message];
}
