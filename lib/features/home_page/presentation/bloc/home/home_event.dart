part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class HomeEventObj extends HomeEvent {
  HomeEventObj();

  @override
  List<Object> get props => [];
}
class HideBottomBarEvent extends HomeEvent {
  final bool isHidden ;
  HideBottomBarEvent(this.isHidden);

  @override
  List<Object> get props => [];
}


