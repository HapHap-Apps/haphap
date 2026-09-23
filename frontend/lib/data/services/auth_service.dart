import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:haphap_fe/core/network/api_client.dart';
import 'package:haphap_fe/data/models/auth_response_model.dart';

class AuthService {
  AuthService._();

  static GoogleSignIn? _googleSignIn;

  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final json = await ApiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(json);
  }

  static Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final json = await ApiClient.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
    });
    return AuthResponse.fromJson(json);
  }

  static Future<String?> signInWithGoogle() async {
    final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID']?.trim();
    if (webClientId == null || webClientId.isEmpty) {
      throw const GoogleAuthException(
        'Konfigurasi Google Sign-In belum tersedia. Hubungi pengelola aplikasi.',
      );
    }

    try {
      final googleSignIn = _googleSignIn ??= GoogleSignIn(
        serverClientId: webClientId,
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const GoogleAuthException(
          'Google tidak mengirim token identitas. Periksa konfigurasi OAuth aplikasi.',
        );
      }
      return idToken;
    } on PlatformException catch (error) {
      if (error.code == GoogleSignIn.kSignInCanceledError) return null;

      if (error.code == GoogleSignIn.kNetworkError) {
        throw const GoogleAuthException(
          'Koneksi ke Google gagal. Periksa internet lalu coba lagi.',
        );
      }

      if (error.code == GoogleSignIn.kSignInFailedError) {
        throw const GoogleAuthException(
          'Google Sign-In ditolak oleh konfigurasi aplikasi. Periksa package name, SHA-1, dan Web Client ID.',
        );
      }

      throw const GoogleAuthException(
        'Google Sign-In gagal dimulai. Silakan coba lagi.',
      );
    } on GoogleAuthException {
      rethrow;
    } catch (_) {
      throw const GoogleAuthException(
        'Google Sign-In mengalami kesalahan yang tidak terduga.',
      );
    }
  }
}

class GoogleAuthException implements Exception {
  final String message;

  const GoogleAuthException(this.message);

  @override
  String toString() => message;
}
