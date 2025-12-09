import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F1A),
      appBar: AppBar(
        title: const Text("Hakkımızda"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bu uygulama, barkod tarama teknolojisini kullanarak yiyecek ve içecek ürünlerinin içerik bilgilerini hızlı ve kolay bir şekilde öğrenmenizi sağlar.",
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Özellikler:"),
            _buildListItem("• Barkod ile ürün bilgisi sorgulama"),
            _buildListItem("• Favori ürün listesi oluşturma"),
            _buildListItem("• Geçmiş tarama kayıtlarını görüntüleme"),
            _buildListItem("• Modern ve kullanıcı dostu arayüz"),
            const SizedBox(height: 20),
            _buildSectionTitle("Misyonumuz"),
            const Text(
              "Kullanıcılarımıza sağlıklı ve bilinçli alışveriş yapabilmeleri için doğru ürün bilgilerini sunmak.",
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFB0C4DE),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 10),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
