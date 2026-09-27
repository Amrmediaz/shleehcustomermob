part of 'flats_bloc.dart';

abstract class FlatsState extends Equatable {
  const FlatsState();

  @override
  List<Object?> get props => [];
}

class flatsInitial extends FlatsState {
  const flatsInitial();
}

class LoadingFlatsState extends FlatsState {
  const LoadingFlatsState();
}

class LoadedFlatssState extends FlatsState {
  final List<Flat> flats;
  final dynamic body;
  final int page;
  final int? pageCount;  // ← ADD THIS
  final bool lastEmpty;

  const LoadedFlatssState({
    required this.flats,
    required this.page,
    required this.body,
    this.pageCount,       // ← ADD THIS
    this.lastEmpty = false,
  });

  @override
  List<Object?> get props => [flats, page, body, pageCount, lastEmpty];
}

class ErrorFlatsState extends FlatsState {
  final String message;

  const ErrorFlatsState({required this.message});

  @override
  List<Object> get props => [message];
}