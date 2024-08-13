import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shleehcustomer/core/network/keys.dart';
import 'package:shleehcustomer/features/authentication/login/data/models/user_profile.dart';
import '../../../features/authentication/login/presentation/pages/login_page.dart';
import '../Constants.dart';

class CasheFile {
  static bool staticValue = true;
  static bool isLoginUser = false;
  static bool isTablet = false;

  late SharedPreferences prefs;
  CasheFile() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> setAppLaunched() async {
    await _initPrefs();
    await prefs.setBool(APP_LAUNCHED, true);
  }
  Future<bool> isAppLaunched() async {
    await _initPrefs();
    if (prefs.containsKey(APP_LAUNCHED)) {
      return prefs.getBool(APP_LAUNCHED) ?? false;
    } else {
      return false;
    }
  }
  Future<void> setTempOtp(String otp) async {
    await _initPrefs();
    await prefs.setString(OTP, otp);
  }
  Future<String> getTempOtp() async {
    await _initPrefs();
    if (prefs.containsKey(OTP)) {
      return prefs.getString(OTP) ?? "";
    } else {
      return "";
    }
  }
  Future<String> getUserToken() async {
    await _initPrefs();
    if (prefs.containsKey(USER_TOKEN)) {
      return prefs.getString(USER_TOKEN) ?? "";
    } else {
      return "";
    }
  }
  Future<String> getUserTokenExpireDate() async {
    await _initPrefs();
    if (prefs.containsKey(USER_TOKEN_EXPIRE)) {
      return prefs.getString(USER_TOKEN_EXPIRE) ?? "";
    } else {
      return "";
    }
  }
  Future<void> setLogin(bool isLogined) async {
    await _initPrefs();
    isLoginUser = isLogined;
    await prefs.setBool(IS_LOGIN, isLogined);
  }
  Future<void> setLogout(BuildContext context) async {

    Navigator.of(context, rootNavigator: true)
        .pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const LoginPage();
        },
      ),
          (_) => false,
    );
    await _initPrefs();
    isLoginUser = false;
    await prefs.setBool(IS_LOGIN, false);
    await prefs.remove(USER_TOKEN);
  }
  Future<bool> isLogin() async {
    await _initPrefs();
    if (prefs.containsKey(IS_LOGIN)) {
      isLoginUser = prefs.getBool(IS_LOGIN) ?? false;
      return isLoginUser;
    } else {
      isLoginUser = false;
      return isLoginUser;
    }
  }
  static Future<void> saveUser(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(user.toJson());
    await prefs.setString(USER_PROFILE, userJson);
  }
  static Future<UserProfile?> loadUser() async {
    print("okkk");
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(USER_PROFILE);
    if (userJson != null) {
      Map<String, dynamic> userMap = jsonDecode(userJson);
      return UserProfile.fromJson(userMap);
    }
    return null;
  }
  Future<void> savePhoneForRegisterTemp(String phoneNumber) async {
    await _initPrefs();
    await prefs.setString(PHONE_NUMBER, phoneNumber);
  }
  Future<String> getPhoneForRegisterTemp() async {
    await _initPrefs();
    if (prefs.containsKey(PHONE_NUMBER)){
      return prefs.getString(PHONE_NUMBER) ?? "";
    } else {
      return "";
    }
  }



}
