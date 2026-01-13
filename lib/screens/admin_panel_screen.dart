import 'package:flutter/material.dart';
import '../api/auth_service.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/admin_login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/admin_add');
            },
            child: const Text('Ürün Ekle'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/admin_products');
            },
            child: const Text('Ürünleri Gör'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/admin_comments');
            },
            child: const Text('Yorumları Gör'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/admin_reports');
            },
            child: const Text('Raporları Gör'),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => _logout(context),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}
