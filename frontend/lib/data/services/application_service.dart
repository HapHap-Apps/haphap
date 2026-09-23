import 'package:haphap_fe/core/network/api_client.dart';
import 'package:haphap_fe/data/models/application_model.dart';
import 'package:http/http.dart' as http;
import 'package:haphap_fe/core/network/token_manager.dart';
import 'dart:convert';

class ApplicationService {
  ApplicationService._();

  static Future<List<ApplicationModel>> fetchAll() async {
    final json = await ApiClient.get('/applications');
    final data = json['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<ApplicationModel>> findMyApplications() async {
    final json = await ApiClient.get('/applications/me');
    final data = json['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> updateStatus(
    String applicationId, {
    required String status,
    String? rejectNote,
  }) async {
    final body = <String, dynamic>{
      'status': status,
      if (rejectNote != null && rejectNote.isNotEmpty) 'rejectNote': rejectNote,
    };
    await ApiClient.patch('/applications/$applicationId/status', body);
  }

  static Future<Map<String, dynamic>> createApplication({
    required Map<String, String> fields,
    required String documentPath,
    String? avatarPath,
  }) async {
    final uri = Uri.parse('${ApiClient.baseUrl}/applications');
    final request = http.MultipartRequest('POST', uri);

    final token = await TokenManager.getToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields.addAll(fields);

    request.files.add(await http.MultipartFile.fromPath(
      'document',
      documentPath,
      contentType: ApiClient.getMediaTypeFromPath(documentPath),
    ));

    if (avatarPath != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'avatar',
        avatarPath,
        contentType: ApiClient.getMediaTypeFromPath(avatarPath),
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded['data'] as Map<String, dynamic>? ?? {};
    }

    throw ApiException(
      message: (decoded['message'] ?? 'Terjadi kesalahan').toString(),
      statusCode: response.statusCode,
    );
  }
}
