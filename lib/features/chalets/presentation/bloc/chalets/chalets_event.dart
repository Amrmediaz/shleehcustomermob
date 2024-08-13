part of 'chalets_bloc.dart';

abstract class ChaletsEvent extends Equatable {
  const ChaletsEvent();

  @override
  List<Object> get props => [];
}

class GetAllChaletsMapEvent extends ChaletsEvent {

  GetAllChaletsMapEvent();

  @override
  List<Object> get props => [];
}

class GetAllChaletsEvent extends ChaletsEvent {
  final dynamic body;
  final int pageNumber;

  GetAllChaletsEvent({required this.body , required this.pageNumber});

  @override
  List<Object> get props => [body];
}
class RefreshChaletsEvent extends ChaletsEvent {
  final dynamic body;
  final int pageNumber;

  RefreshChaletsEvent({required this.body ,required this.pageNumber});

  @override
  List<Object> get props => [body];
}


class LoadMoreChaletsEvent extends ChaletsEvent {
  final dynamic body;
  final int pageNumber;

  LoadMoreChaletsEvent({required this.body, required this.pageNumber});

  @override
  List<Object> get props => [body];
}
class LoadChaletsById extends ChaletsEvent {
  final String id;
  LoadChaletsById({required this.id});

  @override
  List<Object> get props => [id];
}
