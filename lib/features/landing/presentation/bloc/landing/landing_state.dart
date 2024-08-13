part of 'landing_bloc.dart';


abstract class LandingState extends Equatable {
  const LandingState();
  @override
  List<Object> get props => [];
}

class LandingInitial extends LandingState {}

class LoadingLandingState extends LandingState {}

class ErrorLandingState extends LandingState {
  final String message;

  ErrorLandingState({required this.message});

  @override
  List<Object> get props => [message];
}

class LoadedOnboardState extends LandingState {
  final List<Onboard>  onboards;
  LoadedOnboardState({required this.onboards});
  @override
  List<Object> get props => [onboards];
}
