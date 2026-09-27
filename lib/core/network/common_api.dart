import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shleehcustomer/core/network/urls.dart';

class CommonApi {
  Future<List<String>> getBookedDates(int buildingId , bool isChalet) async {
    final response = await http.post(
        Uri.parse(BASE_URL + (isChalet ? BOOKED_DAYS_CHALETS_URL : BOOKED_DAYS_BUILDINGS_URL)),
        headers: {"Content-Type": "application/json"},

        body: jsonEncode({"buildingId": buildingId})).timeout(const Duration(seconds: 20));
     print(response.body);
    if (response.statusCode == 200) {
      // Parse the JSON response
      final jsonResponse = json.decode(response.body);
      // Extract and return the list of dates
      return List<String>.from(jsonResponse['message']);
    } else {
      throw Exception('Failed to load dates');
    }
  }
}
