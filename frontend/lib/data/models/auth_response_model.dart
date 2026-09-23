
class AuthResponse {
  final bool success;
  final int statusCode;
  final String message;
  final AuthData? data;

  const AuthResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? AuthData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AuthData {
  final String? token;
  final String? userId;
  final String? email;
  final String? name;
  final String? role;

  const AuthData({
    this.token,
    this.userId,
    this.email,
    this.name,
    this.role,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['accessToken'] as String?,
      userId: json['userId'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      role: json['role'] as String?,
    );
  }
}
