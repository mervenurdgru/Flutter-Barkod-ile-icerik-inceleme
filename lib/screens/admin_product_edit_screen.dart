import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminProductEditScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const AdminProductEditScreen({super.key, required this.product});

  @override
  State<AdminProductEditScreen> createState() => _AdminProductEditScreenState();
}

class _AdminProductEditScreenState extends State<AdminProductEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameCtrl;
  late TextEditingController barcodeCtrl;
  late TextEditingController descCtrl;
  late TextEditingController icerikCtrl;
  late TextEditingController alerjenCtrl;
  late TextEditingController imageCtrl;

  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String baseUrl = "http://192.168.1.13:5000/api";

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.product['productName']);
    barcodeCtrl = TextEditingController(text: widget.product['barcode']);
    descCtrl = TextEditingController(text: widget.product['Description']);
    icerikCtrl = TextEditingController(text: widget.product['Icindekiler']);
    alerjenCtrl = TextEditingController(text: widget.product['AlerjenUyarisi']);
    imageCtrl = TextEditingController(text: widget.product['ImageUrl']);
  }

  Future<void> update() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw "Token yok";

      await _dio.put(
        '$baseUrl/admin/products/update/${widget.product['id']}',
        data: {
          "productName": nameCtrl.text.trim(),
          "barcode": barcodeCtrl.text.trim(),
          "description": descCtrl.text.trim(),
          "Icindekiler": icerikCtrl.text.trim(),
          "AlerjenUyarisi": alerjenCtrl.text.trim(),
          "ImageUrl": imageCtrl.text.trim(),
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ürünü Güncelle")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Ürün Adı"),
                validator: (v) => v!.isEmpty ? "Zorunlu" : null,
              ),
              TextFormField(
                controller: barcodeCtrl,
                decoration: const InputDecoration(labelText: "Barkod"),
                validator: (v) => v!.isEmpty ? "Zorunlu" : null,
              ),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Açıklama"),
              ),
              TextFormField(
                controller: icerikCtrl,
                decoration: const InputDecoration(labelText: "İçindekiler"),
                maxLines: 3,
              ),
              TextFormField(
                controller: alerjenCtrl,
                decoration: const InputDecoration(labelText: "Alerjen Uyarısı"),
              ),
              TextFormField(
                controller: imageCtrl,
                decoration: const InputDecoration(labelText: "Resim URL"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: update, child: const Text("Güncelle")),
            ],
          ),
        ),
      ),
    );
  }
}
