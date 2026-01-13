import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'admin_product_edit_screen.dart';

class AdminProductListScreen extends StatefulWidget {
  const AdminProductListScreen({super.key});

  @override
  State<AdminProductListScreen> createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  final String baseUrl = "http://192.168.1.13:5000/api";

  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<dynamic> products = [];
  bool isLoading = true;
  String? error;

  Future<String?> _token() => _storage.read(key: 'auth_token');

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final token = await _token();
      if (token == null) {
        setState(() {
          isLoading = false;
          error = "Token yok. Lütfen admin giriş yap.";
        });
        return;
      }

      final response = await _dio.get(
        '$baseUrl/admin/products',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        setState(() {
          products = (data as List<dynamic>);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          error = "Ürünler alınamadı: ${response.statusCode}";
        });
      }
    } on DioException catch (e) {
      setState(() {
        isLoading = false;
        error = e.response?.data?['message'] ?? e.message ?? "Sunucu hatası";
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = "Hata: $e";
      });
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final token = await _token();
      if (token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Token yok. Tekrar giriş yap.")),
        );
        return;
      }

      final response = await _dio.delete(
        '$baseUrl/admin/products/delete/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          products.removeWhere((urun) => urun['id'] == id);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ürün silindi')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Silme başarısız: ${response.statusCode}')),
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? "Sunucu hatası";
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Silme hatası: $msg')));
    }
  }

  Future<void> confirmDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Silme Onayı"),
        content: const Text("Bu ürünü silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sil"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await deleteProduct(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tüm Ürünler"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchProducts),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (error != null)
          ? Center(child: Text(error!))
          : products.isEmpty
          ? const Center(child: Text("Ürün bulunamadı."))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final urun = products[index] as Map<String, dynamic>;
                final int id = urun['id'] as int;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.inventory_2),
                    title: Text((urun['productName'] ?? 'İsimsiz').toString()),
                    subtitle: Text(
                      "ID: $id\nBarkod: ${(urun['barcode'] ?? '-').toString()}\nAçıklama: ${(urun['Description'] ?? '-').toString()}",
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AdminProductEditScreen(product: urun),
                              ),
                            );
                            if (updated == true) await fetchProducts();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => confirmDelete(id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
