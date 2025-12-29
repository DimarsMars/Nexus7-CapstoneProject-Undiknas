import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> post(String url, Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Unknown error');
    }
  }
Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final response = await _client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Unknown error');
    }
  }
  Future<Map<String, dynamic>> putMultipart(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    http.MultipartFile? file,
  }) async {
    final request = http.MultipartRequest('PUT', Uri.parse(url));

    if (headers != null) {
      request.headers.addAll(headers);
    }
    if (fields != null) {
      request.fields.addAll(fields);
    }
    if (file != null) {
      request.files.add(file);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty && response.headers['content-type']?.contains('application/json') == true) {
        return jsonDecode(response.body);
      }
      return {};
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Unknown error');
      } catch (e) {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    }
  }
}

