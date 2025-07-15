import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Utility for robust HTTP communication with retries, environment, error decoding.
class NetworkHelper {
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(milliseconds: 800);

  // PUBLIC_INTERFACE
  static Future<http.Response> sendRequest(
    String path, {
    String method = 'GET',
    Map<String, String>? headers,
    dynamic body, // for POST/PUT
    bool authenticated = false,
    String? token,
  }) async {
    final String? baseUrl = dotenv.env['BACKEND_BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('API base URL not set in environment');
    }
    final uri = Uri.parse('$baseUrl$path');
    http.Response response;
    int attempt = 0;

    while (true) {
      try {
        attempt += 1;
        final allHeaders = <String, String>{
          ...?headers,
        };
        if (authenticated && token != null) {
          allHeaders['Authorization'] = 'Bearer $token';
        }
        switch (method.toUpperCase()) {
          case 'GET':
            response = await http.get(uri, headers: allHeaders);
            break;
          case 'POST':
            response = await http.post(uri, headers: allHeaders, body: body);
            break;
          case 'PUT':
            response = await http.put(uri, headers: allHeaders, body: body);
            break;
          case 'DELETE':
            response = await http.delete(uri, headers: allHeaders);
            break;
          default:
            throw Exception('HTTP method $method not supported');
        }

        // Success or handled error
        return response;
      } on SocketException catch (_) {
        if (attempt < _maxRetries) {
          await Future.delayed(_retryDelay);
          continue;
        }
        rethrow;
      } on http.ClientException catch (_) {
        if (attempt < _maxRetries) {
          await Future.delayed(_retryDelay);
          continue;
        }
        rethrow;
      }
    }
  }

  // PUBLIC_INTERFACE
  static String extractApiError(dynamic response) {
    if (response == null) return "Unknown error";
    try {
      final dynamic data = response is String ? jsonDecode(response) : response;
      if (data is Map && data.containsKey('detail')) {
        return data['detail'].toString();
      } else if (data is Map && data.containsKey('message')) {
        return data['message'].toString();
      } else {
        return data.toString();
      }
    } catch (_) {
      return response.toString();
    }
  }
}
