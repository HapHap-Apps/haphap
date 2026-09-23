import 'package:haphap_fe/core/network/api_client.dart';
import 'package:haphap_fe/data/models/user_profile_model.dart';

class UserService {
  UserService._();

  static Future<UserProfileModel> getMe() async {
    try {
      final json = await ApiClient.get('/users/me');
      return UserProfileModel.fromJson(json['data'] ?? json);
    } catch (e) {
      throw Exception('Gagal mengambil data profil: $e');
    }
  }

  static Future<Map<String, dynamic>> updateMe({
    String? name,
    String? email,
    String? phone,
    String? avatarPath,
  }) async {
    final fields = <String, String>{
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
    };
    final json = await ApiClient.multipartPatch(
      '/users/me',
      fields: fields,
      filePath: avatarPath,
      fileFieldName: 'avatar',
    );
    return json['data'] as Map<String, dynamic>? ?? {};
  }
}
