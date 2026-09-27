import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shleehcustomer/features/buildings/data/models/building_model.dart';

import '../../../../core/error/exceptions.dart';

abstract class BuildingLocalDataSource {
  Future<List<BuildingModel>> getCachedBuildings();
  Future<Unit> cacheBuildings(List<BuildingModel> postModels);
}

const CACHED_BuildingS = "CACHED_BuildingS";

class BuildingLocalDataSourceImpl implements BuildingLocalDataSource {
  final SharedPreferences sharedPreferences;

  BuildingLocalDataSourceImpl({required this.sharedPreferences});
  @override
  Future<Unit> cacheBuildings(List<BuildingModel> Buildings) {
    List BuildingsetsModelsToJson = Buildings
        .map<Map<String, dynamic>>((Buildings) => Buildings.toJson())
        .toList();
    sharedPreferences.setString(CACHED_BuildingS, json.encode(BuildingsetsModelsToJson));
    return Future.value(unit);
  }

  @override
  Future<List<BuildingModel>> getCachedBuildings() {
    final jsonString = sharedPreferences.getString(CACHED_BuildingS);
    if (jsonString != null) {
      List decodeJsonData = json.decode(jsonString);
      List<BuildingModel> BuildingsetsModelsToJson = decodeJsonData
          .map<BuildingModel>((BuildingsetsModelsToJson) => BuildingModel.fromJson(BuildingsetsModelsToJson))
          .toList();
      return Future.value(BuildingsetsModelsToJson);
    } else {
      throw EmptyCacheException();
    }
  }
}
