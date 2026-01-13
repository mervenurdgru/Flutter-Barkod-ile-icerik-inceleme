import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminProductAddScreen extends StatefulWidget {
  const AdminProductAddScreen({super.key});

  @override
  State<AdminProductAddScreen> createState() => _AdminProductAddScreenState();
}

class _AdminProductAddScreenState extends State<AdminProductAddScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _icerikCtrl = TextEditingController();
  final _alerjenCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();

  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final String baseUrl = "http://192.168.1.13:5000/api";
  bool loading = false;

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw "Token yok";

      final response = await _dio.post(
        '$baseUrl/admin/products/add',
        data: {
          "productName": _nameCtrl.text.trim(),
          "barcode": _barcodeCtrl.text.trim(),
          "description": _descCtrl.text.trim(),
          "Icindekiler": _icerikCtrl.text.trim(),
          "AlerjenUyarisi": _alerjenCtrl.text.trim(),
          "ImageUrl": _imageCtrl.text.trim(),
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Ürün eklendi")));
        _formKey.currentState!.reset();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: $e")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ürün Ekle")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Ürün Adı"),
                validator: (v) => v!.isEmpty ? "Zorunlu" : null,
              ),
              TextFormField(
                controller: _barcodeCtrl,
                decoration: const InputDecoration(labelText: "Barkod"),
                validator: (v) => v!.isEmpty ? "Zorunlu" : null,
              ),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: "Açıklama"),
              ),
              TextFormField(
                controller: _icerikCtrl,
                decoration: const InputDecoration(labelText: "İçindekiler"),
                maxLines: 3,
              ),
              TextFormField(
                controller: _alerjenCtrl,
                decoration: const InputDecoration(labelText: "Alerjen Uyarısı"),
              ),
              TextFormField(
                controller: _imageCtrl,
                decoration: const InputDecoration(labelText: "Resim URL"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : submit,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Kaydet"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
