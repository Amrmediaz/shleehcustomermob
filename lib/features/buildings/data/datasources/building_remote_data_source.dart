import 'dart:convert';

import 'package:shleehcustomer/core/network/urls.dart';
import 'package:shleehcustomer/features/buildings/data/models/flat_model.dart';

import '../models/building_details.dart';

import '../../../../core/error/exceptions.dart';
import '../models/building_map_model.dart';
import '../models/building_model.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../models/flat_Response.dart';

abstract class BuildingRemoteDataSource {
  Future<List<BuildingModel>> getBuildings({dynamic body});
  Future<BuildingDetailsModel> getBuildingById({required int id});
  Future<List<BuildingMapModel>> getBuildingsMap();
  Future<FlatsResponse> getFlatsByBuildingId(dynamic body);

}

class BuildingsRemoteDataSourceImpl implements BuildingRemoteDataSource {
  final http.Client client;

  BuildingsRemoteDataSourceImpl({required this.client});

  @override
  Future<List<BuildingModel>> getBuildings({dynamic body}) async {
    // This runs on every list load and pagination scroll — was printing
    // the full request + response body on every call (real CPU/logcat
    // overhead in both debug and release), trimmed to just error paths.
    Uri uri = Uri.parse(
        IS_STATGING
            ? BASE_URL_STAGGING
            : BASE_URL + (
            body.containsKey("serviesList")
                ? BUILDINGS_FILTER_URL
                : body.containsKey("startDate")
                ? BUILDINGS_FILTER_DATE_URL
                : BUILDINGS_URL
        )
    );
    final response = await client.post(
      uri,
      body: jsonEncode(body),
      headers: {"Content-Type": "application/json"},
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final List decodedJson =
          json.decode(response.body)["message"]["results"] as List;
      final List<BuildingModel> BuildingModels = decodedJson
          .map<BuildingModel>(
              (jsonPostModel) => BuildingModel.fromJson(jsonPostModel))
          .toList();
      return BuildingModels;
    } else {
      print('❌ getBuildings: HTTP ${response.statusCode}');
      throw ServerException();
    }
  }

  @override
  Future<BuildingDetailsModel> getBuildingById({required int id}) async {
    final response = await client.get(
      Uri.parse(
          IS_STATGING ? BASE_URL_STAGGING : "$BASE_URL$BUILDING_DETAILS_URL$id"),
      headers: {"Content-Type": "application/json"},
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      final Map<String, dynamic> results = responseBody["message"];

      final BuildingDetailsModel decodedJson =
          BuildingDetailsModel.fromJson(results);

      return decodedJson;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<BuildingMapModel>> getBuildingsMap() async {
    final response = await client.get(
      Uri.parse(IS_STATGING ? BASE_URL_STAGGING : BASE_URL + BUILDINGS_MAP_URL),
      headers: {"Content-Type": "application/json"},
    ).timeout(const Duration(seconds: 20));
    if (response.statusCode == 200) {
      final List decodedJson = json.decode(response.body)["message"] as List;
      final List<BuildingMapModel> BuildingModels = decodedJson
          .map<BuildingMapModel>(
              (jsonBuildingsModel) => BuildingMapModel.fromJson(jsonBuildingsModel))
          .toList();

      return BuildingModels;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<FlatsResponse> getFlatsByBuildingId(dynamic body) async {
    // NOTE: this used to be `print(id);` — `id` isn't a parameter or field
    // anywhere in this class/method, so that line referenced an undefined
    // identifier. Removed (along with the other per-call debug dumps of
    // the full request/response body, which also run on every pagination
    // scroll and add real overhead).
    Uri uri = Uri.parse(
        IS_STATGING
            ? BASE_URL_STAGGING
            : BASE_URL + FLAT_URL
    );

    final response = await client.post(
      uri,
      body: jsonEncode(body),
      headers: {"Content-Type": "application/json"},
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedJson = json.decode(response.body);
      final Map<String, dynamic> messageData = decodedJson["message"] as Map<String, dynamic>;

      // Create FlatsResponse with pagination info
      final flatsResponse = FlatsResponse.fromJson(messageData);

      // Convert results to FlatModel objects
      final List<FlatModel> flatModels = (flatsResponse.results as List)
          .map<FlatModel>((item) => FlatModel.fromJson(item as Map<String, dynamic>))
          .toList();

      // Return response with models
      return FlatsResponse(
        results: flatModels,
        currentPage: flatsResponse.currentPage,
        pageCount: flatsResponse.pageCount,
        rowCount: flatsResponse.rowCount,
        pageSize: flatsResponse.pageSize,
      );
    } else {
      throw ServerException();
    }
  }
}
