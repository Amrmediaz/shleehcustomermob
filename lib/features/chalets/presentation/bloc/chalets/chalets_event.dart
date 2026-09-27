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

  GetAllChaletsEvent({required this.body, required this.pageNumber});

  @override
  List<Object> get props => [body];
}

class GetAllChaletsFilterDateEvent extends ChaletsEvent {
  final dynamic body;
  final int pageNumber;

  GetAllChaletsFilterDateEvent({required this.body, required this.pageNumber});

  @override
  List<Object> get props => [body];
}

class RefreshChaletsEvent extends ChaletsEvent {
  final dynamic body;
  final int pageNumber;

  RefreshChaletsEvent({required this.body, required this.pageNumber});

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

// ---------------------------------------------------------------------------
// NEW: dedicated events for the FilterWidget -> ChaletsByFilterPage flow.
// These mirror GetAllChaletsFilterDateEvent/LoadMoreChaletsEvent/
// RefreshChaletsEvent exactly (same {body, pageNumber} shape), but map to
// their own Loading/Loaded/Error*Filter* states below instead of reusing
// LoadedChaletsState — so pagination on the filter results page can never
// accidentally merge with whatever list the home feed (LoadedChaletsState)
// happened to be holding.
//
// IMPORTANT: wherever ChaletsByFilterPage currently dispatches
// LoadMoreChaletsEvent / RefreshChaletsEvent for its own infinite scroll /
// pull-to-refresh, switch those to LoadMoreChaletsFilterEvent /
// RefreshChaletsFilterEvent so every step of the filter flow stays on the
// Filter* states. I don't have that file, so this part needs to be wired
// up on your end.
// ---------------------------------------------------------------------------

class GetAllChaletsFilterEvent extends ChaletsEvent {
  final dynamic body;
  final int pageNumber;

  GetAllChaletsFilterEvent({required this.body, required this.pageNumber});

  @override
  List<Object> get props => [body];
}

class LoadMoreChaletsFilterEvent extends ChaletsEvent {
  final dynamic body;
  final int pageNumber;

  LoadMoreChaletsFilterEvent({required this.body, required this.pageNumber});

  @override
  List<Object> get props => [body];
}

class RefreshChaletsFilterEvent extends ChaletsEvent {
  final dynamic body;
  final int pageNumber;

  RefreshChaletsFilterEvent({required this.body, required this.pageNumber});

  @override
  List<Object> get props => [body];
}