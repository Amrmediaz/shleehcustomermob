part of 'chalets_bloc.dart';

abstract class ChaletsState extends Equatable {
  const ChaletsState();

  @override
  List<Object?> get props => [];
}

class ChaletsInitial extends ChaletsState {
  const ChaletsInitial();
}

class LoadingChaletsState extends ChaletsState {
  const LoadingChaletsState();
}
class LoadingFilterDateChaletsState extends ChaletsState {
  const LoadingFilterDateChaletsState();
}

class LoadingChaletsMapState extends ChaletsState {
  const LoadingChaletsMapState();
}

class LoadingChaletIdState extends ChaletsState {
  const LoadingChaletIdState();
}

class LoadedChaletsState extends ChaletsState {
  final List<Chalet> chalets;
  final dynamic body;
  final int page;
  final bool lastEmpty; // ✅ NEW FIELD - Controls pagination stop

  const LoadedChaletsState({
    required this.chalets,
    required this.page,
    required this.body,
    this.lastEmpty = false, // ✅ Default to false
  });

  @override
  List<Object?> get props => [chalets, page, body, lastEmpty]; // ✅ Include in props
}

class LoadedChaletsFilterDateState extends ChaletsState {
  final List<Chalet> chalets;
  final dynamic body;
  final int page;
  final bool lastEmpty; // ✅ NEW FIELD - Controls pagination stop

  const LoadedChaletsFilterDateState({
    required this.chalets,
    required this.page,
    required this.body,
    this.lastEmpty = false, // ✅ Default to false
  });

  @override
  List<Object?> get props => [chalets, page, body, lastEmpty]; // ✅ Include in props
}

class LoadedChaletsMapState extends ChaletsState {
  final List<ChaletMap> chalets;

  const LoadedChaletsMapState({required this.chalets});

  @override
  List<Object> get props => [chalets];
}

class LoadedChaletIdState extends ChaletsState {
  final ChaletDetails chalet;

  const LoadedChaletIdState({required this.chalet});

  @override
  List<Object> get props => [chalet];
}

class ErrorChaletsMapState extends ChaletsState {
  final String message;

  const ErrorChaletsMapState({required this.message});

  @override
  List<Object> get props => [message];
}

class ErrorChaletsState extends ChaletsState {
  final String message;

  const ErrorChaletsState({required this.message});

  @override
  List<Object> get props => [message];
}

class ErrorChaletsIdState extends ChaletsState {
  final String message;

  const ErrorChaletsIdState({required this.message});

  @override
  List<Object> get props => [message];
}

// ---------------------------------------------------------------------------
// NEW: dedicated states for the general FilterWidget -> ChaletsByFilterPage
// flow (GetAllChaletsFilterEvent / LoadMoreChaletsFilterEvent /
// RefreshChaletsFilterEvent in chalets_event.dart). Same shape as
// LoadedChaletsFilterDateState, kept separate so filter-page pagination
// never merges with the home feed's LoadedChaletsState list.
// ---------------------------------------------------------------------------

class LoadingChaletsFilterState extends ChaletsState {
  const LoadingChaletsFilterState();
}

class LoadedChaletsFilterState extends ChaletsState {
  final List<Chalet> chalets;
  final dynamic body;
  final int page;
  final bool lastEmpty;

  const LoadedChaletsFilterState({
    required this.chalets,
    required this.page,
    required this.body,
    this.lastEmpty = false,
  });

  @override
  List<Object?> get props => [chalets, page, body, lastEmpty];
}

class ErrorChaletsFilterState extends ChaletsState {
  final String message;

  const ErrorChaletsFilterState({required this.message});

  @override
  List<Object> get props => [message];
}