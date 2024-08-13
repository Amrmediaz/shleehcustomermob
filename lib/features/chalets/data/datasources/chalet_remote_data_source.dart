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
  Future<List<ChaletModel>> getChalets({dynamic body}) async {
    print(body);
    // var body = {
    //   "page": pageNum,
    //   "pageSize": pageSize,
    //   "heightolow": priceHighToLowFilter,
    //   "rateheightolow": rateHighToLow
    // };
    Uri uri = Uri.parse(
        IS_STATGING
            ? BASE_URL_STAGGING
            : BASE_URL + (
            body.containsKey("serviesList")
                ? CHALETS_FILTER_URL
                : body.containsKey("startDate")
                ? CHALETS_FILTER_DATE_URL
                : CHALETS_URL
        )
    );
    final response = await client.post(
      uri,
      body: jsonEncode(body),
      headers: {"Content-Type": "application/json"},
    );
    print(jsonEncode(body));

    if (response.statusCode == 200) {
      print(response.body);
      final List decodedJson =
          json.decode(response.body)["message"]["results"] as List;
      final List<ChaletModel> chaletModels = decodedJson
          .map<ChaletModel>(
              (jsonPostModel) => ChaletModel.fromJson(jsonPostModel))
          .toList();
      print(chaletModels.length);
      return chaletModels;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<ChaletDetailsModel> getChaletById({required int id}) async {
    final response = await client.get(
      Uri.parse(
          IS_STATGING ? BASE_URL_STAGGING : "$BASE_URL$CHALET_DETAILS_URL$id"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      final Map<String, dynamic> results = responseBody["message"];
      print(results['buldingService']);

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
    );
    print(response.body);
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
