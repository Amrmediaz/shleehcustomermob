import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../network/urls.dart';
import '../util/cashed_data/cashed_file.dart';
import 'favorite_item.dart';

// Backend's `type` field is a numeric enum, confirmed with backend:
// 1 = chalet, 2 = building — no separate "flat" value, favoriting is at
// the building level like everywhere else. (An earlier round of testing
// was told 0/1 — that turned out to be wrong and is why favorited chalets
// were coming back with the account holder's name instead of the chalet's:
// sending 0 for chalet didn't match any real enum member server-side.)
// Converted here at the service boundary only, so FavoriteItem.type stays
// a plain 'chalet'/'building' string everywhere else it's already used
// (isChalet, chalet_card.dart, building_card.dart).
const _typeToNum = {'chalet': 1, 'building': 2};
const _numToType = {1: 'chalet', 2: 'building'};

/// Backend-synced favorites — previously pure local persistence
/// (shared_preferences). Now calls GetFavorites/ToggleFavorite so favorites
/// survive a reinstall and stay in sync with the website (see
/// FAVORITES-API-SPEC.md in the shleeh_com_customer repo for the full
/// contract both platforms share). Same http.Client + CasheFile token
/// pattern already used everywhere else in this app (e.g.
/// chalet_remote_data_source.dart's bookPayment).
class FavoritesService {
  final http.Client client;
  final casheFile = CasheFile();

  FavoritesService(this.client);

  /// Returns [] for a guest (no token) rather than hitting the network at
  /// all — favoriting requires an account, same as the website.
  Future<List<FavoriteItem>> getAll() async {
    final token = await casheFile.getUserToken();
    if (token.isEmpty) return [];

    try {
      final response = await client
          .get(
            Uri.parse('$BASE_URL$FAVORITES_URL'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true && body['message'] is List) {
          return (body['message'] as List).map((e) {
            final map = Map<String, dynamic>.from(e as Map<String, dynamic>);
            map['type'] = _numToType[map['type']] ?? 'chalet';
            // The client always sends a full absolute URL when favoriting
            // (see the int/type conversions above — same network-boundary
            // pattern), but backend has echoed back a bare relative path
            // on GetFavorites for at least one item. Prefix BASE_URL only
            // if it isn't already absolute, same as every other image
            // field in this app (e.g. chalet_card.dart's
            // `BASE_URL + chalet.image`).
            final rawImage = '${map['image'] ?? ''}';
            if (rawImage.isNotEmpty && !rawImage.startsWith('http')) {
              map['image'] = '$BASE_URL$rawImage';
            }
            return FavoriteItem.fromJson(map);
          }).toList();
        }
      }
    } catch (e) {
      // A failed favorites fetch shouldn't crash the favorites tab — just
      // show empty/whatever was already loaded — but still log it (unlike
      // the old bare `catch (_) {}` here, which is exactly why the
      // GetFavorite/GetFavorites URL typo bug was invisible for so long).
      debugPrint('[Favorites] getAll() failed: $e');
    }
    return [];
  }

  /// Adds [item] if it isn't already favorited, removes it if it is.
  /// Returns the new state (true = now favorited) so the caller can trust
  /// the server's result instead of just assuming its own optimistic
  /// update was correct. Throws if the call fails, so FavoritesCubit can
  /// roll back its optimistic update.
  Future<bool> toggle(FavoriteItem item) async {
    final token = await casheFile.getUserToken();
    if (token.isEmpty) {
      throw Exception('Login required to favorite');
    }

    // FavoriteItem.id is a Dart String everywhere else in this app (route
    // params, widget keys), but the backend's `id` field is a number — the
    // website's client already sends it as one. Sending a JSON string
    // "12" instead of a number 12 here risks the exact kind of strict
    // model-binding 400 the backend threw earlier for a similar type
    // mismatch on the booking endpoint, so this is deliberately
    // int-converted only at this network boundary, not on FavoriteItem
    // itself (which stays a String everywhere it's already used for
    // navigation).
    final payload = item.toJson();
    payload['id'] = int.tryParse(item.id) ?? item.id;
    payload['type'] = _typeToNum[item.type] ?? 1;
    // Per backend's FavoriteDTO schema, `rating` has no nullable annotation
    // (unlike name/image/price/location) — it's a non-nullable double
    // server-side, so sending JSON null would fail to deserialize. Default
    // to 0, same as any item with no rating yet.
    payload['rating'] = item.rating ?? 0;

    final response = await client
        .post(
          Uri.parse('$BASE_URL$TOGGLE_FAVORITE_URL'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body['status'] == true) {
        return body['message']?['isFavorite'] == true;
      }
    }
    throw Exception('Failed to update favorite');
  }
}
