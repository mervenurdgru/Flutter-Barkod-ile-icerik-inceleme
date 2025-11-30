import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Emülatör için 10.0.2.2, Port: 5000 (React Native kodundaki gibi)
  final String baseUrl = "http://10.0.2.2:5000/api";

  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Giriş Yapma Fonksiyonu
  Future<String?> login(String username, String password) async {
    try {
      // Backend'in beklediği tam adres: /users/login
      final response = await _dio.post(
        '$baseUrl/users/login',
        data: {
          'KullaniciAdi': username, // Backend bu ismi bekliyor
          'Sifre': password, // Backend bu ismi bekliyor
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        if (token != null) {
          await _storage.write(key: 'auth_token', value: token);
          return null; // Başarılı
        } else {
          return 'Token alınamadı.';
        }
      } else {
        return 'Giriş başarısız.';
      }
    } on DioException catch (e) {
      // Backend'den gelen hata mesajını yakala
      if (e.response != null && e.response!.data != null) {
        return e.response!.data['message'] ??
            'Sunucu hatası: ${e.response!.statusCode}';
      }
      return 'Bağlantı hatası: Lütfen internetinizi veya sunucuyu kontrol edin.';
    } catch (e) {
      return 'Bir hata oluştu: $e';
    }
  }
}
