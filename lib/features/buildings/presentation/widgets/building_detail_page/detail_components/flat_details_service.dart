import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../data/models/flat_details.dart';

/// Thin service around GET /api/FlatsCustomer/GetFlatData.
///
/// NOTE: this project already has `CommonApi` in
/// `core/network/common_api.dart` handling networking elsewhere (auth
/// headers, base URL, error interceptors, etc.). If that class exposes a
/// shared http client / base request method, move the call below into a
/// method on `CommonApi` instead (e.g. `CommonApi().getFlatDetails(flatId)`)
/// so this feature reuses the same headers/error handling as the rest of
/// the app. Kept standalone here since `common_api.dart`'s contents weren't
/// available to edit directly.
class FlatDetailsService {
  static const String _baseUrl = 'https://shleeh.com/api/FlatsCustomer/GetFlatData';

  Future<FlatDetailsModel> getFlatDetails(int flatId) async {
    final uri = Uri.parse('$_baseUrl?FlatId=$flatId');
    final response = await http.get(uri).timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Failed to load flat details (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final bool status = decoded['status'] ?? false;
    if (!status || decoded['message'] == null) {
      throw Exception('Flat details request returned no data');
    }

    return FlatDetailsModel.fromJson(decoded['message'] as Map<String, dynamic>);
  }
}