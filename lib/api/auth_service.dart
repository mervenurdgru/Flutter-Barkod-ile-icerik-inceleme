import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl = "http://172.20.10.2:5000/api";

  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/users/login',
        data: {'KullaniciAdi': username, 'Sifre': password},
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        if (token != null) {
          await _storage.write(key: 'auth_token', value: token);
          return null;
        } else {
          return 'Token alınamadı.';
        }
      } else {
        return 'Giriş başarısız.';
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        return e.response!.data['message'] ??
            'Sunucu hatası: ${e.response!.statusCode}';
      }
      return 'Bağlantı hatası: Lütfen internetinizi veya sunucuyu kontrol edin.';
    } catch (e) {
      return 'Bir hata oluştu: $e';
    }
  }

  Future<String?> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '$baseUrl/users/register',
        data: {'KullaniciAdi': username, 'Email': email, 'Sifre': password},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.data['token'] != null) {
          await _storage.write(
            key: 'auth_token',
            value: response.data['token'],
          );
          return null;
        }
        return null;
      } else {
        return 'Kayıt başarısız.';
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        return e.response!.data['message'] ?? 'Kayıt hatası';
      }
      return 'Bağlantı hatası.';
    } catch (e) {
      return 'Hata: $e';
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }
}
