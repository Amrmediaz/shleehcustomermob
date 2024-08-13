import 'dart:convert';

import 'package:shleehcustomer/core/network/keys.dart';
import 'package:shleehcustomer/core/network/urls.dart';
import 'package:shleehcustomer/core/util/cashed_data/cashed_file.dart';
import 'package:shleehcustomer/features/authentication/login/data/models/user_logon_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shleehcustomer/features/authentication/login/data/models/user_profile.dart';
import '../../../../../core/error/exceptions.dart';
import '../models/UserLoginResponseModel.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
abstract class LoginDataSource {
  Future<Unit> login(dynamic body);
}


class LoginDataSourceImpl implements LoginDataSource {
  final http.Client client;
  LoginDataSourceImpl({required this.client});
  @override
  Future<Unit> login(dynamic body) async {


    final response = await client.post(
        Uri.parse( (IS_STATGING ? BASE_URL_STAGGING : BASE_URL) + LOGIN_URL),
      body: jsonEncode(body),  headers: {"Content-Type": "application/json"}
    );
      print(body);
    if (response.statusCode == 201) {
      final Map<String, dynamic> decodedJson = json.decode(response.body);
      await saveUserLoginData(decodedJson);
      return Future.value(unit);
    } else {
      throw AuthenticationException();
    }
  }
  late SharedPreferences sharedPreferences;
  Future saveUserLoginData(Map<String,dynamic> decodedJson ) async{
    sharedPreferences = await SharedPreferences.getInstance();
    final UserLoginResponseModel userLoginResponseModel = UserLoginResponseModel.fromJson(decodedJson);
    sharedPreferences.setString(USER_TOKEN, userLoginResponseModel.token);
    await getUserData(userLoginResponseModel.token);
    sharedPreferences.setString(USER_TOKEN_EXPIRE, userLoginResponseModel.expaire);
    await CasheFile().setLogin(true);
  }
  Future<Unit> getUserData(String token) async {

    final response = await client.get(
        Uri.parse( (IS_STATGING ? BASE_URL_STAGGING : BASE_URL) + PROFILE_URL), headers: {"Authorization" :"Bearer $token"}
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedJson = json.decode(response.body);
      if (decodedJson["status"] == true){
        CasheFile.saveUser(UserProfile.fromJson(decodedJson["message"]) );

      } else {
        throw AuthenticationException();
      }

      return Future.value(unit);
    } else {
      throw AuthenticationException();
    }
  }
}