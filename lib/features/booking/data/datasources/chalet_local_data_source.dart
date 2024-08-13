import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
// import '../../../posts/data/datasources/post_local_data_source.dart';
import '../models/booking_model.dart';

// abstract class ChaletLocalDataSource {
//   Future<List<ChaletModel>> getCachedChalets();
//   Future<Unit> cacheChalets(List<ChaletModel> postModels);
// }
//
//
//
// class ChaletLocalDataSourceImpl implements ChaletLocalDataSource {
//   final SharedPreferences sharedPreferences;
//
//   ChaletLocalDataSourceImpl({required this.sharedPreferences});
//   @override
//   Future<Unit> cacheChalets(List<ChaletModel> chaletModel) {
//     List chaletModelsToJson = chaletModel
//         .map<Map<String, dynamic>>((chaletModel) => chaletModel.toJson())
//         .toList();
//     sharedPreferences.setString(CACHED_POSTS, json.encode(chaletModelsToJson));
//     return Future.value(unit);
//   }
//
//   @override
//   Future<List<ChaletModel>> getCachedChalets() {
//     final jsonString = sharedPreferences.getString(CACHED_POSTS);
//     if (jsonString != null) {
//       List decodeJsonData = json.decode(jsonString);
//       List<ChaletModel> jsonChaletModel = decodeJsonData
//           .map<ChaletModel>((jsonChaletModel) => ChaletModel.fromJson(jsonChaletModel))
//           .toList();
//       return Future.value(jsonChaletModel);
//     } else {
//       throw EmptyCacheException();
//     }
//   }
// }
