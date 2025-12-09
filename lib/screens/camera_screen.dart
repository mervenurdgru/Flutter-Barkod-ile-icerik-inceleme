import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barkodu Tara'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (!_isScanning) return;

          final List<Barcode> barcodes = capture.barcodes;

          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              final String code = barcode.rawValue!;

              setState(() {
                _isScanning = false;
              });
              _showResultDialog(code);
              break;
            }
          }
        },
      ),
    );
  }

  void _showResultDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false, // Boşluğa basınca kapanmasın
      builder: (context) => AlertDialog(
        title: const Text("Barkod Bulundu!"),
        content: Text(
          "Okunan Kod: $code\n\nBu ürünün detaylarını getirelim mi?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              // İptal derse tekrar taramaya başla
              Navigator.pop(context);
              setState(() {
                _isScanning = true;
              });
            },
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Diyaloğu kapat
              // İLERİDE BURADA DETAY SAYFASINA GİDECEĞİZ
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ürün detaylarına gidiliyor...")),
              );
              // Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(barcode: code)));
            },
            child: const Text("İncele"),
          ),
        ],
      ),
    );
  }
}
