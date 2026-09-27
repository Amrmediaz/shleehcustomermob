import 'dart:convert';

import 'package:shleehcustomer/core/network/urls.dart';
import 'package:shleehcustomer/core/util/cashed_data/cashed_file.dart';
import 'package:shleehcustomer/features/chalets/domain/entities/chalet_details_model.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/PaginatedBookings.dart';
import '../models/booking_details.dart';
import '../models/booking_model.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

abstract class BookingRemoteDataSource {
  Future<PaginatedBookings> getBookings(
      {required int pageNum, required int pageSize , required bool isChalet});
  Future<BookingDetailsModel> getBookingById({required int id , required bool isChalet});
  Future<double> getBookingDates({required dynamic dates , required bool isChalet});
  Future<int> bookChalet({required dynamic bookingData , required bool isChalet});
  Future<String> bookPayment({required dynamic paymentData ,  required bool isChalet});
  Future<Map<String, dynamic>> bookPaymentQpay({required dynamic paymentData , required bool isChalet});
  Future<String> sendQpayOtp({required dynamic otpData, required bool isChalet});
  Future<dynamic> getQpayCards({required dynamic cardsData, required bool isChalet});
  Future<dynamic> confirmQpay({required dynamic confirmData, required bool isChalet});
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final http.Client client;
  var casheFile = CasheFile();
  BookingRemoteDataSourceImpl({required this.client});

