import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'product_detail_screen.dart';
import 'favorites_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';
import '../api/auth_service.dart';
import 'about_screen.dart';
import 'contact_screen.dart';
import 'share_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _barcodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F1A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      drawer: Drawer(
        backgroundColor: const Color(0xFF1C1F2E),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF0E0F1A)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 50,
                    color: Color(0xFFB0C4DE),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Menü",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFFB0C4DE)),
              title: const Text(
                'Ana Sayfa',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context),
            ),

            ListTile(
              leading: const Icon(Icons.favorite, color: Color(0xFFB0C4DE)),
              title: const Text(
                'Favorilerim',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.history, color: Color(0xFFB0C4DE)),
              title: const Text(
                'Geçmiş',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),

            const Divider(color: Colors.grey),

            ListTile(
              leading: const Icon(Icons.info_outline, color: Color(0xFFB0C4DE)),
              title: const Text(
                'Hakkımızda',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.headset_mic, color: Color(0xFFB0C4DE)),
              title: const Text(
                'Bize Ulaşın',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactScreen(),
                  ),
                );
              },
            ),

            // Paylaş
            ListTile(
              leading: const Icon(Icons.share, color: Color(0xFFB0C4DE)),
              title: const Text(
                'Paylaş',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShareScreen()),
                );
              },
            ),

            const Divider(color: Colors.grey),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Çıkış Yap',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () async {
                await AuthService().logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Barkod ile Ürün İnceleme",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFB0C4DE),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                const Text(
                  "Kamerayı açarak veya numara girerek ürünleri tarayın",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CameraScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text(
                      "Kamerayı Aç",
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB0C4DE),
                      foregroundColor: const Color(0xFF0E0F1A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: 250,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => _showManualEntryDialog(context),
                    icon: const Icon(Icons.keyboard),
                    label: const Text(
                      "Barkod Numarası Gir",
                      style: TextStyle(fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB0C4DE),
                      side: const BorderSide(
                        color: Color(0xFFB0C4DE),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showManualEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Barkod Numarası",
          style: TextStyle(color: Colors.black),
        ),
        content: TextField(
          controller: _barcodeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Örn: 869...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_barcodeController.text.isNotEmpty) {
                String barcodeInput = _barcodeController.text.trim();
                Navigator.pop(context);
                _barcodeController.clear();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductDetailScreen(barcode: barcodeInput),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF075EEC),
            ),
            child: const Text("Sorgula", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
