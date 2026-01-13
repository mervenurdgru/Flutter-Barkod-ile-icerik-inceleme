import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProductService {
  //final String baseUrl = "http://172.20.10.2:5000/api";
  final String baseUrl = "http://192.168.1.13:5000/api";

  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>?> getProduct(String barcode) async {
    try {
      final response = await _dio.get('$baseUrl/products/$barcode');
      if (response.statusCode == 200) {
        return response.data['urun'];
      }
      return null;
    } catch (e) {
      print("Ürün getirme hatası: $e");
      return null;
    }
  }

  Future<void> addToHistory(int productId, String barcode) async {
    try {
      String? token = await _storage.read(key: 'auth_token');
      if (token == null) return;

      await _dio.post(
        '$baseUrl/users/history/add',
        data: {'ProductID': productId, 'Barkod': barcode},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      print("Geçmişe ekleme hatası: $e");
    }
  }

  Future<List<dynamic>> getHistory() async {
    try {
      String? token = await _storage.read(key: 'auth_token');
      if (token == null) return [];

      final response = await _dio.get(
        '$baseUrl/users/history',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      print("Geçmiş hatası: $e");
      return [];
    }
  }

  Future<List<dynamic>> getFavorites() async {
    try {
      String? token = await _storage.read(key: 'auth_token');
      if (token == null) return [];

      final response = await _dio.get(
        '$baseUrl/users/favorites',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      print("Favori getirme hatası: $e");
      return [];
    }
  }

  Future<bool> toggleFavorite(int productId, bool isCurrentlyFavorite) async {
    try {
      String? token = await _storage.read(key: 'auth_token');
      if (token == null) return false;

      final endpoint = isCurrentlyFavorite ? 'remove' : 'add';

      final response = await _dio.post(
        '$baseUrl/users/favorites/$endpoint',
        data: {'ProductID': productId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Favori işlem hatası: $e");
      return false;
    }
  }
}
