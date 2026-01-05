import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _client = http.Client();

  // ===========================================================================
  // METHOD GET (Signature Teman, Logic Aman Punya Anda)
  // ===========================================================================
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

    return _handleResponse(response);
  }

  // ===========================================================================
  // METHOD POST (Signature Teman, Logic Aman Punya Anda)
  // Penting: Tetap pakai parameter {headers} agar kode teman Anda tidak error
  // ===========================================================================
  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers, 
  }) async {
    final response = await _client.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // ===========================================================================
  // METHOD DELETE (Signature Teman, Logic Aman Punya Anda)
  // ===========================================================================
  Future<Map<String, dynamic>> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    final response = await _client.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
    );

    return _handleResponse(response);
  }

  // ===========================================================================
  // METHOD PUT MULTIPART (Tambahan dari File Anda)
  // ===========================================================================
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

    return _handleResponse(response);
  }

  // ===========================================================================
  // HELPER (Logic Response Handling dari File Anda)
  // Digunakan oleh semua fungsi di atas agar kode lebih rapi & aman
  // ===========================================================================
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Logic Anda: Cek body tidak kosong dan content-type json
      if (response.body.isNotEmpty) {
        // Coba decode, jika gagal return empty (untuk handle kasus sukses tapi bukan json)
        try {
           return jsonDecode(response.body);
        } catch (e) {
           return {}; 
        }
      }
      return {};
    } else {
      // Logic Anda: Error handling dengan try-catch yang lebih aman
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Unknown error');
      } catch (e) {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    }
  }
}