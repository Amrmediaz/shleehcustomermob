
import 'dart:convert';
import 'dart:math';
import 'package:shleehcustomer/core/network/keys.dart';
import 'package:shleehcustomer/core/network/urls.dart';
import 'package:shleehcustomer/core/util/cashed_data/cashed_file.dart';
import 'package:shleehcustomer/core/util/common_functions.dart';
import 'package:shleehcustomer/features/authentication/login/data/models/user_logon_model.dart';
import 'package:shleehcustomer/features/authentication/register/data/models/UserRegisterModel.dart';
import 'package:shleehcustomer/features/authentication/register/data/models/register_user_model_response.dart';
import 'package:shleehcustomer/features/authentication/register/domain/entities/UserRegister.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/error/exceptions.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../../login/data/models/user_profile.dart';
abstract class RegisterDataSource {
  Future<Unit> register(UserRegisterModel userRegisterModel);
  Future<Unit> sendOtp(String phoneNumber);
  Future<Unit> verifyOtp(String phoneNumber, String otpCode);
  Future<Unit> checkUser(String phoneNumber);


}

class RegisterDataSourceImp implements RegisterDataSource {
  final http.Client client;
  RegisterDataSourceImp({required this.client});
  @override
  Future<Unit> register(UserRegisterModel userRegisterModel) async {
    // return Future.value(unit);

    final response = await client.post(
        Uri.parse( (IS_STATGING ? BASE_URL_STAGGING : BASE_URL) + Register_URL),
        body: jsonEncode(userRegisterModel.toJson()),  headers: {"Content-Type": "application/json"}
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedJson = json.decode(response.body);
      await saveUserTokenData(decodedJson);
      return Future.value(unit);
    } else {
      print(response.body);
      throw AuthenticationException();
    }
  }
  late SharedPreferences sharedPreferences;
  var casheFile =  CasheFile();
  Future saveUserTokenData(Map<String,dynamic> decodedJson ) async{
    sharedPreferences = await SharedPreferences.getInstance();
    final RegisterUserModelResponse registerUserModelResponse = RegisterUserModelResponse.fromJson(decodedJson);
    sharedPreferences.setString(USER_TOKEN, registerUserModelResponse.token);
    sharedPreferences.setString(USER_TOKEN_EXPIRE, registerUserModelResponse.expaire);
    await casheFile.setLogin(true);
    await getUserData(registerUserModelResponse.token);

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

  @override
  Future<Unit> sendOtp(String phoneNumber) async {
   // return Future.value(unit);

    var otp = "${getGeneratedOtp(length: 4)}";
    await CasheFile().setTempOtp(otp);
    //return Future.value(unit);
    final body = {
      "phone": phoneNumber,
      "message": "Your otp code is $otp",
      "token": "AVUD00KF14BD76DUDB",

    };
    print(otp);

    final response = await client.post(
        Uri.parse( (IS_STATGING ? BASE_URL_STAGGING : BASE_URL) + SEND_OTP_URL),
        body: jsonEncode(body),  headers: {"Content-Type": "application/json"}
    );

    if (response.statusCode == 200) {

      return Future.value(unit);
    } else {
      throw AuthenticationException();
    }
  }
  int getGeneratedOtp({required int length}) {
    final random = Random();
    // Calculate the upper bound based on the desired length
    final upperBound = pow(10, length).toInt() - 1;
    return random.nextInt(upperBound);
  }

  @override
  Future<Unit> verifyOtp(String phoneNumber, String otpCode) async {

    var otpSaved = await CasheFile().getTempOtp();
    print(otpCode);
    if (otpSaved == otpCode){
      return Future.value(unit);
    } else {
      throw OtpException();
    }
  }

  @override
  Future<Unit> checkUser(String phoneNumber) async{

    final body = {
      "email": phoneNumber,
    };
    final response = await client.post(
        Uri.parse((IS_STATGING ? BASE_URL_STAGGING : BASE_URL) + CHECK_USER_EXISTED),
        body: jsonEncode(body), headers: {"Content-Type": "application/json"}
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedJson = json.decode(response.body);
      if (decodedJson["message"] != "Data Used") {
        return Future.value(unit);
      } else {
        print(response.body);
        throw UserExistedException();
      }
    } else {
      throw UserExistedException();
    }
  }}