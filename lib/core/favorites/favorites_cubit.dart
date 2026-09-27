import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'favorite_item.dart';
import 'favorites_service.dart';

class FavoritesState extends Equatable {
  final List<FavoriteItem> items;
  final bool isLoading;

  const FavoritesState(this.items, {this.isLoading = false});

  bool isFavorite(String key) => items.any((e) => e.key == key);

  @override
  List<Object?> get props => [items, isLoading];
}

/// App-wide favorites state — now backed by the real API (see
/// FavoritesService / FAVORITES-API-SPEC.md) instead of local persistence.
/// Registered once (same lifecycle convention as every other Bloc in this
/// app — a factory in the DI container that's only ever instantiated once,
/// at the root MultiBlocProvider), so every screen that reads it — chalet/
/// building cards, the Favorites tab — shares the exact same in-memory list
/// and never drifts out of sync with each other.
class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesService service;

  // Client-side cap only — not enforced by the backend. Matches the same
  // limit on the website (see FAVORITES_LIMIT in FavoritesContext.jsx).
  static const maxFavorites = 15;

  FavoritesCubit(this.service) : super(const FavoritesState([]));

  /// Fetches favorites from the backend. Call once at app start (same
  /// call site as before, `main.dart`'s `..load()`), and again after
  /// login/logout so the list reflects whichever account is currently
  /// signed in instead of leaking the previous session's data.
  Future<void> load() async {
    emit(FavoritesState(state.items, isLoading: true));
    final items = await service.getAll();
    emit(FavoritesState(items, isLoading: false));
  }

  /// Clears the list immediately (e.g. on logout) without a network call —
  /// there's nothing to fetch for a guest, and no reason to keep showing
  /// the previous user's favorites for even a moment.
  void clear() {
    emit(const FavoritesState([]));
  }

  /// Returns false (without making a network call) if this would add a new
  /// favorite past [maxFavorites] — the caller (FavoriteButton) checks this
  /// to decide whether to show a "limit reached" message. Removing always
  /// succeeds regardless of the current count.
  Future<bool> toggle(FavoriteItem item) async {
    final previous = state;
    final current = List<FavoriteItem>.from(state.items);
    final index = current.indexWhere((e) => e.key == item.key);
    final isAdding = index < 0;

    if (isAdding && current.length >= maxFavorites) {
      return false;
    }

    // Optimistic update so the heart icon responds instantly instead of
    // waiting on the network round trip; rolled back below on failure.
    if (isAdding) {
      current.insert(0, item); // newest favorite shows first
    } else {
      current.removeAt(index);
    }
    emit(FavoritesState(current, isLoading: previous.isLoading));

    try {
      await service.toggle(item);
      return true;
    } catch (_) {
      emit(previous); // roll back to exactly the pre-toggle state
      return true; // toggle was attempted, just failed — not a limit block
    }
  }
}
