import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:haphap_fe/core/network/token_manager.dart';

class ApiClient {
  ApiClient._();

  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3000/api';

  static Future<Map<String, String>> get _headers async {
    final token = await TokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');

    try {
      final response = await http.get(uri, headers: await _headers);
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message:
            'Tidak dapat terhubung ke server. Periksa koneksi internet kamu.',
        statusCode: 0,
      );
    }
  }

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$path');

    try {
      final response = await http.post(
        uri,
        headers: await _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message:
            'Tidak dapat terhubung ke server. Periksa koneksi internet kamu.',
        statusCode: 0,
      );
    }
  }

  static Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$path');

    try {
      final response = await http.patch(
        uri,
        headers: await _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message:
            'Tidak dapat terhubung ke server. Periksa koneksi internet kamu.',
        statusCode: 0,
      );
    }
  }

  static Future<Map<String, dynamic>> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');

    try {
      final response = await http.delete(uri, headers: await _headers);
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message:
            'Tidak dapat terhubung ke server. Periksa koneksi internet kamu.',
        statusCode: 0,
      );
    }
  }

  static Future<Map<String, dynamic>> multipartPost(
    String path, {
    required Map<String, String> fields,
    String? filePath,
    String fileFieldName = 'image',
  }) async {
    return _multipartRequest('POST', path, fields: fields, filePath: filePath, fileFieldName: fileFieldName);
  }

  static Future<Map<String, dynamic>> multipartPatch(
    String path, {
    required Map<String, String> fields,
    String? filePath,
    String fileFieldName = 'avatar',
  }) async {
    return _multipartRequest('PATCH', path, fields: fields, filePath: filePath, fileFieldName: fileFieldName);
  }

  static Future<Map<String, dynamic>> _multipartRequest(
    String method,
    String path, {
    required Map<String, String> fields,
    String? filePath,
    String fileFieldName = 'image',
  }) async {
    final uri = Uri.parse('$baseUrl$path');

    try {
      final request = http.MultipartRequest(method, uri);

      final token = await TokenManager.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields.addAll(fields);

      if (filePath != null && filePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            fileFieldName,
            filePath,
            contentType: getMediaTypeFromPath(filePath),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Tidak dapat mengirim data. Periksa koneksi internet kamu.',
        statusCode: 0,
      );
    }
  }

  static MediaType getMediaTypeFromPath(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    const mimeMap = <String, String>{
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'webp': 'image/webp',
      'gif': 'image/gif',
      'heic': 'image/heic',
      'heif': 'image/heif',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    };
    return MediaType.parse(mimeMap[ext] ?? 'image/jpeg');
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    debugPrint('RAW RESPONSE: ${response.body}');
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final message =
        decoded['message'] ?? 'Terjadi kesalahan pada server.';
    throw ApiException(
      message: message.toString(),
      statusCode: response.statusCode,
    );
  }

}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
