import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:shleehcustomer/core/network/urls.dart';
import 'package:shleehcustomer/core/util/cashed_data/cashed_file.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import 'package:http/http.dart' as http;

abstract class SettingRemoteDataSource {
  Future<UserModel> getUser();
  Future<Unit> updateUser(dynamic body);
  Future<Unit> deleteUser(dynamic userId);

}

class SettingRemoteDataSourceImpl implements SettingRemoteDataSource {
  final http.Client client;
  var casheFile = CasheFile();

  SettingRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> getUser() async {
    var token = await CasheFile().getUserToken();

    final response = await client.get(
      Uri.parse(IS_STATGING ? BASE_URL_STAGGING : "$BASE_URL$GET_USER_URL"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    ).timeout(const Duration(seconds: 20));
    print(response.statusCode);
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      final Map<String, dynamic> results = responseBody["message"];

      final UserModel decodedJson = UserModel.fromJson(results);

      return decodedJson;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<Unit> updateUser(body) async {
    var token = await CasheFile().getUserToken();
    print(body);
    final response = await client.post(
      Uri.parse(IS_STATGING ? BASE_URL_STAGGING : "$BASE_URL$UPDATE_USER_URL"),
      body: jsonEncode(body),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    ).timeout(const Duration(seconds: 20));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      if (responseBody["status"] == true) {
        return unit;
      } else {
        throw ServerException();
      }
    } else {
      throw ServerException();
    }
  }

  @override
  Future<Unit> deleteUser(userId) async{
    var token = await CasheFile().getUserToken();

    final response = await client.get(
      Uri.parse(IS_STATGING ? BASE_URL_STAGGING : "$BASE_URL$DELETE_USER_URL?ID=$userId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    ).timeout(const Duration(seconds: 20));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      if (responseBody["status"] == true) {
        return unit;
      } else {
        throw ServerException();
      }
    } else {
      throw ServerException();
    }
}}