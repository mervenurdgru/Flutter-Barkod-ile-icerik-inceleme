import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminCommentListScreen extends StatefulWidget {
  const AdminCommentListScreen({super.key});

  @override
  State<AdminCommentListScreen> createState() => _AdminCommentListScreenState();
}

class _AdminCommentListScreenState extends State<AdminCommentListScreen> {
  final String baseUrl = "http://192.168.1.13:5000/api";

  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<dynamic> comments = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<String?> _token() => _storage.read(key: 'auth_token');

  Future<void> fetchComments() async {
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
        '$baseUrl/admin/comments',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        setState(() {
          comments = (data as List<dynamic>);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          error = "Yorumlar alınamadı: ${response.statusCode}";
        });
      }
    } on DioException catch (e) {
      setState(() {
        isLoading = false;
        error =
            e.response?.data?['message'] ?? e.message ?? "Sunucu hatası (Dio)";
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = "Hata: $e";
      });
    }
  }

  Future<void> deleteComment(int commentId) async {
    try {
      final token = await _token();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Token yok. Tekrar giriş yap.")),
        );
        return;
      }

      final response = await _dio.delete(
        '$baseUrl/admin/comments/$commentId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        setState(() {
          comments.removeWhere((c) => c['CommentID'] == commentId);
        });
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Yorum silindi")));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Silme hatası: ${response.statusCode}")),
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? "Sunucu hatası";
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Silme hatası: $msg")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Silme hatası: $e")));
    }
  }

  Future<void> confirmDelete(int commentId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Yorumu Sil"),
        content: const Text("Bu yorumu silmek istediğinize emin misiniz?"),
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

    if (result == true) {
      await deleteComment(commentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tüm Yorumlar")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (error != null)
          ? Center(child: Text(error!))
          : comments.isEmpty
          ? const Center(child: Text("Hiç yorum bulunamadı."))
          : ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final yorum = comments[index] as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 10,
                  ),
                  child: ListTile(
                    title: Text((yorum['YorumMetni'] ?? '').toString()),
                    subtitle: Text(
                      "Puan: ${yorum['Puan']}  •  Ürün: ${(yorum['ProductName'] ?? yorum['ProductID']).toString()}",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => confirmDelete(yorum['CommentID'] as int),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
