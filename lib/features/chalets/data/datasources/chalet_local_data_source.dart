import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shleehcustomer/features/chalets/data/models/chalet_model.dart';

import '../../../../core/error/exceptions.dart';

abstract class ChaletLocalDataSource {
  Future<List<ChaletModel>> getCachedChalets();
  Future<Unit> cacheChalets(List<ChaletModel> postModels);
}

const CACHED_CHALETS = "CACHED_CHALETS";

class ChaletLocalDataSourceImpl implements ChaletLocalDataSource {
  final SharedPreferences sharedPreferences;

  ChaletLocalDataSourceImpl({required this.sharedPreferences});
  @override
  Future<Unit> cacheChalets(List<ChaletModel> chalets) {
    List chaletsetsModelsToJson = chalets
        .map<Map<String, dynamic>>((chalets) => chalets.toJson())
        .toList();
    sharedPreferences.setString(CACHED_CHALETS, json.encode(chaletsetsModelsToJson));
    return Future.value(unit);
  }

  @override
  Future<List<ChaletModel>> getCachedChalets() {
    final jsonString = sharedPreferences.getString(CACHED_CHALETS);
    if (jsonString != null) {
      List decodeJsonData = json.decode(jsonString);
      List<ChaletModel> chaletsetsModelsToJson = decodeJsonData
          .map<ChaletModel>((chaletsetsModelsToJson) => ChaletModel.fromJson(chaletsetsModelsToJson))
          .toList();
      return Future.value(chaletsetsModelsToJson);
    } else {
      throw EmptyCacheException();
    }
  }
}
