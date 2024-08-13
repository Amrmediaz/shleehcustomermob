part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object> get props => [];
}

class LoginInitial extends HomeState {}

class LoadingHomeState extends HomeState {}
class hideBottomBarState extends HomeState {
  final bool  isHidden;
  hideBottomBarState({required this.isHidden});
}

class ErrorHomeState extends HomeState {
  final String message;

  ErrorHomeState({required this.message});

  @override
  List<Object> get props => [message];
}

class LoadedOnboardState extends HomeState {
  final List<Onboard>  onboards;
  LoadedOnboardState({required this.onboards});
  @override
  List<Object> get props => [onboards];
}
