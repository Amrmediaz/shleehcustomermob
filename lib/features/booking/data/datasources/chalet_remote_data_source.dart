import 'dart:convert';

import 'package:shleehcustomer/core/network/urls.dart';
import 'package:shleehcustomer/core/util/cashed_data/cashed_file.dart';
import 'package:shleehcustomer/features/chalets/domain/entities/chalet_details_model.dart';

import '../../../../core/error/exceptions.dart';
import '../models/booking_details.dart';
import '../models/booking_model.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

abstract class BookingRemoteDataSource {
  Future<List<BookingModel>> getBookings(
      {required int pageNum, required int pageSize});
  Future<BookingDetailsModel> getBookingById({required int id});
  Future<double> getBookingDates({required dynamic dates});
  Future<int> bookChalet({required dynamic bookingData});
  Future<String> bookPayment({required dynamic paymentData});
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final http.Client client;
  var casheFile = CasheFile();
  BookingRemoteDataSourceImpl({required this.client});

  @override
  Future<BookingDetailsModel> getBookingById({required int id}) async {
    var token = await CasheFile().getUserToken();

    final response = await client.get(
      Uri.parse(IS_STATGING
          ? BASE_URL_STAGGING
          : "$BASE_URL$BOOKING_DETAILS_URL?bookingID=$id"),
      headers: {"Content-Type": "application/json" , "Authorization" : "Bearer $token"},

    );
    print(response.body);
    if (response.statusCode == 200) {

      final Map<String, dynamic> responseBody = json.decode(response.body);

      final Map<String, dynamic> results = responseBody["message"];

      final BookingDetailsModel decodedJson =
          BookingDetailsModel.fromJson(results);

      return decodedJson;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<BookingModel>> getBookings(
      {required int pageNum, required int pageSize}) async {
    var token = await CasheFile().getUserToken();

    var body = {"page": pageNum, "pageSize": pageSize};
    final response = await client.post(
      Uri.parse(IS_STATGING ? BASE_URL_STAGGING : BASE_URL + BOOKINGS_URL),
      body: jsonEncode(body),
      headers: {"Content-Type": "application/json" , "Authorization" : "Bearer $token"},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {

      final List decodedJson =
          json.decode(response.body)["message"]["results"] as List;
      final List<BookingModel> bookingModel = decodedJson
          .map<BookingModel>(
              (jsonPostModel) => BookingModel.fromJson(jsonPostModel))
          .toList();

      return bookingModel;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<double> getBookingDates({required dynamic dates}) async {
    print(dates);
    final response = await client.post(
      Uri.parse(IS_STATGING
          ? BASE_URL_STAGGING
          : BASE_URL + CALCULATE_BOOKING_PRICE_URL),
      body: dates,
      headers: {"Content-Type": "application/json"},
    );
    print(response.body);
    if (response.statusCode == 200) {
      print(response.body);
      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (responseBody["status"] == true) {
        print(responseBody["message"]["total"] as int);
        return double.parse("${responseBody["message"]["total"]}");
      } else {
        throw ServerException();
      }
    } else {
      throw ServerException();
    }
  }

  @override
  Future<int> bookChalet({required bookingData}) async {
    var userToken = await casheFile.getUserToken();
    print("bookingDatazxxzcxzc");
    final response = await client.post(
      Uri.parse(
          IS_STATGING ? BASE_URL_STAGGING : BASE_URL + CHALET_BOOKING_URL),
      body: jsonEncode(bookingData),
      headers: {
    "Content-Type": "application/json",
        "Authorization": "Bearer $userToken"
      },
    );
    print(response.body);
    if (response.statusCode == 200) {

      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (responseBody["status"] == true) {

        return responseBody["message"]["id"] ?? 0 ;

      } else {
        throw ServerException();
      }
    } else {
      throw ServerException();
    }
  }

  @override
  Future<String> bookPayment({required paymentData}) async {
    var userToken = await casheFile.getUserToken();
    print(userToken);
    final response = await client.post(
      Uri.parse(
          IS_STATGING ? BASE_URL_STAGGING : BASE_URL + PAYMENT_BOOKING_URL),
      body: jsonEncode(paymentData),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $userToken"
      },
    );

    if (response.statusCode == 200) {
      print(response.body);
      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (responseBody["status"] == true) {
        return responseBody["message"] as String;
      } else {
        throw ServerException();
      }
    } else {
      throw ServerException();
    }
  }
}