  @override
  Future<BookingDetailsModel> getBookingById({required int id , required bool isChalet}) async {
    var token = await CasheFile().getUserToken();

    final response = await client.get(
      Uri.parse(IS_STATGING
          ? BASE_URL_STAGGING
          : "$BASE_URL${isChalet ? BOOKING_DETAILS_URL  : BOOKING_DETAILS_FLAT_URL}?bookingID=$id"),
      headers: {"Content-Type": "application/json" , "Authorization" : "Bearer $token"},

    ).timeout(const Duration(seconds: 20));
    print(response.body);
    if (response.statusCode == 200) {

      final Map<String, dynamic> responseBody = json.decode(response.body);

      final Map<String, dynamic> results = responseBody["message"];

      final BookingDetailsModel decodedJson =
          BookingDetailsModel.fromJson(results,isChalet);

      return decodedJson;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<PaginatedBookings> getBookings(
      {required int pageNum, required int pageSize, required bool isChalet}) async {
    var token = await CasheFile().getUserToken();
    var body = {"page": pageNum, "pageSize": pageSize};

    final response = await client.post(
      Uri.parse(IS_STATGING ? BASE_URL_STAGGING : BASE_URL + (isChalet ? CHAELTS_BOOKINGS_URL : FLAT_BOOKINGS_URL)),
      body: jsonEncode(body),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final Map<String, dynamic> message = json.decode(response.body)["message"];
      final List results = message["results"] as List;

      final bookings = results
          .map<BookingModel>((j) => BookingModel.fromJson(j, isChalet))
          .toList();

      return PaginatedBookings(
        bookings: bookings,
        currentPage: message["currentPage"] as int,
        pageCount: message["pageCount"] as int,
      );
    } else {
      throw ServerException();
    }
  }

  @override
  Future<double> getBookingDates({required dynamic dates , required bool isChalet}) async {
    print(dates);
    final response = await client.post(
      Uri.parse(IS_STATGING
          ? BASE_URL_STAGGING
          : BASE_URL + (isChalet ? CALCULATE_BOOKING_PRICE_URL : CALCULATE_BOOKING_Building_PRICE_URL)),
      body: dates,
      headers: {"Content-Type": "application/json"},
    ).timeout(const Duration(seconds: 20));
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
  Future<int> bookChalet({required bookingData , required isChalet}) async {
    var userToken = await casheFile.getUserToken();
    print(isChalet ? CHALET_BOOKING_URL : FLAT_BOOKING_URL);
    final response = await client.post(
      Uri.parse(
          IS_STATGING ? BASE_URL_STAGGING : BASE_URL + (isChalet ? CHALET_BOOKING_URL : FLAT_BOOKING_URL)),
      body: jsonEncode(bookingData),
      headers: {
    "Content-Type": "application/json",
        "Authorization": "Bearer $userToken"
      },
    ).timeout(const Duration(seconds: 20));
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
  Future<String> bookPayment({required paymentData , required bool isChalet}) async {
    var userToken = await casheFile.getUserToken();
    print(userToken);

    final response = await client.post(
      Uri.parse(
          IS_STATGING ? BASE_URL_STAGGING : BASE_URL + ( isChalet ? PAYMENT_BOOKING_URL : PAYMENT_BOOKING_FLAT_URL)),
      body: jsonEncode(paymentData),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $userToken"
      },
    ).timeout(const Duration(seconds: 20));
    print(response.body);
    print(   IS_STATGING ? BASE_URL_STAGGING : BASE_URL + ( isChalet ? PAYMENT_BOOKING_URL : PAYMENT_BOOKING_FLAT_URL));
    if (response.statusCode == 200) {

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

  // QPay (installments) phone step — CONFIRMED shape, see urls.dart.
  // Returns the raw { plansList, principalId, paymentNumber } map so the
  // presentation layer can render the real installment plans.
  @override
  Future<Map<String, dynamic>> bookPaymentQpay({required paymentData , required bool isChalet}) async {
    var userToken = await casheFile.getUserToken();

    final response = await client.post(
      Uri.parse(
          IS_STATGING ? BASE_URL_STAGGING : BASE_URL + ( isChalet ? PAYMENT_BOOKING_QPAY_URL : PAYMENT_BOOKING_FLAT_QPAY_URL)),
      body: jsonEncode(paymentData),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $userToken"
      },
    ).timeout(const Duration(seconds: 20));
    if (response.statusCode == 200) {

      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (responseBody["status"] == true) {
        return responseBody["message"] as Map<String, dynamic>;
      } else {
        throw ServerException();
      }
    } else {
      throw ServerException();
    }
  }

  // QPay OTP send/resend — dedicated CustomerData/FlatsCustomer endpoints
  // per booking type (CORRECTED 10 Sep 2026, see urls.dart).
  @override
  Future<String> sendQpayOtp({required otpData, required bool isChalet}) async {
    var userToken = await casheFile.getUserToken();

    final response = await client.post(
      Uri.parse(IS_STATGING ? BASE_URL_STAGGING : BASE_URL + (isChalet ? QPAY_SEND_OTP_URL : QPAY_SEND_OTP_FLAT_URL)),
      body: jsonEncode(otpData),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $userToken"
      },
    ).timeout(const Duration(seconds: 20));
    if (response.statusCode == 200) {

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

  // QPay cards — verifies the OTP and returns the customer's saved QPay
  // cards. Shape of "message" here isn't fully confirmed beyond "a list"
  // (Ahmed only shared the request body), so this is passed through as
  // dynamic and normalized on the presentation side, same caution as the
  // other backend fields with a history of inconsistent shapes.
  @override
  Future<dynamic> getQpayCards({required cardsData, required bool isChalet}) async {
    var userToken = await casheFile.getUserToken();

    final response = await client.post(
      Uri.parse(IS_STATGING ? BASE_URL_STAGGING : BASE_URL + (isChalet ? QPAY_CARDS_URL : QPAY_CARDS_FLAT_URL)),
      body: jsonEncode(cardsData),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $userToken"
      },
    ).timeout(const Duration(seconds: 20));
    if (response.statusCode == 200) {

      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (responseBody["status"] == true) {
        return responseBody["message"];
      } else {
        throw ServerException();
      }
    } else {
      throw ServerException();
    }
  }

  // QPay confirm — the final step that actually charges the selected card.
  @override
  Future<dynamic> confirmQpay({required confirmData, required bool isChalet}) async {
    var userToken = await casheFile.getUserToken();

    final response = await client.post(
      Uri.parse(IS_STATGING ? BASE_URL_STAGGING : BASE_URL + (isChalet ? QPAY_CONFIRM_URL : QPAY_CONFIRM_FLAT_URL)),
      body: jsonEncode(confirmData),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $userToken"
      },
    ).timeout(const Duration(seconds: 20));
    if (response.statusCode == 200) {

      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (responseBody["status"] == true) {
        return responseBody["message"];
      } else {
        throw ServerException();
      }
    } else {
      throw ServerException();
    }
  }
}
