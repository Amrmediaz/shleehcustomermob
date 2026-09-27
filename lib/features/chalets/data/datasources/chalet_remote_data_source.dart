import 'dart:convert';

import 'package:shleehcustomer/core/network/urls.dart';
import 'package:shleehcustomer/features/chalets/domain/entities/chalet_details_model.dart';
import 'package:shleehcustomer/features/chalets/domain/entities/chalet_map.dart';

import '../../../../core/error/exceptions.dart';
import '../models/chalet_details.dart';
import '../models/chalet_map_model.dart';
import '../models/chalet_model.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

abstract class ChaletRemoteDataSource {
  Future<List<ChaletModel>> getChalets({dynamic body});
  Future<ChaletDetailsModel> getChaletById({required int id});
  Future<List<ChaletMapModel>> getChaletsMap();
}

class ChaletsRemoteDataSourceImpl implements ChaletRemoteDataSource {
  final http.Client client;

  ChaletsRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ChaletModel>> getChalets({ dynamic body}) async {
    // This runs on every list load AND every infinite-scroll pagination
    // trigger. It previously logged ~20 lines per call, including the full
    // raw response body (easily tens of KB of JSON per page) — real CPU
    // and logcat I/O overhead on every scroll, and it runs in release
    // builds too since print() isn't stripped there. Trimmed to just the
    // error paths, which is all that's actually actionable.
    final baseUrl = IS_STATGING ? BASE_URL_STAGGING : BASE_URL;
    final fullUrl = baseUrl + (body.toString().contains("endDate") ? CHALETS_FILTER_DATE_URL  : (body.toString().contains("serviesList") ? CHALETS_FILTER_URL : CHALETS_FILTER_URL) ) ;
    Uri uri = Uri.parse(fullUrl);

    String requestBody;
    try {
      requestBody = jsonEncode(body);
    } catch (e) {
      print('❌ getChalets: error encoding request body: $e');
      throw ServerException();
    }

    final response = await client.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: requestBody,
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      print('❌ getChalets: HTTP ${response.statusCode}');
      throw ServerException();
    }

    try {
      final Map<String, dynamic> decodedJson = json.decode(response.body);
      final message = decodedJson["message"];
      final List results = message["results"] as List;

      return results
          .map<ChaletModel>((item) => ChaletModel.fromJson(item))
          .toList();
    } catch (e) {
      print('❌ getChalets: error parsing response: $e');
      throw ServerException();
    }
  }
  @override
  Future<ChaletDetailsModel> getChaletById({required int id}) async {
    final response = await client.get(
      Uri.parse(
          IS_STATGING ? BASE_URL_STAGGING : "$BASE_URL$CHALET_DETAILS_URL$id"),
      headers: {"Content-Type": "application/json"},
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      final Map<String, dynamic> results = responseBody["message"];

      final ChaletDetailsModel decodedJson =
          ChaletDetailsModel.fromJson(results);

      return decodedJson;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<ChaletMapModel>> getChaletsMap() async {
    final response = await client.get(
      Uri.parse(IS_STATGING ? BASE_URL_STAGGING : BASE_URL + CHALETS_MAP_URL),
      headers: {"Content-Type": "application/json"},
    ).timeout(const Duration(seconds: 20));
    if (response.statusCode == 200) {
      final List decodedJson = json.decode(response.body)["message"] as List;
      final List<ChaletMapModel> chaletModels = decodedJson
          .map<ChaletMapModel>(
              (jsonChaletsModel) => ChaletMapModel.fromJson(jsonChaletsModel))
          .toList();

      return chaletModels;
    } else {
      throw ServerException();
    }
  }
}
