import 'dart:convert';

import 'package:shleehcustomer/core/network/urls.dart';
import '../../../../../core/error/exceptions.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
abstract class ResetPasswordDataSource {
  Future<Unit> resetPassword(String phoneNumber);
}


class ResetPasswordDataSourceImpl implements ResetPasswordDataSource {
  final http.Client client;
  ResetPasswordDataSourceImpl({required this.client});
  @override
  Future<Unit> resetPassword(String phoneNumber) async {
    final body = {
      "email": phoneNumber,
    };
    print(body);
    final response = await client.post(
        Uri.parse( (IS_STATGING ? BASE_URL_STAGGING : BASE_URL) + RESET_PASSWORD_URL),

      body: jsonEncode(body),  headers: {"Content-Type": "application/json"}
    );
    print(response.body);
    if (response.statusCode == 200) {
      return Future.value(unit);
    } else {
      throw ResetPasswordException();
    }
  }

}