import 'dart:convert'; // Ensure this is imported
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';

// ApiService class
class ApiService {
  final http.Client client;

  ApiService(this.client);

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await client.post(
      Uri.parse('http://www.shleekjkjkh.com/api/CustomerData/Locccgidn'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 201) {
      print(response.body);
      // Parse the response body
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }
}

// Create a Mock Client

void main() {
  group('ApiService', () {

      test('status == 201', () async {
        final mockClient = MockClient((request) async {
          return Response(json.encode({
          "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NjgwMDAwMDAwMEBnbWFpbC5jb20iLCJqdGkiOiI0NWY3NzcyMC1jNmY1LTRjMzgtOGEzNC02MzMzYmNiYmUyMjgiLCJ1bmlxdWVfbmFtZSI6Ijk2ODAwMDAwMDAwIiwiZXhwIjoxNzIzMDU2ODg4LCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjM2MDI5IiwiYXVkIjoidXNlcnMifQ.f587jqUHfsJVlWlJg2nvAMTLIyCKPnexeL_Mqcz4dBs",
              "expaire": "2024-08-07T18:54:48Z",
              "status": true
          }), 201);
        });
        final service = ApiService(mockClient);
        final actualResponse = await service.login("9680000000", "Abc12345#");
        //
        final expectedResponse = {
          "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5NjgwMDAwMDAwMEBnbWFpbC5jb20iLCJqdGkiOiI0NWY3NzcyMC1jNmY1LTRjMzgtOGEzNC02MzMzYmNiYmUyMjgiLCJ1bmlxdWVfbmFtZSI6Ijk2ODAwMDAwMDAwIiwiZXhwIjoxNzIzMDU2ODg4LCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjM2MDI5IiwiYXVkIjoidXNlcnMifQ.f587jqUHfsJVlWlJg2nvAMTLIyCKPnexeL_Mqcz4dBs",
          "expaire": "2024-08-07T18:54:48Z",
          "status": true
        };
        expect(actualResponse, expectedResponse);



    });

    // test('throws an exception on failed login', () async {
    //   final client = MockClient();
    //   final apiService = ApiService(client);
    //
    //   // Simulate a failed login response
    //   when(client.post(
    //     Uri.parse('http://www.shleeh.com/api/CustomerData/Login'),
    //     headers: {'Content-Type': 'application/json'},
    //     body: json.encode({'username': 'testuser', 'password': 'testpass'}),
    //   )).thenAnswer((_) async => http.Response('{"error": "Invalid credentials"}', 400));
    //
    //   // Act and Assert
    //   expect(() async => await apiService.login('testuser', 'testpass'), throwsException);
    // });
  });
}
