import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminReportListScreen extends StatefulWidget {
  const AdminReportListScreen({super.key});

  @override
  State<AdminReportListScreen> createState() => _AdminReportListScreenState();
}

class _AdminReportListScreenState extends State<AdminReportListScreen> {
  final String baseUrl = "http://192.168.1.13:5000/api";

  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<dynamic> reports = [];
  bool isLoading = true;
  String? error;

  Future<String?> _token() => _storage.read(key: 'auth_token');

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
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
        '$baseUrl/admin/reports',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        setState(() {
          reports = (data as List<dynamic>);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          error = "Raporlar alınamadı: ${response.statusCode}";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tüm Raporlar"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchReports),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (error != null)
          ? Center(child: Text(error!))
          : reports.isEmpty
          ? const Center(child: Text("Hiç rapor bulunamadı."))
          : ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final rapor = reports[index] as Map<String, dynamic>;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 10,
                  ),
                  child: ListTile(
                    title: Text((rapor['Aciklama'] ?? '').toString()),
                    subtitle: Text(
                      "Kullanıcı: ${(rapor['KullaniciAdi'] ?? '-').toString()}\n"
                      "Ürün: ${(rapor['ProductName'] ?? '-').toString()}\n"
                      "Durum: ${(rapor['Durum'] ?? '-').toString()} • Tarih: ${(rapor['Tarih'] ?? '-').toString()}",
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
